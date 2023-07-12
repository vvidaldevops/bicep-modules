param storageAccountName string
param location string
// param resourceGroupName string
param accountTier string
param workspaceId string


// Storage Account
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


// Diagnostic Settings
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diagset-lab'
  scope: storageAccount
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}
