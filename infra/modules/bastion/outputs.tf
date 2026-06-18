output "bastion_id" {
  description = "Bastion host ID."
  value       = azurerm_bastion_host.main.id
}

output "public_ip_address" {
  description = "Bastion public IP address."
  value       = azurerm_public_ip.main.ip_address
}
