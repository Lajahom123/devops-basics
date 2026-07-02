resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_application_insights_workbook" "aks_observability" {
  name                = "4fda7b17-4d7f-42d4-a9d2-f4030a635c64"
  resource_group_name = var.resource_group_name
  location            = var.location

  display_name = "${var.name_prefix}-aks-observability"

  source_id = lower(azurerm_log_analytics_workspace.main.id)

  data_json = file("${path.module}/workbooks/devops-tracker-aks-observability.workbook")

  tags = var.tags
}