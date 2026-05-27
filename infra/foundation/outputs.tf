output "resource_group_name" {
  value = data.azurerm_resource_group.main.name
}

output "location" {
  value = data.azurerm_resource_group.main.location
}

# Network 

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

output "private_endpoints_subnet_name" {
  value = azurerm_subnet.private_endpoints.name
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "github_runner_subnet_name" {
  value = azurerm_subnet.github_runner.name
}

output "github_runner_subnet_id" {
  value = azurerm_subnet.github_runner.id
}

# DNS

output "postgres_private_dns_zone_name" {
  value = azurerm_private_dns_zone.postgres.name
}

output "postgres_private_dns_zone_id" {
  value = azurerm_private_dns_zone.postgres.id
}

output "webapp_private_dns_zone_name" {
  value = azurerm_private_dns_zone.web_app.name
}

output "webapp_private_dns_zone_id" {
  value = azurerm_private_dns_zone.web_app.id
}

# Web app

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

# Azure IDs

output "azure_deploy_client_id" {
  value = azuread_application.github_actions_deploy.client_id
}

output "azure_dev_operator_client_id" {
  value = azuread_application.github_actions_dev_operator.client_id
}

output "azure_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "azure_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

# Github actions

output "github_actions_deploy_principal_id" {
  value = azuread_service_principal.github_actions_deploy.object_id
}

# Github runner

output "github_runner_identity_id" {
  value = azurerm_user_assigned_identity.github_runner.id
}

output "github_runner_identity_client_id" {
  value = azurerm_user_assigned_identity.github_runner.client_id
}

output "github_runner_identity_principal_id" {
  value = azurerm_user_assigned_identity.github_runner.principal_id
}

# Migration job

output "migration_job_identity_id" {
  value = azurerm_user_assigned_identity.migration_job.id
}

output "migration_job_identity_client_id" {
  value = azurerm_user_assigned_identity.migration_job.client_id
}

output "migration_job_identity_principal_id" {
  value = azurerm_user_assigned_identity.migration_job.principal_id
}