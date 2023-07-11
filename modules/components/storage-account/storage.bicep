param storageAccountName string
param location string
// param resourceGroupName string
param accountTier string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: accountTier
  }
  properties: {
    allowBlobPublicAccess: false
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
// output storageAccountConnectionString string = listKeys(resourceId(resourceGroupName, 'Microsoft.Storage/storageAccounts/blobServices', storageAccountName), '2021-06-01').keys[0].value
//
