resource "azurerm_service_plan" "main" {
  name                = "plan-${local.name_prefix}"
  resource_group_name = data.azurerm_resource_group.foundation.name
  location            = var.location

  os_type  = "Linux"
  sku_name = var.app_service_sku
}

resource "azurerm_linux_web_app" "main" {
  name                = var.web_app_name
  resource_group_name = data.azurerm_resource_group.foundation.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  https_only                      = true
  key_vault_reference_identity_id = data.azurerm_user_assigned_identity.web_app.id

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.web_app.id,
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
    container_registry_managed_identity_client_id = data.azurerm_user_assigned_identity.web_app.client_id

    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = local.app_settings

  depends_on = [
    azurerm_role_assignment.web_app_acr_pull,
    azurerm_role_assignment.web_app_key_vault_secrets_user,
  ]
}

resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = data.azurerm_subnet.app_service.id
}

resource "azurerm_role_assignment" "github_actions_web_app_contributor" {
  scope                = azurerm_linux_web_app.main.id
  role_definition_name = "Contributor"
  principal_id         = var.github_actions_principal_id
}
