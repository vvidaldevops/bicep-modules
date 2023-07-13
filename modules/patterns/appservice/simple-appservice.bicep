// Commom Variables
param location string

// App Service Plan Parameters
param appServicePlanName string
//param resourceGroupName string

// App Service parameters
param appServiceAppName string
// param appServicePlanId string

param workspaceId string


// Storage Account
//param storageAccountName string


// App Service Plan
module appServicePlanModule 'br:vidalabacr.azurecr.io/bicep/components/appserviceplan:v1' = {
  name: 'appServicePlanModule'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    workspaceId: workspaceId
  }
}
//output teste string = appServicePlanModule.outputs.appServicePlanId

// App Service
module appServiceModule 'br/ACR-LAB:bicep/components/appservice:v1' = {
  name: 'appServiceModule'
  // dependsOn: [
  //   appServicePlanModule
  // ]
  params: {
    appServiceAppName: appServiceAppName
    location: location
    farmId: appServicePlanModule.outputs.farmId
    //AppServicePlanID: appServicePlanId
    workspaceId: workspaceId
  }
}

/*
// Storage Account
module storageAccount 'br/ACR-LAB:bicep/components/storage:v1' = {
  name: 'storageAccount'
  //path: storageAccountModulePath
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}
*/

