@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the App Service plan.')
param appServicePlanName string

//@description('The name of the App Service plan SKU.')
//param appServicePlanSkuName string

param workspaceId string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'Basic'
  }
}
output appServicePlanId string = appServicePlan.id

// output appServiceAppHostName string = appServiceApp.properties.defaultHostName


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
  name: 'diagset-appsvcplan'
  scope: appServicePlan
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AppServiceEnvironmentPlatformLogs'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}
