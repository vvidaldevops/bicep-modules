@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the App Service app.')
param appServiceAppName string

param appServicePlanId string
param workspaceId string

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName

// output stringOutput string = deployment().name
// output integerOutput int = length(environment().authentication.audiences)
// output booleanOutput bool = contains(deployment().name, 'demo')
// output arrayOutput array = environment().authentication.audiences
// output objectOutput object = subscription()
// var user = {
//   'user-name': 'Test Person'
// }
// output stringOutput string = user['user-name']

// Diagnostic Settings
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
    ]
  }
}
