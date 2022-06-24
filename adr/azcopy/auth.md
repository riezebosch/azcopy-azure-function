# SAS

Although azcopy is capable of using the managed identity _for the source_ container, it turns out this only works for an Azure VM and not with Azure Functions. For the source container you need a token anyway.

> Azure Blob (SAS or public) -> Azure Blob (SAS or OAuth authentication)
Source: https://docs.microsoft.com/en-us/azure/storage/common/storage-ref-azcopy-copy?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json#synopsis


It is possible to use `az` cmdlets to generate the tokens on the fly:

```powershell
$context = New-AzStorageContext -ConnectionString $connectionString
New-AzStorageContainerSASToken -Context $context -Name $name -Permission racwlmeop -FullUri -ExpiryTime (Get-Date).AddDays(3)
```

Using the `New-AzStorageContext` requires you to specify its `name` _and_ `resource group` when not using the connection string.

Having the `az` cmdlets has an impact on warmup time since the packages need to installed:


`requirements.psd1`:
```powershell
@{
    # For latest supported version, go to 'https://www.powershellgallery.com/packages/Az'. 
    # To use the Az module in your function app, please uncomment the line below.
    # 'Az' = '7.*'
    'Az.Accounts' = '2.7'
    'Az.Storage' = '4.5'
}
```