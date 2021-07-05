#!/bin/bash
echo "Be sure to disconnect from wifi first..."
openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//' | sudo xargs ifconfig en0 ether
echo "New temporary mac address on wifi:"
ifconfig en0 | grep -i 'ether'
echo "Setting TTL to 65 for any device throttling on tethering..."
sudo sysctl -w net.inet.ip.ttl=65
