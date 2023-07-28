// Common Parameters
//*****************************************************************************************************
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
// @description('The Azure region into which the resources should be deployed.')
// param location string

// @description('The name of the App Service plan.')
// param appServicePlanName string

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

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param functionWorkerRuntime string


// Storage Account Parameters
// @description('The Name from Storage Account')
// param storageAccountName string

@description('The Storage Account tier')
param funcStorageAccountTier string

@description('The Storage Account tier')
param funcStorageAccessTier string
//*****************************************************************************************************


// App Service Plan
//*****************************************************************************************************
// module appServicePlanModule 'br:vidalabacr.azurecr.io/bicep/components/appserviceplan:v1.0.0' = {
  module appServicePlanModule '../../../modules/components/appserviceplan/appserviceplan.bicep' = {
    name: 'appServicePlanModule'
    params: {
      bu: bu
      stage: stage
      role: role
      appId: appId
      appname: appname
      // appServicePlanName: appServicePlanName
      appServicePlanSkuName: appServicePlanSkuName
      createNewAppServicePlan: createNewAppServicePlan
      // location: location
      workspaceId: workspaceId
      tags: tags
    }
  }  
//*****************************************************************************************************


// Storage Account for Function App
// https://github.com/Azure/bicep/issues/2163 // https://stackoverflow.com/questions/47985364/listkeys-for-azure-function-app/47985475#47985475
//*****************************************************************************************************

// module storageAccountModule 'br:vidalabacr.azurecr.io/bicep/components/storage-account:v1.0.0' = {
  module functionStorageAccountModule '../../../modules/components/storage-account/storage.bicep' = {
    name: 'funcStorageAccountModule'
    params: {
      // storageAccountName: 'func-${storageAccountName}'
      // location: location
      accountTier: accountTier
      accessTier: accessTier
      workspaceId: workspaceId
      tags: tags
    }
  }
//*****************************************************************************************************


// Function App
//*****************************************************************************************************
module functionAppModule 'br:vidalabacr.azurecr.io/bicep/components/functionapp:v1.0.0' = {
// module functionAppModule '../../../modules/components/functionapp/functionapp.bicep' ={
  name: 'functionAppModule'
  params: {
    // functionAppName: functionAppName
    // location: location
    // storageAccountName: storageAccountName
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname    
    farmId: createNewAppServicePlan ? appServicePlanModule.outputs.farmId : appServicePlanId
    functionWorkerRuntime: functionWorkerRuntime
    funcStorageAccountTier: funcStorageAccountTier
    funcStorageAccessTier: funcStorageAccessTier
    funcStorageAccountName: functionStorageAccountModule.outputs.storageAccountName
    workspaceId: workspaceId
    pvtEndpointSubnetId: pvtEndpointSubnetId
    tags: tags
  }
}
//*****************************************************************************************************
