output "cluster_id" {
  description = "AKS cluster resource ID."
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.main.name
}

output "kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet managed identity."
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

output "kubelet_identity_client_id" {
  description = "Client ID of the AKS kubelet managed identity."
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id
}

output "node_resource_group" {
  description = "AKS managed node resource group."
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "oidc_issuer_url" {
  description = "AKS OIDC issuer URL."
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.main.kube_config[0]
  sensitive   = true
}
