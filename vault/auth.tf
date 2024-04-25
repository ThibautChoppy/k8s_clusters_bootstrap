resource "vault_auth_backend" "userpass" {
  type    = "userpass"
  tune  { 
    listing_visibility  = "unauth"
  }
}

# Create a user, 'admin'
resource "vault_generic_endpoint" "admin" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/admin"
  ignore_absent_fields = true

  data_json = jsonencode({
    "policies": ["admin"],
    "password": var.user_admin_passwd
  })
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  description = "local cluster login"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.SA_ADDR
  kubernetes_ca_cert     = file("ca.crt")
  token_reviewer_jwt     = var.SA_TOKEN
  issuer                 = "https://kubernetes.default.svc.cluster.local"
  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "production-app" {
  backend                           = vault_auth_backend.kubernetes.path
  depends_on                        = [vault_auth_backend.kubernetes]
  role_name                         = "production-app"
  bound_service_account_names       = ["*"]
  bound_service_account_namespaces  = ["*"]
  token_ttl                         = 3600
  token_policies                    = ["default", "production"]
}
