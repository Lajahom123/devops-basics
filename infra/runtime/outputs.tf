output "resource_group_name" {
  value = data.terraform_remote_state.foundation.outputs.resource_group_name
}

output "acr_name" {
  value = azurerm_container_registry.main.name
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "web_app_name" {
  value = azurerm_linux_web_app.main.name
}

output "web_app_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "app_service_plan_name" {
  value = azurerm_service_plan.main.name
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}

output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.main.name
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}
