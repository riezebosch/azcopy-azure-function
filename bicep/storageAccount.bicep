param location string = resourceGroup().location
param name string
param subnets array = [
]

resource storage 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  kind: 'StorageV2'
  location: location
  name: name
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [for subnet in subnets: {
          id: subnet
          action: 'Allow'
      }]
      ipRules: [
        {
          value: '20.76.109.96'
          action: 'Allow'
        }
        {
          value: '20.76.109.97'
          action: 'Allow'
        }
        {
          value: '20.76.109.98'
          action: 'Allow'
        }
        {
          value: '20.76.109.99'
          action: 'Allow'
        }
        {
          value: '20.76.109.102'
          action: 'Allow'
        }
        {
          value: '20.76.109.103'
          action: 'Allow'
        }
        {
          value: '20.76.109.106'
          action: 'Allow'
        }
        {
          value: '20.76.109.107'
          action: 'Allow'
        }
        {
          value: '20.76.109.110'
          action: 'Allow'
        }
        // {
        //   value: '20.101.218.112/28'
        //   action: 'Allow'
        // }
        // {
        //   value: '20.101.218.128/28'
        //   action: 'Allow'
        // }
        // {
        //   value: '52.156.255.136/29'
        //   action: 'Allow'
        // }
        {
          value: '164.140.188.224/28'
          action: 'Allow'
        }
        {
          value: '164.140.203.224/28'
          action: 'Allow'
        }
        {
          value: '167.202.201.0/27'
          action: 'Allow'
        }
      ]
    }
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  parent: storage
  name: 'default'
}
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  parent: blob
  name: 'my-datalake'
  properties: {
    
  }
}
