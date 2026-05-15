resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${local.name_prefix}"
  resource_group_name        = data.azurerm_resource_group.main.name
  location                   = var.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  infrastructure_subnet_id = data.terraform_remote_state.foundation.outputs.container_apps_subnet_id

  tags = local.common_tags
}
