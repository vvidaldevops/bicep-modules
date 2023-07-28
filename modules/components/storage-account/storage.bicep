// Common Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@allowed([ 'set', 'setf', 'jmf', 'jmfe' ])
param bu string

@allowed([ 'poc', 'dev', 'qa', 'uat', 'prd' ])
param stage string

@maxLength(6)
param role string

@maxLength(2)
param appId string

@maxLength(6)
param appname string

@description('Resource Tags')
param tags object
//*****************************************************************************************************

// Parameters
//*****************************************************************************************************
// @description('The Name from Storage Account')
// param storageAccountName string

@description('The Storage Account tier')
param accountTier string

@description('The Storage Account tier')
param accessTier string

@description('The ID of Log Analytics Workspace.')
param workspaceId string
//*****************************************************************************************************


// Storage Account
//*****************************************************************************************************
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  // name: storageAccountName
  name: toLower('stg${bu}${stage}${appname}${role}${appId}')
  location: location
  kind: 'StorageV2'
  sku: {
    name: accountTier
  }
  properties: {
    allowBlobPublicAccess: false
    accessTier: accessTier
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }    
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true 
  }
  tags: tags
}
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name

// output primaryKey string = storageAccount.listKeys().keys[0].value 
// https://github.com/Azure/bicep/issues/2163 // https://stackoverflow.com/questions/47985364/listkeys-for-azure-function-app/47985475#47985475
//*****************************************************************************************************


// Diagnostic Settings
//*****************************************************************************************************
resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${storageAccount.name}'
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
