output "nat_gateway_id" {
  description = "NAT Gateway ID."
  value       = azurerm_nat_gateway.main.id
}

output "public_ip_address" {
  description = "NAT public IP address."
  value       = azurerm_public_ip.main.ip_address
}
