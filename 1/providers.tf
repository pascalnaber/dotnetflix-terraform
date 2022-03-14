provider "azurerm" {
  features {
  }
}

provider "azuread" {
}

data "terraform_remote_state" "state" {
  backend = "azurerm"
  config = {
    storage_account_name = "sadnfterraformnonprodwe"
    container_name       = "terraformstate"
    key                  = "dnf.nonprod.tfstate"
    resource_group_name  = "rg-dnf-terraform-nonprod-we-001"
  }
}