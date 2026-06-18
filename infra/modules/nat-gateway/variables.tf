variable "name" {
  description = "NAT Gateway name."
  type        = string
}

variable "public_ip_name" {
  description = "Public IP name for the NAT Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where NAT resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for NAT resources."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to associate with the NAT Gateway."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to NAT resources."
  type        = map(string)
  default     = {}
}
