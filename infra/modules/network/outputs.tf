output "vnet_id" {
  description = "Virtual network ID."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual network name."
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Subnet IDs keyed by logical subnet name."
  value = {
    for key, subnet in azurerm_subnet.main : key => subnet.id
  }
}

output "subnet_names" {
  description = "Subnet names keyed by logical subnet name."
  value = {
    for key, subnet in azurerm_subnet.main : key => subnet.name
  }
}

output "aks_subnet_id" {
  description = "AKS node subnet ID."
  value       = azurerm_subnet.main["aks_nodes"].id
}

output "postgres_subnet_id" {
  description = "PostgreSQL subnet ID."
  value       = azurerm_subnet.main["postgres"].id
}

output "private_endpoints_subnet_id" {
  description = "Private endpoints subnet ID."
  value       = azurerm_subnet.main["private_endpoints"].id
}
