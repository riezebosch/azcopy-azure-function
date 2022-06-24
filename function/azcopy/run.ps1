# Input bindings are passed in via param block.
param($Timer)
$ErrorActionPreference = "Stop"

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# /tmp is automatically cleared after the function finishes
# preventing from overflowing the disk with log files and job plans
$env:AZCOPY_LOG_LOCATION = Join-Path (Get-Item temp:) '.azcopy'
$env:AZCOPY_JOB_PLAN_LOCATION = Join-Path $env:AZCOPY_LOG_LOCATION 'plans'

Write-Host $env:AZCOPY_LOG_LOCATION
Write-Host $env:AZCOPY_JOB_PLAN_LOCATION

& $PSScriptRoot/azcopy env *>&1 | Write-Output

# azcopy sync crashes on subsequent runs after indexing the destination container
# azcopy v10.14.1 write humongous log files even with log level set to NONE
& $PSScriptRoot/azcopy copy $env:SOURCE $env:SINK --recursive --overwrite ifSourceNewer --preserve-permissions --log-level ERROR *>&1 | Write-Output
if ($LASTEXITCODE -ne 0) {
    throw "Exit code: $LASTEXITCODE"
}
