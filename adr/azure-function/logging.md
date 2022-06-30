File share `azcopy-logs` from the storage account is mounted on `/mnt/azcopy` and azcopy is configured to log to this location. Logs can be downloaded from the storage account.

Set logging-level to `ERROR`, `FATAL` or `NONE` ~because of disk space issues~ to save disk space.

Cleanup old logs before new run to prevent from disk space issues.

Console output is written to Log Analytics.