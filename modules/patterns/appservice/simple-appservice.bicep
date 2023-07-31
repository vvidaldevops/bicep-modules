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
@allowed([
  'new'
  'existing'
])
param newOrExistingAppServicePlan string

@description('The name of the App Service plan (When existing was selected.')
param existingAppServicePlanName string

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string
//*****************************************************************************************************

// App Service Parameters
//*****************************************************************************************************
@description('The ID of Log Analytics Workspace.')
param workspaceId string

// @description('Indicates whether AppServicePlan should be created or using an existing one.')
// param createNewAppServicePlan bool

// @description('If the above option is = true, the existing App Service Plan ID should be provided.')
// param appServicePlanId string

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string
//*****************************************************************************************************


// App Service Plan Module
//*****************************************************************************************************
// module appServicePlanModule 'br/ACR-LAB:bicep/components/appserviceplan:v1.0.0' = {
module appServicePlanModule '../../components/appserviceplan/appserviceplan.bicep' = {
  name: 'appServicePlanModule'
  params: {
    location: location
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname
    appServicePrefix: 'appsvcplan'
    appServicePlanSkuName: appServicePlanSkuName
    // createNewAppServicePlan: createNewAppServicePlan
    newOrExistingAppServicePlan: newOrExistingAppServicePlan
    existingAppServicePlanName: existingAppServicePlanName
    workspaceId: workspaceId
    tags: tags
  }
}
//*****************************************************************************************************


// App Service Module
//*****************************************************************************************************
// module appServiceModule 'br/ACR-LAB:bicep/components/appservice:v1.0.0' = {
module appServiceModule '../../components/appservice/appservice.bicep' = {
  name: 'appServiceModule'
  params: {
    location: location
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname
    // farmId: createNewAppServicePlan ? appServicePlanModule.outputs.farmId : appServicePlanId
    farmId: appServicePlanModule.outputs.farmId
    workspaceId: workspaceId
    pvtEndpointSubnetId: pvtEndpointSubnetId
    tags: tags
  }
}
//*****************************************************************************************************



