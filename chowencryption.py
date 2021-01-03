#!/usr/bin/env python3
'''
Licensed under GPLv2.0
Dennis Chow dchow[AT]xtecsystems.com
2021-Jan-02
Compatibility tested on Python 3.9.x 64bit
Usage chowencryption.py </path/to/text2encryptordecrypt.txt> <somewholenumberforkey> <encrypt/decrypt>'
**NOTICE**
This is a custom simple symmetric stream cipher with single byte IV, 
and unsigned-integer based key for PoC purposes only.
The encryption function is cryptographically weak and should not be used 
for any serious privacy.
'''
#for use in sysargv style arguments from cli and file ops
import sys, os
#grab a random integer between lower and upperbound + 1
from random import randint


def chowencrypt(cleartext, key):
    #data dictionary of common text and CLI chars
    encodeddict = {
        'a' : 1, 'b' : 2, 'c' : 3, 'd' : 4,
        'e' : 5, 'f' : 6, 'g' : 7, 'h' : 8,
        'i' : 9, 'j' : 10, 'k' : 11, 'l' : 12,
        'm' : 13, 'n' : 14, 'o' : 15, 'p' : 16,
        'q' : 17, 'r' : 18, 's' : 19, 't' : 20,
        'u' : 21, 'v' : 22, 'w' : 23, 'x' : 24,
        'y' : 25, 'z' :26, ' ' : 100, 'A' : 101,
        'B' : 102, 'C' : 103, 'D' : 103, 'E' : 104,
        'F' : 105, 'G' : 106, 'H' : 107, 'I' : 108,
        'J' : 109, 'K' : 110, 'L' : 111, 'M' : 112,
        'N' : 113, 'O' : 114, 'P' : 115, 'Q' : 116,
        'R' : 117, 'S' : 118, 'T' : 119, 'U' : 120,
        'V' : 121, 'W' : 122, 'X' : 123, 'Y' : 124,
        'Z' : 125, '.' : 200, '/' : 201, '\\' : 202,
        '$' : 203, '#' : 204, '@' : 205, '%' : 206,
        '^' : 207, '*' : 208, '(' : 209, ')' : 210,
        '_' : 211, '-' : 212, '=' : 213, '+' : 214,
        '>' : 215, '<' : 216, '?' : 217, ';' : 218,
        ':' : 219, '\'' : 220, '\"' : 221, '{' : 222,
        '}' : 223, '[' : 224, ']' : 225, '|' : 226,
        '`' : 227, '~' : 228, '!' : 229, '0' : 300,
        '1' : 301, '2' : 302, '3' : 303, '4' : 304,
        '5' : 306, '6' : 307, '7' : 308, '8' : 309,
        '9' : 310
    }
    #Create an IV seed value to prepend
    #Note: creating a large 32bit IV value adds ease of statistical analysis
    #iv = randint(350, 4294967296)
    #use an IV with a smaller size helps to blend the cipher text more
    iv = randint(311, 457)

    #Start encoding our clear text and prepend IV
    encodedbuffer = []
    encodedbuffer.append(iv)
    for i in str(cleartext):
        encodedbuffer.append(encodeddict[i])
    print('encoded string: ' + str(encodedbuffer))


    #Use encryption algo to convert encoded data to cipher text
    #Weak algo: 3x + key for demo purposes
    cipherstream = []
    for i in encodedbuffer:
        encryptedbyte = (3 * i) + int(key)
        cipherstream.append(encryptedbyte)

    print('encrypted string: ' + str(cipherstream))
    #Remember this wil return as a LIST data type

    #writing to a file for ease of use instead of copy/paste from std out
    print('***writing encrypted list to file... encrypted.txt***')
    encryptedfile = open('encrypted.txt', 'w')
    #save a reference marker of standard out first
    originalstdout = sys.stdout
    #redirect standard out to the file handler
    sys.stdout = encryptedfile
    print(str(cipherstream))
    #reset the standard out descriptor
    sys.stdout = originalstdout
    encryptedfile.close()
    return cipherstream

def chowdecrypt(ciphertext, key):
    #data dictionary of common text and CLI chars
    encodeddict = {
        'a' : 1, 'b' : 2, 'c' : 3, 'd' : 4,
        'e' : 5, 'f' : 6, 'g' : 7, 'h' : 8,
        'i' : 9, 'j' : 10, 'k' : 11, 'l' : 12,
        'm' : 13, 'n' : 14, 'o' : 15, 'p' : 16,
        'q' : 17, 'r' : 18, 's' : 19, 't' : 20,
        'u' : 21, 'v' : 22, 'w' : 23, 'x' : 24,
        'y' : 25, 'z' :26, ' ' : 100, 'A' : 101,
        'B' : 102, 'C' : 103, 'D' : 103, 'E' : 104,
        'F' : 105, 'G' : 106, 'H' : 107, 'I' : 108,
        'J' : 109, 'K' : 110, 'L' : 111, 'M' : 112,
        'N' : 113, 'O' : 114, 'P' : 115, 'Q' : 116,
        'R' : 117, 'S' : 118, 'T' : 119, 'U' : 120,
        'V' : 121, 'W' : 122, 'X' : 123, 'Y' : 124,
        'Z' : 125, '.' : 200, '/' : 201, '\\' : 202,
        '$' : 203, '#' : 204, '@' : 205, '%' : 206,
        '^' : 207, '*' : 208, '(' : 209, ')' : 210,
        '_' : 211, '-' : 212, '=' : 213, '+' : 214,
        '>' : 215, '<' : 216, '?' : 217, ';' : 218,
        ':' : 219, '\'' : 220, '\"' : 221, '{' : 222,
        '}' : 223, '[' : 224, ']' : 225, '|' : 226,
        '`' : 227, '~' : 228, '!' : 229, '0' : 300,
        '1' : 301, '2' : 302, '3' : 303, '4' : 304,
        '5' : 306, '6' : 307, '7' : 308, '8' : 309,
        '9' : 310
    }

    '''
    #This portion is only required if you're using strings only
    #Ensure our ciphertext is proper type case
    #Be sure to comment out the second encodedbuffer var
    #if you use this modifier to this function
    encodedbuffer = []
    #Remember ciphertext is a LIST data type
    for i in ciphertext:
        encodedbuffer.append(int(i))
    '''
   
    '''
    **SECURITY CONSIDERATION**
    Note: The use of eval isn't best practice and I could've just wrote single bytes per line
    but to shorten the length of the file we created standard out to be a list format written
    to a file instead for ease of viewing. 
    
    The use of eval without a whitelist can have
    security implications. Please see the following refs for more details:
    https://realpython.com/python-eval-function/#minimizing-the-security-issues-of-eval
    https://www.geeksforgeeks.org/eval-in-python/
    https://www.journaldev.com/22504/python-eval-function#security-risks-with-eval-function
    '''
    #Using the eval built in to interpret the files line as a list instead string
    #Utilize a whitelist to only allow the list builtin class
    encodedbuffer = eval(ciphertext, {"__builtins__": {'list' : list}})

    #Use decryption algo which is inverse: (3x+key)^-1
    #Decryption algo: (x-k)/3
    decryptedsignal = []
    for i in encodedbuffer:
        decryptedsignal.append(int((i - int(key)) / 3))
    print('decrypted signal: ' + str(decryptedsignal))
    
    #Return the decrypted codes to the original ASCII equiv
    decryptedtext = []
    for i in decryptedsignal:
        #remember encodeddict is a dictionary using key value pairs
        #must access via .items method for value to key
        for k,v in encodeddict.items():
            if v == i:
                decryptedtext.append(k)
    print('decrypted string as list: ' + str(decryptedtext))
    #convert the list decryptedtext into original string form
    decryptedtextstring = ''
    for i in decryptedtext:
        decryptedtextstring = decryptedtextstring + str(i)
    
    print('decrypted string original: ' + str(decryptedtextstring))
    return decryptedtextstring


#driver dunder statement for the main program
if __name__ == '__main__':
    if len(sys.argv) > 4 or len(sys.argv) < 4:
        print('Usage chow-encryption.py </path/to/text2encryptordecrypt.txt> <somewholenumberforkey> <encrypt/decrypt>')
        print('Example Encryption: chowencryption.py /tmp/mycleartext.txt 888 encrypt')
        print('Note: The decryption function is expecting a continuous list type per LINE as exported from encryption')
        print('Example Decryption: chowencryption.py /tmp/myciphertextlist.txt 888 decrypt')
    elif sys.argv[3] == 'encrypt':
        cleartextfile = open(sys.argv[1], 'r')
        for i in cleartextfile:
            chowencrypt(i, sys.argv[2])
        cleartextfile.close()
    elif sys.argv[3] == 'decrypt':
        ciphertextfile = open(sys.argv[1], 'r')
        for i in ciphertextfile:
            chowdecrypt(i, sys.argv[2])
        ciphertextfile.close()

'''
If you wish to reference chowencryption.py as a library import use the following syntaxes:

import chowencryption

#Static tests without driver code from main()
#Test encryption function
print('testing encryption...')
chowencryption.chowencrypt('this is foobar', 888)

#Take the returned value cipher text as LIST to decrypt
print ('testing decryption...')
ciphertext = str(chowencryption.chowencrypt('this is foobar', 888))
chowencryption.chowdecrypt(ciphertext, 888)
'''