output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.main.name
}

output "web_app_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "acr_name" {
  value = azurerm_container_registry.main.name
}

output "azure_client_id" {
  value = azuread_application.github_actions.client_id
}

output "azure_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "azure_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}