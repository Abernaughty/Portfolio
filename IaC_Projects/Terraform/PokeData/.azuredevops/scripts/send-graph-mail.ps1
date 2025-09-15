param(
  [Parameter(Mandatory=$true)][string]$From,          # e.g., ci@maber.io
  [Parameter(Mandatory=$true)][string]$To,            # e.g., mike@maber.io
  [Parameter(Mandatory=$true)][string]$Environment,   # e.g., dev/staging/prod
  [string]$JobStatus,
  [string]$Branch,
  [string]$RequestedFor
)

$ErrorActionPreference = 'Stop'

# Prefer explicit args; fall back to env vars if missing
$jobStatus    = if ($JobStatus)    { $JobStatus }    elseif ($env:AGENT_JOBSTATUS)          { $env:AGENT_JOBSTATUS }          else { 'Unknown' }
$branchName   = if ($Branch)       { $Branch }       elseif ($env:BUILD_SOURCEBRANCHNAME)    { $env:BUILD_SOURCEBRANCHNAME }    else { 'unknown-branch' }
$requestedFor = if ($RequestedFor) { $RequestedFor } elseif ($env:BUILD_REQUESTEDFOR)        { $env:BUILD_REQUESTEDFOR }        else { 'unknown' }

$subject = "PokeData Pipeline - $Environment - $branchName - $jobStatus"

$bodyText = @"
Pipeline Status: $jobStatus
Environment: $Environment
Build Number: $($env:BUILD_BUILDNUMBER)
Commit: $($env:BUILD_SOURCEVERSION)
Triggered By: $requestedFor

View Pipeline:
$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$($env:SYSTEM_TEAMPROJECT)/_build/results?buildId=$($env:BUILD_BUILDID)
"@

$payload = @{
  message = @{
    subject = $subject
    body    = @{ contentType = "Text"; content = $bodyText }
    toRecipients = @(@{ emailAddress = @{ address = $To } })
  }
  saveToSentItems = $true
} | ConvertTo-Json -Depth 6

# Get a Microsoft Graph token using the service connection context
$token = az account get-access-token --resource-type ms-graph --query accessToken -o tsv
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
$uri = "https://graph.microsoft.com/v1.0/users/$From/sendMail"

Invoke-RestMethod -Method POST -Uri $uri -Headers $headers -Body $payload
Write-Host "📧 Sent Graph email from $From to $To"
