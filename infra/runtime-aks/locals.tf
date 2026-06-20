locals {
  foundation = data.terraform_remote_state.foundation.outputs

  project     = "devops-tracker"
  environment = "dev"

  platform_resource_group_name = local.foundation.resource_group_name
  resource_group_name          = "rg-${local.project}-${local.environment}-runtime"
  location                     = local.foundation.location

  vnet_id            = local.foundation.vnet_id
  subnet_ids         = local.foundation.subnet_ids
  aks_subnet_id      = local.foundation.aks_subnet_id
  postgres_subnet_id = local.foundation.postgres_subnet_id

  acr_id           = local.foundation.acr_id
  acr_name         = local.foundation.acr_name
  acr_login_server = local.foundation.acr_login_server

  key_vault_id   = local.foundation.key_vault_id
  key_vault_name = local.foundation.key_vault_name

  log_analytics_workspace_id = local.foundation.log_analytics_workspace_id

  managed_identities = local.foundation.managed_identities

  github_actions_deploy_identity = {
    name         = local.foundation.github_actions_deploy_identity_name
    resource_id  = local.foundation.github_actions_deploy_identity_id
    client_id    = local.foundation.github_actions_deploy_client_id
    principal_id = local.foundation.github_actions_deploy_principal_id
  }

  aks_workload_identity = {
    name         = local.foundation.aks_workload_identity_name
    resource_id  = local.foundation.aks_workload_identity_id
    client_id    = local.foundation.aks_workload_identity_client_id
    principal_id = local.foundation.aks_workload_identity_principal_id
  }

  migration_job_identity = {
    name         = local.foundation.migration_job_identity_name
    resource_id  = local.foundation.migration_job_identity_id
    client_id    = local.foundation.migration_job_identity_client_id
    principal_id = local.foundation.migration_job_identity_principal_id
  }

  github_runner_identity = {
    name         = local.foundation.github_runner_identity_name
    resource_id  = local.foundation.github_runner_identity_id
    client_id    = local.foundation.github_runner_identity_client_id
    principal_id = local.foundation.github_runner_identity_principal_id
  }

  private_runner_identity = {
    name         = local.foundation.private_runner_identity_name
    resource_id  = local.foundation.private_runner_identity_id
    client_id    = local.foundation.private_runner_identity_client_id
    principal_id = local.foundation.private_runner_identity_principal_id
  }

  postgres_name_suffix = replace(local.acr_name, "devopstrackerdev", "")
  postgres_server_name = coalesce(var.postgres_server_name, "psql-devops-tracker-${local.postgres_name_suffix}-swn")
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
