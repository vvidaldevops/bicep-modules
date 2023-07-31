// Common Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The business unit owning the resources.')
@allowed([ 'set', 'setf', 'jmf', 'jmfe' ])
param bu string

@description('The deployment stage where the resources.')
@allowed([ 'poc', 'dev', 'qa', 'uat', 'prd' ])
param stage string

@description('The role of the resource. Six (6) characters maximum')
@maxLength(6)
param role string

@description('A unique identifier for an environment. Two (2) characters maximum')
@maxLength(2)
param appId string

@description('The application name. Six (6) characters maximum')
@maxLength(6)
param appname string

@description('Resource Tags')
param tags object
//*****************************************************************************************************

// Function App Parameters
//*****************************************************************************************************
@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string

@description('The name from Service Endpoint VNET.')
param serviceEndpointVnetName string

@description('The name from Service Endpoint Subnet.')
param serviceEndpointSubnetName string

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param functionWorkerRuntime string

@description('ID from existing App Service Plan')
param farmId string

@description('The storage account name for Function App')
param funcStorageAccountName string
//*****************************************************************************************************

// Function App Variables
//*****************************************************************************************************
var httpsOnly = true
var publicNetworkAccess = 'Disabled'
var ftpsState = 'FtpsOnly'
//*****************************************************************************************************

// Data Subnet to configure Service Endpoint
//*****************************************************************************************************
resource vNet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: serviceEndpointVnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
   name : serviceEndpointSubnetName
   parent: vNet
}
//*****************************************************************************************************

// Storage Account for FunctionApp Resource
//*****************************************************************************************************
resource funcStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: funcStorageAccountName
}
//*****************************************************************************************************


// Function App Resource
//*****************************************************************************************************
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: toLower('funcapp-${bu}-${stage}-${appname}-${role}-${appId}')
  location: location
  kind: 'functionapp'
  properties: {
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkSubnetId: subnet.id
    serverFarmId: farmId
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
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
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
      ftpsState: ftpsState
      minTlsVersion: '1.2'
    }
    httpsOnly: httpsOnly
  }
  tags: tags
}
//*****************************************************************************************************


// Diagnostic Settings Resource
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${functionApp.name}'
  scope: functionApp
  properties: {
    workspaceId: workspaceId
    metrics: [
      {
        category: 'AllMetrics'
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


// Application Insights Resource
//*****************************************************************************************************
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  // name: 'insights-${functionApp.name}'
  name: 'insights-functionapp'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
//*****************************************************************************************************


// Private Endpoint Resource
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
