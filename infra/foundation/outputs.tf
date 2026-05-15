output "resource_group_name" {
  value = data.azurerm_resource_group.main.name
}

output "location" {
  value = data.azurerm_resource_group.main.location
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "app_service_subnet_name" {
  value = azurerm_subnet.app_service.name
}

output "app_service_subnet_id" {
  value = azurerm_subnet.app_service.id
}

output "postgres_subnet_name" {
  value = azurerm_subnet.postgres.name
}

output "postgres_subnet_id" {
  value = azurerm_subnet.postgres.id
}

output "admin_subnet_name" {
  value = azurerm_subnet.admin.name
}

output "admin_subnet_id" {
  value = azurerm_subnet.admin.id
}

output "container_apps_subnet_name" {
  value = azurerm_subnet.container_apps.name
}

output "container_apps_subnet_id" {
  value = azurerm_subnet.container_apps.id
}

output "postgres_private_dns_zone_name" {
  value = azurerm_private_dns_zone.postgres.name
}

output "postgres_private_dns_zone_id" {
  value = azurerm_private_dns_zone.postgres.id
}

output "web_app_identity_name" {
  value = azurerm_user_assigned_identity.web_app.name
}

output "web_app_identity_id" {
  value = azurerm_user_assigned_identity.web_app.id
}

output "web_app_identity_client_id" {
  value = azurerm_user_assigned_identity.web_app.client_id
}

output "web_app_identity_principal_id" {
  value = azurerm_user_assigned_identity.web_app.principal_id
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

output "github_actions_principal_id" {
  value = azuread_service_principal.github_actions.object_id
}

output "migration_job_identity_id" {
  value = azurerm_user_assigned_identity.migration_job.id
}

output "migration_job_identity_client_id" {
  value = azurerm_user_assigned_identity.migration_job.client_id
}

output "migration_job_identity_principal_id" {
  value = azurerm_user_assigned_identity.migration_job.principal_id
}