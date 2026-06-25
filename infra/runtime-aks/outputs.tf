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

output "aks_cluster_id" {
  description = "AKS cluster resource ID."
  value       = module.aks.cluster_id
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = module.aks.cluster_name
}

output "aks_kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet managed identity."
  value       = module.aks.kubelet_identity_object_id
}

output "aks_kubelet_identity_client_id" {
  description = "Client ID of the AKS kubelet managed identity."
  value       = module.aks.kubelet_identity_client_id
}

output "aks_node_resource_group" {
  description = "AKS managed node resource group."
  value       = module.aks.node_resource_group
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL."
  value       = module.aks.oidc_issuer_url
}
