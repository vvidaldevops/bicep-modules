// Parameters
//*****************************************************************************************************
@description('The Name from Storage Account')
param storageAccountName string

@description('The Azure region into which the resources should be deployed.')
param location string

@description('The Storage Account tier')
param accountTier string

@description('The ID of Log Analytics Workspace.')
param workspaceId string

// @description('Resource Tags')
// param tags string
//*****************************************************************************************************


// Storage Account Module
//*****************************************************************************************************
module storageAccountModule 'br:vidalabacr.azurecr.io/bicep/components/storage-account:v1' = {
  name: 'storageAccountModule'
  params: {
    storageAccountName: storageAccountName
    location: location
    accountTier: accountTier
    workspaceId: workspaceId
    // tags: tags
  }
}
//*****************************************************************************************************
