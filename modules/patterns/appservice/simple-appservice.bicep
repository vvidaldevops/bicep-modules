// Parameters
@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the App Service plan.')
param appServicePlanName string

@description('The name of the App Service.')
param appServiceAppName string

@description('The ID of Log Analytics Workspace.')
param workspaceId string


//-----------------------------------------------------------------------------------------------

// App Service Plan
module appServicePlanModule 'br:vidalabacr.azurecr.io/bicep/components/appserviceplan:v2' = {
//  module appServicePlanModule '../../components/appserviceplan/appserviceplan.bicep' = {
  name: 'appServicePlanModule'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    workspaceId: workspaceId
  }
}

//-----------------------------------------------------------------------------------------------

// App Service
module appServiceModule 'br/ACR-LAB:bicep/components/appservice:v2' = {
//  module appServiceModule '../../components/appservice/appservice.bicep' = {
  name: 'appServiceModule'
  params: {
    appServiceAppName: appServiceAppName
    location: location
    farmId: appServicePlanModule.outputs.farmId
  }
}
