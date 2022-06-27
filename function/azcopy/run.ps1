# Input bindings are passed in via param block.
param($Timer)
$ErrorActionPreference = "Stop"

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

Write-Output "clean"
& $PSScriptRoot/azcopy jobs clean *>&1 | Write-Output

Write-Output "env"
& $PSScriptRoot/azcopy env *>&1 | Write-Output

Write-Output "copy"
# azcopy sync crashes on subsequent runs after indexing the destination container
# azcopy v10.15.0 writes humongous log files even with log level set to NONE
& $PSScriptRoot/azcopy copy $env:SOURCE $env:SINK --recursive --overwrite ifSourceNewer --preserve-permissions --log-level ERROR *>&1 | Write-Output
if ($LASTEXITCODE -ne 0) {
    throw "Exit code: $LASTEXITCODE"
}

