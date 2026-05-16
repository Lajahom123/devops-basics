# Log diagnostics for the web app
data "azurerm_monitor_diagnostic_categories" "web_app" {
  resource_id = azurerm_linux_web_app.main.id
}

resource "azurerm_monitor_diagnostic_setting" "web_app" {
  name                       = "diag-${azurerm_linux_web_app.main.name}"
  target_resource_id         = azurerm_linux_web_app.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.web_app.log_category_types)

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.web_app.metrics)

    content {
      category = metric.value
      enabled  = true
    }
  }
}

# Log diagnostics for the container app environment
data "azurerm_monitor_diagnostic_categories" "container_app_environment" {
  resource_id = azurerm_container_app_environment.main.id
}

resource "azurerm_monitor_diagnostic_setting" "container_app_environment" {
  name                       = "diag-${azurerm_container_app_environment.main.name}"
  target_resource_id         = azurerm_container_app_environment.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.container_app_environment.log_category_types)

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.container_app_environment.metrics)

    content {
      category = metric.value
      enabled  = true
    }
  }
}