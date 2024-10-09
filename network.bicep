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

var varBgpConnectionNameVwanHub1VmSpoke21 = 'bgpconnection-${varVwanHub1Name}-${varVmSpoke21Name}'
var varBgpConnectionNameVwanHub1VmSpoke22 = 'bgbconnection-${varVwanHub1Name}-${varVmSpoke22Name}'
var varBgpConnectionNameVwanHub2VmSpoke41 = 'bgbconnection-${varVwanHub2Name}-${varVmSpoke41Name}'
var varBgpConnectionNameVwanHub2VmSpoke42 = 'bgbconnection-${varVwanHub2Name}-${varVmSpoke42Name}'

var varVnetBranch1Name = 'branch1'
var varVnetBranch1Region = parVwanHub1Region
var varVnetBranch1AddressPrefix = '10.100.0.0/16'
var varVnetBranch1Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.100.0.0/24'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgBranch1.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.100.1.0/26'
      ]
      defaultOutboundAccess: true
    }
  }
  {
    name: 'GatewaySubnet'
    properties: {
      addressPrefixes: [
        '10.100.100.0/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetBranch2Name = 'branch2'
var varVnetBranch2Region = parVwanHub2Region
var varVnetBranch2AddressPrefix = '10.200.0.0/16'
var varVnetBranch2Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.200.0.0/24'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgBranch2.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.200.1.0/26'
      ]
      defaultOutboundAccess: true
    }
  }
  {
    name: 'GatewaySubnet'
    properties: {
      addressPrefixes: [
        '10.200.100.0/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetSpoke1Name = 'spoke1'
var varVnetSpoke1Region = parVwanHub1Region
var varVnetSpoke1AddressPrefix = '10.1.0.0/24'
var varVnetSpoke1Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.1.0.0/27'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgSpoke1.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.1.0.128/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetSpoke2Name = 'spoke2'
var varVnetSpoke2Region = parVwanHub1Region
var varVnetSpoke2AddressPrefix = '10.2.0.0/24'
var varVnetSpoke2Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.2.0.0/27'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgSpoke2.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.2.0.128/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetSpoke3Name = 'spoke3'
var varVnetSpoke3Region = parVwanHub2Region
var varVnetSpoke3AddressPrefix = '10.3.0.0/24'
var varVnetSpoke3Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.3.0.0/27'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgSpoke3.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.3.0.128/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetSpoke4Name = 'spoke4'
var varVnetSpoke4Region = parVwanHub2Region
var varVnetSpoke4AddressPrefix = '10.4.0.0/24'
var varVnetSpoke4Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.4.0.0/27'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgSpoke4.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.4.0.128/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetSpoke5Name = 'spoke5'
var varVnetSpoke5Region = parVwanHub1Region
var varVnetSpoke5AddressPrefix = '10.2.1.0/24'
var varVnetSpoke5Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.2.1.0/27'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgSpoke5.id
      }
      routeTable: {
        id: resRouteTableSpoke5.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.2.1.128/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetSpoke6Name = 'spoke6'
var varVnetSpoke6Region = parVwanHub1Region
var varVnetSpoke6AddressPrefix = '10.2.2.0/24'
var varVnetSpoke6Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.2.2.0/27'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgSpoke6.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.2.2.128/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetSpoke7Name = 'spoke7'
var varVnetSpoke7Region = parVwanHub2Region
var varVnetSpoke7AddressPrefix = '10.4.1.0/24'
var varVnetSpoke7Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.4.1.0/27'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgSpoke7.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.4.1.128/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetSpoke8Name = 'spoke8'
var varVnetSpoke8Region = parVwanHub2Region
var varVnetSpoke8AddressPrefix = '10.4.2.0/24'
var varVnetSpoke8Subnets = [
  {
    name: 'main'
    properties: {
      addressPrefixes: [
        '10.4.2.0/27'
      ]
      defaultOutboundAccess: true
      networkSecurityGroup: {
        id: resNsgSpoke8.id
      }
    }
  }
  {
    name: 'AzureBastionSubnet'
    properties: {
      addressPrefixes: [
        '10.4.2.128/26'
      ]
      defaultOutboundAccess: true
    }
  }
]

var varVnetPeeringSpoke2to5Name = 'vnetpeering-${varVnetSpoke2Name}-to-${varVnetSpoke5Name}'
var varVnetPeeringSpoke5to2Name = 'vnetpeering-${varVnetSpoke5Name}-to-${varVnetSpoke2Name}'
var varVnetPeeringSpoke2to6Name = 'vnetpeering-${varVnetSpoke2Name}-to-${varVnetSpoke6Name}'
var varVnetPeeringSpoke6to2Name = 'vnetpeering-${varVnetSpoke6Name}-to-${varVnetSpoke2Name}'
var varVnetPeeringSpoke4to7Name = 'vnetpeering-${varVnetSpoke4Name}-to-${varVnetSpoke7Name}'
var varVnetPeeringSpoke7to4Name = 'vnetpeering-${varVnetSpoke7Name}-to-${varVnetSpoke4Name}'
var varVnetPeeringSpoke4to8Name = 'vnetpeering-${varVnetSpoke4Name}-to-${varVnetSpoke8Name}'
var varVnetPeeringSpoke8to4Name = 'vnetpeering-${varVnetSpoke8Name}-to-${varVnetSpoke4Name}'

var varNsgBranch1Name = 'nsg-${varVnetBranch1Name}'
var varNsgBranch2Name = 'nsg-${varVnetBranch2Name}'
var varNsgSpoke1Name = 'nsg-${varVnetSpoke1Name}'
var varNsgSpoke2Name = 'nsg-${varVnetSpoke2Name}'
var varNsgSpoke3Name = 'nsg-${varVnetSpoke3Name}'
var varNsgSpoke4Name = 'nsg-${varVnetSpoke4Name}'
var varNsgSpoke5Name = 'nsg-${varVnetSpoke5Name}'
var varNsgSpoke6Name = 'nsg-${varVnetSpoke6Name}'
var varNsgSpoke7Name = 'nsg-${varVnetSpoke7Name}'
var varNsgSpoke8Name = 'nsg-${varVnetSpoke8Name}'

var varRouteTableSpoke5Name = 'routetable-${varVnetSpoke5Name}'
var varRouteTableSpoke6Name = 'routetable-${varVnetSpoke6Name}'
var varRouteTableSpoke7Name = 'routetable-${varVnetSpoke7Name}'
var varRouteTableSpoke8Name = 'routetable-${varVnetSpoke8Name}'

var varHubVnetConnectionHub1Spoke1Name = 'hubvnetconnection-${varVwanHub1Name}-to-${varVnetSpoke1Name}'
var varHubVnetConnectionHub1Spoke2Name = 'hubvnetconnection-${varVwanHub1Name}-to-${varVnetSpoke2Name}'
var varHubVnetConnectionHub2Spoke3Name = 'hubvnetconnection-${varVwanHub2Name}-to-${varVnetSpoke3Name}'
var varHubVnetConnectionHub2Spoke4Name = 'hubvnetconnection-${varVwanHub2Name}-to-${varVnetSpoke4Name}'

var varVnetGatewayBranch1Name = 'vnetgateway-${varVnetBranch1Name}'
var varVnetGatewayBranch2Name = 'vnetgateway-${varVnetBranch2Name}'

var varPipVnetGatewayBranch1Name = 'vnetgateway-${varVnetBranch1Name}-pip'
var varPipVnetGatewayBranch2Name = 'vnetgateway-${varVnetBranch2Name}-pip'

var varVpnGatewayHub1Name = 'vpngateway-${varVwanHub1Name}'
var varVpnGatewayHub2Name = 'vpngateway-${varVwanHub2Name}'

var varVpnSiteBranch1Name = 'vpnsite-${varVnetBranch1Name}'
var varVpnSiteBranch2Name = 'vpnsite-${varVnetBranch2Name}'

var varVpnConnectionHub1Branch1Name = 'vpnconnection-${varVwanHub1Name}-to-${varVnetBranch1Name}'
var varVpnConnectionHub2Branch2Name = 'vpnconnection-${varVwanHub1Name}-to-${varVnetBranch2Name}'

var varVnetVwanHub1LocalNetworkGw1Name = 'localnetworkgateway-${varVwanHub1Name}-gw1'
var varVnetVwanHub1LocalNetworkGw2Name = 'localnetworkgateway-${varVwanHub1Name}-gw2'
var varVnetVwanHub2LocalNetworkGw1Name = 'localnetworkgateway-${varVwanHub2Name}-gw1'
var varVnetVwanHub2LocalNetworkGw2Name = 'localnetworkgateway-${varVwanHub2Name}-gw2'

var varConnectionBranch1Hub1Gw1Name = 'connection-${varVnetBranch1Name}-to-${varVwanHub1Name}-gw1'
var varConnectionBranch1Hub1Gw2Name = 'connection-${varVnetBranch1Name}-to-${varVwanHub1Name}-gw2'
var varConnectionBranch2Hub2Gw1Name = 'connection-${varVnetBranch2Name}-to-${varVwanHub2Name}-gw1'
var varConnectionBranch2Hub2Gw2Name = 'connection-${varVnetBranch2Name}-to-${varVwanHub2Name}-gw2'

var varVmSpoke21Name = 'vm-${varVnetSpoke2Name}-1'
var varVmSpoke22Name = 'vm-${varVnetSpoke2Name}-2'
var varVmSpoke41Name = 'vm-${varVnetSpoke4Name}-1'
var varVmSpoke42Name = 'vm-${varVnetSpoke4Name}-2'

var varVmSpoke21NicName = '${varVmSpoke21Name}-nic'
var varVmSpoke22NicName = '${varVmSpoke22Name}-nic'
var varVmSpoke41NicName = '${varVmSpoke41Name}-nic'
var varVmSpoke42NicName = '${varVmSpoke42Name}-nic'

var varVmSpoke21ExtensionAadLogin = 'aadlogin-${varVmSpoke21Name}'
var varVmSpoke22ExtensionAadLogin = 'aadlogin-${varVmSpoke22Name}'
var varVmSpoke41ExtensionAadLogin = 'aadlogin-${varVmSpoke41Name}'
var varVmSpoke42ExtensionAadLogin = 'aadlogin-${varVmSpoke42Name}'

var varVmSpoke21ExtensionAutomanage = 'automanage-${varVmSpoke21Name}'
var varVmSpoke22ExtensionAutomanage = 'automanage-${varVmSpoke22Name}'
var varVmSpoke41ExtensionAutomanage = 'automanage-${varVmSpoke41Name}'
var varVmSpoke42ExtensionAutomanage = 'automanage-${varVmSpoke42Name}'

var varVmSpoke21ExtensionCustomScript = 'customscript-${varVmSpoke21Name}'
var varVmSpoke22ExtensionCustomScript = 'customscript-${varVmSpoke22Name}'
var varVmSpoke41ExtensionCustomScript = 'customscript-${varVmSpoke41Name}'
var varVmSpoke42ExtensionCustomScript = 'customscript-${varVmSpoke42Name}'

var varVmSpoke21Schedule = 'shutdown-computevm-${varVmSpoke21Name}'
var varVmSpoke22Schedule = 'shutdown-computevm-${varVmSpoke22Name}'
var varVmSpoke41Schedule = 'shutdown-computevm-${varVmSpoke41Name}'
var varVmSpoke42Schedule = 'shutdown-computevm-${varVmSpoke42Name}'

var varLoadBalancerSpoke2Name = 'loadbalancer-${varVnetSpoke2Name}'
// var varLoadBalancerFrontEndSpoke2Name = '${varLoadBalancerSpoke2Name}-fe'
// var varLoadBalancerBackEndSpoke2Name = '${varLoadBalancerSpoke2Name}-be'
// var varLoadBalancerProbeSpoke2Name = '${varLoadBalancerSpoke2Name}-probe'
// var varLoadBalancerRuleSpoke2Name = '${varLoadBalancerSpoke2Name}-rule'

var varLoadBalancerSpoke4Name = 'loadbalancer-${varVnetSpoke4Name}'
// var varLoadBalancerFrontEndSpoke4Name = '${varLoadBalancerSpoke4Name}-fe'
// var varLoadBalancerBackEndSpoke4Name = '${varLoadBalancerSpoke4Name}-be'
// var varLoadBalancerProbeSpoke4Name = '${varLoadBalancerSpoke4Name}-probe'
// var varLoadBalancerRuleSpoke4Name = '${varLoadBalancerSpoke4Name}-rule'

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

resource resNsgBranch1 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgBranch1Name
  location: varVnetBranch1Region
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
          priority: 4000
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

resource resNsgBranch2 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgBranch2Name
  location: varVnetBranch2Region
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
          priority: 4000
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

resource resNsgSpoke1 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgSpoke1Name
  location: varVnetSpoke1Region
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
          priority: 4000
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

resource resNsgSpoke2 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgSpoke2Name
  location: varVnetSpoke2Region
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
          priority: 4000
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

resource resNsgSpoke3 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgSpoke3Name
  location: varVnetSpoke3Region
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
          priority: 4000
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

resource resNsgSpoke4 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgSpoke4Name
  location: varVnetSpoke4Region
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
          priority: 4000
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

resource resNsgSpoke5 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgSpoke5Name
  location: varVnetSpoke5Region
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
          priority: 4000
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

resource resNsgSpoke6 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgSpoke6Name
  location: varVnetSpoke6Region
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
          priority: 4000
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

resource resNsgSpoke7 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgSpoke7Name
  location: varVnetSpoke7Region
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
          priority: 4000
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

resource resNsgSpoke8 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: varNsgSpoke8Name
  location: varVnetSpoke8Region
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
          priority: 4000
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

resource resRouteTableSpoke5 'Microsoft.Network/routeTables@2024-01-01' = {
  name: varRouteTableSpoke5Name
  location: varVnetSpoke5Region
  dependsOn: [
    resWait
  ]
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'AzureCloud-to-Internet'
        properties: {
          addressPrefix: 'AzureCloud'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'Default-to-NVA'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resLoadBalancerSpoke2.properties.frontendIPConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource resRouteTableSpoke6 'Microsoft.Network/routeTables@2024-01-01' = {
  name: varRouteTableSpoke6Name
  location: varVnetSpoke6Region
  dependsOn: [
    resWait
  ]
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'AzureCloud-to-Internet'
        properties: {
          addressPrefix: 'AzureCloud'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'Default-to-NVA'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resLoadBalancerSpoke2.properties.frontendIPConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource resRouteTableSpoke7 'Microsoft.Network/routeTables@2024-01-01' = {
  name: varRouteTableSpoke7Name
  location: varVnetSpoke7Region
  dependsOn: [
    resWait
  ]
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'AzureCloud-to-Internet'
        properties: {
          addressPrefix: 'AzureCloud'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'Default-to-NVA'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resLoadBalancerSpoke4.properties.frontendIPConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource resRouteTableSpoke8 'Microsoft.Network/routeTables@2024-01-01' = {
  name: varRouteTableSpoke8Name
  location: varVnetSpoke8Region
  dependsOn: [
    resWait
  ]
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'AzureCloud-to-Internet'
        properties: {
          addressPrefix: 'AzureCloud'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'Default-to-NVA'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resLoadBalancerSpoke4.properties.frontendIPConfigurations[0].properties.privateIPAddress
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetBranch1Subnets
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetBranch2Subnets
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetSpoke1Subnets
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetSpoke2Subnets
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetSpoke3Subnets
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetSpoke4Subnets
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetSpoke5Subnets
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetSpoke6Subnets
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetSpoke7Subnets
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
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: varVnetSpoke8Subnets
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
  name: varHubVnetConnectionHub1Spoke1Name
  parent: resVwanHub1
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke1.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub1Spoke2 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: varHubVnetConnectionHub1Spoke2Name
  parent: resVwanHub1
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke2.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub2Spoke3 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: varHubVnetConnectionHub2Spoke3Name
  parent: resVwanHub2
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke3.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub2Spoke4 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: varHubVnetConnectionHub2Spoke4Name
  parent: resVwanHub2
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke4.id
    }
  }
}

resource resPipBranch1VpnGw 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: varPipVnetGatewayBranch1Name
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
  name: varPipVnetGatewayBranch2Name
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
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              varVnetBranch1Name,
              'GatewaySubnet'
            )
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
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              varVnetBranch2Name,
              'GatewaySubnet'
            )
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
  resource resVmSpoke21AadLogin 'extensions@2024-07-01' = {
    name: varVmSpoke21ExtensionAadLogin
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADSSHLoginForLinux'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      settings: {}
      protectedSettings: {}
    }  
  }
  resource resVmSpoke21Automanage 'extensions@2024-07-01' = {
    name: varVmSpoke21ExtensionAutomanage
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
  resource resVmSpoke21CustomScript 'extensions@2024-07-01' = {
    name: varVmSpoke21ExtensionCustomScript
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
}

resource resVmSpoke21Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: varVmSpoke21NicName
  location: varVnetSpoke2Region
  dependsOn: [
    resVnetSpoke2
    resLoadBalancerSpoke2
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
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              varVnetSpoke2Name,
              'main'
            )
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/backendAddressPools',
                varLoadBalancerSpoke2Name,
                'backend'
              )
            }
          ]
        }
      }
    ]
  }
}

// resource resVmSpoke21Aadlogin 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke21ExtensionAadLogin
//   location: varVnetSpoke2Region
//   parent: resVmSpoke21
//   properties: {
//     publisher: 'Microsoft.Azure.ActiveDirectory'
//     type: 'AADSSHLoginForLinux'
//     typeHandlerVersion: '1.0'
//     autoUpgradeMinorVersion: true
//     settings: {}
//     protectedSettings: {}
//   }
// }

// resource resVmSpoke21Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke21ExtensionAutomanage
//   location: varVnetSpoke2Region
//   parent: resVmSpoke21
//   properties: {
//     publisher: 'Microsoft.GuestConfiguration'
//     type: 'ConfigurationforLinux'
//     typeHandlerVersion: '1.0'
//     autoUpgradeMinorVersion: true
//     enableAutomaticUpgrade: true
//     settings: {}
//     protectedSettings: {}
//   }
// }

// resource resVmSpoke21CustomScript 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke21ExtensionCustomScript
//   location: varVnetSpoke2Region
//   parent: resVmSpoke21
//   properties: {
//     publisher: 'Microsoft.Azure.Extensions'
//     type: 'CustomScript'
//     typeHandlerVersion: '2.1'
//     autoUpgradeMinorVersion: true
//     settings: {}
//     protectedSettings: {
//       fileUris: [
//         'https://raw.githubusercontent.com/simonhutson/Azure-Bicep-Inter-Region-VWAN-NVA-BGP/refs/heads/main/linuxrouterbgpfrr.sh'
//       ]
//       commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke2Asn} ${resVmSpoke21Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.2.0.0/16 ${varVwanHub1VirtualRouterIps[0]} ${varVwanHub1VirtualRouterIps[1]}'
//     }
//   }
// }

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
  resource resVmSpoke22AadLogin 'extensions@2024-07-01' = {
    name: varVmSpoke22ExtensionAadLogin
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADSSHLoginForLinux'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      settings: {}
      protectedSettings: {}
    }  
  }
  resource resVmSpoke22Automanage 'extensions@2024-07-01' = {
    name: varVmSpoke22ExtensionAutomanage
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
  resource resVmSpoke22CustomScript 'extensions@2024-07-01' = {
    name: varVmSpoke22ExtensionCustomScript
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
}

resource resVmSpoke22Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: varVmSpoke22NicName
  location: varVnetSpoke2Region
  dependsOn: [
    resVnetSpoke2
    resLoadBalancerSpoke2
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
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              varVnetSpoke2Name,
              'main'
            )
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/backendAddressPools',
                varLoadBalancerSpoke2Name,
                'backend'
              )
            }
          ]
        }
      }
    ]
  }
}

// resource resVmSpoke22Aadlogin 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke22ExtensionAadLogin
//   location: varVnetSpoke2Region
//   parent: resVmSpoke22
//   properties: {
//     publisher: 'Microsoft.Azure.ActiveDirectory'
//     type: 'AADSSHLoginForLinux'
//     typeHandlerVersion: '1.0'
//     autoUpgradeMinorVersion: true
//     settings: {}
//     protectedSettings: {}
//   }
// }

// resource resVmSpoke22Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke22ExtensionAutomanage
//   location: varVnetSpoke2Region
//   parent: resVmSpoke22
//   properties: {
//     publisher: 'Microsoft.GuestConfiguration'
//     type: 'ConfigurationforLinux'
//     typeHandlerVersion: '1.0'
//     autoUpgradeMinorVersion: true
//     enableAutomaticUpgrade: true
//     settings: {}
//     protectedSettings: {}
//   }
// }

// resource resVmSpoke22CustomScript 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke22ExtensionCustomScript
//   location: varVnetSpoke2Region
//   parent: resVmSpoke22
//   properties: {
//     publisher: 'Microsoft.Azure.Extensions'
//     type: 'CustomScript'
//     typeHandlerVersion: '2.1'
//     autoUpgradeMinorVersion: true
//     settings: {}
//     protectedSettings: {
//       fileUris: [
//         'https://raw.githubusercontent.com/simonhutson/Azure-Bicep-Inter-Region-VWAN-NVA-BGP/refs/heads/main/linuxrouterbgpfrr.sh'
//       ]
//       commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke2Asn} ${resVmSpoke22Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.2.0.0/16 ${varVwanHub1VirtualRouterIps[0]} ${varVwanHub1VirtualRouterIps[1]}'
//     }
//   }
// }

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

resource resLoadBalancerSpoke2 'Microsoft.Network/loadBalancers@2024-01-01' = {
  name: varLoadBalancerSpoke2Name
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
        name: 'frontend'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              varVnetSpoke2Name,
              'main'
            )
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend'
      }
    ]
    probes: [
      {
        name: 'probe'
        properties: {
          port: 22
          protocol: 'Tcp'
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'rule'
        properties: {
          frontendPort: 0
          protocol: 'All'
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIPConfigurations',
              varLoadBalancerSpoke2Name,
              'frontend'
            )
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              varLoadBalancerSpoke2Name,
              'backend'
            )
          }
          probe: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/probes',
              varLoadBalancerSpoke2Name,
              'probe'
            )
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
  resource resVmSpoke41AadLogin 'extensions@2024-07-01' = {
    name: varVmSpoke41ExtensionAadLogin
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADSSHLoginForLinux'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      settings: {}
      protectedSettings: {}
    }  
  }
  resource resVmSpoke41Automanage 'extensions@2024-07-01' = {
    name: varVmSpoke41ExtensionAutomanage
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
  resource resVmSpoke41CustomScript 'extensions@2024-07-01' = {
    name: varVmSpoke41ExtensionCustomScript
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
        commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke4Asn} ${resVmSpoke41Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.2.0.0/16 ${varVwanHub1VirtualRouterIps[0]} ${varVwanHub1VirtualRouterIps[1]}'
      }
    }
  }
}

resource resVmSpoke41Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: varVmSpoke41NicName
  location: varVnetSpoke4Region
  dependsOn: [
    resVnetSpoke4
    resLoadBalancerSpoke4
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
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              varVnetSpoke4Name,
              'main'
            )
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/backendAddressPools',
                varLoadBalancerSpoke4Name,
                'backend'
              )
            }
          ]
        }
      }
    ]
  }
}

// resource resVmSpoke41Aadlogin 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke41ExtensionAadLogin
//   location: varVnetSpoke4Region
//   parent: resVmSpoke41
//   properties: {
//     publisher: 'Microsoft.Azure.ActiveDirectory'
//     type: 'AADSSHLoginForLinux'
//     typeHandlerVersion: '1.0'
//     autoUpgradeMinorVersion: true
//     settings: {}
//     protectedSettings: {}
//   }
// }

// resource resVmSpoke41Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke41ExtensionAutomanage
//   location: varVnetSpoke4Region
//   parent: resVmSpoke41
//   properties: {
//     publisher: 'Microsoft.GuestConfiguration'
//     type: 'ConfigurationforLinux'
//     typeHandlerVersion: '1.0'
//     autoUpgradeMinorVersion: true
//     enableAutomaticUpgrade: true
//     settings: {}
//     protectedSettings: {}
//   }
// }

// resource resVmSpoke41CustomScript 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke41ExtensionCustomScript
//   location: varVnetSpoke4Region
//   parent: resVmSpoke41
//   properties: {
//     publisher: 'Microsoft.Azure.Extensions'
//     type: 'CustomScript'
//     typeHandlerVersion: '2.1'
//     autoUpgradeMinorVersion: true
//     settings: {}
//     protectedSettings: {
//       fileUris: [
//         'https://raw.githubusercontent.com/simonhutson/Azure-Bicep-Inter-Region-VWAN-NVA-BGP/refs/heads/main/linuxrouterbgpfrr.sh'
//       ]
//       commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke4Asn} ${resVmSpoke41Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.4.0.0/16 ${varVwanHub2VirtualRouterIps[0]} ${varVwanHub2VirtualRouterIps[1]}'
//     }
//   }
// }

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
  resource resVmSpoke42AadLogin 'extensions@2024-07-01' = {
    name: varVmSpoke42ExtensionAadLogin
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADSSHLoginForLinux'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      settings: {}
      protectedSettings: {}
    }  
  }
  resource resVmSpoke42Automanage 'extensions@2024-07-01' = {
    name: varVmSpoke42ExtensionAutomanage
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
  resource resVmSpoke42CustomScript 'extensions@2024-07-01' = {
    name: varVmSpoke42ExtensionCustomScript
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
        commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke4Asn} ${resVmSpoke42Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.2.0.0/16 ${varVwanHub1VirtualRouterIps[0]} ${varVwanHub1VirtualRouterIps[1]}'
      }
    }
  }
}

resource resVmSpoke42Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: varVmSpoke42NicName
  location: varVnetSpoke4Region
  dependsOn: [
    resVnetSpoke4
    resLoadBalancerSpoke4
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
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              varVnetSpoke4Name,
              'main'
            )
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/backendAddressPools',
                varLoadBalancerSpoke4Name,
                'backend'
              )
            }
          ]
        }
      }
    ]
  }
}

// resource resVmSpoke42Aadlogin 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke42ExtensionAadLogin
//   location: varVnetSpoke4Region
//   parent: resVmSpoke42
//   properties: {
//     publisher: 'Microsoft.Azure.ActiveDirectory'
//     type: 'AADSSHLoginForLinux'
//     typeHandlerVersion: '1.0'
//     autoUpgradeMinorVersion: true
//     settings: {}
//     protectedSettings: {}
//   }
// }

// resource resVmSpoke42Automanage 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke42ExtensionAutomanage
//   location: varVnetSpoke4Region
//   parent: resVmSpoke42
//   properties: {
//     publisher: 'Microsoft.GuestConfiguration'
//     type: 'ConfigurationforLinux'
//     typeHandlerVersion: '1.0'
//     autoUpgradeMinorVersion: true
//     enableAutomaticUpgrade: true
//     settings: {}
//     protectedSettings: {}
//   }
// }

// resource resVmSpoke42CustomScript 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
//   name: varVmSpoke42ExtensionCustomScript
//   location: varVnetSpoke4Region
//   parent: resVmSpoke42
//   properties: {
//     publisher: 'Microsoft.Azure.Extensions'
//     type: 'CustomScript'
//     typeHandlerVersion: '2.1'
//     autoUpgradeMinorVersion: true
//     settings: {}
//     protectedSettings: {
//       fileUris: [
//         'https://raw.githubusercontent.com/simonhutson/Azure-Bicep-Inter-Region-VWAN-NVA-BGP/refs/heads/main/linuxrouterbgpfrr.sh'
//       ]
//       commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke4Asn} ${resVmSpoke42Nic.properties.ipConfigurations[0].properties.privateIPAddress} 10.4.0.0/16 ${varVwanHub2VirtualRouterIps[0]} ${varVwanHub2VirtualRouterIps[1]}'
//     }
//   }
// }

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

resource resLoadBalancerSpoke4 'Microsoft.Network/loadBalancers@2024-01-01' = {
  name: varLoadBalancerSpoke4Name
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
        name: 'frontend'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              varVnetSpoke4Name,
              'main'
            )
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend'
      }
    ]
    probes: [
      {
        name: 'probe'
        properties: {
          port: 22
          protocol: 'Tcp'
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'rule'
        properties: {
          frontendPort: 0
          protocol: 'All'
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIPConfigurations',
              varLoadBalancerSpoke4Name,
              'frontend'
            )
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              varLoadBalancerSpoke4Name,
              'backend'
            )
          }
          probe: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/probes',
              varLoadBalancerSpoke4Name,
              'probe'
            )
          }
        }
      }
    ]
  }
}

resource resVwanHub1VmSpoke21BgpConnection 'Microsoft.Network/virtualHubs/bgpConnections@2024-01-01' = {
  name: varBgpConnectionNameVwanHub1VmSpoke21
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
  name: varBgpConnectionNameVwanHub1VmSpoke22
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
  name: varBgpConnectionNameVwanHub2VmSpoke41
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
  name: varBgpConnectionNameVwanHub2VmSpoke42
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

// ------------------------------------
// RESOURCES (Test VMs & Bastion Hosts)
// ------------------------------------

@description('List of test VMs')
var varTestVMs = [
  {
    region: varVnetBranch1Region
    vnet: varVnetBranch1Name
  }
  {
    region: varVnetBranch2Region
    vnet: varVnetBranch2Name
  }
  {
    region: varVnetSpoke1Region
    vnet: varVnetSpoke1Name
  }
  {
    region: varVnetSpoke2Region
    vnet: varVnetSpoke2Name
  }
  {
    region: varVnetSpoke3Region
    vnet: varVnetSpoke3Name
  }
  {
    region: varVnetSpoke4Region
    vnet: varVnetSpoke4Name
  }
  {
    region: varVnetSpoke5Region
    vnet: varVnetSpoke5Name
  }
  {
    region: varVnetSpoke6Region
    vnet: varVnetSpoke6Name
  }
  {
    region: varVnetSpoke7Region
    vnet: varVnetSpoke7Name
  }
  {
    region: varVnetSpoke8Region
    vnet: varVnetSpoke8Name
  }
]

resource resBastionPips 'Microsoft.Network/publicIPAddresses@2024-01-01'= [for varTestVM in varTestVMs: {
  name: 'bastion-${varTestVM.vnet}-pip'
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
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    ddosSettings: {
      protectionMode: 'Enabled'
    }
  }  
}]

resource resBastions 'Microsoft.Network/bastionHosts@2024-01-01' = [for varTestVM in varTestVMs: {
  name: 'bastion-${varTestVM.vnet}'
  location: varTestVM.region
  dependsOn: [
    resBastionPips
  ]
  sku: {
    name: 'Basic'
  }
  properties: {
    scaleUnits: 2
    ipConfigurations:[
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(
              'Microsoft.Network/publicIPAddresses/',
              'bastion-${varTestVM.vnet}-pip'
            )
          }
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets/',
              varTestVM.vnet, 
              'AzureBastionSubnet'
            )
          }
        }
      }
    ]
  }
}]

resource resTestVmNics 'Microsoft.Network/networkInterfaces@2024-01-01'= [for varTestVM in varTestVMs: {
  name: 'vm-${varTestVM.vnet}-nic'
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
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets/',
              varTestVM.vnet, 
              'main'
            )
          }
          // publicIPAddress: {
          //   id: resourceId(
          //     'Microsoft.Network/publicIPAddresses/',
          //     'vm-${varTestVM.vnet}-pip'
          //   )
          //   properties: {
          //     deleteOption: 'Delete'
          //   }
          // }
        }
      }
    ]
  }
}]

resource resTestVms 'Microsoft.Compute/virtualMachines@2024-07-01'= [for varTestVM in varTestVMs: {
  name: 'vm-${varTestVM.vnet}'
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
      computerName: 'vm-${varTestVM.vnet}'
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
          id: resourceId(
            'Microsoft.Network/networkInterfaces/',
            'vm-${varTestVM.vnet}-nic'
          )
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
  name: 'vm-${varTestVM.vnet}/antimalware'
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
  name: 'vm-${varTestVM.vnet}/automanage'
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
  name: 'shutdown-computevm-vm-${varTestVM.vnet}'
  location: varTestVM.region
  dependsOn: [
    resTestVms
  ]
  properties: {
    targetResourceId: resourceId(
      'Microsoft.Compute/virtualMachines/',
      'vm-${varTestVM.vnet}'
    )
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

// ------------------------------------------------
// RESOURCES (Apply Route Tables to Existing VNETs)
// ------------------------------------------------

resource resVnetSpoke5Existing 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: varVnetSpoke5Name
}

resource resVnetSpoke5SubnetMain 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: 'main'
  parent: resVnetSpoke5Existing
  dependsOn: [
    resVmSpoke21
    resVmSpoke22
    resTestVms
  ]
  properties: {
    routeTable: {
      id: resRouteTableSpoke5.id
    }
  }
}

resource resVnetSpoke6Existing 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: varVnetSpoke6Name
}

resource resVnetSpoke6SubnetMain 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: 'main'
  parent: resVnetSpoke6Existing
  dependsOn: [
    resVmSpoke21
    resVmSpoke22
    resTestVms
  ]
  properties: {
    routeTable: {
      id: resRouteTableSpoke6.id
    }
  }
}

resource resVnetSpoke7Existing 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: varVnetSpoke7Name
}

resource resVnetSpoke7SubnetMain 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: 'main'
  parent: resVnetSpoke7Existing
  dependsOn: [
    resVmSpoke41
    resVmSpoke42
    resTestVms
  ]
  properties: {
    routeTable: {
      id: resRouteTableSpoke7.id
    }
  }
}

resource resVnetSpoke8Existing 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: varVnetSpoke8Name
}

resource resVnetSpoke8SubnetMain 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  name: 'main'
  parent: resVnetSpoke8Existing
  dependsOn: [
    resVmSpoke41
    resVmSpoke42
    resTestVms
  ]
  properties: {
    routeTable: {
      id: resRouteTableSpoke8.id
    }
  }
}
