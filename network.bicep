targetScope = 'resourceGroup'
metadata description = 'Create a two-region, Virtual WAN environemnt with NVA spokes'

// ----------
// PARAMETERS
// ----------

@description('The default region.')
param parVwanRegion string = resourceGroup().location

@description('The virtual WAN hub 1 region.')
@allowed(['northeurope','westeurope','uksouth','swedencentral','francecentral','germanywestcentral','italynorth','norwayeast','polandcentral','switzerlandnorth','spaincentral'])
param parVwanHub1Region string = 'uksouth'

@description('The virtual WAN hub 2 region.')
@allowed(['northeurope','westeurope','uksouth','swedencentral','francecentral','germanywestcentral','italynorth','norwayeast','polandcentral','switzerlandnorth','spaincentral'])
param parVwanHub2Region string = 'swedencentral'

@description('The password for VM admins.')
@secure()
param parVmPassword string

@description('The password for VM admins.')
param parVmUserName string = 'srh'


// ---------
// VARIABLES
// ---------

var varVwanName = 'vwan-nvabgp'

var varVwanHub1Name = 'hub1'
var varVwanHub1AddressPrefix = '192.168.1.0/24'

var varVwanHub2Name = 'hub2'
var varVwanHub2AddressPrefix = '192.168.2.0/24'

var varVnetBranch1Name = 'branch1'
var varVnetBranch1Region = parVwanHub1Region
var varVnetBranch1AddressPrefix = '10.100.0.0/16'
var varVnetBranch1Subnet1Name = 'main'
var varVnetBranch1Subnet1AddressPrefix = '10.100.0.0/24'
var varVnetBranch1Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetBranch1Name, varVnetBranch1Subnet1Name)
var varVnetBranch1Subnet2Name = 'GatewaySubnet'
var varVnetBranch1Subnet2AddressPrefix = '10.100.100.0/26'
var varVnetBranch1Subnet2Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetBranch1Name, varVnetBranch1Subnet2Name)

var varVnetBranch2Name = 'branch2'
var varVnetBranch2Region = parVwanHub2Region
var varVnetBranch2AddressPrefix = '10.200.0.0/16'
var varVnetBranch2Subnet1Name = 'main'
var varVnetBranch2Subnet1AddressPrefix = '10.200.0.0/24'
var varVnetBranch2Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetBranch2Name, varVnetBranch2Subnet1Name)
var varVnetBranch2Subnet2Name = 'GatewaySubnet'
var varVnetBranch2Subnet2AddressPrefix = '10.200.100.0/26'
var varVnetBranch2Subnet2Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetBranch2Name, varVnetBranch2Subnet2Name)

var varVnetSpoke1Name = 'spoke1'
var varVnetSpoke1Region = parVwanHub1Region
var varVnetSpoke1AddressPrefix = '10.1.0.0/24'
var varVnetSpoke1Subnet1Name = 'main'
var varVnetSpoke1Subnet1AddressPrefix = '10.1.0.0/27'
var varVnetSpoke1Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke1Name, varVnetSpoke1Subnet1Name)

var varVnetSpoke2Name = 'spoke2'
var varVnetSpoke2Region = parVwanHub1Region
var varVnetSpoke2AddressPrefix = '10.2.0.0/24'
var varVnetSpoke2Subnet1Name = 'main'
var varVnetSpoke2Subnet1AddressPrefix = '10.2.0.0/27'
var varVnetSpoke2Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke2Name, varVnetSpoke2Subnet1Name)

var varVnetSpoke3Name = 'spoke3'
var varVnetSpoke3Region = parVwanHub2Region
var varVnetSpoke3AddressPrefix = '10.3.0.0/24'
var varVnetSpoke3Subnet1Name = 'main'
var varVnetSpoke3Subnet1AddressPrefix = '10.3.0.0/27'
var varVnetSpoke3Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke3Name, varVnetSpoke3Subnet1Name)

var varVnetSpoke4Name = 'spoke4'
var varVnetSpoke4Region = parVwanHub2Region
var varVnetSpoke4AddressPrefix = '10.4.0.0/24'
var varVnetSpoke4Subnet1Name = 'main'
var varVnetSpoke4Subnet1AddressPrefix = '10.4.0.0/27'
var varVnetSpoke4Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke4Name, varVnetSpoke4Subnet1Name)

var varVnetSpoke5Name = 'spoke5'
var varVnetSpoke5Region = parVwanHub1Region
var varVnetSpoke5AddressPrefix = '10.2.1.0/24'
var varVnetSpoke5Subnet1Name = 'main'
var varVnetSpoke5Subnet1AddressPrefix = '10.2.1.0/27'
var varVnetSpoke5Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke5Name, varVnetSpoke5Subnet1Name)

var varVnetSpoke6Name = 'spoke6'
var varVnetSpoke6Region = parVwanHub1Region
var varVnetSpoke6AddressPrefix = '10.2.2.0/24'
var varVnetSpoke6Subnet1Name = 'main'
var varVnetSpoke6Subnet1AddressPrefix = '10.2.2.0/27'
var varVnetSpoke6Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke6Name, varVnetSpoke6Subnet1Name)

var varVnetSpoke7Name = 'spoke7'
var varVnetSpoke7Region = parVwanHub2Region
var varVnetSpoke7AddressPrefix = '10.4.1.0/24'
var varVnetSpoke7Subnet1Name = 'main'
var varVnetSpoke7Subnet1AddressPrefix = '10.4.1.0/27'
var varVnetSpoke7Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke7Name, varVnetSpoke7Subnet1Name)

var varVnetSpoke8Name = 'spoke8'
var varVnetSpoke8Region = parVwanHub2Region
var varVnetSpoke8AddressPrefix = '10.4.2.0/24'
var varVnetSpoke8Subnet1Name = 'main'
var varVnetSpoke8Subnet1AddressPrefix = '10.4.2.0/27'
var varVnetSpoke8Subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke8Name, varVnetSpoke8Subnet1Name)

var varVnetPeeringSpoke2to5Name = '${varVnetSpoke2Name}-to-${varVnetSpoke5Name}'
var varVnetPeeringSpoke5to2Name = '${varVnetSpoke5Name}-to-${varVnetSpoke2Name}'
var varVnetPeeringSpoke2to6Name = '${varVnetSpoke2Name}-to-${varVnetSpoke6Name}'
var varVnetPeeringSpoke6to2Name = '${varVnetSpoke6Name}-to-${varVnetSpoke2Name}'
var varVnetPeeringSpoke4to7Name = '${varVnetSpoke4Name}-to-${varVnetSpoke7Name}'
var varVnetPeeringSpoke7to4Name = '${varVnetSpoke7Name}-to-${varVnetSpoke4Name}'
var varVnetPeeringSpoke4to8Name = '${varVnetSpoke4Name}-to-${varVnetSpoke8Name}'
var varVnetPeeringSpoke8to4Name = '${varVnetSpoke8Name}-to-${varVnetSpoke4Name}'

var varNsgRegion1Name = 'default-nsg-${parVwanHub1Region}'
var varNsgRegion2Name = 'default-nsg-${parVwanHub2Region}'

var varVpnGatewayHub1Name = '${varVwanHub1Name}-vpngw'
var varVpnGatewayHub2Name = '${varVwanHub2Name}-vpngw'

var varHubVirtualNetworkConnectionHub1Spoke1Name = '${varVwanHub1Name}-to-${varVnetSpoke1Name}-conn'
var varHubVirtualNetworkConnectionHub1Spoke2Name = '${varVwanHub1Name}-to-${varVnetSpoke2Name}-conn'
var varHubVirtualNetworkConnectionHub2Spoke3Name = '${varVwanHub2Name}-to-${varVnetSpoke3Name}-conn'
var varHubVirtualNetworkConnectionHub2Spoke4Name = '${varVwanHub2Name}-to-${varVnetSpoke4Name}-conn'

var varVnetGatewayBranch1Name = '${varVnetBranch1Name}-vpngw'
var varVnetGatewayBranch2Name = '${varVnetBranch2Name}-vpngw'

var varPipBranch1VpnGwName = '${varVnetBranch1Name}-vpngw-pip'
var varPipBranch2VpnGwName = '${varVnetBranch2Name}-vpngw-pip'

var varVpnSiteBranch1Name = 'site-${varVnetBranch1Name}'
var varVpnSiteBranch2Name = 'site-${varVnetBranch2Name}'

var varVpnConnectionHub1Branch1Name = '${varVwanHub1Name}-to-${varVnetBranch1Name}-conn'
var varVpnConnectionHub2Branch2Name = '${varVwanHub1Name}-to-${varVnetBranch2Name}-conn'

var varVnetVwanHub1LocalNetworkGw1Name = 'lng-${varVwanHub1Name}-gw1'
var varVnetVwanHub1LocalNetworkGw2Name = 'lng-${varVwanHub1Name}-gw2'
var varVnetVwanHub2LocalNetworkGw1Name = 'lng-${varVwanHub2Name}-gw1'
var varVnetVwanHub2LocalNetworkGw2Name = 'lng-${varVwanHub2Name}-gw2'

var varConnectionBranch1Hub1Gw1Name = '${varVnetBranch1Name}-to-${varVwanHub1Name}-gw1-conn'
var varConnectionBranch1Hub1Gw2Name = '${varVnetBranch1Name}-to-${varVwanHub1Name}-gw2-conn'
var varConnectionBranch2Hub2Gw1Name = '${varVnetBranch2Name}-to-${varVwanHub2Name}-gw1-conn'
var varConnectionBranch2Hub2Gw2Name = '${varVnetBranch2Name}-to-${varVwanHub2Name}-gw2-conn'

var varVmBranch1Name = 'vm-${varVnetBranch1Name}'
var varVmBranch2Name = 'vm-${varVnetBranch2Name}'
var varVmSpoke1Name = 'vm-${varVnetSpoke1Name}'
var varVmSpoke3Name = 'vm-${varVnetSpoke3Name}'
var varVmSpoke5Name = 'vm-${varVnetSpoke5Name}'
var varVmSpoke6Name = 'vm-${varVnetSpoke6Name}'
var varVmSpoke7Name = 'vm-${varVnetSpoke7Name}'
var varVmSpoke8Name = 'vm-${varVnetSpoke8Name}'

var varVmBranch1ExtensionAntimalware = 'extension-antimalware-${varVmBranch1Name}'
var varVmBranch2ExtensionAntimalware = 'extension-antimalware-${varVmBranch2Name}'
var varVmSpoke1ExtensionAntimalware = 'extension-antimalware-${varVmSpoke1Name}'
var varVmSpoke3ExtensionAntimalware = 'extension-antimalware-${varVmSpoke3Name}'
var varVmSpoke5ExtensionAntimalware = 'extension-antimalware-${varVmSpoke5Name}'
var varVmSpoke6ExtensionAntimalware = 'extension-antimalware-${varVmSpoke6Name}'
var varVmSpoke7ExtensionAntimalware = 'extension-antimalware-${varVmSpoke7Name}'
var varVmSpoke8ExtensionAntimalware = 'extension-antimalware-${varVmSpoke8Name}'

var varVmBranch1ExtensionAutomanage = 'extension-automanage-${varVmBranch1Name}'
var varVmBranch2ExtensionAutomanage = 'extension-automanage-${varVmBranch2Name}'
var varVmSpoke1ExtensionAutomanage = 'extension-automanage-${varVmSpoke1Name}'
var varVmSpoke3ExtensionAutomanage = 'extension-automanage-${varVmSpoke3Name}'
var varVmSpoke5ExtensionAutomanage = 'extension-automanage-${varVmSpoke5Name}'
var varVmSpoke6ExtensionAutomanage = 'extension-automanage-${varVmSpoke6Name}'
var varVmSpoke7ExtensionAutomanage = 'extension-automanage-${varVmSpoke7Name}'
var varVmSpoke8ExtensionAutomanage = 'extension-automanage-${varVmSpoke8Name}'

var varVmBranch1Schedule = 'shutdown-computevm-${varVmBranch1Name}'
var varVmBranch2Schedule = 'shutdown-computevm-${varVmBranch2Name}'
var varVmSpoke1Schedule = 'shutdown-computevm-${varVmSpoke1Name}'
var varVmSpoke3Schedule = 'shutdown-computevm-${varVmSpoke3Name}'
var varVmSpoke5Schedule = 'shutdown-computevm-${varVmSpoke5Name}'
var varVmSpoke6Schedule = 'shutdown-computevm-${varVmSpoke6Name}'
var varVmSpoke7Schedule = 'shutdown-computevm-${varVmSpoke7Name}'
var varVmSpoke8Schedule = 'shutdown-computevm-${varVmSpoke8Name}'

// ---------
// RESOURCES
// ---------

resource resVwan 'Microsoft.Network/virtualWans@2024-01-01' = {
  name: varVwanName
  location: parVwanRegion
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
  }
}

resource resVwanHub1 'Microsoft.Network/virtualHubs@2024-01-01' = {
  name: varVwanHub1Name
  location: parVwanHub1Region
  properties: {
    virtualWan: {
      id: resVwan.id
    }
    addressPrefix: varVwanHub1AddressPrefix
    virtualRouterAsn: 65515
    allowBranchToBranchTraffic: false
    hubRoutingPreference: 'ExpressRoute'
    virtualRouterAutoScaleConfiguration: {
      minCapacity: 2
    }
  }
}

resource resVwanHub2 'Microsoft.Network/virtualHubs@2024-01-01' = {
  name: varVwanHub2Name
  location: parVwanHub2Region
  properties: {
    virtualWan: {
      id: resVwan.id
    }
    addressPrefix: varVwanHub2AddressPrefix
    virtualRouterAsn: 65515
    allowBranchToBranchTraffic: false
    hubRoutingPreference: 'ExpressRoute'
    virtualRouterAutoScaleConfiguration: {
      minCapacity: 2
    }
  }
}

resource resVnetBranch1 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetBranch1Name
  location: varVnetBranch1Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetBranch1AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetBranch1Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetBranch1Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion1.id
          }

        }
      }
      {
        name: varVnetBranch1Subnet2Name
        properties: {
          addressPrefixes: [
            varVnetBranch1Subnet2AddressPrefix
          ]
          defaultOutboundAccess: false
        }
      }
    ]
  }
}

resource resVnetBranch2 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetBranch2Name
  location: varVnetBranch2Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetBranch2AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetBranch2Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetBranch2Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion2.id
          }
        }
      }
      {
        name: varVnetBranch2Subnet2Name
        properties: {
          addressPrefixes: [
            varVnetBranch2Subnet2AddressPrefix
          ]
          defaultOutboundAccess: false
        }
      }
    ]
  }
}

resource resVnetSpoke1 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetSpoke1Name
  location: varVnetSpoke1Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetSpoke1AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetSpoke1Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetSpoke1Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion1.id
          }
        }
      }
    ]
  }
}

resource resVnetSpoke2 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetSpoke2Name
  location: varVnetSpoke2Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetSpoke2AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetSpoke2Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetSpoke2Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion1.id
          }
        }
      }
    ]
  }
}

resource resVnetSpoke3 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetSpoke3Name
  location: varVnetSpoke3Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetSpoke3AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetSpoke3Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetSpoke3Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion2.id
          }
        }
      }
    ]
  }
}

resource resVnetSpoke4 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetSpoke4Name
  location: varVnetSpoke4Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetSpoke4AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetSpoke4Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetSpoke4Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion2.id
          }
        }
      }
    ]
  }
}

resource resVnetSpoke5 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetSpoke5Name
  location: varVnetSpoke5Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetSpoke5AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetSpoke5Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetSpoke5Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion1.id
          }
        }
      }
    ]
  }
}

resource resVnetSpoke6 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetSpoke6Name
  location: varVnetSpoke6Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetSpoke6AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetSpoke6Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetSpoke6Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion1.id
          }
        }
      }
    ]
  }
}

resource resVnetSpoke7 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetSpoke7Name
  location: varVnetSpoke7Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetSpoke7AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetSpoke7Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetSpoke7Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion2.id
          }
        }
      }
    ]
  }
}

resource resVnetSpoke8 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetSpoke8Name
  location: varVnetSpoke8Region
  properties: {
    addressSpace: {
      addressPrefixes: [
        varVnetSpoke8AddressPrefix
      ]
    }
    subnets: [
      {
        name: varVnetSpoke8Subnet1Name
        properties: {
          addressPrefixes: [
            varVnetSpoke8Subnet1AddressPrefix
          ]
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: resNsgRegion2.id
          }
        }
      }
    ]
  }
}

resource resVnetPeeringSpoke2to5 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: varVnetPeeringSpoke2to5Name
  parent: resVnetSpoke2
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peerCompleteVnets: true
    remoteVirtualNetwork: {
      id: resVnetSpoke5.id
    }
  }
}

resource resVnetPeeringSpoke5to2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: varVnetPeeringSpoke5to2Name
  parent: resVnetSpoke5
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peerCompleteVnets: true
    remoteVirtualNetwork: {
      id: resVnetSpoke2.id
    }
  }
}

resource resVnetPeeringSpoke2to6 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: varVnetPeeringSpoke2to6Name
  parent: resVnetSpoke2
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peerCompleteVnets: true
    remoteVirtualNetwork: {
      id: resVnetSpoke6.id
    }
  }
}

resource resVnetPeeringSpoke6to2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: varVnetPeeringSpoke6to2Name
  parent: resVnetSpoke6
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peerCompleteVnets: true
    remoteVirtualNetwork: {
      id: resVnetSpoke2.id
    }
  }
}

resource resVnetPeeringSpoke4to7 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: varVnetPeeringSpoke4to7Name
  parent: resVnetSpoke4
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peerCompleteVnets: true
    remoteVirtualNetwork: {
      id: resVnetSpoke7.id
    }
  }
}

resource resVnetPeeringSpoke7to4 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: varVnetPeeringSpoke7to4Name
  parent: resVnetSpoke7
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peerCompleteVnets: true
    remoteVirtualNetwork: {
      id: resVnetSpoke4.id
    }
  }
}

resource resVnetPeeringSpoke4to8 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: varVnetPeeringSpoke4to8Name
  parent: resVnetSpoke4
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peerCompleteVnets: true
    remoteVirtualNetwork: {
      id: resVnetSpoke8.id
    }
  }
}

resource resVnetPeeringSpoke8to4 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: varVnetPeeringSpoke8to4Name
  parent: resVnetSpoke8
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    peerCompleteVnets: true
    remoteVirtualNetwork: {
      id: resVnetSpoke4.id
    }
  }
}

resource resNsgRegion1 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgRegion1Name
  location: parVwanHub1Region
  properties: {
    securityRules: [
      {
        name: 'default-allow-ssh-rdp'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          description: 'Allow inbound SSH/RDP'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
        }
      }
    ]
  }
}

resource resNsgRegion2 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgRegion2Name
  location: parVwanHub2Region
  properties: {
    securityRules: [
      {
        name: 'default-allow-ssh-rdp'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          description: 'Allow inbound SSH/RDP'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
        }
      }
    ]
  }
}

resource resPipBranch1VpnGw 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: varPipBranch1VpnGwName
  location: varVnetBranch1Region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource resPipBranch2VpnGw 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: varPipBranch2VpnGwName
  location: varVnetBranch2Region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource resVnetGatewayBranch1 'Microsoft.Network/virtualNetworkGateways@2024-01-01' = {
  name: varVnetGatewayBranch1Name
  location: varVnetBranch1Region
  dependsOn: [
    resVnetBranch1
  ]
  properties: {
    gatewayType: 'Vpn'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation1'
    enableBgp: true
    bgpSettings: {
      asn: 65510
    }
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: varVnetBranch1Subnet2Ref
          }
          publicIPAddress: {
            id: resPipBranch1VpnGw.id
          }
        }
      }
    ]
  }
}

resource resVnetGatewayBranch2 'Microsoft.Network/virtualNetworkGateways@2024-01-01' = {
  name: varVnetGatewayBranch2Name
  location: varVnetBranch2Region
  dependsOn: [
    resVnetBranch2
  ]
  properties: {
    gatewayType: 'Vpn'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation1'
    enableBgp: true
    bgpSettings: {
      asn: 65510
    }
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: varVnetBranch2Subnet2Ref
          }
          publicIPAddress: {
            id: resPipBranch2VpnGw.id
          }
        }
      }
    ]
  }
}

resource resVpnGatewayHub1 'Microsoft.Network/vpnGateways@2024-01-01' = {
  name: varVpnGatewayHub1Name
  location: parVwanHub1Region
  properties: {
    virtualHub: {
      id: resVwanHub1.id
    }
  }
}

resource resVpnGatewayHub2 'Microsoft.Network/vpnGateways@2024-01-01' = {
  name: varVpnGatewayHub2Name
  location: parVwanHub2Region
  properties: {
    virtualHub: {
      id: resVwanHub2.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub1Spoke1 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: varHubVirtualNetworkConnectionHub1Spoke1Name
  parent: resVwanHub1
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke1.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub1Spoke2 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: varHubVirtualNetworkConnectionHub1Spoke2Name
  parent: resVwanHub1
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke2.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub2Spoke3 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: varHubVirtualNetworkConnectionHub2Spoke3Name
  parent: resVwanHub2
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke3.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub2Spoke4 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: varHubVirtualNetworkConnectionHub2Spoke4Name
  parent: resVwanHub2
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke4.id
    }
  }
}

resource resVpnSiteBranch1 'Microsoft.Network/vpnSites@2024-01-01' = {
  name: varVpnSiteBranch1Name
  location: varVnetBranch1Region
  properties: {
    virtualWan: {
      id: resVwan.id
    }
    ipAddress: resPipBranch1VpnGw.properties.ipAddress
    bgpProperties: {
      asn: 65510
      bgpPeeringAddress: resVnetGatewayBranch1.properties.bgpSettings.bgpPeeringAddress
      bgpPeeringAddresses: [
        {
          ipconfigurationId: resVnetGatewayBranch1.properties.ipConfigurations[0].id
        }
      ]
    }
    deviceProperties: {
      deviceModel: 'Azure'
      deviceVendor: 'Microsoft'
      linkSpeedInMbps: 50
    }
  }
}

resource resVpnSiteBranch2 'Microsoft.Network/vpnSites@2024-01-01' = {
  name: varVpnSiteBranch2Name
  location: varVnetBranch2Region
  properties: {
    virtualWan: {
      id: resVwan.id
    }
    ipAddress: resPipBranch2VpnGw.properties.ipAddress
    bgpProperties: {
      asn: 65510
      bgpPeeringAddress: resVnetGatewayBranch2.properties.bgpSettings.bgpPeeringAddress
      bgpPeeringAddresses: [
        {
          ipconfigurationId: resVnetGatewayBranch2.properties.ipConfigurations[0].id
        }
      ]
    }
    deviceProperties: {
      deviceModel: 'Azure'
      deviceVendor: 'Microsoft'
      linkSpeedInMbps: 50
    }
  }
}

resource resVpnConnectionHub1Branch1 'Microsoft.Network/vpnGateways/vpnConnections@2024-01-01' = {
  name: varVpnConnectionHub1Branch1Name
  parent: resVpnGatewayHub1
  properties: {
    remoteVpnSite: {
      id: resVpnSiteBranch1.id
    }
    sharedKey: 'abc123'
    enableInternetSecurity: true
    enableBgp: true
  }
}

resource resVpnConnectionHub2Branch2 'Microsoft.Network/vpnGateways/vpnConnections@2024-01-01' = {
  name: varVpnConnectionHub2Branch2Name
  parent: resVpnGatewayHub2
  properties: {
    remoteVpnSite: {
      id: resVpnSiteBranch2.id
    }
    sharedKey: 'abc123'
    enableInternetSecurity: true
    enableBgp: true
  }
}

resource resLocalNetworkGatewayHub1Gw1 'Microsoft.Network/localNetworkGateways@2024-01-01' = {
  name: varVnetVwanHub1LocalNetworkGw1Name
  location: parVwanHub1Region
  properties: {
    gatewayIpAddress: resVpnGatewayHub1.properties.bgpSettings.bgpPeeringAddresses[0].tunnelIpAddresses[0]
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: resVpnGatewayHub1.properties.bgpSettings.bgpPeeringAddresses[0].defaultBgpIpAddresses[0]
    }
  }
}

resource resLocalNetworkGatewayHub1Gw2 'Microsoft.Network/localNetworkGateways@2024-01-01' = {
  name: varVnetVwanHub1LocalNetworkGw2Name
  location: parVwanHub1Region
  properties: {
    gatewayIpAddress: resVpnGatewayHub1.properties.bgpSettings.bgpPeeringAddresses[1].tunnelIpAddresses[0]
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: resVpnGatewayHub1.properties.bgpSettings.bgpPeeringAddresses[1].defaultBgpIpAddresses[0]
    }
  }
}

resource resLocalNetworkGatewayHub2Gw1 'Microsoft.Network/localNetworkGateways@2024-01-01' = {
  name: varVnetVwanHub2LocalNetworkGw1Name
  location: parVwanHub2Region
  properties: {
    gatewayIpAddress: resVpnGatewayHub2.properties.bgpSettings.bgpPeeringAddresses[0].tunnelIpAddresses[0]
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: resVpnGatewayHub2.properties.bgpSettings.bgpPeeringAddresses[0].defaultBgpIpAddresses[0]
    }
  }
}

resource resLocalNetworkGatewayHub2Gw2 'Microsoft.Network/localNetworkGateways@2024-01-01' = {
  name: varVnetVwanHub2LocalNetworkGw2Name
  location: parVwanHub2Region
  properties: {
    gatewayIpAddress: resVpnGatewayHub2.properties.bgpSettings.bgpPeeringAddresses[1].tunnelIpAddresses[0]
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: resVpnGatewayHub2.properties.bgpSettings.bgpPeeringAddresses[1].defaultBgpIpAddresses[0]
    }
  }
}

resource resConnectionBranch1Hub1Gw1 'Microsoft.Network/connections@2024-01-01' = {
  name: varConnectionBranch1Hub1Gw1Name
  location: varVnetBranch1Region
  properties: {
    virtualNetworkGateway1: {
      id: resVnetGatewayBranch1.id
      properties: {}
    }
    localNetworkGateway2: {
      id: resLocalNetworkGatewayHub1Gw1.id
      properties: {}
    }
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    routingWeight: 10
    enableBgp: true
    sharedKey: 'abc123'
  }
}

resource resConnectionBranch1Hub1Gw2 'Microsoft.Network/connections@2024-01-01' = {
  name: varConnectionBranch1Hub1Gw2Name
  location: varVnetBranch1Region
  properties: {
    virtualNetworkGateway1: {
      id: resVnetGatewayBranch1.id
      properties: {}
    }
    localNetworkGateway2: {
      id: resLocalNetworkGatewayHub1Gw2.id
      properties: {}
    }
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    routingWeight: 10
    enableBgp: true
    sharedKey: 'abc123'
  }
}

resource resConnectionBranch2Hub2Gw1 'Microsoft.Network/connections@2024-01-01' = {
  name: varConnectionBranch2Hub2Gw1Name
  location: varVnetBranch2Region
  properties: {
    virtualNetworkGateway1: {
      id: resVnetGatewayBranch2.id
      properties: {}
    }
    localNetworkGateway2: {
      id: resLocalNetworkGatewayHub2Gw1.id
      properties: {}
    }
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    routingWeight: 10
    enableBgp: true
    sharedKey: 'abc123'
  }
}

resource resConnectionBranch2Hub2Gw2 'Microsoft.Network/connections@2024-01-01' = {
  name: varConnectionBranch2Hub2Gw2Name
  location: varVnetBranch2Region
  properties: {
    virtualNetworkGateway1: {
      id: resVnetGatewayBranch2.id
      properties: {}
    }
    localNetworkGateway2: {
      id: resLocalNetworkGatewayHub2Gw2.id
      properties: {}
    }
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    routingWeight: 10
    enableBgp: true
    sharedKey: 'abc123'
  }
}

// --------------
// RESOURCES (VM)
// --------------

resource resVmBranch1 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmBranch1Name
  location: varVnetBranch1Region
  dependsOn: [
    resVnetBranch1
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    hardwareProfile:{
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile:{
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmBranch1Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkApiVersion: '2024-01-01'
      networkInterfaceConfigurations: [
        {
          name: '${varVmBranch1Name}-nic'
          properties: {
            primary: true
            ipConfigurations: [
              {
                name: '${varVmBranch1Name}-nic-ipconfig1'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet:{
                    id: varVnetBranch1Subnet1Ref
                  }
                  publicIPAddressConfiguration: {
                    name: '${varVmBranch1Name}-nic-ipconfig1-pip'
                    properties: {
                      deleteOption: 'Delete'
                      publicIPAddressVersion: 'IPv4'
                      publicIPAllocationMethod: 'Static'
                    }
                  }
                }
              }
            ]
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile:{
      uefiSettings:{
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource resVmBranch1Antmalware 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmBranch1ExtensionAntimalware
  location: varVnetBranch1Region
  parent: resVmBranch1
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: false
        day: '7'
        time: '120'
        scanType: 'Quick'
      }
      Exclusions: {
        Extensions: ''
        Paths: ''
        Processes: ''
      }
    }
    protectedSettings: {}
  }
}

resource resVmBranch1Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmBranch1ExtensionAutomanage
  location: varVnetBranch1Region
  parent: resVmBranch1
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmBranch1Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmBranch1Schedule
  location: varVnetBranch1Region
  properties: {
    targetResourceId: resVmBranch1.id
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '0300'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
       notificationLocale: 'en'
    }
  }
}

resource resVmBranch2 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmBranch2Name
  location: varVnetBranch2Region
  dependsOn: [
    resVnetBranch2
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    hardwareProfile:{
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile:{
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmBranch2Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkApiVersion: '2024-01-01'
      networkInterfaceConfigurations: [
        {
          name: '${varVmBranch2Name}-nic'
          properties: {
            primary: true
            ipConfigurations: [
              {
                name: '${varVmBranch2Name}-nic-ipconfig1'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet:{
                    id: varVnetBranch2Subnet1Ref
                  }
                  publicIPAddressConfiguration: {
                    name: '${varVmBranch2Name}-nic-ipconfig1-pip'
                    properties: {
                      deleteOption: 'Delete'
                      publicIPAddressVersion: 'IPv4'
                      publicIPAllocationMethod: 'Static'
                    }
                  }
                }
              }
            ]
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile:{
      uefiSettings:{
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource resVmBranch2Antmalware 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmBranch2ExtensionAntimalware
  location: varVnetBranch2Region
  parent: resVmBranch2
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: false
        day: '7'
        time: '120'
        scanType: 'Quick'
      }
      Exclusions: {
        Extensions: ''
        Paths: ''
        Processes: ''
      }
    }
    protectedSettings: {}
  }
}

resource resVmBranch2Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmBranch2ExtensionAutomanage
  location: varVnetBranch2Region
  parent: resVmBranch2
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmBranch2Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmBranch2Schedule
  location: varVnetBranch2Region
  properties: {
    targetResourceId: resVmBranch2.id
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '0300'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
       notificationLocale: 'en'
    }
  }
}

resource resVmSpoke1 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke1Name
  location: varVnetSpoke1Region
  dependsOn: [
    resVnetSpoke1
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    hardwareProfile:{
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile:{
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke1Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkApiVersion: '2024-01-01'
      networkInterfaceConfigurations: [
        {
          name: '${varVmSpoke1Name}-nic'
          properties: {
            primary: true
            ipConfigurations: [
              {
                name: '${varVmSpoke1Name}-nic-ipconfig1'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet:{
                    id: varVnetSpoke1Subnet1Ref
                  }
                  publicIPAddressConfiguration: {
                    name: '${varVmSpoke1Name}-nic-ipconfig1-pip'
                    properties: {
                      deleteOption: 'Delete'
                      publicIPAddressVersion: 'IPv4'
                      publicIPAllocationMethod: 'Static'
                    }
                  }
                }
              }
            ]
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile:{
      uefiSettings:{
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource resVmSpoke1Antmalware 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke1ExtensionAntimalware
  location: varVnetSpoke1Region
  parent: resVmSpoke1
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: false
        day: '7'
        time: '120'
        scanType: 'Quick'
      }
      Exclusions: {
        Extensions: ''
        Paths: ''
        Processes: ''
      }
    }
    protectedSettings: {}
  }
}

resource resVmSpoke1Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke1ExtensionAutomanage
  location: varVnetSpoke1Region
  parent: resVmSpoke1
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke1Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke1Schedule
  location: varVnetSpoke1Region
  properties: {
    targetResourceId: resVmSpoke1.id
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '0300'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
       notificationLocale: 'en'
    }
  }
}

resource resVmSpoke3 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke3Name
  location: varVnetSpoke3Region
  dependsOn: [
    resVnetSpoke3
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    hardwareProfile:{
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile:{
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke3Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkApiVersion: '2024-01-01'
      networkInterfaceConfigurations: [
        {
          name: '${varVmSpoke3Name}-nic'
          properties: {
            primary: true
            ipConfigurations: [
              {
                name: '${varVmSpoke3Name}-nic-ipconfig1'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet:{
                    id: varVnetSpoke3Subnet1Ref
                  }
                  publicIPAddressConfiguration: {
                    name: '${varVmSpoke3Name}-nic-ipconfig1-pip'
                    properties: {
                      deleteOption: 'Delete'
                      publicIPAddressVersion: 'IPv4'
                      publicIPAllocationMethod: 'Static'
                    }
                  }
                }
              }
            ]
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile:{
      uefiSettings:{
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource resVmSpoke3Antmalware 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke3ExtensionAntimalware
  location: varVnetSpoke3Region
  parent: resVmSpoke3
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: false
        day: '7'
        time: '120'
        scanType: 'Quick'
      }
      Exclusions: {
        Extensions: ''
        Paths: ''
        Processes: ''
      }
    }
    protectedSettings: {}
  }
}

resource resVmSpoke3Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke3ExtensionAutomanage
  location: varVnetSpoke3Region
  parent: resVmSpoke3
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke3Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke3Schedule
  location: varVnetSpoke3Region
  properties: {
    targetResourceId: resVmSpoke3.id
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '0300'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
       notificationLocale: 'en'
    }
  }
}

resource resVmSpoke5 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke5Name
  location: varVnetSpoke5Region
  dependsOn: [
    resVnetSpoke5
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    hardwareProfile:{
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile:{
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke5Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkApiVersion: '2024-01-01'
      networkInterfaceConfigurations: [
        {
          name: '${varVmSpoke5Name}-nic'
          properties: {
            primary: true
            ipConfigurations: [
              {
                name: '${varVmSpoke5Name}-nic-ipconfig1'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet:{
                    id: varVnetSpoke5Subnet1Ref
                  }
                  publicIPAddressConfiguration: {
                    name: '${varVmSpoke5Name}-nic-ipconfig1-pip'
                    properties: {
                      deleteOption: 'Delete'
                      publicIPAddressVersion: 'IPv4'
                      publicIPAllocationMethod: 'Static'
                    }
                  }
                }
              }
            ]
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile:{
      uefiSettings:{
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource resVmSpoke5Antmalware 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke5ExtensionAntimalware
  location: varVnetSpoke5Region
  parent: resVmSpoke5
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: false
        day: '7'
        time: '120'
        scanType: 'Quick'
      }
      Exclusions: {
        Extensions: ''
        Paths: ''
        Processes: ''
      }
    }
    protectedSettings: {}
  }
}

resource resVmSpoke5Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke5ExtensionAutomanage
  location: varVnetSpoke5Region
  parent: resVmSpoke5
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke5Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke5Schedule
  location: varVnetSpoke5Region
  properties: {
    targetResourceId: resVmSpoke5.id
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '0300'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
       notificationLocale: 'en'
    }
  }
}

resource resVmSpoke6 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke6Name
  location: varVnetSpoke6Region
  dependsOn: [
    resVnetSpoke6
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    hardwareProfile:{
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile:{
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke6Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkApiVersion: '2024-01-01'
      networkInterfaceConfigurations: [
        {
          name: '${varVmSpoke6Name}-nic'
          properties: {
            primary: true
            ipConfigurations: [
              {
                name: '${varVmSpoke6Name}-nic-ipconfig1'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet:{
                    id: varVnetSpoke6Subnet1Ref
                  }
                  publicIPAddressConfiguration: {
                    name: '${varVmSpoke6Name}-nic-ipconfig1-pip'
                    properties: {
                      deleteOption: 'Delete'
                      publicIPAddressVersion: 'IPv4'
                      publicIPAllocationMethod: 'Static'
                    }
                  }
                }
              }
            ]
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile:{
      uefiSettings:{
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource resVmSpoke6Antmalware 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke6ExtensionAntimalware
  location: varVnetSpoke6Region
  parent: resVmSpoke6
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: false
        day: '7'
        time: '120'
        scanType: 'Quick'
      }
      Exclusions: {
        Extensions: ''
        Paths: ''
        Processes: ''
      }
    }
    protectedSettings: {}
  }
}

resource resVmSpoke6Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke6ExtensionAutomanage
  location: varVnetSpoke6Region
  parent: resVmSpoke6
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke6Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke6Schedule
  location: varVnetSpoke6Region
  properties: {
    targetResourceId: resVmSpoke6.id
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '0300'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
       notificationLocale: 'en'
    }
  }
}

resource resVmSpoke7 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke7Name
  location: varVnetSpoke7Region
  dependsOn: [
    resVnetSpoke7
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    hardwareProfile:{
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile:{
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke7Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkApiVersion: '2024-01-01'
      networkInterfaceConfigurations: [
        {
          name: '${varVmSpoke7Name}-nic'
          properties: {
            primary: true
            ipConfigurations: [
              {
                name: '${varVmSpoke7Name}-nic-ipconfig1'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet:{
                    id: varVnetSpoke7Subnet1Ref
                  }
                  publicIPAddressConfiguration: {
                    name: '${varVmSpoke7Name}-nic-ipconfig1-pip'
                    properties: {
                      deleteOption: 'Delete'
                      publicIPAddressVersion: 'IPv4'
                      publicIPAllocationMethod: 'Static'
                    }
                  }
                }
              }
            ]
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile:{
      uefiSettings:{
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource resVmSpoke7Antmalware 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke7ExtensionAntimalware
  location: varVnetSpoke7Region
  parent: resVmSpoke7
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: false
        day: '7'
        time: '120'
        scanType: 'Quick'
      }
      Exclusions: {
        Extensions: ''
        Paths: ''
        Processes: ''
      }
    }
    protectedSettings: {}
  }
}

resource resVmSpoke7Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke7ExtensionAutomanage
  location: varVnetSpoke7Region
  parent: resVmSpoke7
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke7Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke7Schedule
  location: varVnetSpoke7Region
  properties: {
    targetResourceId: resVmSpoke7.id
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '0300'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
       notificationLocale: 'en'
    }
  }
}

resource resVmSpoke8 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke8Name
  location: varVnetSpoke8Region
  dependsOn: [
    resVnetSpoke8
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    hardwareProfile:{
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile:{
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke8Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkApiVersion: '2024-01-01'
      networkInterfaceConfigurations: [
        {
          name: '${varVmSpoke8Name}-nic'
          properties: {
            primary: true
            ipConfigurations: [
              {
                name: '${varVmSpoke8Name}-nic-ipconfig1'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet:{
                    id: varVnetSpoke8Subnet1Ref
                  }
                  publicIPAddressConfiguration: {
                    name: '${varVmSpoke8Name}-nic-ipconfig1-pip'
                    properties: {
                      deleteOption: 'Delete'
                      publicIPAddressVersion: 'IPv4'
                      publicIPAllocationMethod: 'Static'
                    }
                  }
                }
              }
            ]
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile:{
      uefiSettings:{
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource resVmSpoke8Antmalware 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke8ExtensionAntimalware
  location: varVnetSpoke8Region
  parent: resVmSpoke8
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: false
        day: '7'
        time: '120'
        scanType: 'Quick'
      }
      Exclusions: {
        Extensions: ''
        Paths: ''
        Processes: ''
      }
    }
    protectedSettings: {}
  }
}

resource resVmSpoke8Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke8ExtensionAutomanage
  location: varVnetSpoke8Region
  parent: resVmSpoke8
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke8Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke8Schedule
  location: varVnetSpoke8Region
  properties: {
    targetResourceId: resVmSpoke8.id
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '0300'
    }
    timeZoneId: 'GMT Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
       notificationLocale: 'en'
    }
  }
}




