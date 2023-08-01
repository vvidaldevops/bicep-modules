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

// App Service Parameters
//*****************************************************************************************************
@description('The ID of App Service Plan.')
param farmId string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string

@description('The name from Service Endpoint Subnet.')
param appServiceEndpointVnetName string

@description('The name from Service Endpoint Subnet.')
param appServiceEndpointSubnetName string
//*****************************************************************************************************

// App Service Variables
//*****************************************************************************************************
var httpsOnly = true
var publicNetworkAccess = 'Disabled'
var ftpsState = 'FtpsOnly'
//*****************************************************************************************************

// Data Subnet to configure Service Endpoint
//*****************************************************************************************************
resource vNet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: appServiceEndpointVnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
   name : appServiceEndpointSubnetName
   parent: vNet
}
//*****************************************************************************************************


// App Service Resource
//*****************************************************************************************************
resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: toLower('appsvc-${bu}-${stage}-${appname}-${role}-${appId}')
  location: location
  kind: 'app'
  properties: {
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkSubnetId: subnet.id
    serverFarmId: farmId
    httpsOnly: httpsOnly
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
      ftpsState: ftpsState
    }
  }
  tags: tags
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
//*****************************************************************************************************


// Private Endpoint Resource
//*****************************************************************************************************
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if (!empty(pvtEndpointSubnetId)) {
  name: 'pvtendpoint-${appServiceApp.name}'
  location: location
  properties: {
    subnet: {
      id: pvtEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pvtlink-${appServiceApp.name}'
        properties:{
          privateLinkServiceId: appServiceApp.id
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


// Diagnostic Settings Resource
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${appServiceApp.name}'
  scope: appServiceApp
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
          }
        }
        {
          category: 'AppServiceIPSecAuditLogs'
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
  name: 'insights-appservice'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
//*****************************************************************************************************
