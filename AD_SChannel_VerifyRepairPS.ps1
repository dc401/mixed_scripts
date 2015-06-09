#20150604 dc
#dchow[AT]xtecsystems.com
#usage run AD_SChannel_Verify.ps1
#Enter your domain admin credentials in DOMAIN\username format as prompted
#Use of nltest https://technet.microsoft.com/en-us/library/cc731935.aspx
#Didn't create an argument pass through; too lazy. Do it yourself.

Try 
{ 
	Import-Module ActiveDirectory -ErrorAction Stop
}
Catch 
{
	Write-Host "Install RSAT tools"; Break
}

#grab interactive creds
$creds = Get-Credential

$hostsArr = Get-ADComputer -Filter * | Select name

#convert arraytoString
#$hostsStr = $hostsArr | Out-String

ForEach ($i in $hostsArr)
{
    #Must use $i.Name method otherwise pulls array in all at once
    Invoke-Command -ComputerName $i.Name -Credential $creds -ThrottleLimit 15 -ScriptBlock `
        {
            #Replace MYDOMAINHERE.COM with your domain
			nltest /sc_verify:MYDOMAINHERE.COM
        } -Verbose  2>> "problemhosts.tmp"
        
        #For use in case you want to stderror or stdout to diff files
        #>> "C:\good.txt" 2>> "C:\bad.txt"
        #For use in case you want to stderror or stdout to same file
        #2>&1 >> "C:\results.txt"
}

#Too lazy to try this in memory. Do it in a file.
Get-Content "problemhosts.tmp" | Select-String -pattern "\[(.+[^\[\]])\]" | Select Matches `
| "resethosts.tmp"

#Going back to an Array
$problemHostsArr = Get-Content "resethosts.tmp" | % {$_.Trim("{[ ]}") }

ForEach ($j in $problemHostsArr)
{
    Invoke-Command -ComputerName $j.Name -Credential $creds -ThrottleLimit 15 -ScriptBlock `
    {
        #Replace MYDOMAINHERE.COM with your domain
		nltest /sc_reset:MYDOMAINHERE.COM
    } -Verbose 2>&1 >> "sChannelResetResults.log"
}

#Standard out the results
$problemhosts = Get-Content "problemhosts.tmp"
$problemresets = Get-Content "resethosts.tmp"

Write-Host "---"
Write-Host "Hosts that failed sChannel verification" -BackgroundColor "black" -ForegroundColor "yellow"
Write-Host "---"
Write-Host $problemhosts

Write-Host "---"
Write-Host "Hosts that failed sChannel reset" -BackgroundColor "yellow" -ForegroundColor "red"
Write-Host "---"
Write-Host $problemresets
Write-Host "---"
Write-Host "Error log: sChannelResetResults.log"

#Clean up files
Remove-Item "problemhosts.tmp"
Remove-Item "resethosts.tmp"
