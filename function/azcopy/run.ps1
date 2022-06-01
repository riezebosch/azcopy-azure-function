# Input bindings are passed in via param block.
param($Timer)
$ErrorActionPreference = "Stop"

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

$env:AZCOPY_LOG_LOCATION = $env:AZCOPY_JOB_PLAN_LOCATION = "$env:TEMP\azcopy"
& $PSScriptRoot\azcopy.exe sync $env:SOURCE $env:SINK --delete-destination true --preserve-permissions | Write-Host
if ($LASTEXITCODE -ne 0) {
    throw "Exit code: $LASTEXITCODE"
}