@ECHO OFF
REM "@ECHO OFF" prevents echoing lines on standard out. Windows/DOS is NON-Case Sensitive
REM 20140522 Dennis Chow - Host to IP lookup script based on file and tutorial for batch scripts
REM Syntax: batch_host2ip.bat listofhosts.txt outputfile.txt

REM Arg Checks
IF [%1]==[] GOTO syntax
IF [%2]==[] GOTO syntax

@echo Looking up hosts from %1
@echo Writing to %2

REM For loop type F denotes iteration over a FILE type with token being an "object"
REM Use of an extra "%" is required vs using regular CLI to process properly in batch file
REM The use of "|" denotes a pipe and the use of "^" caret is to append to next line. 
REM You cannot use a caret during a pipe sequence because it treats it as an external op
REM NTFS limitations of this is to 8192 characters for line length
REM Arguments "%0,1,"etc are all special VARs to be used as arguments
REM Note that without findstr /C statement it will use OR with multiple string tokens
REM You can use an logical OR only once with a single pipe
REM double ">" denotes append to an out file rather than overwrite
REM DOS quirk: nslookup non-resolvable hosts will not write standard error using ">> error.txt 2>&1"

FOR /F "tokens=1" %%a IN (%1) DO nslookup %%a | (findstr /i "Address Name" | findstr /v "10.2.1.79") >> %2
@echo Done
GOTO :EOF

:syntax
@echo Syntax: batch_host2ip.bat listofhosts.txt outputfile.txt
REM Exit /B will exit the batch subroutine and return to the prompt without exiting the shell
exit /B 1
