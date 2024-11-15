az login

# BRANCH1 Virtual Network Gateway Route Table
az network vnet-gateway list-learned-routes -n vnetgateway-branch1 -g RG-VWAN-NVA-BGP -o table

# BRANCH1 Virtual Network Gateway BGP Peers
az network vnet-gateway list-bgp-peer-status -n vnetgateway-branch1 -g RG-VWAN-NVA-BGP -o table

# BRANCH1 Virtual Network Gateway Advertised Routes
az network vnet-gateway list-advertised-routes -n vnetgateway-branch1 -g RG-VWAN-NVA-BGP --peer 192.168.1.12 -o table
az network vnet-gateway list-advertised-routes -n vnetgateway-branch1 -g RG-VWAN-NVA-BGP --peer 192.168.1.13 -o table

# HUB1 VPN Gateway
az network vhub bgpconnection list -g RG-VWAN-NVA-BGP --vhub-name hub1 -o table

az network vhub bgpconnection show -n bgpconnection-hub1-vm-spoke2 -g RG-VWAN-NVA-BGP --vhub-name hub1 -o table