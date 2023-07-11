param storagename string = 'stgaccountvidal'
param location string = 'eastus'

module storageAccountModule 'br:vidalabacr.azurecr.io/bicepmodules/storage:v1' = {
  name: 'storageAccountModule'
  params: {
    storageAccountName: storagename
    location: location
    //resourceGroupName: 'RG-BICEP-ACR'
  }
}

output storageAccountId string = storageAccountModule.outputs.storageAccountId
//output storageAccountConnectionString string = storageAccountModule.outputs.storageAccountConnectionString
//
