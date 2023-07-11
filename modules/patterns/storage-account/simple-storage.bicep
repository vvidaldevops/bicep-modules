param storageAccountName string
param location string
param accountTier string

module storageAccountModule 'br:vidalabacr.azurecr.io/bicep/components/storage-account:v1' = {
  //name: 'storageAccountModule'
  params: {
    storageAccountName: storageAccountName
    location: location
    accountTier: accountTier
  }
}

output storageAccountId string = storageAccountModule.outputs.storageAccountId
//output storageAccountConnectionString string = storageAccountModule.outputs.storageAccountConnectionString
//
