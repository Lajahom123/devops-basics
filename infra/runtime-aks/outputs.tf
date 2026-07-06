output "resource_group_name" {
  description = "Runtime resource group name."
  value       = local.resource_group_name
}

output "platform_resource_group_name" {
  description = "Platform platform resource group name."
  value       = local.platform_resource_group_name
}

output "azure_tenant_id" {
  description = "Microsoft Entra tenant ID."
  value       = local.azure_tenant_id
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

output "postgres_bootstrap_identity_name" {
  description = "PostgreSQL bootstrap managed identity name."
  value       = local.postgres_bootstrap_identity.name
}

output "postgres_bootstrap_identity_client_id" {
  description = "PostgreSQL bootstrap managed identity client ID for the bootstrap Job ServiceAccount."
  value       = local.postgres_bootstrap_identity.client_id
}

output "postgres_bootstrap_identity_principal_id" {
  description = "PostgreSQL bootstrap managed identity principal ID."
  value       = local.postgres_bootstrap_identity.principal_id
}

output "postgres_entra_admin_group_object_id" {
  description = "Object ID of the devops-tracker-postgres-admins Entra group."
  value       = local.postgres_entra_admin_group.object_id
}

output "postgres_entra_admin_group_name" {
  description = "Display name of the devops-tracker-postgres-admins Entra group."
  value       = local.postgres_entra_admin_group.name
}

output "aks_cluster_id" {
  description = "AKS cluster resource ID."
  value       = local.aks_cluster_id
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

output "migration_job_identity_name" {
  description = "Database migration managed identity name for Flyway Job Workload Identity."
  value       = local.migration_job_identity.name
}

output "migration_job_identity_client_id" {
  description = "Database migration managed identity client ID for the Flyway Job ServiceAccount."
  value       = local.migration_job_identity.client_id
}

output "migration_job_identity_principal_id" {
  description = "Database migration managed identity principal ID."
  value       = local.migration_job_identity.principal_id
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL."
  value       = local.aks_oidc_issuer_url
}
