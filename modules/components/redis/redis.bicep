// Common Parameters
//*****************************************************************************************************
@description('(Require) The Azure region into which the resources should be deployed.')
param location string

@description('(Require) The deployment stage where the resources.')
@allowed([
   'poc'
   'dev'
   'qa' 
   'uat' 
   'prd' 
])
param stage string

@description('(Require) Resource Tags')
param tags object

@description('(Require) The business unit owning the resources.')
@allowed([
   'set' 
   'setf' 
   'jmf'
   'jmfe' 
])
param businessUnit string
//*****************************************************************************************************


// Required Parameters - Azure Cache for Redis
//*****************************************************************************************************
@description('(Require) The application name. Nine (9) characters maximum')
@maxLength(9)
param redisName string

@description('(Require) The role of the resource. Two (2) characters maximum')
@maxLength(2)
param redisAppId string

@description('(Require) The role of the resource. Four (4) characters maximum')
@maxLength(4)
param redisRole string
//*****************************************************************************************************

@description('The type of Redis cache to deploy. Valid values: (Basic, Standard, Premium)')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param redisSkuName string = 'Standard'

@description('(The SKU family to use. Valid values: (C, P). (C = Basic/Standard, P = Premium (required)).')
@allowed([
  'C'
  'P'
])
param redisSkuFamily string = 'P'

// Predefined Cache for Redis Parameters

// @description('the name of the Azure Redis Cache')
// param redisCacheName string = 'azureCacheForRedis'

@description('The size of the Redis cache to deploy. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4).')
@allowed([
  1
  2 
  3 
  4
])
param redisCapacity int = 1

@description('Specify a boolean value that indicates whether to allow access via non-SSL ports.')
param enableNonSslPort bool = false

// @description('Specify a boolean value that indicates whether diagnostics should be saved to the specified storage account.')
// param diagnosticsEnabled bool = false

@description('The identity of the resource.')
@allowed([
  'SystemAssigned'
  'UserAssigned'
  'UserAssigned, SystemAssigned'
])
param redisIdentityType string = 'SystemAssigned'

@description('Whether or not public endpoint access is allowed for this cache. Value is optional but if passed in, must be "Enabled" or "Disabled". If "Disabled", private endpoints are the exclusive access method. Default value is "Enabled"')
@allowed([
  'Enabled'
  'Disabled'
])
param redisPublicNetworkAccess string = 'Disabled'

@description('The number of replicas to be created per primary.    ')
param redisReplicasPerMaster int = 2

@description('The number of replicas to be created per primary.    ')
param redisReplicasPerPrimary int = 2

@description('The number of shards to be created on a Premium Cluster Cache.    ')
param redisShardCount int = 2

@description('Static IP address. Optionally, may be specified when deploying a Redis cache inside an existing Azure Virtual Network; auto assigned by default.')
param redisStaticIP string = ''

@description('The full resource ID of a subnet in a virtual network to deploy the Redis cache in. Example format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/Microsoft.{Network,ClassicNetwork}/VirtualNetworks/vnet1/subnets/subnet1')
param redisSubnetId string = ''

@description('A dictionary of tenant settings')
param redisTenantSettings object = {}

// @description('A list of availability zones denoting where the resource needs to come from.')
// @allowed([
//   ''
//   ''
// ])
// param redisZones string = ''

@description('Specifies the frequency for creating rdb backup in minutes. Valid values: (15, 30, 60, 360, 720, 1440)')
@allowed([
  '15' 
  '30' 
  '60' 
  '360' 
  '720' 
  '1440'
])
param redisRdbBackupFrequency string = '60'

// @description('The storage account connection string for storing rdb file')
param redisRddstorageconnectionstring string = ''

// Predefined Cache for Redis Variables
var redisMintlsversion = '1.2'
//*****************************************************************************************************************

// Redis Cache Optional Parameters
//*****************************************************************************************************************
@description('(Require) The ID of Log Analytics Workspace.')
param workspaceId string = ''
//*****************************************************************************************************************

// Redis Cache Resource
//*****************************************************************************************************************
resource cacheForRedis 'Microsoft.Cache/redis@2022-06-01' = {
  name: toLower('redis-${businessUnit}-${stage}-${redisName}-${redisAppId}-${redisRole}')
  location: location
  identity: {
    type: redisIdentityType
  }
  properties: {
    enableNonSslPort: enableNonSslPort
    minimumTlsVersion: redisMintlsversion
    publicNetworkAccess: redisPublicNetworkAccess
    redisConfiguration: {
      'aof-backup-enabled': 'disabled'
      'aof-storage-connection-string-0': 'string'
      'aof-storage-connection-string-1': 'string'
      authnotrequired: 'string'
      'maxfragmentationmemory-reserved': 'string'
      'maxmemory-delta': 'string'
      'maxmemory-policy': 'string'
      'maxmemory-reserved': 'string'
      'preferred-data-persistence-auth-method': 'SAS'
      'rdb-backup-enabled': 'disabled'
      'rdb-backup-frequency': redisRdbBackupFrequency
      // 'rdb-backup-max-snapshot-count': 'string'
      'rdb-storage-connection-string': redisRddstorageconnectionstring
    }
    redisVersion: ''
    replicasPerMaster: redisReplicasPerMaster
    replicasPerPrimary: redisReplicasPerPrimary
    shardCount: redisShardCount
    sku: {
      capacity: redisCapacity
      family: redisSkuFamily
      name: redisSkuName
    }
    staticIP: redisStaticIP
    subnetId: redisSubnetId
    tenantSettings: redisTenantSettings
  }
  //zones: redisZones
  tags: tags
}
//*****************************************************************************************************************


// // Diagnostic Settings Resource
// //*****************************************************************************************************************
// resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(workspaceId)) {
//   name: 'diag-${cacheForRedis.name}'
//   scope: cacheForRedis
//   properties: {
//     workspaceId: workspaceId
//     logs: [
//       {
//         category: 'AppServiceHTTPLogs'
//         enabled: true
//       }
//     ]
//   }
// }
// //*****************************************************************************************************************
