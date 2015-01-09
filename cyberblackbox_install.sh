#!/bin/bash
#DC - transparent bridge mitmproxy netsed lazy setup in Ubuntu 14 Desktop
#Obviously change and modify to your environment. No warranties.

#Enter password and get root
sudo bash

#Get the packages and install them
apt-get update && apt-get upgrade -y
cd ~/
#Make the mitmproxy directory just in case
mkdir ~/.mitmproxy
apt-get install python-pip build-essential python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev netsed -y
pip install mitmproxy
pip install urwid

#Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
#Make it perm for IP Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
#Disable ICMP redirects since likely on same physical network
echo 0 | tee /proc/sys/net/ipv4/conf/*send_redirects

#Ensure firewall is off
ufw disable

#Uncomment and use this if youre not using network-manager
#apt-get install bridge-utils -y
#brctl add br0
#brctl addif br0 eth0
#brctl addif br0 eth1
#brctl stp br0 off
#ifconfig eth0 0.0.0.0 down
#ifconfig eth1 0.0.0.0 down
#ifconfig eth0 up
#ifconifg eth1 up
#ifconfig br0 192.168.1.250 netmask 255.255.255.0 up
#ip route add default gateway via 192.168.1.1
#echo "nameserver 192.168.1.1" >> /etc/resolv.conf

#Route DNS traffic to netsed
iptables -t nat -A PREROUTING -i br0 -p udp --dport 53 -j REDIRECT --to-port 6969

#Straight route web traffic to mitmproxy no pipe
iptables -t nat -A PREROUTING -i br0 -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i br0 -p tcp --dport 443 -j REDIRECT --to-port 8080
#Part of the iptables-persistent dpkg default on Ubuntu 14
iptables-save > /etc/iptables/rules.4

#Sniff some yummy SSL/TLS sessions and save to file on desktop
#gnome-terminal -e 'mitmproxy -T --host -w ~/Desktop/mitmproxy_log.txt'

#Sniff and replace/inject packets on the fly for bad DNS domains and forward to original dest
#Also padd with a null byte at the end so the length matches and doesnt produce errors in tcp stream
#netsed udp 6969 0 0 's/playboy.com/google.com%00'

