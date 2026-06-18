output "acr_id" {
  description = "Azure Container Registry ID."
  value       = azurerm_container_registry.main.id
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "Azure Container Registry login server."
  value       = azurerm_container_registry.main.login_server
}
