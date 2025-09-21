# PokeData Development Environment Configuration
# This file orchestrates all modules to create a complete dev environment

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

# Configure the Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = "555b4cfa-ad2e-4c71-9433-620a59cf7616"
}

# Resource Group for the entire environment
resource "azurerm_resource_group" "main" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.location

  tags = local.common_tags
}

# Cosmos DB Module
module "cosmos_db" {
  source = "../../modules/cosmos-db"

  name                = "${var.project}-cosmos-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment

  # Dev uses serverless for cost optimization
  capacity_mode = "serverless"

  # Basic backup for dev
  backup_type = "Continuous"
  backup_tier = "Continuous7Days" # Use backup_tier instead of backup_retention

  # Consistency
  consistency_level = "Session"

  # Note: Database and containers need to be created separately
  # after the Cosmos DB account is created

  tags = local.common_tags
}

# Pokemon Cards Database
resource "azurerm_cosmosdb_sql_database" "pokemon_cards" {
  name                = "PokemonCards"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = module.cosmos_db.name
}

# Cards Container
resource "azurerm_cosmosdb_sql_container" "cards" {
  name                  = "Cards"
  resource_group_name   = azurerm_resource_group.main.name
  account_name          = module.cosmos_db.name
  database_name         = azurerm_cosmosdb_sql_database.pokemon_cards.name
  partition_key_paths   = ["/setId"] # Or whatever partition key your app needs
  partition_key_version = 1
}

# You could add more containers here:
resource "azurerm_cosmosdb_sql_container" "sets" {
  name                  = "Sets"
  resource_group_name   = azurerm_resource_group.main.name
  account_name          = module.cosmos_db.name
  database_name         = azurerm_cosmosdb_sql_database.pokemon_cards.name
  partition_key_paths   = ["/series"]
  partition_key_version = 1
}

# Storage Account Module - REMOVED
# The PokeData application doesn't currently use blob storage
# This can be added back in the future when blob storage features are needed
# 
# module "storage_account" {
#   source = "../../modules/storage-account"
#   ...
# }

# Random string for storage account name uniqueness - REMOVED
# resource "random_string" "storage_suffix" {
#   length  = 6
#   special = false
#   upper   = false
# }

# Function App Module
module "function_app" {
  source = "../../modules/function-app"

  name                = "${var.project}-func-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment

  # Storage account - let the module create its own
  storage_account_name = ""
  storage_account_key  = ""

  # OS type for Windows Function App
  os_type = "Windows"

  # Dev uses consumption plan
  # The module will automatically select the right SKU based on environment

  # Application settings - All configuration managed by Terraform
  app_settings = {
    # Core Cosmos DB connection (the one actually used by the application)
    "COSMOS_DB_CONNECTION_STRING" = module.cosmos_db.connection_string

    # External API configurations
    "POKEMON_TCG_API_BASE_URL" = "https://api.pokemontcg.io/v2"
    "POKEMON_TCG_API_KEY"      = var.pokemon_tcg_api_key
    "POKEDATA_API_BASE_URL"    = "https://www.pokedata.io/v0"
    "POKEDATA_API_KEY"         = var.pokedata_api_key

    # Application settings
    "ENABLE_REDIS_CACHE" = "false"
    "CACHE_TTL_SETS"     = "604800"

    # Critical runtime settings (previously managed by pipeline)
    "AzureWebJobsFeatureFlags"     = "EnableWorkerIndexing"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~22"
  }

  # CORS settings for dev
  cors_allowed_origins = [
    "http://localhost:3000",
    "http://localhost:4280",
    "https://${module.static_web_app.default_host_name}",
    "https://portal.azure.com"
  ]

  # Identity
  identity_type = "SystemAssigned"

  tags = local.common_tags
}

# Static Web App Module
module "static_web_app" {
  source = "../../modules/static-web-app"

  name                = "${var.project}-swa-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location == "centralus" ? "centralus" : "eastus2" # SWA has limited regions
  environment         = var.environment

  # GitHub configuration
  repository_url    = var.github_repository_url
  repository_branch = var.github_branch # Fixed: use repository_branch instead of branch
  # repository_token  = var.repository_token # Token stored in terraform-dev pipeline variable group

  # Build configuration
  app_location    = "/"
  api_location    = ""
  output_location = "build"

  # The module will automatically select Free tier for dev

  tags = local.common_tags
}

# API Management Module
module "api_management" {
  source = "../../modules/api-management"

  name                = "${var.project}-apim-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment

  # Publisher information
  publisher_name  = var.apim_publisher_name
  publisher_email = var.apim_publisher_email

  # The module will automatically select Consumption tier for dev
  # Note: Products and APIs need to be created as separate resources

  tags = local.common_tags
}

# API Management Backend Configuration
resource "azurerm_api_management_backend" "function_app" {
  name                = "function-app-backend"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = module.api_management.name
  protocol            = "http"
  url                 = "https://${module.function_app.default_hostname}/api"

  # Note: Function keys need to be retrieved separately after deployment
  # For dev, we can skip authentication or use a placeholder
}

# API Management API Configuration
resource "azurerm_api_management_api" "pokemon" {
  name                = "pokemon-api"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = module.api_management.name
  revision            = "1"
  display_name        = "Pokemon Card API"
  path                = "pokemon"
  protocols           = ["https"]

  subscription_required = false # Open for dev
}

# Local variables for common configurations
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
    CreatedDate = var.created_date
    Repository  = var.github_repository_url
  }
}
