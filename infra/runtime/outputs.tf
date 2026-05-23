output "resource_group_name" {
  value = data.terraform_remote_state.foundation.outputs.resource_group_name
}

output "front_door_profile_name" {
  value = azurerm_cdn_frontdoor_profile.main.name
}

output "front_door_endpoint_name" {
  value = azurerm_cdn_frontdoor_endpoint.main.name
}

output "front_door_host_name" {
  value = azurerm_cdn_frontdoor_endpoint.main.host_name
}

output "front_door_url" {
  value = "https://${azurerm_cdn_frontdoor_endpoint.main.host_name}"
}

output "app_service_plan_name" {
  value = azurerm_service_plan.main.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.main.name
}

output "web_app_default_hostname" {
  value = azurerm_linux_web_app.main.default_hostname
}

output "web_app_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "staging_slot_name" {
  value = azurerm_linux_web_app_slot.staging.name
}

output "staging_slot_default_hostname" {
  value = azurerm_linux_web_app_slot.staging.default_hostname
}

output "staging_slot_url" {
  value = "https://${azurerm_linux_web_app_slot.staging.default_hostname}"
}

output "acr_name" {
  value = azurerm_container_registry.main.name
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.main.name
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.main.name
}

output "application_insights_name" {
  value = azurerm_application_insights.main.name
}

output "application_insights_connection_string" {
  value     = azurerm_application_insights.main.connection_string
  sensitive = true
}