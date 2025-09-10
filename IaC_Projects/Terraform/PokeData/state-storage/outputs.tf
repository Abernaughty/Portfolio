output "resource_group_name" {
  description = "Name of the resource group containing state storage"
  value       = azurerm_resource_group.state.name
}

output "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  value       = azurerm_storage_account.state.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.state.id
}

output "primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.state.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.state.primary_connection_string
  sensitive   = true
}

output "dev_container_name" {
  description = "Name of the container for dev environment state"
  value       = azurerm_storage_container.dev.name
}

output "staging_container_name" {
  description = "Name of the container for staging environment state"
  value       = azurerm_storage_container.staging.name
}

output "prod_container_name" {
  description = "Name of the container for production environment state"
  value       = azurerm_storage_container.prod.name
}

# Backend configuration helper
output "backend_config_example" {
  description = "Example backend configuration for environments"
  value       = <<-EOT
    terraform {
      backend "azurerm" {
        resource_group_name  = "${azurerm_resource_group.state.name}"
        storage_account_name = "${azurerm_storage_account.state.name}"
        container_name       = "tfstate-<environment>"
        key                  = "<environment>.terraform.tfstate"
      }
    }
  EOT
}
