// ----------------------------------------
// Target scope declaration
// ----------------------------------------
targetScope = 'subscription'

// ----------------------------------------
// Parameter declaration
// ----------------------------------------
param currentDate string = utcNow('u')

@description('The Resource Group name.')
param parRgName string = 'VWAN-NVA-BGP'

@description('The password for VM admins.')
@secure()
param parVmPassword string

// ----------------------------------------
// Resource declaration
// ----------------------------------------

resource resResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: parRgName
  location: 'uksouth'
}

module network 'network.bicep' = {
  scope: resResourceGroup
  name: 'network-${uniqueString(currentDate)}'
  params: {
    parRegion1: 'uksouth'
    parRegion2: 'swedencentral'
    parVmPassword: parVmPassword
    parVmUserName: 'azureuser'
  }
}
