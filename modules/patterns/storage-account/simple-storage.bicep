// Common Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string

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


// Storage Account Module
//*****************************************************************************************************
// module storageAccountModule 'br/ACR-LAB:bicep/components/storage-account:v1.0.0' = {
module storageAccountModule '../../../modules/components/storage-account/storage.bicep' = {
  name: 'storageAccountModule'
  params: {
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname
    // storageAccountName: storageAccountName
    location: location
    accountTier: accountTier
    accessTier: accessTier
    workspaceId: workspaceId
    tags: tags
  }
}
//*****************************************************************************************************
