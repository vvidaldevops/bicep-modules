// To be TESTED !!!
// Commom Variables
param location string

// App Service Plan Parameters
param appServicePlanName string
//param resourceGroupName string

// App Service parameters
param appServiceAppName string
param AppServicePlanID string

// Storage Account
param storageAccountName string

// App Service Plan
module appServicePlan 'br:vidalabacr.azurecr.io/bicep/components/appserviceplan:v1' = {
  name: 'appServicePlan'
  params: {
    appServicePlanName: appServicePlanName
    //resourceGroupName: resourceGroupName
    location: location
  }
}

// App Service
module appServiceApp 'br:vidalabacr.azurecr.io/bicep/components/appservice:v1' = {
  name: 'appServiceApp'
  location: location
  params: {
    appServiceAppName: appServiceAppName
    AppServicePlanID: AppServicePlanID
  }
}

// Storage Account
module storageAccount 'br/ACR-LAB:bicep/components/storage:v1' = {
  name: 'storageAccount'
  //path: storageAccountModulePath
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}


