#!/bin/bash
#Uses ipmitool to check for cipher 0 auth bypass for HP iLo default accounts
# $1 is the argument from the CLI syntax for the filename list of IPs or FQDNs
#Usage ipimi_cipher_validate.sh input.txt
#input.txt is a text file of single line IP addresses

#Strip out any Windows encoding non-print chars
dos2unix $1

#turning debugging on
set -x

#read line by line from input and append std err and std out to same file
while read line
do
	#ipmitool -I lanplus -v -C 0 -H $line -U Administrator -P foo power status; echo "$line" >> results.txt 2>&1
	#read line by line from input and show only successful validated hosts
	ipmitool -I lanplus -v -C 0 -H $line -U Administrator -P foo power status && echo "$line" >> results.txt

done < $1
