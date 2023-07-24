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

// @description('Indicates whether a Privante endpoint should be created.')
// param useAppPrivateEndpoint bool

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string

// @description('Resource Tags')
// param tags string
//*****************************************************************************************************


// App Service
//*****************************************************************************************************
resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: farmId
    httpsOnly: true
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
  name: 'diagset-${appServiceAppName}'
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
