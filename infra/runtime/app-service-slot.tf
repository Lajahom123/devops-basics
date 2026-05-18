resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main.id

  identity {
    type         = "UserAssigned"
    identity_ids = [data.terraform_remote_state.foundation.outputs.web_app_identity_id]
  }

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "${azurerm_container_registry.main.login_server}/devops-tracker:bootstrap"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = data.terraform_remote_state.foundation.outputs.web_app_identity_client_id
  }

  app_settings = azurerm_linux_web_app.main.app_settings
}