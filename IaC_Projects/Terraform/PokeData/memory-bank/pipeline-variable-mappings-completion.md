# Pipeline Variable Mappings Completion

## Summary
Successfully added environment variable mappings for API keys to Azure DevOps pipeline templates to resolve Terraform validation errors.

## Changes Made

### terraform-plan.yml
Added environment variable mappings to all relevant tasks:
- `TF_VAR_pokemon_tcg_api_key: $(pokemon_tcg_api_key)`
- `TF_VAR_pokedata_api_key: $(pokedata_api_key)`

Tasks updated:
1. Terraform Init task
2. Terraform Plan task  
3. Generate Plan Summary PowerShell task

### terraform-apply.yml
Added environment variable mappings to all relevant tasks:
- `TF_VAR_pokemon_tcg_api_key: $(pokemon_tcg_api_key)`
- `TF_VAR_pokedata_api_key: $(pokedata_api_key)`

Tasks updated:
1. Terraform Init (Apply) task
2. Terraform Apply task
3. Extract Terraform outputs PowerShell task
4. Generate Deployment Summary PowerShell task

## Resolution Complete
This completes the resolution of all Terraform validation errors:

1. ✅ **Variable Declaration Errors**: Added missing variable declarations in `environments/dev/variables.tf`
2. ✅ **Cosmos DB Output Reference Error**: Fixed deprecated `connection_string` reference to `primary_sql_connection_string` in `environments/dev/main.tf`
3. ✅ **Pipeline Variable Mapping**: Added environment variable mappings in both `terraform-plan.yml` and `terraform-apply.yml`

## Next Steps
The pipeline should now execute successfully with all Terraform validation errors resolved. The API keys will be passed from Azure DevOps variable groups to Terraform via the `TF_VAR_` environment variable pattern.

## Technical Pattern
This follows the established pattern of:
- Azure DevOps Variable Groups → `$(variable_name)` → `TF_VAR_variable_name` → Terraform variables
- Maintains security by keeping sensitive values in Azure DevOps variable groups
- Uses consistent environment variable mapping across all pipeline tasks
