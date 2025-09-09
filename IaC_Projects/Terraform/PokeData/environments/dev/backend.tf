# Backend configuration for state management
# This file will be configured after running the state-storage setup

# Using Azure Storage for remote state management
terraform {
  backend "azurerm" {
    resource_group_name  = "pokedata-terraform-state-rg"
    storage_account_name = "tfstateyul4ts"  # Your actual storage account name
    container_name       = "tfstate-dev"
    key                  = "dev.terraform.tfstate"
  }
}

# Note: If you need to switch back to local backend for testing:
# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }
