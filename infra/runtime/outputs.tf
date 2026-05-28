output "resource_group_name" {
  value = data.terraform_remote_state.foundation.outputs.resource_group_name
}

# Front door

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

# App service

output "app_service_plan_name" {
  value = azurerm_service_plan.main.name
}

# Web app 

output "web_app_name" {
  value = azurerm_linux_web_app.main.name
}

output "web_app_default_hostname" {
  value = azurerm_linux_web_app.main.default_hostname
}

output "web_app_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}

# Staging slot

output "staging_slot_name" {
  value = azurerm_linux_web_app_slot.staging.name
}

output "staging_slot_default_hostname" {
  value = azurerm_linux_web_app_slot.staging.default_hostname
}

output "staging_slot_url" {
  value = "https://${azurerm_linux_web_app_slot.staging.default_hostname}"
}

# Postgres

output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.main.name
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

# AKS

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_id" {
  description = "ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_node_resource_group" {
  description = "Automatically created AKS node resource group."
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}
