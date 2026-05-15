resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.name_prefix}"
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  location            = var.location

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = local.common_tags
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${local.name_prefix}"
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  location            = var.location

  workspace_id     = azurerm_log_analytics_workspace.main.id
  application_type = "web"

  tags = local.common_tags
}