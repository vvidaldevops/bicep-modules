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
  tags: TagPocEnvironment
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
//*****************************************************************************************************


// Diagnostic Settings
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diagset-appsvc'
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
