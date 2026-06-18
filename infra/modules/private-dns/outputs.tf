output "zone_ids" {
  description = "Private DNS zone IDs keyed by logical name."
  value = {
    for key, zone in azurerm_private_dns_zone.main : key => zone.id
  }
}

output "zone_names" {
  description = "Private DNS zone names keyed by logical name."
  value = {
    for key, zone in azurerm_private_dns_zone.main : key => zone.name
  }
}

output "virtual_network_link_ids" {
  description = "Private DNS zone virtual network link IDs keyed by logical name."
  value = {
    for key, link in azurerm_private_dns_zone_virtual_network_link.main : key => link.id
  }
}
