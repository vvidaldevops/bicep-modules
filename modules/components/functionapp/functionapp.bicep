// Common Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@allowed([ 'set', 'setf', 'jmf', 'jmfe' ])
param bu string

@allowed([ 'poc', 'dev', 'qa', 'uat', 'prd' ])
param stage string

@maxLength(6)
param role string

@maxLength(2)
param appId string

@maxLength(6)
param appname string

@description('Resource Tags')
param tags object
//*****************************************************************************************************


// Parameters
//*****************************************************************************************************
// @description('The name of the function app that you wish to create.')
// param functionAppName string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param functionWorkerRuntime string

@description('ID from existing App Service Plan')
param farmId string

// var functionWorkerRuntime = runtime

// @description('The Storage Account tier')
// param funcStorageAccountTier string

// @description('The Storage Account tier')
// param funcStorageAccessTier string

param funcStorageAccountName string

// @secure()
// param funcStorageString object 
//*****************************************************************************************************

// Variables
//*****************************************************************************************************
// var storageKind = 'StorageV2'
//*****************************************************************************************************

/*
// Storage Account for FunctionApp
//*****************************************************************************************************
resource funcStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  // name: funcStorageAccountName
  name: toLower('funcstg${bu}${stage}${appname}${role}${appId}')
  location: location
  kind: storageKind
  sku: {
    name: funcStorageAccountTier
  }
  properties: {
    // Testing to create Function App
    allowBlobPublicAccess: true
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
  tags: tags
}

// output storageAccountId string = funcStorageAccount.id
// output storageAccountName string = funcStorageAccountName.name
// https://github.com/Azure/bicep/issues/2163 // https://stackoverflow.com/questions/47985364/listkeys-for-azure-function-app/47985475#47985475
//*****************************************************************************************************
*/


// Storage Account for FunctionApp
//*****************************************************************************************************
resource funcStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: funcStorageAccountName
}
//*****************************************************************************************************


// Function App
//*****************************************************************************************************
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: toLower('funcapp-${bu}-${stage}-${appname}-${role}-${appId}')
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
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcStorageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('funcapp-${bu}-${stage}-${appname}-${role}-${appId}')
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
          name: 'ContentStorageAccount'
          value: funcStorageAccountName
        }   
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
  tags: tags
}
//*****************************************************************************************************


// Diagnostic Settings
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${functionApp.name}'
  scope: functionApp
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
  // name: 'insights-${functionApp.name}'
  name: 'insights-function-check'
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
  name: '${functionApp.name}-PvtEndpoint'
  location: location
  properties: {
    subnet: {
      id: pvtEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${functionApp.name}-PvtLink'
        properties:{
          privateLinkServiceId: functionApp.id
          groupIds:[
            'sites'
          ]
        }
      }
    ]
  }
  tags: tags
}  
//*****************************************************************************************************
