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


// Parameters
//*****************************************************************************************************
// @description('Indicates whether a new App Service Plan should be created or using an existing one.')
@allowed([
  'new'
  'existing'
])
param newOrExistingAppServicePlan string

@description('The name of the App Service plan (When existing was selected.')
param existingAppServicePlanName string

param appServicePrefix string

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

// @description('Indicates whether AppServicePlan should be created or using an existing one.')
// param createNewAppServicePlan bool


//*****************************************************************************************************


// App Service Plan Resource 
//*****************************************************************************************************
// resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = if (createNewAppServicePlan) {
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = if (newOrExistingAppServicePlan == 'new') {
  name: toLower('${appServicePrefix}-${bu}-${stage}-${appname}-${role}-${appId}')
  location: location
  sku: {
    name: appServicePlanSkuName
  }
  tags: tags
}

resource appServicePlanExisting 'Microsoft.Web/serverfarms@2022-03-01' existing = if (newOrExistingAppServicePlan == 'existing') {
  name: existingAppServicePlanName
}

// @description('Output the farm id')
// output farmId string = appServicePlan.id

output farmId string = ((appServicePlanExisting == 'new') ? appServicePlan.id : appServicePlanExisting.id)

//*****************************************************************************************************


// Diagnostic Settings Resource
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
