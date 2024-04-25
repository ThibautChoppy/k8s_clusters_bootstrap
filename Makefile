.ONESHELL:
SHELL := /bin/sh
DIR := $(notdir ${CURDIR})

## Common ##

TEXT		:=
BOXNAME		:=
COLOR 		:= 7

# 0 = gris
# 1 = rouge
# 2 = vert
# 3 = jaune
# 4 = bleu
# 5 = violet
# 6 = bleu ciel
# 7 = blanc

.PHONY: .show-text
.show-text: BOXSCRIPT := .github/printBoxScript.sh
.show-text:
	@$(BOXSCRIPT) "${BOXNAME}" "${TEXT}" "${COLOR}"

.PHONY: .ask-confirmation
.ask-confirmation:
	@$(MAKE) -s .show-text TEXT="${TEXT} [y/N]" && read ans && [ $${ans:-N} = y ] || exit 1

### Cluster ###

.PHONY: set-kubeconfig
set-kubeconfig: ENV := cluster-0
set-kubeconfig:
	@mkdir -p ~/.kube
	@if ! ( ls ~/.kube | grep "${ENV}" > /dev/null ); then\
		$(MAKE) -s .show-text TEXT="No corresponding kubeconfig found! Check of ~/.kube/config-${ENV}" BOXNAME="Kubeconfig Error" COLOR="1";\
	else\
		cp ~/.kube/$$(ls ~/.kube | grep ${ENV}) ~/.kube/config;\
	fi

.PHONY: k8s-vault-init
k8s-vault-init: ENV := cluster-0
k8s-vault-init: set-kubeconfig ## Initializing vault
	@kubectl exec -it vault-0 -n vault -- vault operator init > unseal.txt
	@grep -E 'Unseal Key|Initial Root Token' unseal.txt | \
		sed -e 's/^Unseal Key \(.*\): \(.*\)/UNSEAL_KEY_\1="\2"/' \
    		-e 's/^Initial Root Token: \(.*\)/ROOT_TOKEN="\1"/' > unseal-keys

include unseal-keys

.PHONY: k8s-vault-unseal
k8s-vault-unseal: ENV := cluster-0
k8s-vault-unseal: set-kubeconfig ## Unsealing vault
	@kubectl exec -it vault-0 -n vault -- vault operator unseal ${UNSEAL_KEY_1}
	@kubectl exec -it vault-0 -n vault -- vault operator unseal ${UNSEAL_KEY_2}
	@kubectl exec -it vault-0 -n vault -- vault operator unseal ${UNSEAL_KEY_3}
	@kubectl exec -it vault-1 -n vault -- vault operator unseal ${UNSEAL_KEY_1}
	@kubectl exec -it vault-1 -n vault -- vault operator unseal ${UNSEAL_KEY_2}
	@kubectl exec -it vault-1 -n vault -- vault operator unseal ${UNSEAL_KEY_3}

.PHONY: k8s-vault-sync
k8s-vault-sync: ENV := cluster-0
k8s-vault-sync: set-kubeconfig ## Vault configuration with terraform
	@cd vault && export VAULT_TOKEN=${VAULT_TOKEN} && export VAULT_ADDR=${VAULT_ADDR}
	@KUBERNETES_PORT_ADDR=$$(kubectl exec -it vault-0 -n vault -- printenv | grep KUBERNETES_PORT_443_TCP_ADDR | cut -d'=' -f2 | tr -d '\r')
	@export TF_VAR_SA_ADDR="https://$${KUBERNETES_PORT_ADDR}:443"
	@export TF_VAR_SA_TOKEN="$$(kubectl exec -it vault-0 -n vault -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
	@echo "$$(kubectl exec -it vault-0 -n vault -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt)" > ca.crt
	@terraform init
	@terraform apply
	@rm ca.crt

.DEFAULT_GOAL := show-help

# Inspired by https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html.
.PHONY: show-help
show-help:
	@echo "Help:"
	@echo
	@awk 'BEGIN {FS = ":.*?## "}; /^###/ { if (title) { printf "\n" }; printf "%s\n", $$1; title = $$1 }; /^[[:alnum:]_-]+:.*?##/ { printf "  %-30s%s\n", $$1, $$2 }' Makefile
	@echo
