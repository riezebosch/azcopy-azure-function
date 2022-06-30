param name string
param location string = resourceGroup().location
param schedule string = '0 0 22 * * *'
param sas_source string
param sas_sink string

// replace this with a shared workspace when deploying multiple functions
// or when reusing the same workspace to monitor other applications
resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 120
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// probably a good idea to have each function use its own app insights
resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspace.id
  }
  kind: 'web'
}

// use separate vnet for each functionapp to grant granular access to specific storage accounts
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet' // change to functionapp specific name for future functionapps
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

// use separate storage for eacht functionapp
resource storage 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/default'
          action: 'Allow'
        }
      ]
      ipRules: [
      ]
    }
  }
}

resource shares 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  name: 'default'
  parent: storage
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name: 'azcopy-logs'
  parent: shares
  properties: {
    accessTier: 'Cool'
  }

}

// reuse same app service for deploying multiple functionapps
resource plan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: name
  location: location
  kind: 'linux'
  sku: {
    name: 'P3V3'
    tier: 'PremiumV3'
  }
  properties: {
    reserved: true
  }
}

resource app 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          // in future use to managed identity to connect: 
          // https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob#connecting-to-host-storage-with-an-identity-preview
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${listKeys(storage.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: ai.properties.InstrumentationKey
        }
        {
          name: 'TimerSchedule'
          value: schedule
        }
        {
          name: 'SOURCE'
          value: sas_source
        }
        {
          name: 'SINK'
          value: sas_sink
        }
        {
          name: 'AZCOPY_CONCURRENCY_VALUE'
          value: '1000' // https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-optimize#increase-concurrency
        }
        {
          name: 'AZCOPY_CONCURRENT_SCAN'
          value: '1000' // not sure if this helps with s2s copy but sure it doesn't bite
        }
        {
          name: 'WEBSITE_PROACTIVE_AUTOHEAL_ENABLED'
          value: 'false' // high CPU and memory load is to be expected
        }
        {
          name: 'AZCOPY_LOG_LOCATION'
          value: '/mnt/azcopy'
        }
      ]
      netFrameworkVersion: 'v6.0'
      powerShellVersion: '7.2'
      alwaysOn: true
      azureStorageAccounts: {
        'azcopy-logs': {
          type: 'AzureFiles'
          accountName: storage.name
          shareName: share.name
          mountPath: '/mnt/azcopy'
          accessKey: storage.listKeys().keys[0].value
        }
      }
    }
  }
}

resource networkConfig 'Microsoft.Web/sites/networkConfig@2021-03-01' = {
  name: 'virtualNetwork'
  parent: app
  properties: {
    subnetResourceId: '${vnet.id}/subnets/default'
  }
}
