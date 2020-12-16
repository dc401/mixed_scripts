#!/usr/bin/env python3
'''
DLP basic search
pulls out common SSN, password, and PHI related items read per line in a while
usage: dlp-search.py <file to look at>
Licensed under GPLv2 Dennis Chow 2020-Dec-10 
dchow[AT]xtecsystems.com
Demonstrations purposes only
'''

#get the libraries
import re, sys

#check for position arguments
if len(sys.argv) == 1:
    print('usage: dlp-search.py </path/to/file.txt>')
    sys.exit(0)

#grab the filename from sysargv parameter
file_name = str(sys.argv[1])

#file heandler object open the file
data_file = open(file_name, 'r')

#function to find regex patterns of sensitive data
def data_hunt(data_file):
    #get a counter to print the line number
    counter = 0
    #pull file in and parse line by line
    for line in data_file:
        #count the line number
        counter = counter + 1
        ssn = re.match("\d{3}-\d{2}-\d{4}", line)
        password = re.match("(password\=|pass\=|pw\=)(\S|\s)\S{3,30}", line)
        phi = re.match("(MRN\=|mrn\=)(\S|\s)\S{3,30}", line)
        if ssn:
            print('Found SSN: ' + str(ssn))
            print('Line number: ' + str(counter))
        if password:
            print('Found Password: ' + str(password))
            print('Line number: ' + str(counter))
        if phi:
            print('Found PHI: ' + str(phi))
            print('Line number: ' + str(counter))

#data_hunt(data_file)


#define a main function
def main(data_file):
    #execute search on the file and close
    data_hunt(data_file)
    data_file.close()

#call main and clean up exit success
main(data_file)
sys.exit(0)

