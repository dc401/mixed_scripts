<#
Author: Dennis Chow dchow[AT]xtecsystems.com
Version: 1.0
Date: April 26, 2019
Dependencies: admin privileges, Set-ExecutionPolicy -bypass get-srm-prereqs.ps1 at runtime, PSv3 or higher
License: GPL v2.0 - Free to use and modify, no expressed warranities.

Runtime: 
Run this script with admin priv an output file get-system-sec-info-output.log will be created in the same directory
Warnings in different color will display on the string for certain conditions such as egress ports open

DISCLAIMER: This script augments the evidence collection process for potential control categories
Manual validation or analysis should be performed where missing, unclear, or omitted. 

#>

#Version Check
If ($PSVersionTable.PSVersion.Major -ge 3)
{
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Local Users and Groups" | Tee-Object -Append 'get-system-sec-info-output.log'
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'

Write-Host "Local Users and Groups: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black

#Local users
Get-LocalUser | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'

#Local user groups
Get-LocalGroup | Where-Object {$_.Name -like "*admin*"} | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'


echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Local Share Info" | Tee-Object -Append 'get-system-sec-info-output.log'
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'

Write-Host "Local Shares: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black

#Get SMB share and access cotnrol details
Get-SmbShare | ForEach-Object { Get-SmbShareAccess -Name $_.Name } | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'


echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Local Site AD Domain Controller" | Tee-Object -Append 'get-system-sec-info-output.log'
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'

Write-Host "Local Site AD Domain Controller: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black

#Get AD status
Get-LocalDomainController | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'


echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Software Inventory" | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Common AV Services" | Tee-Object -Append 'get-system-sec-info-output.log'
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'

Write-Host "Software Inventory: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black
Write-Host "Common AV Services: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black


#Software inventory
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'

#Get AV Services Running
Get-Service | Where-Object {$_.DisplayName -like "*defender*" -or $_.DisplayName -like "*symantec*" -or $_.DisplayName -like "*mcafee*"} | Format-Table –AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'


echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Certificate Store PKI Info" | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Support Ciphers and Suites" | Tee-Object -Append 'get-system-sec-info-output.log'
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'

Write-Host "Certificate and Cipher Suites: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black


#Grab SSL/TLS Cipher Suites Supported
Get-ChildItem -Recurse "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\" | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'

#Grab Certificate and PKI Store Information
$ExecGPresult = ("$Env:SystemRoot\System32\certutil.exe" + " " + "/v")
Invoke-Expression $ExecGPresult | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'


echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Firewall Profile Status" | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Egress TCP Port Check" | Tee-Object -Append 'get-system-sec-info-output.log'
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'

Write-Host "Firewall Profile Status: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black
Write-Host "Egress TCP Port Check: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black

#Get Firewall Status
Get-NetFirewallProfile | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'

#Check egress TCP ports
$portList = (22,53,80,443,8080,666,6667,3389)

ForEach ($port in $portList)
    {
        Test-NetConnection -ComputerName portquiz.net -Port $port | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'
        $portStatus = (Test-NetConnection -ComputerName portquiz.net -Port $port).TcpTestSucceeded
        If ($portStatus -eq 'True')
            {
                Write-Host "egress open port found" -ForegroundColor Yellow -BackgroundColor Black
            }
    }


echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'
echo "NTP Details" | Tee-Object -Append 'get-system-sec-info-output.log'
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'

Write-Host "NTP Details: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black

#Grab the NTP time synch info
$Execw32tm = ("$Env:SystemRoot\System32\w32tm.exe" + " " + "/query /computer:127.0.0.1 /status /verbose")
Invoke-Expression $Execw32tm | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'


#Grab the NTP server details
$ExecNetTime = ("$Env:SystemRoot\System32\net.exe" + " " + "time")
Invoke-Expression $ExecNetTime | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'




echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'
echo "Security Audit Policies" | Tee-Object -Append 'get-system-sec-info-output.log'
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'

Write-Host "Security Audit Policies: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black


#Grab Windows Event and other Auditing GPO details
$ExecAuditPol = ("$Env:SystemRoot\System32\auditpol.exe" + " " + "/get /category:*")
Invoke-Expression $ExecAuditPol | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'


echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'
echo "GPO Applied to Computer" | Tee-Object -Append 'get-system-sec-info-output.log'
echo ".................................." | Tee-Object -Append 'get-system-sec-info-output.log'

Write-Host "GPO Applied to Computer: Enumeration Starting" -ForegroundColor Green -BackgroundColor Black

#Grab GPO details of the computer scope
$ExecGPresult = ("$Env:SystemRoot\System32\gpresult.exe" + " " + "/scope:computer /v")
Invoke-Expression $ExecGPresult | Format-Table -AutoSize | Tee-Object -Append 'get-system-sec-info-output.log'
}

#exit script
exit

Write-Host "Output saved to: get-system-sec-info-output.log" -ForegroundColor Yellow -BackgroundColor Black

Else
    {
        Write-Host "You need PS version 3 or higher." -foregroundcolor red -backgroundcolor yellow
        Write-Host "Download WMF v5 here: https://www.microsoft.com/en-us/download/details.aspx?id=50395 "
        Write-Host "Exiting..."
        exit
    }
