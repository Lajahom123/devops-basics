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
