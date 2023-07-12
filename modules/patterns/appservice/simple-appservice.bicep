// To be TESTED !!!
// Commom Variables
param location string

// App Service Plan Parameters
param appServicePlanName string
//param resourceGroupName string

// App Service parameters
param appServiceAppName string
//param AppServicePlan.id string

param workspaceId string

// Storage Account
//param storageAccountName string


// App Service Plan
module appServicePlan 'br:vidalabacr.azurecr.io/bicep/components/appserviceplan:v1' = {
  name: 'appServicePlan'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    workspaceId: workspaceId
  }
}

// App Service
module appServiceApp 'br/ACR-LAB:bicep/components/appservice:v1' = {
  name: 'appServiceApp'
  params: {
    appServiceAppName: appServiceAppName
    location: location
    AppServicePlanID: appServicePlan.id
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

