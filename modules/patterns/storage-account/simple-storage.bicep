// Parameters
param storageAccountName string
param location string
param accountTier string

//@description('The ID of Log Analytics Workspace.')
//param workspaceId string

//-----------------------------------------------------------------------------------------------

module storageAccountModule2 'br:vidalabacr.azurecr.io/bicep/components/storage-account:v1' = {
  name: 'storageAccountModule2'
  params: {
    storageAccountName: storageAccountName
    location: location
    accountTier: accountTier
    //workspaceId: workspaceId
  }
}
