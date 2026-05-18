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