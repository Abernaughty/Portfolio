# Azure Function Deployment Troubleshooting

## Session 13 - September 16, 2025

### Problem Statement
Functions deploy successfully to `pokedata-func` (via GitHub Actions) but not to `pokedata-func-dev` (via Azure DevOps pipeline + Terraform)

### Root Cause Analysis: CRITICAL FINDINGS ⚠️

**MISSING CRITICAL APP SETTING IN TERRAFORM**
- ❌ **Missing**: `AzureWebJobsFeatureFlags = "EnableWorkerIndexing"` 
- ✅ **Required**: This setting is MANDATORY for Azure Functions v4 programming model
- 🔍 **Evidence**: Azure CLI shows this setting is missing from pokedata-func-dev app settings

### Deployment Method Comparison

#### Working: GitHub Actions → pokedata-func ✅
- **Location**: `C:\Users\maber\Documents\GitHub\PokeData\.github\workflows\deploy-function.yml`
- **Method**: Direct deployment to existing function app (likely has the required app setting)
- **Status**: Functions visible and working in Azure portal

#### Broken: Azure DevOps → pokedata-func-dev ❌
- **Location**: `IaC_Projects/Terraform/PokeData/.azuredevops/azure-pipelines.yml`
- **Method**: Terraform creates infrastructure + Azure DevOps deploys code
- **Issue 1**: Terraform module missing `AzureWebJobsFeatureFlags = "EnableWorkerIndexing"`
- **Issue 2**: Pipeline deployment may not be setting correct app settings
- **Status**: Infrastructure exists but no functions visible (empty function list)

### Technical Analysis

#### Azure Function App Current State (pokedata-func-dev)
```json
{
  "name": "pokedata-func-dev",
  "resourceGroupName": "pokedata-dev-rg", 
  "location": "centralus",
  "status": "Running",
  "appSettings": {
    "FUNCTIONS_EXTENSION_VERSION": "~4",
    "WEBSITE_NODE_DEFAULT_VERSION": "~22",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "WEBSITE_RUN_FROM_PACKAGE": "1",
    "COSMOS_DB_CONNECTION_STRING": "[CONFIGURED]"
  },
  "missingSettings": {
    "AzureWebJobsFeatureFlags": "EnableWorkerIndexing"  // CRITICAL MISSING
  },
  "functionsDeployed": []  // EMPTY - NO FUNCTIONS
}
```

#### Local Function Code Analysis ✅
- **Programming Model**: Azure Functions v4 with `app.http()` and `app.timer()` registration
- **TypeScript Compilation**: Working correctly, outputs to `/dist` folder
- **Function Registration**: 5 functions properly registered (3 HTTP + 2 timer)
- **Dependencies**: All correct (@azure/functions@4.7.2, Node.js 22)

#### Azure DevOps Pipeline Analysis ✅
- **Build Process**: Correctly uses PNPM, builds TypeScript, creates deployment artifact
- **Deployment Process**: Uses `AzureFunctionApp@2` task with correct package
- **App Settings**: Only sets `COSMOS_DB_CONNECTION_STRING`, missing critical v4 settings

#### Terraform Configuration Analysis ❌
- **Missing Setting**: `AzureWebJobsFeatureFlags = "EnableWorkerIndexing"` not in default_app_settings
- **Node.js Version**: ✅ Correctly set to "~22"
- **Functions Extension**: ✅ Correctly set to "~4"
- **Runtime**: ✅ Correctly set to "node"

### IMMEDIATE FIXES REQUIRED (Next Session) 🎯

#### 1. Fix Terraform Configuration
**File**: `IaC_Projects/Terraform/PokeData/modules/function-app/main.tf`

```hcl
# CURRENT (BROKEN):
default_app_settings = {
  "FUNCTIONS_WORKER_RUNTIME" = "node"
  "WEBSITE_RUN_FROM_PACKAGE" = "1"
}

# REQUIRED FIX:
default_app_settings = {
  "FUNCTIONS_WORKER_RUNTIME"     = "node"
  "WEBSITE_RUN_FROM_PACKAGE"     = "1"
  "AzureWebJobsFeatureFlags"     = "EnableWorkerIndexing"  # CRITICAL: Required for v4 model
  "WEBSITE_NODE_DEFAULT_VERSION" = "~22"                   # Ensure Node.js version consistency
}
```

#### 2. Fix Azure DevOps Pipeline App Settings
**File**: `IaC_Projects/Terraform/PokeData/.azuredevops/azure-pipelines.yml`

```yaml
# CURRENT (INCOMPLETE):
appSettings: '-COSMOS_DB_CONNECTION_STRING $(COSMOS_DB_CONNECTION_STRING)'

# REQUIRED FIX:
appSettings: |
  -COSMOS_DB_CONNECTION_STRING $(COSMOS_DB_CONNECTION_STRING)
  -AzureWebJobsFeatureFlags EnableWorkerIndexing
  -WEBSITE_NODE_DEFAULT_VERSION ~22
```

#### 3. Deployment Testing Sequence
1. **Apply Terraform Changes**: Update function app with missing app setting
2. **Redeploy via Pipeline**: Test Azure DevOps deployment with fixed configuration
3. **Verify Functions**: Check if functions now appear in Azure portal
4. **Test Endpoints**: Validate function endpoints are working
5. **Compare Configurations**: Ensure pokedata-func-dev matches working pokedata-func

### Troubleshooting Checklist for Next Session
- [ ] Add AzureWebJobsFeatureFlags to Terraform function-app module
- [ ] Update Azure DevOps pipeline app settings configuration
- [ ] Apply Terraform changes to update pokedata-func-dev
- [ ] Redeploy function code via Azure DevOps pipeline
- [ ] Verify functions appear in Azure portal
- [ ] Test function endpoints (GetSetList, GetCardInfo, etc.)
- [ ] Compare app settings between working and fixed function apps
- [ ] Document successful deployment pattern for future environments

### Expected Function Endpoints After Fix
```
GET https://pokedata-func-dev.azurewebsites.net/api/sets
GET https://pokedata-func-dev.azurewebsites.net/api/sets/{setId}/cards/{cardId}
GET https://pokedata-func-dev.azurewebsites.net/api/sets/{setId}/cards
```

### Success Criteria
- [ ] Functions visible in Azure portal
- [ ] Function endpoints return valid responses
- [ ] Timer functions show in portal (refreshData, monitorCredits)
- [ ] App settings match working configuration
- [ ] Azure DevOps pipeline deploys successfully

### Key Learning
**Azure Functions v4 Programming Model requires `AzureWebJobsFeatureFlags = "EnableWorkerIndexing"`** - This is not optional and must be set for functions to be discovered and registered properly.

### Next Session Priority
**CRITICAL**: Fix the missing app setting first, then test deployment. This single setting is likely the root cause of all function visibility issues.
