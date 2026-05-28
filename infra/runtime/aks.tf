resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  location            = var.location
  dns_prefix          = var.aks_dns_prefix
  tags                = local.common_tags

  sku_tier = "Free"

  default_node_pool {
    name           = "system"
    node_count     = var.aks_node_count
    vm_size        = var.aks_node_vm_size
    vnet_subnet_id = data.terraform_remote_state.foundation.outputs.aks_subnet_id

    orchestrator_version = null
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"

    load_balancer_sku = "standard"
    outbound_type     = "userAssignedNATGateway"

    pod_cidr       = "10.244.0.0/16"
    service_cidr   = "10.245.0.0/16"
    dns_service_ip = "10.245.0.10"
  }

  oms_agent {
    log_analytics_workspace_id = data.terraform_remote_state.foundation.outputs.log_analytics_workspace_id
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = data.terraform_remote_state.foundation.outputs.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}