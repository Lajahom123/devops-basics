resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.foundation.name
  location            = var.location
  sku                 = "Basic"

  admin_enabled = false
  tags          = local.common_tags
}

resource "azurerm_role_assignment" "web_app_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_user_assigned_identity.web_app.principal_id
}

resource "azurerm_role_assignment" "github_actions_acr_push" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = var.github_actions_principal_id
}

resource "azurerm_role_assignment" "migration_job_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = data.terraform_remote_state.foundation.outputs.migration_job_identity_principal_id
}