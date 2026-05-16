resource "azurerm_monitor_action_group" "main" {
  name                = "ag-devops-tracker"
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  short_name          = "devops"

  email_receiver {
    name                    = "main"
    email_address           = var.owner_email
    use_common_alert_schema = true
  }

  tags = local.common_tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_requests" {
  name                = "alert-failed-requests"
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  location            = var.location

  evaluation_frequency = "P1D"
  window_duration      = "P1D"
  scopes               = [azurerm_log_analytics_workspace.main.id]

  severity = 2
  enabled  = true

  criteria {
    query = <<-QUERY
      AppRequests
      | where Success == false
      | summarize FailedRequests = count()
    QUERY

    time_aggregation_method = "Total"
    threshold               = 50
    operator                = "GreaterThan"
    metric_measure_column   = "FailedRequests"
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = local.common_tags
}