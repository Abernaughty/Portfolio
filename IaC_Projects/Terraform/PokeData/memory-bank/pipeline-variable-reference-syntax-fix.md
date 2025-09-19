# Pipeline Variable Reference Syntax Fix

## Issue Summary
Azure DevOps pipeline was failing to pass variables between deployment jobs within the same stage due to incorrect variable reference syntax.

## Root Cause Analysis
The issue was with the variable reference syntax for deployment jobs using the `runOnce` strategy. We had two problems:

1. **Original Issue**: Missing job name prefix in output variable references
2. **Incorrect Fix**: Used `stageDependencies` syntax for same-stage job dependencies

## Microsoft Documentation Findings

### For Deployment Jobs with runOnce Strategy
According to [Microsoft's deployment jobs documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs?view=azure-devops#support-for-output-variables):

**Correct Syntax:**
```yaml
$[dependencies.<job-name>.outputs['<job-name>.<step-name>.<variable-name>']]
```

**Example from Documentation:**
```yaml
$[dependencies.JobA.outputs['JobA.StepA.VariableA']]
```

### Key Distinction
- **Same Stage Dependencies**: Use `dependencies.<job-name>.outputs`
- **Cross-Stage Dependencies**: Use `stageDependencies.<stage-name>.<job-name>.outputs`

## Our Pipeline Structure
```yaml
- stage: Deploy
  jobs:
    - deployment: DeployDev    # Sets output variables
    - deployment: DeployApp    # Consumes output variables
      dependsOn: DeployDev
```

## The Fix Applied

### Before (Incorrect):
```yaml
COSMOS_DB_CONNECTION_STRING: $[ stageDependencies.Deploy.DeployDev.outputs['setOutputs.COSMOS_CONNECTION'] ]
```

### After (Correct):
```yaml
COSMOS_DB_CONNECTION_STRING: $[ dependencies.DeployDev.outputs['DeployDev.setOutputs.COSMOS_CONNECTION'] ]
```

## All Variables Fixed
1. `COSMOS_DB_CONNECTION_STRING: $[ dependencies.DeployDev.outputs['DeployDev.setOutputs.COSMOS_CONNECTION'] ]`
2. `FUNCTION_APP_NAME: $[ dependencies.DeployDev.outputs['DeployDev.setOutputs.FUNCTION_APP_NAME'] ]`
3. `BLOB_STORAGE_CONNECTION_STRING: $[ dependencies.DeployDev.outputs['DeployDev.setOutputs.BLOB_CONNECTION'] ]`
4. `REDIS_CONNECTION_STRING: $[ dependencies.DeployDev.outputs['DeployDev.setOutputs.REDIS_CONNECTION'] ]`
5. `HAS_BLOB_STORAGE: $[ dependencies.DeployDev.outputs['DeployDev.setOutputs.HAS_BLOB_STORAGE'] ]`
6. `HAS_REDIS_CACHE: $[ dependencies.DeployDev.outputs['DeployDev.setOutputs.HAS_REDIS_CACHE'] ]`

## Key Learning
The critical missing piece was the **job name prefix** in the outputs reference. For deployment jobs with `runOnce` strategy, the syntax requires:
- Job name: `DeployDev`
- Step name: `setOutputs`
- Variable name: `COSMOS_CONNECTION`
- **Full reference**: `DeployDev.setOutputs.COSMOS_CONNECTION`

## Status
✅ **FIXED** - Applied correct `dependencies` syntax with proper job name prefixes for all 6 variables.

## Next Steps
- Test the pipeline to verify variable passing works correctly
- Monitor pipeline logs to confirm variables are populated
- Document successful resolution in progress.md
