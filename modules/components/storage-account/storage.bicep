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


// Storage Account
//*****************************************************************************************************
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  // tags: tags
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
//*****************************************************************************************************


// Diagnostic Settings
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diagset-stg'
  scope: storageAccount
  properties: {
    workspaceId: workspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}
//*****************************************************************************************************
