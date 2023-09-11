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
param business_unit string
//*****************************************************************************************************


// Require Parameters Sql Server
//*****************************************************************************************************
param sqlserver_tenantid string

@description('(Require) The application name. Six (6) characters maximum')
@maxLength(6)
param sqlserver_appname string

@description('(Require) The role of the resource. Six (6) characters maximum')
@maxLength(6)
param sqlserver_role string

// @description('(Require)The administrator password of the SQL logical server.')
// @secure()
// param sqlserver_admLoginPassword string

// @description('The administrator username of the SQL logical server.')
// @secure()
// param sqlserver_admLogin string
//*****************************************************************************************************

// Storage Account Optional Parameters
//*****************************************************************************************************
@description('(Optional) Type of managed service identity.')
@allowed([
  'SystemAssigned'
  'SystemAssigned,UserAssigned'
  'UserAssigned'
])
param sqlserver_identity_type string = 'SystemAssigned'

@description('(Optional) Type of the sever administrator.')
@allowed([
  'ActiveDirectory'
  ])
param sqlserver_administratorType string = 'ActiveDirectory'

@description('(Optional) Azure Active Directory only Authentication enabled.')
param sqlserver_azureADOnlyAuthentication bool = true

@description('(Optional) Login name of the server administrator.')
param sqlserver_login string = ''

@description('(Optional) Principal Type of the sever administrator.')
@allowed([
'Group'
])
param sqlserver_principalType string = 'Group'

@description('(Optional) SID (object ID) of the server administrator.')
param sqlserver_groupsid string = ''

@description('(Optional) SID (object ID) of the server administrator.')
param sqlserver_UserAssignedIdentityId string = ''

@description('(Optional) 	Whether or not to restrict outbound network access for this server. Value is optional but if passed in, must be Enabled or Disabled')
param sqlserver_restrictOutboundNetworkAccess string = 'Disabled'

@description('(Required) The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). Changing this forces a new resource to be created.')
param sqlserver_version string = '12.0'

param sqlserver_auditActionsAndGroups array = [
  'BATCH_COMPLETED_GROUP'
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
]

param sqlserver_retentionDays int = 7
//*****************************************************************************************************


// Predefined Sql Server Variables
//*****************************************************************************************************
var sqlserver_publicNetworkAccess = 'Disabled'
var sqlserver_TlsVersion = '1.2'
//*****************************************************************************************************

resource userAssigned 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (sqlserver_identity_type != 'SystemAssigned') {
  name: toLower('mi-${business_unit}-${stage}-${sqlserver_appname}')
}

// Sql Server Resource
//*****************************************************************************************************
resource SqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: toLower('sql-${business_unit}-${stage}-${sqlserver_appname}-${sqlserver_role}')
  location: location
  identity: {
    type: sqlserver_identity_type
    userAssignedIdentities: (sqlserver_identity_type == 'UserAssigned' || sqlserver_identity_type == 'SystemAssigned, UserAssigned') ? {
      '${userAssigned.id}': {}
    } : null
  }
  properties: {
    // administratorLogin: sqlserver_admLogin
    // administratorLoginPassword: sqlserver_admLoginPassword
    administrators: {
      administratorType: sqlserver_administratorType 
      tenantId: sqlserver_tenantid
      azureADOnlyAuthentication: sqlserver_azureADOnlyAuthentication
      login: sqlserver_login
      principalType: sqlserver_principalType
      sid: sqlserver_groupsid
     }
    minimalTlsVersion: sqlserver_TlsVersion
    primaryUserAssignedIdentityId: sqlserver_UserAssignedIdentityId
    publicNetworkAccess: sqlserver_publicNetworkAccess
    restrictOutboundNetworkAccess: sqlserver_restrictOutboundNetworkAccess
    version: sqlserver_version
  }
  tags: tags
}
//*****************************************************************************************************


// Azure SQL Server Auditing
//*****************************************************************************************************
resource sqlAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2022-08-01-preview' = {  
  name: 'default'  
  parent: SqlServer  
  properties: {      
    auditActionsAndGroups: sqlserver_auditActionsAndGroups    
    isAzureMonitorTargetEnabled: true    
    isManagedIdentityInUse: true    
    retentionDays: sqlserver_retentionDays    
    state: 'Enabled'  
  }
}
//*****************************************************************************************************


// Azure Defender to SQL Server 
//*****************************************************************************************************
resource sqlServerAdvancedSecurityAssessment 'Microsoft.Sql/servers/securityAlertPolicies@2021-08-01-preview' = {
  parent: SqlServer
  name: 'advancedSecurityAssessment'
  properties:{
    state: 'Enabled'
  }
}
//*****************************************************************************************************
