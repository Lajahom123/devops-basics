locals {
  resource_group_name = "rg-${var.project}-${var.environment}-platform"
  vnet_name           = "vnet-${var.project}-${var.environment}"

  unique_suffix = substr(md5("${data.azurerm_client_config.current.subscription_id}-${var.project}-${var.environment}"), 0, 6)
  acr_name      = substr(replace("${var.project}${var.environment}${local.unique_suffix}", "/[^0-9A-Za-z]/", ""), 0, 50)
  key_vault_name = substr(
    replace("kv-${var.project}-${var.environment}-${local.unique_suffix}", "/[^0-9A-Za-z-]/", ""),
    0,
    24
  )

  default_tags = {
    project     = var.project
    environment = var.environment
    layer       = "platform"
  }

  common_tags = merge(local.default_tags, var.tags)

  subnets = {
    private_endpoints = {
      name                              = "snet-private-endpoints"
      address_prefixes                  = ["10.20.1.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
    postgres = {
      name              = "snet-postgres"
      address_prefixes  = ["10.20.2.0/24"]
      service_endpoints = ["Microsoft.Storage"]
      delegations = {
        postgres = {
          name = "postgres-delegation"
          service_delegation = {
            name = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action",
            ]
          }
        }
      }
    }
    admin = {
      name             = "snet-admin"
      address_prefixes = ["10.20.3.0/24"]
    }
    labs = {
      name             = "snet-labs"
      address_prefixes = ["10.20.10.0/24"]
    }
    github_runner = {
      name             = "snet-github-runner"
      address_prefixes = ["10.20.20.0/24"]
    }
    aks_nodes = {
      name             = "snet-aks-nodes"
      address_prefixes = ["10.20.64.0/22"]
    }
  }
}
