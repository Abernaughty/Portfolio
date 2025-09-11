# Environment-specific variables for dev environment

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralus"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "pokedata"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "DevOps Team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "Development"
}

# GitHub Configuration
variable "github_repository_url" {
  description = "GitHub repository URL for Static Web App"
  type        = string
  default     = "https://github.com/Abernaughty/PokeData"
}

variable "github_branch" {
  description = "GitHub branch to deploy from"
  type        = string
  default     = "main"
}

variable "repository_token" {
  description = "GitHub personal access token for Static Web App deployment"
  type        = string
  sensitive   = true
}

# API Management Configuration
variable "apim_publisher_name" {
  description = "Publisher name for API Management"
  type        = string
  default     = "PokeData Development Team"
}

variable "apim_publisher_email" {
  description = "Publisher email for API Management"
  type        = string
  default     = "admin@pokedata.dev"
}

# Optional overrides for module defaults
variable "cosmos_capacity_mode" {
  description = "Cosmos DB capacity mode (Serverless or Provisioned)"
  type        = string
  default     = "Serverless"
}

variable "function_app_sku" {
  description = "Override for Function App SKU"
  type        = string
  default     = "" # Empty means use module default based on environment
}

variable "static_web_app_sku" {
  description = "Override for Static Web App SKU"
  type        = string
  default     = "" # Empty means use module default based on environment
}

variable "apim_sku" {
  description = "Override for API Management SKU"
  type        = string
  default     = "" # Empty means use module default based on environment
}

# Networking
variable "enable_private_endpoints" {
  description = "Enable private endpoints for resources"
  type        = bool
  default     = false # Disabled for dev to save costs
}

variable "allowed_ip_ranges" {
  description = "IP ranges allowed to access resources"
  type        = list(string)
  default     = [] # Empty means public access (dev only)
}

# Monitoring
variable "enable_monitoring" {
  description = "Enable Application Insights and monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

# Feature Flags
variable "enable_auto_scaling" {
  description = "Enable auto-scaling for applicable resources"
  type        = bool
  default     = false # Disabled for dev
}

variable "enable_backup" {
  description = "Enable backup for databases"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7 # Minimal for dev
}

# Infrastructure Metadata
variable "created_date" {
  description = "Date when the infrastructure was first created (format: YYYY-MM-DD)"
  type        = string
  default     = "2025-01-08" # Date when dev environment was first deployed
}
