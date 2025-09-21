# Terraform Variable Declarations Fix

## Problem Identified (September 20, 2025)
**Terraform Validation Errors** - Pipeline failing with "Reference to undeclared input variable" errors

### Error Details
```
Error: Reference to undeclared input variable
  on main.tf line 133, in module "function_app":
 133:     "POKEMON_TCG_API_KEY"      = var.pokemon_tcg_api_key

Error: Reference to undeclared input variable
  on main.tf line 135, in module "function_app":
 135:     "POKEDATA_API_KEY"         = var.pokedata_api_key
```

## Root Cause Analysis
1. **Missing Variable Declarations**: `environments/dev/main.tf` references two variables that aren't declared in `variables.tf`
2. **Pipeline Variable Group Setup**: User confirmed these variables are configured in Azure DevOps pipeline variable groups
3. **Terraform Requirement**: Terraform requires variable declarations even when values come from external sources

## Solution Applied ✅

### Added Variable Declarations
Added to `environments/dev/variables.tf`:

```hcl
# External API Configuration
variable "pokemon_tcg_api_key" {
  description = "API key for Pokemon TCG API"
  type        = string
  sensitive   = true
}

variable "pokedata_api_key" {
  description = "API key for PokeData API"
  type        = string
  sensitive   = true
}
```

### How This Works
1. **Variable Declaration**: Terraform now recognizes these as valid input variables
2. **Pipeline Integration**: Azure DevOps pipeline variable groups provide the actual values
3. **Security**: Variables marked as `sensitive = true` to prevent logging
4. **Flow**: Pipeline Variables → Terraform Variables → Function App Settings

## Fix Results ✅
- **Terraform Validation**: Should now pass without "undeclared input variable" errors
- **Pipeline Variables**: Existing variable group configuration remains unchanged
- **Security**: API keys properly marked as sensitive
- **App Configuration**: Function App will receive API keys as environment variables

## Context
This fix completes the app configuration conflict resolution work from previous sessions. The Pure Terraform approach is now fully implemented with:
1. ✅ Terraform manages all app settings
2. ✅ Pipeline deploys code only (no app settings)
3. ✅ All required variables properly declared
4. ✅ Configuration drift eliminated

## Next Steps
1. **Pipeline Test**: Run pipeline to verify Terraform validation passes
2. **Deployment Verification**: Confirm Function App receives all environment variables
3. **API Testing**: Test external API integrations work with provided keys

## Technical Pattern
**Standard Terraform + Azure DevOps Integration**:
- Declare variables in `variables.tf` with appropriate types and sensitivity
- Provide values through Azure DevOps variable groups
- Reference variables in Terraform configuration
- Pipeline passes values automatically during deployment
