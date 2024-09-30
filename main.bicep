// ----------------------------------------
// Target scope declaration
// ----------------------------------------
targetScope = 'subscription'

// ----------------------------------------
// Parameter declaration
// ----------------------------------------
param currentDate string = utcNow('u')

@description('The Resource Group name.')
param parRgName string = 'SRH-VWAN-NVA-BGP'

@description('The Resource Group name.')
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
    parVwanHub1Region: 'uksouth'
    parVwanHub2Region: 'swedencentral'
    parVmPassword: parVmPassword
    parVmUserName: 'srh'
  }
}
