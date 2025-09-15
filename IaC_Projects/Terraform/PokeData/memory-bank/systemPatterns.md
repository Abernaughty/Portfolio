# PokeData System Patterns

## Architecture Patterns

### Module Structure Pattern
```
modules/
├── <resource-name>/
│   ├── main.tf           # Resource definitions
│   ├── variables.tf      # Input variables
│   ├── outputs.tf        # Output values
│   ├── versions.tf       # Provider requirements
│   └── README.md         # Module documentation
```

### Naming Conventions
```hcl
# Resource naming pattern
"${var.project}-${var.resource_type}-${var.environment}-${var.location_short}"

# Examples:
# pokedata-rg-dev-cus        (resource group)
# pokedata-func-prod-cus     (function app)
# pokedata-cosmos-staging-cus (cosmos db)
```

### Module Design Principles

#### 1. Single Responsibility
Each module manages one logical Azure resource or tightly coupled resource group:
- `api-management/` - APIM instance and policies
- `function-app/` - Function app and app service plan
- `static-web-app/` - SWA and custom domains
- `cosmos-db/` - Cosmos account, databases, and containers

#### 2. Composability
Modules can be combined to create complete environments:
```hcl
module "cosmos" {
  source = "../../modules/cosmos-db"
  # ...
}

module "function" {
  source = "../../modules/function-app"
  cosmos_connection_string = module.cosmos.connection_string
  # ...
}
```

#### 3. Environment Abstraction
```hcl
# environments/dev/main.tf
module "infrastructure" {
  source = "../../modules/complete-stack"
  
  environment = "dev"
  sku_tier    = "free"
  replicas    = 1
}

# environments/prod/main.tf
module "infrastructure" {
  source = "../../modules/complete-stack"
  
  environment = "prod"
  sku_tier    = "standard"
  replicas    = 3
}
```

## State Management Pattern

### Backend Configuration
```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "pokedata-terraform-state-rg"
    storage_account_name = "tfstateyul4ts"
    container_name       = "tfstate${environment}"
    key                  = "${tenant}/${subscription}/${environment}.tfstate"
  }
}
```

### State Isolation
- One state file per environment
- Separate storage accounts for production
- State file locking enabled
- Versioning and soft delete enabled

## Variable Management Pattern

### Variable Hierarchy
1. **Module defaults** - Sensible defaults in module
2. **Environment variables** - Environment-specific values
3. **Runtime overrides** - CI/CD pipeline injections

```hcl
# Module variable with default
variable "sku_name" {
  description = "SKU for the resource"
  type        = string
  default     = "Free"  # Module default
}

# Environment override
# terraform.tfvars
sku_name = "Standard"  # Environment specific

# Runtime override
# terraform apply -var="sku_name=Premium"
```

### Secret Handling
```hcl
# Never hardcode secrets
variable "cosmos_key" {
  description = "Cosmos DB access key"
  type        = string
  sensitive   = true
}

# Reference from Key Vault
data "azurerm_key_vault_secret" "cosmos_key" {
  name         = "cosmos-key"
  key_vault_id = var.key_vault_id
}
```

## CI/CD Pipeline Patterns

### Pipeline Stages Pattern
```yaml
stages:
  - validate    # Syntax and security checks
  - test        # Infrastructure tests
  - plan        # Terraform plan
  - approve     # Manual gate
  - apply       # Terraform apply
  - verify      # Post-deployment tests
```

### Environment Promotion Pattern
```
feature/* → dev (auto)
    ↓
develop → staging (auto with tests)
    ↓
main → production (manual approval)
```

### Rollback Pattern
1. **Terraform State Rollback**: Revert to previous state version
2. **Git Revert**: Revert infrastructure code changes
3. **Blue-Green**: Switch traffic back to previous version
4. **Backup Restore**: Restore data from backups

## Testing Patterns

### Test Pyramid
```
         /\
        /  \  E2E Tests (5%)
       /    \
      /------\ Integration Tests (25%)
     /        \
    /----------\ Unit Tests (70%)
```

### Terratest Pattern
```go
func TestModule(t *testing.T) {
    // Arrange
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/function-app",
        Vars: map[string]interface{}{
            "environment": "test",
        },
    })
    
    // Act
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Assert
    output := terraform.Output(t, terraformOptions, "function_url")
    assert.NotEmpty(t, output)
}
```

## Security Patterns

### Least Privilege Access
```hcl
# Service Principal per environment
resource "azuread_application" "sp" {
  display_name = "sp-terraform-${var.environment}"
}

# Role assignment scoped to resource group
resource "azurerm_role_assignment" "sp" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = var.environment == "prod" ? "Reader" : "Contributor"
  principal_id         = azuread_service_principal.sp.object_id
}
```

### Network Security Pattern
```hcl
# Progressive network isolation
locals {
  network_rules = {
    dev     = { public = true,  vnet = false }
    staging = { public = false, vnet = true  }
    prod    = { public = false, vnet = true  }
  }
}
```

## Monitoring Patterns

### Observability Stack
```hcl
# Centralized logging
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project}-law-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${var.project}-ai-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
}
```

### Alert Pattern
```hcl
# Standardized alerts across environments
locals {
  alerts = {
    high_error_rate = {
      threshold = var.environment == "prod" ? 1 : 5
      severity  = var.environment == "prod" ? 1 : 3
    }
    high_latency = {
      threshold = var.environment == "prod" ? 1000 : 3000
      severity  = var.environment == "prod" ? 2 : 4
    }
  }
}
```

## Cost Optimization Patterns

### Resource Sizing
```hcl
locals {
  sku_mapping = {
    dev = {
      apim_sku     = "Consumption_0"
      func_sku     = "Y1"
      cosmos_mode  = "Serverless"
      swa_sku      = "Free"
    }
    prod = {
      apim_sku     = "Standard_1"
      func_sku     = "P1v2"
      cosmos_mode  = "Provisioned"
      swa_sku      = "Standard"
    }
  }
}
```

### Auto-Shutdown Pattern
```hcl
# Dev/Test environments auto-shutdown
resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  count = var.environment != "prod" ? 1 : 0
  
  virtual_machine_id = azurerm_virtual_machine.main.id
  location          = azurerm_resource_group.main.location
  enabled           = true
  daily_recurrence_time = "1900"
  timezone          = "Central Standard Time"
}
```

## Multi-Tenant Patterns

### Tenant Isolation
```hcl
# Separate provider per tenant
provider "azurerm" {
  alias           = "tenant_a"
  subscription_id = var.tenant_a_subscription
  tenant_id       = var.tenant_a_id
}

provider "azurerm" {
  alias           = "tenant_b"
  subscription_id = var.tenant_b_subscription
  tenant_id       = var.tenant_b_id
}
```

### Cross-Tenant Resource Sharing
```hcl
# Shared services in management subscription
module "shared_services" {
  source = "./modules/shared"
  providers = {
    azurerm = azurerm.management
  }
}

# Tenant-specific resources
module "tenant_resources" {
  source = "./modules/tenant"
  providers = {
    azurerm = azurerm.tenant_a
  }
  shared_keyvault_id = module.shared_services.keyvault_id
}
