locals {
  platform = data.terraform_remote_state.platform.outputs

  project     = "devops-tracker"
  environment = "dev"

  platform_resource_group_name = local.platform.resource_group_name
  resource_group_name          = "rg-${local.project}-${local.environment}-runtime"
  location                     = local.platform.location
  azure_tenant_id              = local.platform.azure_tenant_id

  vnet_id            = local.platform.vnet_id
  subnet_ids         = local.platform.subnet_ids
  aks_subnet_id      = local.platform.aks_subnet_id
  postgres_subnet_id = local.platform.postgres_subnet_id

  acr_id           = local.platform.acr_id
  acr_name         = local.platform.acr_name
  acr_name_suffix  = replace(local.acr_name, "devopstrackerdev", "")
  acr_login_server = local.platform.acr_login_server

  key_vault_id   = local.platform.key_vault_id
  key_vault_name = local.platform.key_vault_name

  log_analytics_workspace_id = local.platform.log_analytics_workspace_id

  aks_identity = {
    id           = local.platform.aks_identity_id
    principal_id = local.platform.aks_identity_principal_id
  }

  github_actions_deploy_identity = {
    name         = local.platform.github_actions_deploy_identity_name
    id           = local.platform.github_actions_deploy_identity_id
    client_id    = local.platform.github_actions_deploy_client_id
    principal_id = local.platform.github_actions_deploy_principal_id
  }

  aks_workload_identity = {
    name         = local.platform.aks_workload_identity_name
    id           = local.platform.aks_workload_identity_id
    client_id    = local.platform.aks_workload_identity_client_id
    principal_id = local.platform.aks_workload_identity_principal_id
  }

  migration_job_identity = {
    name         = local.platform.migration_job_identity_name
    id           = local.platform.migration_job_identity_id
    client_id    = local.platform.migration_job_identity_client_id
    principal_id = local.platform.migration_job_identity_principal_id
  }

  github_runner_identity = {
    name         = local.platform.github_runner_identity_name
    id           = local.platform.github_runner_identity_id
    client_id    = local.platform.github_runner_identity_client_id
    principal_id = local.platform.github_runner_identity_principal_id
  }

  private_runner_identity = {
    name         = local.platform.private_runner_identity_name
    id           = local.platform.private_runner_identity_id
    client_id    = local.platform.private_runner_identity_client_id
    principal_id = local.platform.private_runner_identity_principal_id
  }

  postgres_bootstrap_identity = {
    name         = local.platform.postgres_bootstrap_identity_name
    id           = local.platform.postgres_bootstrap_identity_id
    client_id    = local.platform.postgres_bootstrap_identity_client_id
    principal_id = local.platform.postgres_bootstrap_identity_principal_id
  }

  postgres_entra_admin_group = {
    object_id = local.platform.postgres_entra_admin_group_object_id
    name      = local.platform.postgres_entra_admin_group_name
  }

  aks_cluster_id      = module.aks.cluster_id
  aks_oidc_issuer_url = module.aks.oidc_issuer_url

  aks_cluster_name     = coalesce(var.aks_cluster_name, "aks-${local.project}-${local.environment}-${local.acr_name_suffix}-swn")
  aks_dns_prefix       = coalesce(var.aks_dns_prefix, "aks-${local.project}-${local.environment}-${local.acr_name_suffix}")
  postgres_server_name = coalesce(var.postgres_server_name, "psql-devops-tracker-${local.acr_name_suffix}-swn")
  postgres_app_entra_principal_name = coalesce(
    var.postgres_app_entra_principal_name,
    local.aks_workload_identity.name
  )

  tags = {
    project     = local.project
    environment = local.environment
    layer       = "runtime"
  }
}
