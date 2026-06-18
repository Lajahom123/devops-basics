output "network_security_group_ids" {
  description = "NSG IDs keyed by logical name."
  value = {
    for key, nsg in azurerm_network_security_group.main : key => nsg.id
  }
}
