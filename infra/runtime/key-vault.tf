locals {
  name_prefix = var.project_name
  key_vault_name = var.key_vault_name != null ? var.key_vault_name : substr(
    replace(lower("kv-devops-tracker-swn"), "/[^a-z0-9-]/", ""),
    0,
    24
  )
  common_tags = {
    Owner = var.owner_email
  }
}

resource "azurerm_key_vault" "main" {
  name                = local.key_vault_name
  resource_group_name = data.azurerm_resource_group.foundation.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.common_tags

  sku_name                      = "standard"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  enable_rbac_authorization     = true
  public_network_access_enabled = true
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
