# Outputs for the dev environment

# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Cosmos DB Outputs
output "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint"
  value       = module.cosmos_db.endpoint
}

output "cosmos_db_id" {
  description = "Cosmos DB account ID"
  value       = module.cosmos_db.id
}

output "cosmos_db_connection_string" {
  description = "Cosmos DB primary SQL connection string"
  value       = module.cosmos_db.primary_sql_connection_string
  sensitive   = true
}

# Function App Outputs
output "function_app_name" {
  description = "Name of the Function App"
  value       = module.function_app.name
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App"
  value       = module.function_app.default_hostname
}

output "function_app_url" {
  description = "URL of the Function App"
  value       = "https://${module.function_app.default_hostname}"
}

output "function_app_identity" {
  description = "Managed identity principal ID of the Function App"
  value       = module.function_app.identity_principal_id
}

output "function_app_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.function_app.application_insights_instrumentation_key
  sensitive   = true
}

# Static Web App Outputs
output "static_web_app_name" {
  description = "Name of the Static Web App"
  value       = module.static_web_app.name
}

output "static_web_app_url" {
  description = "URL of the Static Web App"
  value       = "https://${module.static_web_app.default_host_name}"
}

output "static_web_app_api_key" {
  description = "API key for Static Web App deployment"
  value       = module.static_web_app.api_key
  sensitive   = true
}

# API Management Outputs
output "api_management_name" {
  description = "Name of the API Management instance"
  value       = module.api_management.name
}

output "api_management_gateway_url" {
  description = "Gateway URL of the API Management instance"
  value       = module.api_management.gateway_url
}

output "api_management_developer_portal_url" {
  description = "Developer portal URL of the API Management instance"
  value       = module.api_management.developer_portal_url
}

output "api_management_identity" {
  description = "Managed identity principal ID of the API Management instance"
  value       = module.api_management.identity_principal_id
}

# Environment Information
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "deployment_timestamp" {
  description = "Timestamp of the deployment"
  value       = var.created_date
}

# Connection Information Summary
output "connection_summary" {
  description = "Summary of all service endpoints"
  value = {
    static_web_app = "https://${module.static_web_app.default_host_name}"
    function_app   = "https://${module.function_app.default_hostname}"
    api_gateway    = module.api_management.gateway_url
    cosmos_db      = module.cosmos_db.endpoint
  }
}

# Cost Optimization Information
output "cost_optimization_notes" {
  description = "Cost optimization settings for this environment"
  value = {
    cosmos_db    = "Serverless mode - pay per request"
    function_app = "Consumption plan - pay per execution"
    static_web   = "Free tier"
    api_mgmt     = "Consumption tier - pay per call"
  }
}
