locals {
  name_prefix = var.project_name
  key_vault_name = var.key_vault_name != null ? var.key_vault_name : substr(
    replace(lower("kv-devops-tracker-swn"), "/[^a-z0-9-]/", ""),
    0,
    24
  )
  database_url = "postgres://${var.postgres_admin_username}:${random_password.postgres_admin.result}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.main.name}?sslmode=require"

  app_settings = {
    DATABASE_SSL                        = "true"
    DATABASE_SSL_REJECT_UNAUTHORIZED    = "true"
    DATABASE_URL                        = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_url.id})"
    NODE_ENV                            = var.environment
    PORT                                = var.container_port
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = var.container_port
  }
}

resource "azurerm_key_vault" "main" {
  name                = local.key_vault_name
  resource_group_name = data.azurerm_resource_group.foundation.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                      = "standard"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  enable_rbac_authorization     = true
  public_network_access_enabled = true
}

resource "azurerm_key_vault_secret" "database_url" {
  name         = "database-url"
  value        = local.database_url
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.current_user_key_vault_secrets_officer
  ]
}

resource "azurerm_role_assignment" "current_user_key_vault_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "web_app_key_vault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_user_assigned_identity.web_app.principal_id
}
