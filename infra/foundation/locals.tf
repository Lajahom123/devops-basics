locals {
  name_prefix         = "${var.project}-${var.environment}"
  resource_group_name = "rg-${var.project}-${var.environment}-platform"
  vnet_name           = "vnet-${var.project}-${var.environment}"

  unique_suffix         = random_string.foundation_suffix.result
  acr_name              = substr(lower(replace("${var.project}${var.environment}${local.unique_suffix}", "/[^0-9A-Za-z]/", "")), 0, 50)
  github_deploy_subject = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
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

  private_dns_zones = {
    postgres = {
      name                 = "privatelink.postgres.database.azure.com"
      virtual_network_link = "link-${local.vnet_name}-postgres"
    }
    key_vault = {
      name                 = "privatelink.vaultcore.azure.net"
      virtual_network_link = "link-${local.vnet_name}-key-vault"
    }
  }

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
