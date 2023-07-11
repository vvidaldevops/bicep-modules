param storageAccountName string
param location string
param accountTier string

module storageAccountModule2 'br:vidalabacr.azurecr.io/bicep/components/storage-account:v1' = {
  name: 'storageAccountModule2'
  params: {
    storageAccountName: storageAccountName
    location: location
    accountTier: accountTier
  }
}

// output storageAccountId string = storageAccountModule2.outputs.storageAccountId
//output storageAccountConnectionString string = storageAccountModule.outputs.storageAccountConnectionString
