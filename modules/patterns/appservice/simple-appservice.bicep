// Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the App Service plan.')
param appServicePlanName string

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string

@description('The name of the App Service.')
param appServiceAppName string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('Indicates whether an existing AppServicePlan should be used.')
param useExistingAppServicePlan bool

@description('If the above option is = true, the existing App Service Plan ID should be provided.')
param appServicePlanId string

@description('Indicates whether a Privante endpoint should be created.')
param useAppPrivateEndpoint bool

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string

// @description('Resource Tags')
// param tags string
//*****************************************************************************************************


// App Service Plan
//*****************************************************************************************************
module appServicePlanModule 'br:vidalabacr.azurecr.io/bicep/components/appserviceplan:v1.0.0' = {
  name: 'appServicePlanModule'
  params: {
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
    workspaceId: workspaceId
    // tags: tags
  }
}
//*****************************************************************************************************


// App Service
//*****************************************************************************************************
module appServiceModule 'br/ACR-LAB:bicep/components/appservice:v1.1.0' = {
  name: 'appServiceModule'
  params: {
    appServiceAppName: appServiceAppName
    location: location
    farmId: useExistingAppServicePlan ? appServicePlanId : appServicePlanModule.outputs.farmId
    workspaceId: workspaceId
    useAppPrivateEndpoint: useAppPrivateEndpoint ? pvtEndpointSubnetId : ''
    // tags: tags
  }
}
//*****************************************************************************************************



