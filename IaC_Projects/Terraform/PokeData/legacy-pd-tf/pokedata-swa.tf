terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "4.40.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_static_web_app" "res-0" {
  api_key                            = "" # Masked sensitive attribute
  app_settings                       = {}
  configuration_file_changes_enabled = true
  location                           = "centralus"
  name                               = "Pokedata-SWA"
  preview_environments_enabled       = true
  public_network_access_enabled      = true
  repository_branch                  = "main"
  repository_token                   = "" # Masked sensitive attribute
  repository_url                     = "https://github.com/Abernaughty/PokeData"
  resource_group_name                = "pokedata-rg"
  sku_size                           = "Free"
  sku_tier                           = "Free"
  tags                               = {}
}
