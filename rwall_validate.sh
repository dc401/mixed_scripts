#!/bin/bash
#Syntax - rwall_validate.sh listofIPs.txt nameofMessageFile.txt

#strip out windows encoding
dos2unix $1
dos2unix $2

#debugging on
set -x

#read line by line 
while read line
do
	#take argument from runtime
	rwall $line $2

#alternative to doing for loop with cat
done < $1

#exits status of last command
exit
