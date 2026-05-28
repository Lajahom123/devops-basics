resource "azurerm_private_endpoint" "web_app" {
  name                = "pe-${var.web_app_name}"
  location            = var.location
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  subnet_id           = data.terraform_remote_state.foundation.outputs.private_endpoints_subnet_id

  private_service_connection {
    name                           = "psc-${var.web_app_name}"
    private_connection_resource_id = azurerm_linux_web_app.main.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      data.terraform_remote_state.foundation.outputs.webapp_private_dns_zone_id
    ]
  }

  tags = local.common_tags
}

resource "azurerm_private_endpoint" "web_app_staging" {
  name                = "pe-${var.web_app_name}-staging"
  location            = var.location
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  subnet_id           = data.terraform_remote_state.foundation.outputs.private_endpoints_subnet_id

  private_service_connection {
    name                           = "psc-${var.web_app_name}-staging"
    private_connection_resource_id = azurerm_linux_web_app.main.id
    subresource_names              = ["sites-staging"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      data.terraform_remote_state.foundation.outputs.webapp_private_dns_zone_id
    ]
  }

  tags = local.common_tags
}