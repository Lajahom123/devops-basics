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

resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  short_name          = "devops"

  email_receiver {
    name                    = "main"
    email_address           = var.owner_email
    use_common_alert_schema = true
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_requests" {
  name                = "alert-${var.name_prefix}-failed-requests"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = var.alert_evaluation_frequency
  window_duration      = var.alert_window_duration

  scopes = [azurerm_application_insights.main.id]

  severity = 2
  enabled  = true

  criteria {
    query = <<-QUERY
      requests
      | where success == false
      | summarize FailedRequests = count()
    QUERY

    time_aggregation_method = "Total"
    metric_measure_column   = "FailedRequests"
    operator                = "GreaterThan"
    threshold               = 5
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = var.tags
}

# TODO(observability): Add synthetic availability probe alert when SLO-based monitoring is introduced.

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "high_request_latency" {
  count = var.enable_high_latency_alert ? 1 : 0

  name                = "alert-${var.name_prefix}-high-request-latency"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = var.alert_evaluation_frequency
  window_duration      = var.alert_window_duration

  scopes = [azurerm_application_insights.main.id]

  severity = 2
  enabled  = true

  criteria {
    query = <<-QUERY
      requests
      | where timestamp > ago(5m)
      | summarize AvgDurationMs = avg(duration)
    QUERY

    time_aggregation_method = "Average"
    metric_measure_column   = "AvgDurationMs"
    operator                = "GreaterThan"
    threshold               = var.high_latency_threshold_ms
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "pod_restarts" {
  count = var.enable_pod_restart_alert ? 1 : 0

  name                = "alert-${var.name_prefix}-pod-restarts"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = var.alert_evaluation_frequency
  window_duration      = var.alert_window_duration

  scopes = [azurerm_log_analytics_workspace.main.id]

  severity = 2
  enabled  = true

  criteria {
    query = <<-QUERY
      KubePodInventory
      | where TimeGenerated > ago(10m)
      | where Namespace == "${var.kubernetes_namespace}"
      | summarize Restarts = sum(ContainerRestartCount) by Name
      | summarize TotalRestarts = sum(Restarts)
    QUERY

    time_aggregation_method = "Total"
    metric_measure_column   = "TotalRestarts"
    operator                = "GreaterThan"
    threshold               = var.pod_restart_threshold
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_pods" {
  count = var.enable_failed_pod_alert ? 1 : 0

  name                = "alert-${var.name_prefix}-failed-pods"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = var.alert_evaluation_frequency
  window_duration      = var.alert_window_duration

  scopes = [azurerm_log_analytics_workspace.main.id]

  severity = 2
  enabled  = true

  criteria {
    query = <<-QUERY
      KubePodInventory
      | where TimeGenerated > ago(10m)
      | where Namespace == "${var.kubernetes_namespace}"
      | where PodStatus in ("Failed", "Unknown")
      | summarize FailedPods = count()
    QUERY

    time_aggregation_method = "Total"
    metric_measure_column   = "FailedPods"
    operator                = "GreaterThan"
    threshold               = 0
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = var.tags
}