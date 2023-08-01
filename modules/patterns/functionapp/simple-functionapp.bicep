// Common Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string

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

// App Service Plan Parameters
//*****************************************************************************************************
@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string

@description('Indicates whether AppServicePlan should be created or using an existing one.')
param createNewFcnServicePlan bool

@description('If the above option is = true, the existing App Service Plan ID should be provided.')
param existingFcnServicePlanId string
//*****************************************************************************************************

// Function App Parameters
//*****************************************************************************************************
@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string

@description('The name from Function Service Endpoint VNET.')
param funcServiceEndpointVnetName string

@description('The name from Function Service Endpoint Subnet.')
param funcServiceEndpointSubnetName string

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param functionWorkerRuntime string
//*****************************************************************************************************

// Storage Account for Function App Parameters
//*****************************************************************************************************
@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param funcStorageAccountTier string

@description('The name from Function Storage Service Endpoint VNET.')
param funcStgServiceEndpointvNetName string

@description('The name from Function Storage Service Endpoint Subnet.')
param funcStgServiceEndpointSubnetName string
//*****************************************************************************************************


// App Service Plan Module
//*****************************************************************************************************
module appServicePlanModule 'br/ACR-LAB:bicep/components/appserviceplan:v1.0.0' = {
//module appServicePlanModule '../../components/appserviceplan/appserviceplan.bicep' = {
  name: 'appServicePlanModule'
  params: {
    location: location
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname
    appServicePrefix: 'funcsvcplan'
    appServicePlanSkuName: appServicePlanSkuName
    createNewAppServicePlan: createNewFcnServicePlan
    workspaceId: workspaceId
    tags: tags
  }
}  
//*****************************************************************************************************


// Storage Account for Function App Module
//*****************************************************************************************************
module functionStorageAccountModule 'br/ACR-LAB:bicep/components/storage-account:v1.0.0' = {
//module functionStorageAccountModule '../../components/storage-account/storage.bicep' = {
  name: 'funcStorageAccountModule'
  params: {
    location: location
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname
    serviceEndpointVnetName: funcStgServiceEndpointvNetName
    serviceEndpointSubnetName: funcStgServiceEndpointSubnetName
    storagePrefix: 'fcn'
    accountTier: funcStorageAccountTier
    accessTier: 'Hot'
    workspaceId: workspaceId
    tags: tags
  }
}
//*****************************************************************************************************


// Function App Module
//*****************************************************************************************************
module functionAppModule 'br/ACR-LAB:bicep/components/functionapp:v1.0.0' = {
//module functionAppModule '../../components/functionapp/functionapp.bicep' = {
  name: 'functionAppModule'
  params: {
    location: location
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname
    serviceEndpointVnetName: funcServiceEndpointVnetName
    serviceEndpointSubnetName: funcServiceEndpointSubnetName
    farmId: createNewFcnServicePlan ? appServicePlanModule.outputs.farmId : existingFcnServicePlanId
    functionWorkerRuntime: functionWorkerRuntime
    funcStorageAccountName: functionStorageAccountModule.outputs.storageAccountName
    workspaceId: workspaceId
    pvtEndpointSubnetId: pvtEndpointSubnetId
    tags: tags
  }
}
//*****************************************************************************************************
