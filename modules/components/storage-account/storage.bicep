// Common Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The business unit owning the resources.')
@allowed([ 'set', 'setf', 'jmf', 'jmfe' ])
param bu string

@description('The deployment stage where the resources.')
@allowed([ 'poc', 'dev', 'qa', 'uat', 'prd' ])
param stage string

@description('The role of the resource. Six (6) characters maximum')
@maxLength(6)
param role string

@description('A unique identifier for an environment. Two (2) characters maximum')
@maxLength(2)
param appId string

@description('The application name. Six (6) characters maximum')
@maxLength(6)
param appname string

@description('Resource Tags')
param tags object
//*****************************************************************************************************

// Storage Parameters
//*****************************************************************************************************
@description('Storage account prefix')
@maxLength(3)
param storagePrefix string

@description('The Storage Account tier')
param accountTier string

@description('The Storage Access tier')
param accessTier string

@description('The ID of Log Analytics Workspace.')
param workspaceId string
//*****************************************************************************************************

// Storage Variables
//*****************************************************************************************************
@description('Storage Kind')
var storageKind = 'StorageV2'

@description('Allow or Deny the storage public access. Default is false')
var allowBlobPublicAccess = false   

@description('Minimum TLS Vesion')
var minimumTlsVersion = 'TLS1_2'

@description('HTTP Only?')
var HttpsTrafficOnly = true
//*****************************************************************************************************


// Storage Account Resource
//*****************************************************************************************************
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  // name: storageAccountName
  name: toLower('${storagePrefix}${bu}${stage}${appname}${role}${appId}')
  location: location
  kind: storageKind
  sku: {
    name: accountTier
  }
  properties: {
    allowBlobPublicAccess: allowBlobPublicAccess
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
    minimumTlsVersion: minimumTlsVersion
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: HttpsTrafficOnly 
  }
  tags: tags
}
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
//*****************************************************************************************************


// Diagnostic Settings Resource
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
