<#
Takes line-by-line of a file input of email addresses and delim parses
them into email,first,last into a csv for Metasploit phishing emails
Syntax: phish_emails_list_csv.ps1 -i list.txt -o outputfile.csv

Dennis Chow v1.0 20140402

Some code inspired from:
http://social.technet.microsoft.com/Forums/en-US/c208a3fd-2bc5-4bfc-9752-4244d5961b8d/powershell-combine-two-files-into-array?forum=winserverpowershell

Notes on encoding:
http://stackoverflow.com/questions/10655788/powershell-set-content-and-out-file-what-is-the-difference

#>

#Check for arguments
param([string]$i , [string]$o)

Write-Host "Reading from: $i"
Write-Host "Writing to: $o"

IF (Test-Path -isvalid $i)
{
	#Powershell may also use regex in the replace operator.
	Get-Content $i | Foreach-Object {$_ -replace ("@.*"), ""} | Out-File firstLast.tmp -append;
	Get-Content firstLast.tmp | Foreach-Object {$_.Split(".")[0]} | Out-File first.tmp -append;
	Get-Content firstLast.tmp | Foreach-Object {$_.Split(".")[1]} | Out-File last.tmp -append;
				
	#Poweshell grabs an array. Easier to use than string type
	$emailArray = Get-Content $i
	$firstArray = Get-Content first.tmp
	$lastArray =  Get-Content last.tmp
	
	#Creating header because Metasploit is picky
	$header = "email_address,first_name,last_name"
	$header | Out-File $o -append
	
	#So much easier if in Linux using "paste -d"
	FOR($index=0;$index -lt $emailArray.Count;$index++)
	{
		#($emailArray[$index] + "," + $firstArray[$index] + "," + $lastArray[$index] ) | Out-File out.tmp -append
		($emailArray[$index] + "," + $firstArray[$index] + "," + $lastArray[$index] ) | Out-File $o -append
	}
	
	#Run a sort unique on the file
	#Get-Content out.tmp | Sort-Object -Unique | Out-File $o -append
	
	#Clean up temp files	
	Remove-Item firstLast.tmp;
	Remove-Item first.tmp;
	Remove-Item last.tmp;
	#Remove-Item out.tmp;
	#Time to scrub I/O
	sleep 1
	Write-Host "Done."
	#Beep to get your attention
	$([char]7)
}
ELSE
{
	Write-Host "Phish_email_list_csv.ps1 -i list.txt -o outputfile.csv"
	exit;
}
