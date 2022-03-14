variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "account_replication_type" {
  type        = string
  description = "The type of replication used for this storage account."
  default     = "LRS"
}

variable "shares" {
  description = "The map object to configure one or several additional shares."
  type        = map(object({
    name  = string
    quota = number
  }))
  default     = {}
}

variable "role_assignments" {
  type    = list(object({
    name                 = string
    object_id            = string
    role_definition_name = string
  }))
  default = []
}

variable "network_rules_default_action" {
  type    = string
  default = "Deny"
}

variable "ip_rules" {
  type    = list(object({
    name    = string
    ip_rule = string
  }))
  default = []
}

variable "virtual_network_subnet_ids" {
  type    = list(string)
  default = []
}

variable "containers" {
  description = "The map object to configure one or several additional containers."
  type        = list(object({
    name             = string
    role_assignments = list(object({
      name                 = string
      object_id            = string
      role_definition_name = string
    }))
  }))
  default     = []
}

variable "account_kind" {
  type    = string
  default = "StorageV2"
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "access_tier" {
  type    = string
  default = "Hot"
}
