variable "resource_group_name" {
  description = "Resource group where NSGs are created."
  type        = string
}

variable "location" {
  description = "Azure region for NSGs."
  type        = string
}

variable "network_security_groups" {
  description = "NSGs keyed by logical name. Pass subnet_id to associate."
  type = map(object({
    name      = string
    subnet_id = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to NSGs."
  type        = map(string)
  default     = {}
}
