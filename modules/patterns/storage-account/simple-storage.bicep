// Parameters
param storageAccountName string
param location string
param accountTier string

//@description('The ID of Log Analytics Workspace.')
param workspaceId string

//-----------------------------------------------------------------------------------------------

module storageAccountModule 'br:vidalabacr.azurecr.io/bicep/components/storage-account:v1' = {
  name: 'storageAccountModule'
  params: {
    storageAccountName: storageAccountName
    location: location
    accountTier: accountTier
    workspaceId: workspaceId
  }
}
