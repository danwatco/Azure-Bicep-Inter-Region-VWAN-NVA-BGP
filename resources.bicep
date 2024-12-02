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

var varVmSize = 'Standard_B2as_v2'

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

// ----------------------------------------------
// RESOURCES VNETs, NSGs, Route Tables & Peerings
// ----------------------------------------------

resource resNsgBranch1 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-${varVnetBranch1Name}'
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
  name: 'nsg-${varVnetBranch2Name}'
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
  name: 'nsg-${varVnetSpoke1Name}'
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
  name: 'nsg-${varVnetSpoke2Name}'
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
  name: 'nsg-${varVnetSpoke3Name}'
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
  name: 'nsg-${varVnetSpoke4Name}'
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
  name: 'nsg-${varVnetSpoke5Name}'
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
  name: 'nsg-${varVnetSpoke6Name}'
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
  name: 'nsg-${varVnetSpoke7Name}'
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
  name: 'nsg-${varVnetSpoke8Name}'
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
  name: 'rt-${varVnetSpoke5Name}'
  location: varVnetSpoke5Region
  dependsOn: [
    resWait
  ]
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'Default-to-Internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
        }
      }
      {
        name: '192.168.0.0-to-NVA'
        properties: {
          addressPrefix: '192.168.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke2Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: '172.16.0.0-to-NVA'
        properties: {
          addressPrefix: '172.16.0.0/12'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke2Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: '10.0.0.0-to-NVA'
        properties: {
          addressPrefix: '10.0.0.0/8'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke2Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource resRouteTableSpoke6 'Microsoft.Network/routeTables@2024-01-01' = {
  name: 'rt-${varVnetSpoke6Name}'
  location: varVnetSpoke6Region
  dependsOn: [
    resWait
  ]
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'Default-to-Internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
        }
      }
      {
        name: '192.168.0.0-to-NVA'
        properties: {
          addressPrefix: '192.168.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke2Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: '172.16.0.0-to-NVA'
        properties: {
          addressPrefix: '172.16.0.0/12'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke2Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: '10.0.0.0-to-NVA'
        properties: {
          addressPrefix: '10.0.0.0/8'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke2Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource resRouteTableSpoke7 'Microsoft.Network/routeTables@2024-01-01' = {
  name: 'rt-${varVnetSpoke7Name}'
  location: varVnetSpoke7Region
  dependsOn: [
    resWait
  ]
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'Default-to-Internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
        }
      }
      {
        name: '192.168.0.0-to-NVA'
        properties: {
          addressPrefix: '192.168.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke4Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: '172.16.0.0-to-NVA'
        properties: {
          addressPrefix: '172.16.0.0/12'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke4Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: '10.0.0.0-to-NVA'
        properties: {
          addressPrefix: '10.0.0.0/8'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke4Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource resRouteTableSpoke8 'Microsoft.Network/routeTables@2024-01-01' = {
  name: 'rt-${varVnetSpoke8Name}'
  location: varVnetSpoke8Region
  dependsOn: [
    resWait
  ]
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'Default-to-Internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
        }
      }
      {
        name: '192.168.0.0-to-NVA'
        properties: {
          addressPrefix: '192.168.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke4Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: '172.16.0.0-to-NVA'
        properties: {
          addressPrefix: '172.16.0.0/12'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke4Nic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: '10.0.0.0-to-NVA'
        properties: {
          addressPrefix: '10.0.0.0/8'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resNvaSpoke4Nic.properties.ipConfigurations[0].properties.privateIPAddress
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
  name: 'vnetpeering-${resVnetSpoke5.name}'
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
  name: 'vnetpeering-${resVnetSpoke5.name}-to-${resVnetSpoke2.name}'
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
  name: 'vnetpeering-${resVnetSpoke6.name}'
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
  name: 'vnetpeering-${resVnetSpoke2.name}'
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
  name: 'vnetpeering-${resVnetSpoke7.name}'
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
  name: 'vnetpeering-${resVnetSpoke4.name}'
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
  name: 'vnetpeering-${resVnetSpoke8.name}'
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
  name: 'vnetpeering-${resVnetSpoke4.name}'
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
  name: 'hubvnetconnection-${resVnetSpoke1.name}'
  parent: resVwanHub1
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke1.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub1Spoke2 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: 'hubvnetconnection-${resVnetSpoke2.name}'
  parent: resVwanHub1
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke2.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub2Spoke3 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: 'hubvnetconnection-${resVnetSpoke3.name}'
  parent: resVwanHub2
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke3.id
    }
  }
}

resource resHubVirtualNetworkConnectionHub2Spoke4 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: 'hubvnetconnection-${resVnetSpoke4.name}'
  parent: resVwanHub2
  properties: {
    remoteVirtualNetwork: {
      id: resVnetSpoke4.id
    }
  }
}

// ----------------------------------------
// RESOURCES (VPN Gateways & VNET Gateways)
// ----------------------------------------

resource resPipBranch1VpnGw 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: 'vnetgw-${resVnetBranch1.name}-pip'
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
  name: 'vnetgw-${resVnetBranch2.name}-pip'
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
  name: 'vnetgw-${resVnetBranch1.name}'
  location: varVnetBranch1Region
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
              resVnetBranch1.name,
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
  name: 'vnetgw-${resVnetBranch2.name}'
  location: varVnetBranch2Region
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
              resVnetBranch2.name,
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
  name: 'vpngw-${resVwanHub1.name}'
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
  name: 'vpngw-${resVwanHub2.name}'
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
  name: 'vpnsite-${resVnetBranch1.name}'
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
  name: 'vpnsite-${resVnetBranch2.name}'
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
  name: 'vpnconnection-${resVnetBranch1.name}'
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
  name: 'vpnconnection-${resVnetBranch2.name}'
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
  name: 'localgw-${resVwanHub1.name}-gw1'
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
  name: 'localgw-${resVwanHub1.name}-gw2'
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
  name: 'localgw-${resVwanHub2.name}-gw1'
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
  name: 'localgw-${resVwanHub2.name}-gw2'
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
  name: 'connection-${resVwanHub1.name}-gw1'
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
  name: 'connection-${resVwanHub1.name}-gw2'
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
  name: 'connection-${resVwanHub2.name}-gw1'
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
  name: 'connection-${resVwanHub2.name}-gw2'
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

// -----------------------------------
// RESOURCES (NVAs in Spokes 2 & 4)
// -----------------------------------

resource resNvaSpoke2 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'nva-${resVnetSpoke2.name}'
  location: varVnetSpoke2Region
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: varVmSize
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
      computerName: 'nva-${resVnetSpoke2.name}'
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
          id: resNvaSpoke2Nic.id
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
  resource resNvaSpoke2AadLogin 'extensions@2024-07-01' = {
    name: 'aadlogin-nva-${resVnetSpoke2.name}'
    location: varVnetSpoke2Region
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADSSHLoginForLinux'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      settings: {}
      protectedSettings: {}
    }  
  }
  resource resNvaSpoke2Automanage 'extensions@2024-07-01' = {
    name: 'automanage-nva-${resVnetSpoke2.name}'
    location: varVnetSpoke2Region
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
  resource resNvaSpoke21CustomScript 'extensions@2024-07-01' = {
    name: 'customscript-nva-${resVnetSpoke2.name}'
    location: varVnetSpoke2Region
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
        commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke2Asn} ${resNvaSpoke2Nic.properties.ipConfigurations[0].properties.privateIPAddress} ${varVwanHub1VirtualRouterIps[0]} ${varVwanHub1VirtualRouterIps[1]} 10.2.1.0/24 10.2.2.0/24 8.8.8.0/24'
      }
    }
  }
}

resource resNvaSpoke2Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: 'nva-${resVnetSpoke2.name}-nic'
  location: varVnetSpoke2Region
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
              resVnetSpoke2.name,
              'main'
            )
          }
        }
      }
    ]
  }
}

resource resNvaSpoke2Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-nva-${resVnetSpoke2.name}'
  location: varVnetSpoke2Region
  properties: {
    targetResourceId: resNvaSpoke2.id
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

resource resNvaSpoke4 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'nva-${resVnetSpoke4.name}'
  location: varVnetSpoke4Region
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: varVmSize
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
      computerName: 'nva-${resVnetSpoke4.name}'
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
          id: resNvaSpoke4Nic.id
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
  resource resNvaSpoke4AadLogin 'extensions@2024-07-01' = {
    name: 'aadlogin-nva-${resVnetSpoke4.name}'
    location: varVnetSpoke4Region
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADSSHLoginForLinux'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      settings: {}
      protectedSettings: {}
    }  
  }
  resource resNvaSpoke4Automanage 'extensions@2024-07-01' = {
    name: 'automanage-nva-${resVnetSpoke4.name}'
    location: varVnetSpoke4Region
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
  resource resNvaSpoke4CustomScript 'extensions@2024-07-01' = {
    name: 'customscript-nva-${resVnetSpoke4.name}'
    location: varVnetSpoke4Region
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
        commandToExecute: 'sh linuxrouterbgpfrr.sh azureuser ${varSpoke4Asn} ${resNvaSpoke4Nic.properties.ipConfigurations[0].properties.privateIPAddress} ${varVwanHub2VirtualRouterIps[0]} ${varVwanHub2VirtualRouterIps[1]} 10.4.1.0/24 10.4.2.0/24 9.9.9.0/24'
      }
    }
  }
}

resource resNvaSpoke4Nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: 'nva-${resVnetSpoke4.name}-nic'
  location: varVnetSpoke4Region
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
              resVnetSpoke4.name,
              'main'
            )
          }
        }
      }
    ]
  }
}

resource resNvaSpoke4Schedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-nva-${resVnetSpoke4.name}'
  location: varVnetSpoke4Region
  properties: {
    targetResourceId: resNvaSpoke4.id
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

// -----------------------------------------------------------
// RESOURCES (BGP Connections between FRR VMs and Hub Routers)
// -----------------------------------------------------------

resource resVwanHub1VmSpoke2BgpConnection 'Microsoft.Network/virtualHubs/bgpConnections@2024-01-01' = {
  name: 'bgpconnection-${resNvaSpoke2.name}'
  parent: resVwanHub1
  properties: {
    peerAsn: varSpoke2Asn
    peerIp: resNvaSpoke2Nic.properties.ipConfigurations[0].properties.privateIPAddress
    hubVirtualNetworkConnection: {
      id: resHubVirtualNetworkConnectionHub1Spoke2.id
    }
  }
}

resource resVwanHub2VmSpoke4BgpConnection 'Microsoft.Network/virtualHubs/bgpConnections@2024-01-01' = {
  name: 'bgbconnection-${resNvaSpoke4.name}'
  parent: resVwanHub2
  dependsOn: [
    resNvaSpoke4
  ]
  properties: {
    peerAsn: varSpoke4Asn
    peerIp: resNvaSpoke4Nic.properties.ipConfigurations[0].properties.privateIPAddress
    hubVirtualNetworkConnection: {
      id: resHubVirtualNetworkConnectionHub2Spoke4.id
    }
  }
}

// --------------------
// RESOURCES (Test VMs)
// --------------------

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
    region: varVnetSpoke3Region
    vnet: varVnetSpoke3Name
  }
  {
    region: varVnetSpoke5Region
    vnet: varVnetSpoke5Name
  }
  {
    region: varVnetSpoke7Region
    vnet: varVnetSpoke7Name
  }
]

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
      vmSize: varVmSize
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
    resTestVmsAntmalware
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

// -------------------------
// RESOURCES (Bastion Hosts)
// -------------------------

@description('List of Bastion hosts')
var varBastionHosts = [
  {
    region: varVnetSpoke2Region
    vnet: varVnetSpoke2Name
  }
  {
    region: varVnetSpoke4Region
    vnet: varVnetSpoke4Name
  }
]

resource resBastionPips 'Microsoft.Network/publicIPAddresses@2024-01-01'= [for varBastionHost in varBastionHosts: {
  name: 'bastion-${varBastionHost.vnet}-pip'
  location: varBastionHost.region
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

resource resBastions 'Microsoft.Network/bastionHosts@2024-01-01' = [for varBastionHost in varBastionHosts: {
  name: 'bastion-${varBastionHost.vnet}'
  location: varBastionHost.region
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
              'bastion-${varBastionHost.vnet}-pip'
            )
          }
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets/',
              varBastionHost.vnet, 
              'AzureBastionSubnet'
            )
          }
        }
      }
    ]
  }
}]

