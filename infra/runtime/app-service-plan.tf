resource "azurerm_service_plan" "main" {
  name                = "plan-${local.name_prefix}"
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  location            = var.location
  tags                = local.common_tags

  os_type  = "Linux"
  sku_name = var.app_service_sku
}

resource "azurerm_monitor_autoscale_setting" "app_service_plan" {
  name                = "autoscale-${azurerm_service_plan.main.name}"
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.main.id
  enabled             = true

  profile {
    name = "default"

    capacity {
      default = 1
      minimum = 1
      maximum = 2
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT20M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT15M"
      }
    }
  }

  tags = local.common_tags
}