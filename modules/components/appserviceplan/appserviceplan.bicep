// Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the App Service plan.')
param appServicePlanName string

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('Indicates whether AppServicePlan should be created or using an existing one.')
param createNewAppServicePlan bool

// @description('Resource Tags')
// param tags string
//*****************************************************************************************************


// App Service Plan
//*****************************************************************************************************
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = if (createNewAppServicePlan) {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

@description('Output the farm id')
output farmId string = appServicePlan.id
//*****************************************************************************************************


// Diagnostic Settings
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diagset-${appServicePlanName}'
  scope: appServicePlan
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
