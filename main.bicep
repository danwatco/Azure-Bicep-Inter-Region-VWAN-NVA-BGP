// ----------------------------------------
// Target scope declaration
// ----------------------------------------
targetScope = 'subscription'

// ----------------------------------------
// Parameter declaration
// ----------------------------------------
param currentDate string = utcNow('u')

@description('The Resource Group name.')
param parRgName string = 'RG-VWAN-NVA-BGP'

@description('The virtual WAN region.')
@allowed([
  'northeurope'
  'westeurope'
  'uksouth'
  'swedencentral'
  'francecentral'
  'germanywestcentral'
  'italynorth'
  'norwayeast'
  'polandcentral'
  'switzerlandnorth'
  'spaincentral'
])
param parVwanRegion string = 'uksouth'

@description('The virtual WAN hub 1 region.')
@allowed([
  'northeurope'
  'westeurope'
  'uksouth'
  'swedencentral'
  'francecentral'
  'germanywestcentral'
  'italynorth'
  'norwayeast'
  'polandcentral'
  'switzerlandnorth'
  'spaincentral'
])
param parVwanHub1Region string = 'uksouth'

@description('The virtual WAN hub 2 region.')
@allowed([
  'northeurope'
  'westeurope'
  'uksouth'
  'swedencentral'
  'francecentral'
  'germanywestcentral'
  'italynorth'
  'norwayeast'
  'polandcentral'
  'switzerlandnorth'
  'spaincentral'
])
param parVwanHub2Region string = 'swedencentral'

@description('The user name for VM admins.')
param parVmUserName string = 'azureuser'

@description('The password for VM admins.')
@secure()
param parVmPassword string

// ----------------------------------------
// Resource declaration
// ----------------------------------------

resource resResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: parRgName
  location: parVwanRegion
}

module network 'resources.bicep' = {
  scope: resResourceGroup
  name: 'resources-${uniqueString(currentDate)}'
  params: {
    parVwanHub1Region: parVwanHub1Region
    parVwanHub2Region: parVwanHub2Region
    parVmUserName: parVmUserName
    parVmPassword: parVmPassword
  }
}
