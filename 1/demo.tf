resource "azurerm_resource_group" "rg" {
  name     = "dotnetflix"
  location = "westeurope"

  tags = {
    Environment = "nonprod"
    Team        = "techdriven"
    Project     = "dotnetflix"
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "sadnfdemo"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_container_registry" "acr" {
  name = "aksupdates"
  resource_group_name = "aksupdates-common"
}

data "azuread_user" "user" {
  user_principal_name = "pascal@pascalnaberoutlook.onmicrosoft.com"
}

resource "azurerm_role_assignment" "example" {
  principal_id                     = data.azuread_user.user.object_id 
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.acr.id
}