output "resource_group_name" {
  description = "Runtime resource group name."
  value       = azurerm_resource_group.runtime.name
}

output "platform_resource_group_name" {
  description = "Foundation platform resource group name."
  value       = local.platform_resource_group_name
}

output "postgres_server_id" {
  description = "PostgreSQL Flexible Server resource ID."
  value       = module.postgres.server_id
}

output "postgres_server_name" {
  description = "PostgreSQL Flexible Server name."
  value       = module.postgres.server_name
}

output "postgres_server_fqdn" {
  description = "PostgreSQL Flexible Server fully qualified domain name."
  value       = module.postgres.server_fqdn
}

output "postgres_database_name" {
  description = "Application database name."
  value       = module.postgres.database_name
}

output "postgres_app_entra_principal_name" {
  description = "Microsoft Entra principal name to create in PostgreSQL with pgaadauth_create_principal."
  value       = local.postgres_app_entra_principal_name
}
