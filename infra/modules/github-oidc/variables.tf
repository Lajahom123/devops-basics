variable "name" {
  description = "Federated credential name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the user-assigned identity."
  type        = string
}

variable "parent_identity_id" {
  description = "User-assigned identity resource ID that owns the federated credential."
  type        = string
}

variable "subject" {
  description = "GitHub OIDC subject allowed to federate with the identity."
  type        = string
}
