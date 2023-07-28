// Common Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string

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

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string

// @description('The name of the App Service.')
// param appServiceAppName string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

@description('Indicates whether AppServicePlan should be created or using an existing one.')
param createNewAppServicePlan bool

@description('If the above option is = true, the existing App Service Plan ID should be provided.')
param appServicePlanId string

@description('The ID from Private Endpoint Subnet.')
param pvtEndpointSubnetId string


//*****************************************************************************************************


// App Service Plan
//*****************************************************************************************************
module appServicePlanModule 'br:vidalabacr.azurecr.io/bicep/components/appserviceplan:v1.0.0' = {
//  module appServicePlanModule '../../../modules/components/appserviceplan/appserviceplan.bicep' = {
  name: 'appServicePlanModule'
  params: {
    location: location
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname
    // appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    createNewAppServicePlan: createNewAppServicePlan
    workspaceId: workspaceId
    tags: tags
  }
}
//*****************************************************************************************************


// App Service
//*****************************************************************************************************
// module appServiceModule 'br/ACR-LAB:bicep/components/appservice:v1.0.0' = {
  module appServiceModule '../../../modules/components/appservice/appservice.bicep' = {
  name: 'appServiceModule'
  params: {
    location: location
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname
    // appServiceAppName: appServiceAppName
    farmId: createNewAppServicePlan ? appServicePlanModule.outputs.farmId : appServicePlanId
    workspaceId: workspaceId
    pvtEndpointSubnetId: pvtEndpointSubnetId
    tags: tags
  }
}
//*****************************************************************************************************



