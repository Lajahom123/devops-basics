resource "azurerm_user_assigned_identity" "web_app" {
  name                = "id-${local.name_prefix}-webapp"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location
  tags                = local.common_tags
}

resource "azurerm_user_assigned_identity" "migration_job" {
  name                = "id-${local.name_prefix}-migration-job"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location
  tags                = local.common_tags
}

resource "azurerm_user_assigned_identity" "github_runner" {
  name                = "id-${local.name_prefix}-github-runner"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags
}
/*
resource "azurerm_role_assignment" "github_runner_keyvault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.github_runner.principal_id
}
*/