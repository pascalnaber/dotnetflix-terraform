variable "resource_group_name" {
  type        = string  
} 

variable "storage_account_name" {
  type        = string  
} 

variable "tags" {
  type        = map(string)
}

locals {
  resource_group_name = "rg-${var.resource_group_name}"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "westeurope"

  tags = var.tags
}

module "storage" {
  source = "./modules/storage_account"

  name				= var.storage_account_name
  resource_group_name = azurerm_resource_group.rg.name
  location			= azurerm_resource_group.rg.location
}