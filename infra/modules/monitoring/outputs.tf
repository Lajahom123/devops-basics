output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID."
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name."
  value       = azurerm_log_analytics_workspace.main.name
}

output "application_insights_id" {
  description = "Application Insights ID, when created."
  value       = try(azurerm_application_insights.main[0].id, null)
}

output "application_insights_connection_string" {
  description = "Application Insights connection string, when created."
  value       = try(azurerm_application_insights.main[0].connection_string, null)
  sensitive   = true
}
