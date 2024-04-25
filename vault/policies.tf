# Create production policy
resource "vault_policy" "production" {
  name   = "production"
  policy = file("policies/production.hcl")
}

# Create 'admin' policy
resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("policies/admin.hcl")
}