variable "name" {
  description = "Bastion host name."
  type        = string
}

variable "public_ip_name" {
  description = "Bastion public IP name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where Bastion resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for Bastion resources."
  type        = string
}

variable "subnet_id" {
  description = "AzureBastionSubnet ID."
  type        = string
}

variable "sku" {
  description = "Bastion SKU."
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Tags applied to Bastion resources."
  type        = map(string)
  default     = {}
}
