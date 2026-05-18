locals {
  web_app_shared_settings = {
    DATABASE_SSL                     = "true"
    DATABASE_SSL_REJECT_UNAUTHORIZED = "true"

    AZURE_CLIENT_ID = data.terraform_remote_state.foundation.outputs.web_app_identity_client_id

    POSTGRES_HOST = azurerm_postgresql_flexible_server.main.fqdn
    POSTGRES_PORT = "5432"
    POSTGRES_DB   = "devops_tracker"
    POSTGRES_USER = "id-devops-tracker-webapp"

    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.main.connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY             = azurerm_application_insights.main.instrumentation_key
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"

    PORT                                = var.container_port
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = var.container_port
  }

  web_app_production_overrides = {
    NODE_ENV = var.environment
  }

  web_app_staging_overrides = {
    NODE_ENV = "staging"
  }

  web_app_production_settings = merge(
    local.web_app_shared_settings,
    local.web_app_production_overrides
  )

  web_app_staging_settings = merge(
    local.web_app_shared_settings,
    local.web_app_staging_overrides
  )
}

resource "azurerm_linux_web_app" "main" {
  name                      = var.web_app_name
  resource_group_name       = data.terraform_remote_state.foundation.outputs.resource_group_name
  location                  = var.location
  service_plan_id           = azurerm_service_plan.main.id
  virtual_network_subnet_id = data.terraform_remote_state.foundation.outputs.app_service_subnet_id
  tags                      = local.common_tags

  https_only                      = true
  key_vault_reference_identity_id = data.terraform_remote_state.foundation.outputs.web_app_identity_id

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      data.terraform_remote_state.foundation.outputs.web_app_identity_id,
    ]
  }

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].docker_image_name
    ]
  }

  site_config {
    always_on              = false
    health_check_path      = "/health"
    vnet_route_all_enabled = true

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = data.terraform_remote_state.foundation.outputs.web_app_identity_client_id

    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = local.web_app_production_settings

  sticky_settings {
    app_setting_names = [
      "NODE_ENV"
    ]
  }

  depends_on = [
    azurerm_role_assignment.web_app_acr_pull,
    azurerm_role_assignment.web_app_key_vault_secrets_user,
  ]
}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main.id

  https_only                      = true
  virtual_network_subnet_id       = data.terraform_remote_state.foundation.outputs.app_service_subnet_id
  key_vault_reference_identity_id = data.terraform_remote_state.foundation.outputs.web_app_identity_id

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      data.terraform_remote_state.foundation.outputs.web_app_identity_id,
    ]
  }

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].docker_image_name
    ]
  }

  site_config {
    always_on              = false
    health_check_path      = "/health"
    vnet_route_all_enabled = true

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = data.terraform_remote_state.foundation.outputs.web_app_identity_client_id

    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = local.web_app_staging_settings

  tags = local.common_tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = data.terraform_remote_state.foundation.outputs.app_service_subnet_id
}

resource "azurerm_role_assignment" "github_actions_web_app_contributor" {
  scope                = azurerm_linux_web_app.main.id
  role_definition_name = "Contributor"
  principal_id         = data.terraform_remote_state.foundation.outputs.github_actions_principal_id
}
