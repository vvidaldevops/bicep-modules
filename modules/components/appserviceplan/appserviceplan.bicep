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
// @description('The name of the App Service plan.')
// param appServicePlanName string

param appServicePrefix string

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('Indicates whether AppServicePlan should be created or using an existing one.')
param createNewAppServicePlan bool
//*****************************************************************************************************


// App Service Plan
//*****************************************************************************************************
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = if (createNewAppServicePlan) {
  name: toLower('${appServicePrefix}-${bu}-${stage}-${appname}-${role}-${appId}')
  location: location
  sku: {
    name: appServicePlanSkuName
  }
  tags: tags
}

@description('Output the farm id')
output farmId string = appServicePlan.id
//*****************************************************************************************************


// Diagnostic Settings
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${appServicePlan.name}'
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
