# State Storage Bootstrap Configuration
# This creates the Azure Storage Account for Terraform state management
# Run this once before setting up environments

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "555b4cfa-ad2e-4c71-9433-620a59cf7616"
}

# Generate a unique suffix for the storage account name
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Resource group for state storage
resource "azurerm_resource_group" "state" {
  name     = "pokedata-terraform-state-rg"
  location = var.location

  tags = {
    Purpose     = "Terraform State Storage"
    Project     = "PokeData"
    ManagedBy   = "Terraform"
    Environment = "Shared"
    CreatedDate = timestamp()
  }
}

# Storage account for Terraform state
resource "azurerm_storage_account" "state" {
  name                     = "tfstate${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  # Enable versioning for state file history
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    Purpose     = "Terraform State Storage"
    Project     = "PokeData"
    ManagedBy   = "Terraform"
    Environment = "Shared"
    CreatedDate = timestamp()
  }
}

# Container for dev environment state
resource "azurerm_storage_container" "dev" {
  name                  = "tfstate-dev"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

# Container for staging environment state
resource "azurerm_storage_container" "staging" {
  name                  = "tfstate-staging"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

# Container for production environment state
resource "azurerm_storage_container" "prod" {
  name                  = "tfstate-prod"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

# Storage account network rules (optional - can be configured later)
resource "azurerm_storage_account_network_rules" "state" {
  storage_account_id = azurerm_storage_account.state.id

  default_action = "Allow" # Change to "Deny" for production with specific IP allowlist
  ip_rules       = []      # Add your IP addresses here if needed
  bypass         = ["AzureServices"]
}
