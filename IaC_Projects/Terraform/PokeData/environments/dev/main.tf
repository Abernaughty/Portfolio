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

  # Runtime configuration - using Node.js for the PokeData application
  runtime_stack = {
    node_version = "18"
  }
  os_type = "Windows"

  # Dev uses consumption plan
  # The module will automatically select the right SKU based on environment

  # Application settings
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "node"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "CosmosDb__Endpoint"       = module.cosmos_db.endpoint
    "CosmosDb__Key"            = module.cosmos_db.primary_key
    "CosmosDb__DatabaseName"   = "PokemonData"
    "CosmosDb__ContainerName"  = "Cards"
  }

  # CORS settings for dev
  cors_allowed_origins = [
    "http://localhost:3000",
    "http://localhost:4280",
    "https://${module.static_web_app.default_host_name}"
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
  repository_branch = var.github_branch    # Fixed: use repository_branch instead of branch
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
