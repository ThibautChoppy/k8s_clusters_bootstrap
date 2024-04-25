# Read system health check
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# Create and manage ACL policies broadly across Vault

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable and manage authentication methods broadly across Vault

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# Create, update, and delete totp methods
path "totp/*"
{
  capabilities = ["list", "create", "update", "delete", "sudo"]
}

# List totp method
path "totp"
{
  capabilities = ["read"]
}

# List identity
path "identity/*" 
{
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "identity" 
{
    capabilities = ["read"]
}

# Enable and manage the key/value secrets engine at `secret/` path

# List, create, update, and delete key/value secrets

path "infra/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "infra"
{
  capabilities = ["read"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

# Manage database engines
path "database/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing database engines.
path "database"
{
  capabilities = ["read"]
}