vtysh

show running-config
show run

show ip bgpexit

show ip bgp nei
show ip bgp nei 192.168.1.68 adv

configure terminal
router bgp 65002
address-family ipv4 unicast
no network 10.2.0.0/16
network 8.8.8.8/32
network 8.8.8.9/32
network 8.8.8.7/32
network 8.8.8.7/32
network 7.7.7.7/32
end