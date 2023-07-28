// Parameters
//*****************************************************************************************************
@description('The name of the function app that you wish to create.')
param functionAppName string

@description('Location for all resources.')
param location string = resourceGroup().location

/*
@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string
*/

/*
@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param functionWorkerRuntime string
*/

param farmId string

// var functionWorkerRuntime = runtime

@description('The Storage Account tier')
param funcStorageAccountTier string

@description('The Storage Account tier')
param funcStorageAccessTier string

param funcStorageAccountName string

// @secure()
// param funcStorageString object 

param workspaceId string

param pvtEndpointSubnetId string

//*****************************************************************************************************


// Function Storage Account
//*****************************************************************************************************
resource funcStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: funcStorageAccountName
  location: location
  // tags: tags
  kind: 'StorageV2'
  sku: {
    name: funcStorageAccountTier
  }
  properties: {
    allowBlobPublicAccess: false
    accessTier: funcStorageAccessTier
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }    
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true 
  }
}

// output storageAccountId string = funcStorageAccount.id
// output storageAccountName string = funcStorageAccountName.name
// https://github.com/Azure/bicep/issues/2163 // https://stackoverflow.com/questions/47985364/listkeys-for-azure-function-app/47985475#47985475
//*****************************************************************************************************


// Function App
//*****************************************************************************************************
resource FunctionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  // identity: {
  //  type: 'SystemAssigned'
  // }
  properties: {
    serverFarmId: farmId
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          // value: 'DefaultEndpointsProtocol=https;AccountName=${funcStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcStorageString.listKeys().keys[0].value}'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          // value: 'DefaultEndpointsProtocol=https;AccountName=${funcStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcStorageAccount.listKeys().keys[0].value}'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          // value: functionWorkerRuntime
          value: 'dotnet'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
//*****************************************************************************************************


// Diagnostic Settings
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${functionAppName}'
  scope: FunctionApp
  properties: {
    workspaceId: workspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}
//*****************************************************************************************************


// Application Insights
//*****************************************************************************************************
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'Insights-${functionAppName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
//*****************************************************************************************************


// Private Endpoint
//*****************************************************************************************************
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if (!empty(pvtEndpointSubnetId)) {
  name: '${functionAppName}-PvtEndpoint'
  location: location
  properties: {
    subnet: {
      id: pvtEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${functionAppName}-PvtLink'
        properties:{
          privateLinkServiceId: FunctionApp.id
          groupIds:[
            'sites'
          ]
        }
      }
    ]
  }
}  
//*****************************************************************************************************
