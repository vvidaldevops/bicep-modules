// Common Parameters
//*****************************************************************************************************
@description('The Azure region into which the resources should be deployed.')
param location string

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
@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param accountTier string = 'Standard_LRS'

@description('The Storage Account tier')
param accessTier string

@description('Allow or Deny the storage public access. Default is false')
param allowBlobPublicAccess string

@description('The name from Service Endpoint VNET.')
param stgServiceEndpointVnetName string

@description('The name from Service Endpoint Subnet.')
param stgServiceEndpointSubnetName string

@description('The ID of Log Analytics Workspace.')
param workspaceId string
//*****************************************************************************************************


// Storage Account Module
//*****************************************************************************************************
module storageAccountModule 'br/ACR-LAB:bicep/components/storage-account:v1.0.0' = {
//module storageAccountModule '../../../modules/components/storage-account/storage.bicep' = {
  name: 'storageAccountModule'
  params: {
    bu: bu
    stage: stage
    role: role
    appId: appId
    appname: appname
    storagePrefix: 'stg'
    location: location
    accountTier: accountTier
    accessTier: accessTier
    serviceEndpointVnetName: stgServiceEndpointVnetName
    serviceEndpointSubnetName: stgServiceEndpointSubnetName
    allowBlobPublicAccess: allowBlobPublicAccess
    workspaceId: workspaceId
    tags: tags
  }
}
//*****************************************************************************************************
