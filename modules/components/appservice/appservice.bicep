// Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the App Service app.')
param appServiceAppName string

@description('The ID of App Service Plan.')
param farmId string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string

// @description('Resource Tags')
// param tags string
//*****************************************************************************************************


// Variables
//*****************************************************************************************************
var httpsOnly = true
//*****************************************************************************************************

// App Service
//*****************************************************************************************************
resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: farmId
    httpsOnly: httpsOnly
  }
  // tags: TagPocEnvironment
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
//*****************************************************************************************************


// Private Endpoint
//*****************************************************************************************************
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = if (!empty(pvtEndpointSubnetId)) {
  name: '${appServiceAppName}-PvtEndpoint'
  location: location
  properties: {
    subnet: {
      id: pvtEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${appServiceAppName}-PvtLink'
        properties:{
          privateLinkServiceId: appServiceApp.id
          groupIds:[
            'sites'
          ]
        }
      }
    ]
  }
}  
//*****************************************************************************************************


// Diagnostic Settings
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${appServiceAppName}'
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


/*
// Application Insights
//*****************************************************************************************************
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = if (enableAppInsights) {
  name: 'Insights-${functionAppName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
//*****************************************************************************************************
*/
