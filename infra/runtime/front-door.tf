resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "fd-${var.web_app_name}"
  resource_group_name = data.terraform_remote_state.platform.outputs.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"

  tags = local.common_tags
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "fde-${var.web_app_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  tags = local.common_tags
}

resource "azurerm_cdn_frontdoor_origin_group" "web_app_private" {
  name                     = "og-private-${var.web_app_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/health"
    request_type        = "GET"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "web_app_private" {
  name                          = "origin-private-${var.web_app_name}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web_app_private.id

  enabled                        = true
  host_name                      = "${var.web_app_name}.azurewebsites.net"
  origin_host_header             = "${var.web_app_name}.azurewebsites.net"
  http_port                      = 80
  https_port                     = 443
  certificate_name_check_enabled = true

  priority = 1
  weight   = 1000

  private_link {
    request_message        = "Allow Front Door private access to App Service"
    location               = var.location
    private_link_target_id = azurerm_linux_web_app.main.id
    target_type            = "sites"
  }
}

resource "azurerm_cdn_frontdoor_route" "web_app" {
  name                          = "route-${var.web_app_name}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.web_app_private.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.web_app_private.id]

  enabled = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  link_to_default_domain = true

  depends_on = [
    azurerm_cdn_frontdoor_origin.web_app_private
  ]
}

resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  name                = "waf${replace(var.web_app_name, "-", "")}"
  resource_group_name = data.terraform_remote_state.platform.outputs.resource_group_name
  sku_name            = azurerm_cdn_frontdoor_profile.main.sku_name

  enabled = true
  mode    = "Prevention"

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  tags = local.common_tags
}

resource "azurerm_cdn_frontdoor_security_policy" "main" {
  name                     = "sp-devops-tracker"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.main.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.main.id
        }

        patterns_to_match = ["/*"]
      }
    }
  }
}
