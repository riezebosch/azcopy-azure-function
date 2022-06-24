# Copy

azcopy sync crashes in subsequent runs after indexing the destination container (v10.14).

Therefor using an (incremental) copy:

```powershell
azcopy copy $env:SOURCE $env:SINK --recursive --overwrite ifSourceNewer --preserve-permissions --log-level ERROR *>&1 | Write-Output
```

attribute               | description
------------------------|-------------
copy                    | because sync has issues
recursive               | sync is always recursive, copy not
overwrite ifSourceNewer | only copy changed blobs
preserve-permissions    | copy ACL's for ADLS GEN2
log-level ERROR         | prevent the disk from overflowing
*>&1                    | redirect all output streams to stdout
Write-Ouptut            | make sure output is redirected to log analytics

Using `copy --recursive` instead of `sync` has the drawback that deletions in the source container are not reflected in the destination container.

Remark: ACL's are only updated on copy and ignored when copy is skipped.