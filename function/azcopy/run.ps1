# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

$env:AZCOPY_LOG_LOCATION = $env:AZCOPY_JOB_PLAN_LOCATION = "$env:TEMP\.azcopy"
$env:AZCOPY_CONCURRENCY_VALUE = 1000
$env:AZCOPY_CONCURRENT_SCAN = 1000

& $PSScriptRoot\azcopy.exe sync $env:SOURCE $env:SINK --delete-destination true | Write-Host