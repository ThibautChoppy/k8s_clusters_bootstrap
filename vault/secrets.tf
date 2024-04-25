# Enable K/V v2 secrets engine at 'infra'

resource "vault_mount" "infra" {
    path = "infra"
    type = "kv-v2"
}

resource "vault_kv_secret_v2" "grafana" {
    mount                 = vault_mount.infra.path
    name                  = "grafana"
    cas                   = 1
    delete_all_versions   = true
    data_json             = jsonencode({
        admin_user              = "admin",
        admin_password          = "defaultAdminPass",
        psql_admin_password     = "psqlDefaultAdminPass",
        psql_password           = "psqlDefaultPass",
        psql_postgres_password  = "psqlDefaultPostgresPass",
        psql_repmgr_password    = "psqlDefaultRepmgrPass"
        oidc_client_id          = "aaaaaaaaaaaaaaaaaaaa"
        oidc_client_secret      = "1234567891234567891234567891234567891234"
    })
}