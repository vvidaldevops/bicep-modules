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

// App Service Parameters
//*****************************************************************************************************
// @description('The name of the App Service app.')
// param appServiceAppName string

@description('The ID of App Service Plan.')
param farmId string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string
//*****************************************************************************************************

// App Service Variables
//*****************************************************************************************************
var httpsOnly = true
//*****************************************************************************************************


// App Service
//*****************************************************************************************************
resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: toLower('appsvc-${bu}-${stage}-${appname}-${role}-${appId}')
  location: location
  properties: {
    serverFarmId: farmId
    httpsOnly: httpsOnly
  }
  tags: tags
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
//*****************************************************************************************************


// Private Endpoint
//*****************************************************************************************************
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if (!empty(pvtEndpointSubnetId)) {
  name: 'pvtEndpoint-${appServiceApp.name}'
  location: location
  properties: {
    subnet: {
      id: pvtEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pvtLink-${appServiceApp.name}'
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


// Diagnostic Settings
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


// Application Insights
//*****************************************************************************************************
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'insights-${appServiceApp.name}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
//*****************************************************************************************************
