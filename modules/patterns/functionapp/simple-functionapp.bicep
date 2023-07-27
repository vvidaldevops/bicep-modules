
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

@description('If the above option is = true, the existing App Service Plan ID should be provided.')
param appServicePlanId string

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string

// Function App Parameters
@description('The Name from Function App')
param functionAppName string

// Storage Account Parameters
@description('The Name from Storage Account')
param storageAccountName string

@description('The Storage Account tier')
param accountTier string

@description('The Storage Account tier')
param accessTier string

// @description('Resource Tags')
// param tags string
//*****************************************************************************************************


// App Service Plan
//*****************************************************************************************************
// module appServicePlanModule 'br:vidalabacr.azurecr.io/bicep/components/appserviceplan:v1.0.0' = {
  module appServicePlanModule '../../../modules/components/appserviceplan/appserviceplan.bicep' = {
    name: 'appServicePlanModule'
    params: {
      appServicePlanName: appServicePlanName
      appServicePlanSkuName: appServicePlanSkuName
      createNewAppServicePlan: createNewAppServicePlan
      location: location
      workspaceId: workspaceId
      // tags: tags
    }
  }  
//*****************************************************************************************************


// Function App
//*****************************************************************************************************
// module appServicePlanModule 'br:vidalabacr.azurecr.io/bicep/components/functionapp:v1.0.0' = {
module functionAppModule '../../../modules/components/functionapp/functionapp.bicep' ={
  name: 'functionAppModule'
  params: {
    functionAppName: functionAppName
    location: location
    storageAccountName: storageAccountName
    farmId: createNewAppServicePlan ? appServicePlanModule.outputs.farmId : appServicePlanId
    workspaceId: workspaceId
    pvtEndpointSubnetId: pvtEndpointSubnetId
    // tags: tags
  }
}
//*****************************************************************************************************


// Storage Account
//*****************************************************************************************************
// module storageAccountModule 'br:vidalabacr.azurecr.io/bicep/components/storage-account:v1.0.0' = {
  module storageAccountModule '../../../modules/components/storage-account/storage.bicep' = {
    name: 'storageAccountModule'
    params: {
      storageAccountName: storageAccountName
      location: location
      accountTier: accountTier
      accessTier: accessTier
      workspaceId: workspaceId
      // tags: tags
    }
  }
  //*****************************************************************************************************
