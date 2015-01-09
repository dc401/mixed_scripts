#!/bin/bash
#DC - transparent bridge mitmproxy netsed lazy setup in Ubuntu 14 Desktop
#Obviously change and modify to your environment. No warranties.

#Enter password and get root
sudo bash

#Sniff some yummy SSL/TLS sessions and save to file on desktop
#Sniff and replace/inject packets on the fly for bad DNS domains and forward to original dest
#Also padd with a null byte at the end so the length matches and doesnt produce errors in tcp stream
gnome-terminal -e 'netsed tcp 6969 0 0 's/FOOBAR/BAD%00%00%00'' & gnome-terminal -e 'mitmproxy -T --host -w ~/Desktop/mitmproxy_log.txt'
