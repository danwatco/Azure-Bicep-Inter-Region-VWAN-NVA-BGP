targetScope = 'resourceGroup'
metadata description = 'Create a two-region, Virtual WAN environemnt with NVA spokes'

// ----------
// PARAMETERS
// ----------

@description('The default region.')
param parVwanRegion string = resourceGroup().location

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

// ---------
// VARIABLES
// ---------

var varVwanName = 'vwan-nvabgp'

var varVwanHub1Name = 'hub1'
var varVwanHub1AddressPrefix = '192.168.1.0/24'
var varVwanHub1VirtualRouterIps = [
  '192.168.1.68'
  '192.168.1.69'
]

var varVwanHub2Name = 'hub2'
var varVwanHub2AddressPrefix = '192.168.2.0/24'
var varVwanHub2VirtualRouterIps = [
  '192.168.2.68'
  '192.168.2.69'
]

var varVwanAsn = 65515
var varOnPremisesAsn = 65510
var varSpoke2Asn = 65002
var varSpoke4Asn = 65004

var varVwanHub1VmSpoke21BgpConnectionName = '${varVmSpoke21Name}-bgp-conn'
var varVwanHub1VmSpoke22BgpConnectionName = '${varVmSpoke22Name}-bgp-conn'
var varVwanHub2VmSpoke41BgpConnectionName = '${varVmSpoke41Name}-bgp-conn'
var varVwanHub2VmSpoke42BgpConnectionName = '${varVmSpoke42Name}-bgp-conn'

var varVnetBranch1Name = 'branch1'
var varVnetBranch1Region = parVwanHub1Region
var varVnetBranch1AddressPrefix = '10.100.0.0/16'
var varVnetBranch1Subnet1Name = 'main'
var varVnetBranch1Subnet1AddressPrefix = '10.100.0.0/24'
var varVnetBranch1Subnet2Name = 'GatewaySubnet'
var varVnetBranch1Subnet2AddressPrefix = '10.100.100.0/26'

var varVnetBranch2Name = 'branch2'
var varVnetBranch2Region = parVwanHub2Region
var varVnetBranch2AddressPrefix = '10.200.0.0/16'
var varVnetBranch2Subnet1Name = 'main'
var varVnetBranch2Subnet1AddressPrefix = '10.200.0.0/24'
var varVnetBranch2Subnet2Name = 'GatewaySubnet'
var varVnetBranch2Subnet2AddressPrefix = '10.200.100.0/26'

var varVnetSpoke1Name = 'spoke1'
var varVnetSpoke1Region = parVwanHub1Region
var varVnetSpoke1AddressPrefix = '10.1.0.0/24'
var varVnetSpoke1Subnet1Name = 'main'
var varVnetSpoke1Subnet1AddressPrefix = '10.1.0.0/27'

var varVnetSpoke2Name = 'spoke2'
var varVnetSpoke2Region = parVwanHub1Region
var varVnetSpoke2AddressPrefix = '10.2.0.0/24'
var varVnetSpoke2Subnet1Name = 'main'
var varVnetSpoke2Subnet1AddressPrefix = '10.2.0.0/27'

var varVnetSpoke3Name = 'spoke3'
var varVnetSpoke3Region = parVwanHub2Region
var varVnetSpoke3AddressPrefix = '10.3.0.0/24'
var varVnetSpoke3Subnet1Name = 'main'
var varVnetSpoke3Subnet1AddressPrefix = '10.3.0.0/27'

var varVnetSpoke4Name = 'spoke4'
var varVnetSpoke4Region = parVwanHub2Region
var varVnetSpoke4AddressPrefix = '10.4.0.0/24'
var varVnetSpoke4Subnet1Name = 'main'
var varVnetSpoke4Subnet1AddressPrefix = '10.4.0.0/27'

var varVnetSpoke5Name = 'spoke5'
var varVnetSpoke5Region = parVwanHub1Region
var varVnetSpoke5AddressPrefix = '10.2.1.0/24'
var varVnetSpoke5Subnet1Name = 'main'
var varVnetSpoke5Subnet1AddressPrefix = '10.2.1.0/27'

var varVnetSpoke6Name = 'spoke6'
var varVnetSpoke6Region = parVwanHub1Region
var varVnetSpoke6AddressPrefix = '10.2.2.0/24'
var varVnetSpoke6Subnet1Name = 'main'
var varVnetSpoke6Subnet1AddressPrefix = '10.2.2.0/27'

var varVnetSpoke7Name = 'spoke7'
var varVnetSpoke7Region = parVwanHub2Region
var varVnetSpoke7AddressPrefix = '10.4.1.0/24'
var varVnetSpoke7Subnet1Name = 'main'
var varVnetSpoke7Subnet1AddressPrefix = '10.4.1.0/27'

var varVnetSpoke8Name = 'spoke8'
var varVnetSpoke8Region = parVwanHub2Region
var varVnetSpoke8AddressPrefix = '10.4.2.0/24'
var varVnetSpoke8Subnet1Name = 'main'
var varVnetSpoke8Subnet1AddressPrefix = '10.4.2.0/27'

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


var varVmSpoke21Name = 'vm-${varVnetSpoke2Name}-1'
var varVmSpoke22Name = 'vm-${varVnetSpoke2Name}-2'
var varVmSpoke41Name = 'vm-${varVnetSpoke4Name}-1'
var varVmSpoke42Name = 'vm-${varVnetSpoke4Name}-2'

var varVmSpoke21NicName = '${varVmSpoke21Name}-nic'
var varVmSpoke22NicName = '${varVmSpoke22Name}-nic'
var varVmSpoke41NicName = '${varVmSpoke41Name}-nic'
var varVmSpoke42NicName = '${varVmSpoke42Name}-nic'

var varVmSpoke21PipName = '${varVmSpoke21Name}-pip'
var varVmSpoke22PipName = '${varVmSpoke22Name}-pip'
var varVmSpoke41PipName = '${varVmSpoke41Name}-pip'
var varVmSpoke42PipName = '${varVmSpoke42Name}-pip'

var varVmSpoke21ExtensionAadLogin = 'extension-aadlogin-${varVmSpoke21Name}'
var varVmSpoke22ExtensionAadLogin = 'extension-aadlogin-${varVmSpoke22Name}'
var varVmSpoke41ExtensionAadLogin = 'extension-aadlogin-${varVmSpoke41Name}'
var varVmSpoke42ExtensionAadLogin = 'extension-aadlogin-${varVmSpoke42Name}'

var varVmSpoke21ExtensionAutomanage = 'extension-automanage-${varVmSpoke21Name}'
var varVmSpoke22ExtensionAutomanage = 'extension-automanage-${varVmSpoke22Name}'
var varVmSpoke41ExtensionAutomanage = 'extension-automanage-${varVmSpoke41Name}'
var varVmSpoke42ExtensionAutomanage = 'extension-automanage-${varVmSpoke42Name}'

var varVmSpoke21ExtensionCustomScript = 'extension-customscript-${varVmSpoke21Name}'
var varVmSpoke22ExtensionCustomScript = 'extension-customscript-${varVmSpoke22Name}'
var varVmSpoke41ExtensionCustomScript = 'extension-customscript-${varVmSpoke41Name}'
var varVmSpoke42ExtensionCustomScript = 'extension-customscript-${varVmSpoke42Name}'

var varVmSpoke21Schedule = 'shutdown-computevm-${varVmSpoke21Name}'
var varVmSpoke22Schedule = 'shutdown-computevm-${varVmSpoke22Name}'
var varVmSpoke41Schedule = 'shutdown-computevm-${varVmSpoke41Name}'
var varVmSpoke42Schedule = 'shutdown-computevm-${varVmSpoke42Name}'

var varSpoke2LoadBalancerName = '${varVnetSpoke2Name}-lb'
var varSpoke2LoadBalancerFrontEndName = '${varSpoke2LoadBalancerName}-fe'
var varSpoke2LoadBalancerBackEndName = '${varSpoke2LoadBalancerName}-be'
var varSpoke2LoadBalancerProbeName = '${varSpoke2LoadBalancerName}-probe'
var varSpoke2LoadBalancerRuleName = '${varSpoke2LoadBalancerName}-rule'
var varSpoke2LoadBalancerFrontEndRef = resourceId(
  'Microsoft.Network/loadBalancers/frontendIPConfigurations',
  varSpoke2LoadBalancerName,
  varSpoke2LoadBalancerFrontEndName
)
var varSpoke2LoadBalancerBackEndRef = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  varSpoke2LoadBalancerName,
  varSpoke2LoadBalancerBackEndName
)
var varSpoke2LoadBalancerProbeRef = resourceId(
  'Microsoft.Network/loadBalancers/probes',
  varSpoke2LoadBalancerName,
  varSpoke2LoadBalancerProbeName
)
var varSpoke4LoadBalancerName = '${varVnetSpoke4Name}-lb'
var varSpoke4LoadBalancerFrontEndName = '${varSpoke4LoadBalancerName}-fe'
var varSpoke4LoadBalancerBackEndName = '${varSpoke4LoadBalancerName}-be'
var varSpoke4LoadBalancerProbeName = '${varSpoke4LoadBalancerName}-probe'
var varSpoke4LoadBalancerRuleName = '${varSpoke4LoadBalancerName}-rule'
var varSpoke4LoadBalancerFrontEndRef = resourceId(
  'Microsoft.Network/loadBalancers/frontendIPConfigurations',
  varSpoke4LoadBalancerName,
  varSpoke4LoadBalancerFrontEndName
)
var varSpoke4LoadBalancerBackEndRef = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  varSpoke4LoadBalancerName,
  varSpoke4LoadBalancerBackEndName
)
var varSpoke4LoadBalancerProbeRef = resourceId(
  'Microsoft.Network/loadBalancers/probes',
  varSpoke4LoadBalancerName,
  varSpoke4LoadBalancerProbeName
)

// --------------------
// RESOURCES Networking
// --------------------

resource resVwan 'Microsoft.Network/virtualWans@2024-01-01' = {
  name: varVwanName
  location: parVwanRegion
  properties: {
    type: 'Standard'
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
    sku: 'Standard'
    virtualRouterIps: varVwanHub1VirtualRouterIps
    addressPrefix: varVwanHub1AddressPrefix
    virtualRouterAsn: varVwanAsn
    allowBranchToBranchTraffic: true
    hubRoutingPreference: 'ASPath'
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
    sku: 'Standard'
    virtualRouterIps: varVwanHub2VirtualRouterIps
    addressPrefix: varVwanHub2AddressPrefix
    virtualRouterAsn: varVwanAsn
    allowBranchToBranchTraffic: true
    hubRoutingPreference: 'ASPath'
    virtualRouterAutoScaleConfiguration: {
      minCapacity: 2
    }
  }
}
 
// ----------------------------------------------------------
// RESOURCES Wait 30 mins for vWAN Hubs to finish initialising
// ----------------------------------------------------------

@description('azPowerShellVersion - https://mcr.microsoft.com/v2/azuredeploymentscripts-powershell/tags/list')
resource resWait 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'wait'
  location: resourceGroup().location
  dependsOn: [
    resVwanHub1
    resVwanHub2
  ]
  kind:'AzurePowerShell'
  properties: {
    azPowerShellVersion: '12.2'
    retentionInterval: 'PT1H'
    cleanupPreference: 'Always'
    scriptContent: 'start-sleep -Seconds 1800'
  }
}

resource resNsgRegion1 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgRegion1Name
  location: parVwanHub1Region
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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

resource resVnetBranch1 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: varVnetBranch1Name
  location: varVnetBranch1Region
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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
  dependsOn: [
    resWait
  ]
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

resource resPipBranch1VpnGw 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: varPipBranch1VpnGwName
  location: varVnetBranch1Region
  dependsOn: [
    resVnetBranch1
  ]
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
  dependsOn: [
    resVnetBranch2
  ]
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
      asn: varOnPremisesAsn
    }
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetBranch1Name, varVnetBranch1Subnet2Name)
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
      asn: varOnPremisesAsn
    }
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetBranch2Name, varVnetBranch2Subnet2Name)
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
  dependsOn: [
    resWait
  ]
  properties: {
    virtualHub: {
      id: resVwanHub1.id
    }
  }
}

resource resVpnGatewayHub2 'Microsoft.Network/vpnGateways@2024-01-01' = {
  name: varVpnGatewayHub2Name
  location: parVwanHub2Region
  dependsOn: [
    resWait
  ]
  properties: {
    virtualHub: {
      id: resVwanHub2.id
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
      asn: varOnPremisesAsn
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
      asn: varOnPremisesAsn
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
      asn: varVwanAsn
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
      asn: varVwanAsn
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
      asn: varVwanAsn
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
      asn: varVwanAsn
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

// -----------------------------------------
// RESOURCES (FRR VMs in Spokes 2 & 4)
// -----------------------------------------

resource resVmSpoke21 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke21Name
  location: varVnetSpoke2Region
  dependsOn: [
    resVnetSpoke2
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke21Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      linuxConfiguration: {
        provisionVMAgent: true
        disablePasswordAuthentication: false
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'AutomaticByPlatform'
        }
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resVmSpoke21Nic.id
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
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

resource resVmSpoke21Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: varVmSpoke21NicName
  location: varVnetSpoke2Region
  dependsOn: [
    resVnetSpoke2
    resSpoke2LoadBalancer
  ]
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke2Name, varVnetSpoke2Subnet1Name)
          }
          loadBalancerBackendAddressPools: [
            {
              id: varSpoke2LoadBalancerBackEndRef
            }
          ]
          publicIPAddress: {
            id: resVmSpoke21Pip.id
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
  }
}

resource resVmSpoke21Pip 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: varVmSpoke21PipName
  location: varVnetSpoke2Region
  dependsOn: [
    resVnetSpoke2
  ]
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    ddosSettings: {
      protectionMode: 'Enabled'
    }
  }
}

resource resVmSpoke21Aadlogin 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke21ExtensionAadLogin
  location: varVnetSpoke2Region
  parent: resVmSpoke21
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADSSHLoginForLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke21Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke21ExtensionAutomanage
  location: varVnetSpoke2Region
  parent: resVmSpoke21
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke21CustomScript 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke21ExtensionCustomScript
  location: varVnetSpoke2Region
  parent: resVmSpoke21
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      fileUris: [
        'https://raw.githubusercontent.com/simonhutson/Azure-Bicep-Inter-Region-VWAN-NVA-BGP/refs/heads/main/linuxrouterbgpfrr.sh'
      ]
      commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke2Asn} ${resVmSpoke21Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.2.0.0/16 ${varVwanHub1VirtualRouterIps[0]} ${varVwanHub1VirtualRouterIps[1]}'
    }
  }
}

resource resVmSpoke21Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke21Schedule
  location: varVnetSpoke2Region
  properties: {
    targetResourceId: resVmSpoke21.id
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

resource resVmSpoke22 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke22Name
  location: varVnetSpoke2Region
  dependsOn: [
    resVnetSpoke2
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke22Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      linuxConfiguration: {
        provisionVMAgent: true
        disablePasswordAuthentication: false
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'AutomaticByPlatform'
        }
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resVmSpoke22Nic.id
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
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

resource resVmSpoke22Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: varVmSpoke22NicName
  location: varVnetSpoke2Region
  dependsOn: [
    resVnetSpoke2
    resSpoke2LoadBalancer
  ]
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke2Name, varVnetSpoke2Subnet1Name)
          }
          loadBalancerBackendAddressPools: [
            {
              id: varSpoke2LoadBalancerBackEndRef
            }
          ]
          publicIPAddress: {
            id: resVmSpoke22Pip.id
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
  }
}

resource resVmSpoke22Pip 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: varVmSpoke22PipName
  location: varVnetSpoke2Region
  dependsOn: [
    resVnetSpoke2
  ]
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    ddosSettings: {
      protectionMode: 'Enabled'
    }
  }
}

resource resVmSpoke22Aadlogin 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke22ExtensionAadLogin
  location: varVnetSpoke2Region
  parent: resVmSpoke22
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADSSHLoginForLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke22Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke22ExtensionAutomanage
  location: varVnetSpoke2Region
  parent: resVmSpoke22
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke22CustomScript 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke22ExtensionCustomScript
  location: varVnetSpoke2Region
  parent: resVmSpoke22
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      fileUris: [
        'https://raw.githubusercontent.com/simonhutson/Azure-Bicep-Inter-Region-VWAN-NVA-BGP/refs/heads/main/linuxrouterbgpfrr.sh'
      ]
      commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke2Asn} ${resVmSpoke22Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.2.0.0/16 ${varVwanHub1VirtualRouterIps[0]} ${varVwanHub1VirtualRouterIps[1]}'
    }
  }
}

resource resVmSpoke22Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke22Schedule
  location: varVnetSpoke2Region
  properties: {
    targetResourceId: resVmSpoke22.id
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

resource resSpoke2LoadBalancer 'Microsoft.Network/loadBalancers@2024-01-01' = {
  name: varSpoke2LoadBalancerName
  location: varVnetSpoke2Region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  dependsOn: [
    resVnetSpoke2
  ]
  properties: {
    frontendIPConfigurations: [
      {
        name: varSpoke2LoadBalancerFrontEndName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke2Name, varVnetSpoke2Subnet1Name)
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: varSpoke2LoadBalancerBackEndName
      }
    ]
    probes: [
      {
        name: varSpoke2LoadBalancerProbeName
        properties: {
          port: 22
          protocol: 'Tcp'
        }
      }
    ]
    loadBalancingRules: [
      {
        name: varSpoke2LoadBalancerRuleName
        properties: {
          frontendPort: 0
          protocol: 'All'
          frontendIPConfiguration: {
            id: varSpoke2LoadBalancerFrontEndRef
          }
          backendAddressPool: {
            id: varSpoke2LoadBalancerBackEndRef
          }
          probe: {
            id: varSpoke2LoadBalancerProbeRef
          }
        }
      }
    ]
  }
}

resource resVmSpoke41 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke41Name
  location: varVnetSpoke4Region
  dependsOn: [
    resVnetSpoke4    
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke41Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      linuxConfiguration: {
        provisionVMAgent: true
        disablePasswordAuthentication: false
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'AutomaticByPlatform'
        }
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resVmSpoke41Nic.id
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
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

resource resVmSpoke41Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: varVmSpoke41NicName
  location: varVnetSpoke4Region
  dependsOn: [
    resVnetSpoke4
    resSpoke4LoadBalancer
  ]
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke4Name, varVnetSpoke4Subnet1Name)
          }
          loadBalancerBackendAddressPools: [
            {
              id: varSpoke4LoadBalancerBackEndRef
            }
          ]
          publicIPAddress: {
            id: resVmSpoke41Pip.id
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
  }
}

resource resVmSpoke41Pip 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: varVmSpoke41PipName
  location: varVnetSpoke4Region
  dependsOn: [
    resVnetSpoke4
  ]
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    ddosSettings: {
      protectionMode: 'Enabled'
    }
  }
}

resource resVmSpoke41Aadlogin 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke41ExtensionAadLogin
  location: varVnetSpoke4Region
  parent: resVmSpoke41
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADSSHLoginForLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke41Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke41ExtensionAutomanage
  location: varVnetSpoke4Region
  parent: resVmSpoke41
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke41CustomScript 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke41ExtensionCustomScript
  location: varVnetSpoke4Region
  parent: resVmSpoke41
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      fileUris: [
        'https://raw.githubusercontent.com/simonhutson/Azure-Bicep-Inter-Region-VWAN-NVA-BGP/refs/heads/main/linuxrouterbgpfrr.sh'
      ]
      commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke4Asn} ${resVmSpoke41Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.4.0.0/16 ${varVwanHub2VirtualRouterIps[0]} ${varVwanHub2VirtualRouterIps[1]}'
    }
  }
}

resource resVmSpoke41Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke41Schedule
  location: varVnetSpoke4Region
  properties: {
    targetResourceId: resVmSpoke41.id
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

resource resVmSpoke42 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: varVmSpoke42Name
  location: varVnetSpoke4Region
  dependsOn: [
    resVnetSpoke4    
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varVmSpoke42Name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      linuxConfiguration: {
        provisionVMAgent: true
        disablePasswordAuthentication: false
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'AutomaticByPlatform'
        }
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resVmSpoke42Nic.id
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
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

resource resVmSpoke42Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: varVmSpoke42NicName
  location: varVnetSpoke4Region
  dependsOn: [
    resVnetSpoke4
    resSpoke4LoadBalancer
  ]
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke4Name, varVnetSpoke4Subnet1Name)
          }
          loadBalancerBackendAddressPools: [
            {
              id: varSpoke4LoadBalancerBackEndRef
            }
          ]
          publicIPAddress: {
            id: resVmSpoke42Pip.id
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
  }
}

resource resVmSpoke42Pip 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: varVmSpoke42PipName
  location: varVnetSpoke4Region
  dependsOn: [
    resVnetSpoke4
  ]
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    ddosSettings: {
      protectionMode: 'Enabled'
    }
  }
}

resource resVmSpoke42Aadlogin 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke42ExtensionAadLogin
  location: varVnetSpoke4Region
  parent: resVmSpoke42
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADSSHLoginForLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke42Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke42ExtensionAutomanage
  location: varVnetSpoke4Region
  parent: resVmSpoke42
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

resource resVmSpoke42CustomScript 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  name: varVmSpoke42ExtensionCustomScript
  location: varVnetSpoke4Region
  parent: resVmSpoke42
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      fileUris: [
        'https://raw.githubusercontent.com/simonhutson/Azure-Bicep-Inter-Region-VWAN-NVA-BGP/refs/heads/main/linuxrouterbgpfrr.sh'
      ]
      commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke4Asn} ${resVmSpoke42Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.4.0.0/16 ${varVwanHub2VirtualRouterIps[0]} ${varVwanHub2VirtualRouterIps[1]}'
    }
  }
}

resource resVmSpoke42Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: varVmSpoke42Schedule
  location: varVnetSpoke4Region
  properties: {
    targetResourceId: resVmSpoke42.id
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

resource resSpoke4LoadBalancer 'Microsoft.Network/loadBalancers@2024-01-01' = {
  name: varSpoke4LoadBalancerName
  location: varVnetSpoke4Region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  dependsOn: [
    resVnetSpoke4
  ]
  properties: {
    frontendIPConfigurations: [
      {
        name: varSpoke4LoadBalancerFrontEndName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', varVnetSpoke4Name, varVnetSpoke4Subnet1Name)
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: varSpoke4LoadBalancerBackEndName
      }
    ]
    probes: [
      {
        name: varSpoke4LoadBalancerProbeName
        properties: {
          port: 22
          protocol: 'Tcp'
        }
      }
    ]
    loadBalancingRules: [
      {
        name: varSpoke4LoadBalancerRuleName
        properties: {
          frontendPort: 0
          protocol: 'All'
          frontendIPConfiguration: {
            id: varSpoke4LoadBalancerFrontEndRef
          }
          backendAddressPool: {
            id: varSpoke4LoadBalancerBackEndRef
          }
          probe: {
            id: varSpoke4LoadBalancerProbeRef
          }
        }
      }
    ]
  }
}

resource resVwanHub1VmSpoke21BgpConnection 'Microsoft.Network/virtualHubs/bgpConnections@2024-01-01' = {
  name: varVwanHub1VmSpoke21BgpConnectionName
  parent: resVwanHub1
  properties: {
    peerAsn: varSpoke2Asn
    peerIp: resVmSpoke21Nic.properties.ipConfigurations[0].properties.privateIPAddress
    hubVirtualNetworkConnection: {
      id: resHubVirtualNetworkConnectionHub1Spoke2.id
    }
  }
}

resource resVwanHub1VmSpoke22BgpConnection 'Microsoft.Network/virtualHubs/bgpConnections@2024-01-01' = {
  name: varVwanHub1VmSpoke22BgpConnectionName
  parent: resVwanHub1
  dependsOn: [
    resVwanHub1VmSpoke21BgpConnection
  ]
  properties: {
    peerAsn: varSpoke2Asn
    peerIp: resVmSpoke22Nic.properties.ipConfigurations[0].properties.privateIPAddress
    hubVirtualNetworkConnection: {
      id: resHubVirtualNetworkConnectionHub1Spoke2.id
    }
  }
}

resource resVwanHub2VmSpoke41BgpConnection 'Microsoft.Network/virtualHubs/bgpConnections@2024-01-01' = {
  name: varVwanHub2VmSpoke41BgpConnectionName
  parent: resVwanHub2
  properties: {
    peerAsn: varSpoke4Asn
    peerIp: resVmSpoke41Nic.properties.ipConfigurations[0].properties.privateIPAddress
    hubVirtualNetworkConnection: {
      id: resHubVirtualNetworkConnectionHub2Spoke4.id
    }
  }
}

resource resVwanHub2VmSpoke42BgpConnection 'Microsoft.Network/virtualHubs/bgpConnections@2024-01-01' = {
  name: varVwanHub2VmSpoke42BgpConnectionName
  parent: resVwanHub2
  dependsOn: [
    resVwanHub2VmSpoke41BgpConnection
  ]
  properties: {
    peerAsn: varSpoke4Asn
    peerIp: resVmSpoke42Nic.properties.ipConfigurations[0].properties.privateIPAddress
    hubVirtualNetworkConnection: {
      id: resHubVirtualNetworkConnectionHub2Spoke4.id
    }
  }
}

// --------------------------------
// RESOURCES (Test VMs)
// --------------------------------

@description('List of test VMs')
var varTestVMs = [
  {
    name: 'vm-${varVnetBranch1Name}'
    region: parVwanHub1Region
    vnet: varVnetBranch1Name
  }
  {
    name: 'vm-${varVnetBranch2Name}'
    region: parVwanHub2Region
    vnet: varVnetBranch2Name
  }
  {
    name: 'vm-${varVnetSpoke1Name}'
    region: parVwanHub1Region
    vnet: varVnetSpoke1Name
  }
  {
    name: 'vm-${varVnetSpoke3Name}'
    region: parVwanHub2Region
    vnet: varVnetSpoke3Name
  }
  {
    name: 'vm-${varVnetSpoke5Name}'
    region: parVwanHub1Region
    vnet: varVnetSpoke5Name
  }
  {
    name: 'vm-${varVnetSpoke6Name}'
    region: parVwanHub1Region
    vnet: varVnetSpoke6Name
  }
  {
    name: 'vm-${varVnetSpoke7Name}'
    region: parVwanHub2Region
    vnet: varVnetSpoke7Name
  }
  {
    name: 'vm-${varVnetSpoke8Name}'
    region: parVwanHub2Region
    vnet: varVnetSpoke8Name
  }
]

resource resTestVmPips 'Microsoft.Network/publicIPAddresses@2024-01-01'= [for varTestVM in varTestVMs: {
  name: '${varTestVM.name}-pip'
  location: varTestVM.region
  dependsOn: [
    resVnetBranch1
    resVnetBranch2
    resVnetSpoke1
    resVnetSpoke2
    resVnetSpoke3
    resVnetSpoke4
    resVnetSpoke5
    resVnetSpoke6
    resVnetSpoke7
    resVnetSpoke8
  ]
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    ddosSettings: {
      protectionMode: 'Enabled'
    }
  }  
}]

resource resTestVmNics 'Microsoft.Network/networkInterfaces@2024-01-01'= [for varTestVM in varTestVMs: {
  name: '${varTestVM.name}-nic'
  location: varTestVM.region
  dependsOn: [
    resTestVmPips
  ]
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets/', varTestVM.vnet, 'main')
          }
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses/', '${varTestVM.name}-pip')
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
  }

}]

resource resTestVms 'Microsoft.Compute/virtualMachines@2024-07-01'= [for varTestVM in varTestVMs: {
  name: varTestVM.name
  location: varTestVM.region
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    resTestVmNics
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v5'
    }
    storageProfile: {
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
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: varTestVM.name
      adminUsername: parVmUserName
      adminPassword: parVmPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'AutomaticByPlatform'
        }
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces/','${varTestVM.name}-nic')
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
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
}]

resource resTestVmsAntmalware 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = [for varTestVM in varTestVMs: {
  name: '${varTestVM.name}/extension-antimalware'
  location: varTestVM.region
  dependsOn: [
    resTestVms
  ]
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
}]

resource resTestVmsAutomanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = [for varTestVM in varTestVMs: {
  name: '${varTestVM.name}/extension-automanage'
  location: varTestVM.region
  dependsOn: [
    resTestVms
  ]
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}]

resource resTestVmsSchedule 'Microsoft.DevTestLab/schedules@2018-09-15' = [for varTestVM in varTestVMs: {
  name: 'shutdown-computevm-${varTestVM.name}'
  location: varTestVM.region
  dependsOn: [
    resTestVms
  ]
  properties: {
    targetResourceId: resourceId('Microsoft.Compute/virtualMachines/', varTestVM.name)
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
}]

