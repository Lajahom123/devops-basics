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

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by logical name."
  value       = module.private_dns.zone_ids
}

output "private_dns_zone_names" {
  description = "Private DNS zone names keyed by logical name."
  value       = module.private_dns.zone_names
}

output "private_dns_virtual_network_link_ids" {
  description = "Private DNS zone virtual network link IDs keyed by logical name."
  value       = module.private_dns.virtual_network_link_ids
}

output "postgres_private_dns_zone_id" {
  description = "PostgreSQL private DNS zone ID."
  value       = module.private_dns.zone_ids.postgres
}

output "key_vault_private_dns_zone_id" {
  description = "Key Vault private DNS zone ID."
  value       = module.private_dns.zone_ids.key_vault
}

output "ingress_public_ip_id" {
  description = "Public IP ID for ingress."
  value       = module.network.ingress_public_ip_id
}

output "ingress_public_ip_name" {
  description = "Public IP name for ingress."
  value       = module.network.ingress_public_ip_name
}

output "ingress_public_ip_address" {
  description = "Public IP address for ingress."
  value       = module.network.ingress_public_ip_address
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID."
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name."
  value       = module.monitoring.log_analytics_workspace_name
}

output "application_insights_id" {
  description = "Application Insights ID."
  value       = module.monitoring.application_insights_id
}

output "application_insights_name" {
  description = "Application Insights name."
  value       = module.monitoring.application_insights_name
}

output "application_insights_connection_string" {
  description = "Application Insights connection string."
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
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

output "managed_identities" {
  description = "Managed identity details keyed by logical name."
  value       = module.managed_identities.identities
}

output "aks_identity_id" {
  description = "AKS control plane user-assigned identity resource ID."
  value       = module.managed_identities.identities.aks_control_plane.id
}

output "aks_identity_principal_id" {
  description = "AKS control plane user-assigned identity principal ID."
  value       = module.managed_identities.identities.aks_control_plane.principal_id
}

output "aks_identity_client_id" {
  description = "AKS control plane user-assigned identity client ID."
  value       = module.managed_identities.identities.aks_control_plane.client_id
}

output "github_actions_deploy_identity_name" {
  description = "GitHub Actions deploy identity name."
  value       = module.managed_identities.identities.github_actions_deploy.name
}

output "github_actions_deploy_identity_id" {
  description = "GitHub Actions deploy identity resource ID."
  value       = module.managed_identities.identities.github_actions_deploy.id
}

output "github_actions_deploy_client_id" {
  description = "GitHub Actions deploy identity client ID."
  value       = module.managed_identities.identities.github_actions_deploy.client_id
}

output "github_actions_deploy_principal_id" {
  description = "GitHub Actions deploy identity principal ID."
  value       = module.managed_identities.identities.github_actions_deploy.principal_id
}

output "aks_workload_identity_name" {
  description = "AKS workload identity base identity name."
  value       = module.managed_identities.identities.aks_workload.name
}

output "aks_workload_identity_id" {
  description = "AKS workload identity base identity resource ID."
  value       = module.managed_identities.identities.aks_workload.id
}

output "aks_workload_identity_client_id" {
  description = "AKS workload identity base identity client ID."
  value       = module.managed_identities.identities.aks_workload.client_id
}

output "aks_workload_identity_principal_id" {
  description = "AKS workload identity base identity principal ID."
  value       = module.managed_identities.identities.aks_workload.principal_id
}

output "migration_job_identity_name" {
  description = "Migration job identity name."
  value       = module.managed_identities.identities.migration_job.name
}

output "migration_job_identity_id" {
  description = "Migration job identity resource ID."
  value       = module.managed_identities.identities.migration_job.id
}

output "migration_job_identity_client_id" {
  description = "Migration job identity client ID."
  value       = module.managed_identities.identities.migration_job.client_id
}

output "migration_job_identity_principal_id" {
  description = "Migration job identity principal ID."
  value       = module.managed_identities.identities.migration_job.principal_id
}

output "github_runner_identity_name" {
  description = "GitHub private runner identity name."
  value       = module.managed_identities.identities.github_runner.name
}

output "github_runner_identity_id" {
  description = "GitHub private runner identity resource ID."
  value       = module.managed_identities.identities.github_runner.id
}

output "github_runner_identity_client_id" {
  description = "GitHub private runner identity client ID."
  value       = module.managed_identities.identities.github_runner.client_id
}

output "github_runner_identity_principal_id" {
  description = "GitHub private runner identity principal ID."
  value       = module.managed_identities.identities.github_runner.principal_id
}

output "private_runner_identity_name" {
  description = "Private runner identity name."
  value       = module.managed_identities.identities.private_runner.name
}

output "private_runner_identity_id" {
  description = "Private runner identity resource ID."
  value       = module.managed_identities.identities.private_runner.id
}

output "private_runner_identity_client_id" {
  description = "Private runner identity client ID."
  value       = module.managed_identities.identities.private_runner.client_id
}

output "private_runner_identity_principal_id" {
  description = "Private runner identity principal ID."
  value       = module.managed_identities.identities.private_runner.principal_id
}

output "key_vault_id" {
  description = "Key Vault ID."
  value       = module.key_vault.key_vault_id
}

output "key_vault_name" {
  description = "Key Vault name."
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = module.key_vault.vault_uri
}

output "github_oidc_federated_credential_id" {
  description = "GitHub deploy federated identity credential ID."
  value       = module.github_oidc.federated_credential_id
}

output "github_oidc_federated_credential_name" {
  description = "GitHub deploy federated identity credential name."
  value       = module.github_oidc.federated_credential_name
}

output "github_oidc_subject" {
  description = "GitHub OIDC subject allowed to federate as the deploy identity."
  value       = module.github_oidc.subject
}

output "azure_subscription_id" {
  description = "Azure subscription ID for downstream roots."
  value       = data.azurerm_client_config.current.subscription_id
}

output "azure_tenant_id" {
  description = "Azure tenant ID for downstream roots."
  value       = data.azurerm_client_config.current.tenant_id
}
