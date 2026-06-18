output "resource_group_name" {
  description = "Platform resource group name."
  value       = azurerm_resource_group.platform.name
}

output "location" {
  description = "Azure region used by the foundation."
  value       = azurerm_resource_group.platform.location
}

output "vnet_name" {
  description = "Foundation VNet name."
  value       = module.network.vnet_name
}

output "vnet_id" {
  description = "Foundation VNet ID."
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "Subnet IDs keyed by logical subnet name."
  value       = module.network.subnet_ids
}

output "postgres_subnet_id" {
  description = "Subnet ID reserved for PostgreSQL."
  value       = module.network.postgres_subnet_id
}

output "private_endpoints_subnet_id" {
  description = "Subnet ID reserved for private endpoints."
  value       = module.network.private_endpoints_subnet_id
}

output "aks_subnet_id" {
  description = "Subnet ID reserved for future AKS nodes."
  value       = module.network.aks_subnet_id
}

output "acr_id" {
  description = "Azure Container Registry ID."
  value       = module.acr.acr_id
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = module.acr.acr_name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = module.acr.login_server
}

output "azure_subscription_id" {
  description = "Azure subscription ID for downstream roots."
  value       = data.azurerm_client_config.current.subscription_id
}

output "azure_tenant_id" {
  description = "Azure tenant ID for downstream roots."
  value       = data.azurerm_client_config.current.tenant_id
}
