resource "azurerm_container_app_job" "migration" {
  name                         = "job-${local.name_prefix}-migrations"
  resource_group_name          = data.terraform_remote_state.foundation.outputs.resource_group_name
  location                     = var.location
  container_app_environment_id = azurerm_container_app_environment.main.id

  replica_timeout_in_seconds = 600
  replica_retry_limit        = 1

  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }

  workload_profile_name = "Consumption"

  identity {
    type = "UserAssigned"

    identity_ids = [
      data.terraform_remote_state.foundation.outputs.migration_job_identity_id
    ]
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = data.terraform_remote_state.foundation.outputs.migration_job_identity_id
  }

  secret {
    name  = "postgres-admin-password"
    value = var.postgres_admin_password
  }

  template {
    container {
      name   = "flyway"
      image  = "${azurerm_container_registry.main.login_server}/devops-tracker-migrations:bootstrap"
      cpu    = 0.5
      memory = "1Gi"

      command = ["flyway"]

      args = [
        "-url=jdbc:postgresql://${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.main.name}",
        "-user=${var.postgres_admin_username}",
        "-password=$(POSTGRES_ADMIN_PASSWORD)",
        "migrate"
      ]

      env {
        name        = "POSTGRES_ADMIN_PASSWORD"
        secret_name = "postgres-admin-password"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image
    ]
  }

  tags = local.common_tags
}

resource "azurerm_role_assignment" "migration_job_github_actions_deploy_rg_contributor" {
  scope                = azurerm_container_app_job.migration.id
  role_definition_name = "Contributor"
  principal_id         = data.terraform_remote_state.foundation.outputs.github_actions_deploy_principal_id
}
