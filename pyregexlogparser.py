'''
#Sample Log file input
Feb 25 12:11:24 bridge kernel: INBOUND TCP: IN=br0 PHYSIN=eth0 OUT=br0 PHYSOUT=eth1 SRC=220.228.136.38 DST=11.11.79.83 LEN=64 TOS=0x00 PREC=0x00 TTL=47 ID=17159 DF PROTO=TCP SPT=1629 DPT=139 WINDOW=44620 RES=0x00 SYN URGP=0  
Feb 25 12:11:27 bridge kernel: INBOUND TCP: IN=br0 PHYSIN=eth0 OUT=br0 PHYSOUT=eth1 SRC=220.228.136.38 DST=11.11.79.83 LEN=64 TOS=0x00 PREC=0x00 TTL=47 ID=17800 DF PROTO=TCP SPT=1629 DPT=139 WINDOW=44620 RES=0x00 SYN URGP=0  
'''
#!/usr/bin/env python3
import re, json
from collections import Counter
from colorama import Fore
file = open('log.txt', 'r')
srcipaddrlist = []
dstipaddrlist = []
srcportlist = []
dstportlist = []
protolist = []
for i in file:
  #regex findall method will return a list based your expression
  #use negative look ahead to negate match a group which is surrounded by ()
  srcipaddr = re.findall(r'(?:SRC=)(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', i)
  dstipaddr = re.findall(r'(?:DST=)(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', i)
  srcport = re.findall(r'(?:SPT=)(\d{1,5})', i)
  dstport = re.findall(r'(?:DPT=)(\d{1,5})', i)
  #print(srcipaddr[0])
  #specify the first element to remove nested list and ensure result is not empty
  if len(srcipaddr) > 0:
    srcipaddrlist.append(srcipaddr[0])
  if len(dstipaddr) > 0:
    dstipaddrlist.append(dstipaddr[0])
  if len(srcport) > 0:
    srcportlist.append(srcport[0])
  if len(dstport) > 0:
    dstportlist.append(dstport[0])

#Use Counter method to calculate unique values into counter obj convert to dictionary kv pairs
#print(srcipaddrlist)
srcipdict = dict(Counter(srcipaddrlist))
dstipdict = dict(Counter(dstipaddrlist))
srcportdict = dict(Counter(srcportlist))
dstportdict = dict(Counter(dstportlist))

#Convert KV dictionary pairs to json readable format
srcipjson = json.dumps(srcipdict, indent=4)
dstipjson = json.dumps(dstipdict, indent=4)
srcportjson = json.dumps(srcportdict, indent=4)
dstportjson = json.dumps(dstportdict, indent=4)

#Chow skittle JSON taste the mofo rainbow
print(Fore.RED + "***Source IP Unique Hits***: ")
print(srcipjson)

print(Fore.BLUE + "***Source Port Unique Hits***: ")
print(srcportjson)

print(Fore.YELLOW + "***Dest IP Unique Hits***: ")
print(dstipjson)

print(Fore.GREEN + "***Dest Port Unique Hits***: ")
print(dstportjson)

file.close()
