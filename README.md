# azcopy & azure function

In order to sync two _storage containers_, this _Azure Function_ wraps _azcopy_ into a _PowerShell_ function.

## Azure Function

Since it's the easiest to invoke an external program, the function is written in `PowerShell`. For a quick startup, the executable(s) are packed into the deployment.

## App Service Plan

### Tier

P3V3: 
* Enough memory, vCPU and disk space
* Dedicated host, guarenteed to run >1h

### Linux

* Disk space issues
* Memory issues
* Extremely slow

### Windows

* Quick, on a beefy tier
* Redirect log location and plan directory to temp folder