<#
20150721 dc - Automates the use of sigfind and known malicious exports results to csv
dchow[AT]xtecsystems.com
Dependencies: 
SysinternalsSuite SigCheck v2.2 or higher
https://technet.microsoft.com/en-us/sysinternals/bb897441

Usage:
check_mal_hash.ps1 -s "C:\ShareorPathtoScan\" -o "OutputResultsFile.csv"

#>

#cli arguments
param([string]$s, [string]$o)

If (Test-Path -isvalid $s)
{
	Try
	{
		.\sigcheck.exe -l -s -vt -v -h -c $path | Out-File hashes.csv -Append
	}
	Catch
	{
		Write-Host "Ensure you have sigcheck.exe in the same path as script"
	}
	
	<#
	#read in a line-by-line stream opposed to putting all in memory with import-csv
	$hashedFiles = New-Object System.IO.StreamReader -Arg "hashes.csv"
	while ($line = $hashedFiles.ReadLine()) `
	{	
		$line | Select-String -Pattern '([1-9]{1,3})\|' | Export-Csv $o -Encoding "ASCII" -NoTypeInformation
	}
	$hashedFiles.close()
	#>
	
	Write-Host "Scanning $s and checking against Virus Total for known hashes..."
	#Grab the results and match hashes for 1 or more known detections against virus total
	Import-Csv -Path ".\hashes.csv" | Select-Object "Path", "Date", "MD5", "Verified", "VT Link" | `
	Where-Object { $_.'VT link' -match '([1-9]{1,3})\|' } | Export-Csv $o -Encoding "ASCII" -NoTypeInformation
	Write-Host "Results located in $o" -foregroundcolor green -backgroundcolor black
	
    #Beep to get your attention
    $([char]7)
	
	$MalFilesCount = Get-Content $o | Measure-Object | Select-Object "Count"
	Write-Host "$MalFilesCount total malicious files detected." -foregroundcolor red -backgroundcolor yellow
	#Clear-Variable $MalFilesCount
}
Else
{
	Write-Host "Ensure your file or share to scan is a valid path."
	Write-Host "Usage: check_mal_hash.ps1 -s C:\ShareorPathtoScan\ -o OutputResultsFile.csv" 
}
#clean up
rm "hashes.csv"
