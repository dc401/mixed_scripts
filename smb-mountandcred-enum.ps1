#Licensed under GPLv2 - Free and open to use without expressed warranty
#Dennis Chow 2019-July-25
#dchow[AT]xtecsystems.com

<#
Using invoke-command and enter-pssession are not always options for enum
when WinRM or WS-Mgt is disabled. Sometimes remote WMI accessibility is also not
feasible from within your current position. This script will use the
traditional 'net use' cmd shell utilities to enumerate remote share
success and obtain access permissions

This is an alternative if you don't have access to nmap:
nmap --script smb-enum-shares.nse -p445 <host>
sudo nmap -sU -sS --script smb-enum-shares.nse -p U:137,T:139 <host>

Other useful PS related comdlets to do so manually are:
New-PsSession or New-CIMsession and their relative Get-SmbShare
commands. Get-Wmiobject is useful IF you have WMI enabled.

#>

<#pulled from: https://www.kittell.net/code/powershell-ipv4-range/
powershell has no native interpretation of IPv4 and IPv6, but .NET classes does
Usage: New-IPrnge 10.10.10.1 10.10.20.254
#>
function New-IPRange ($start, $end)
    {
        # created by Dr. Tobias Weltner, MVP PowerShell
        $ip1 = ([System.Net.IPAddress]$start).GetAddressBytes()
        [Array]::Reverse($ip1)
        $ip1 = ([System.Net.IPAddress]($ip1 -join '.')).Address
        $ip2 = ([System.Net.IPAddress]$end).GetAddressBytes()
        [Array]::Reverse($ip2)
        $ip2 = ([System.Net.IPAddress]($ip2 -join '.')).Address
  
        for ($x=$ip1; $x -le $ip2; $x++)
            {
                $ip = ([System.Net.IPAddress]$x).GetAddressBytes()
                [Array]::Reverse($ip)
                $ip -join '.'
            }
    }

#versioncheck min PSv3.0
If ( $PSVersionTable.PSVersion.Major -ge 3)
{

    #menu selection using 'here-string' closing "@ cannot have whitespaces before it
    $userMenu = @"
    1 Run legacy net use non-credentialed [slowest]
    2 Run legacy net use map checks with credentials and user file supplied UNCs [fast]
    3 Run legacy  net use with username credential [fast]
    4 Run WinRM PS style enumeration credentialed [fastest]
    5 Exit
"@
    
    Write-host "NOTE: This script must be run with local admin rights. If not, exit and re-run" -ForegroundColor Red -BackgroundColor Yellow
    Write-Host "How do you want to do windows share enum?" -BackgroundColor Black -ForegroundColor Green
    $menuSelection = Read-Host $userMenu
    switch ($menuSelection)
    {
        "1"
            {
                #provide list of hosts or cidr ranges to try
                $startIP = Read-Host "Enter start IP address in range to try".ToString()
                $endIP = Read-Host "Enter end IP addresss in range to try".ToString()
                Write-Host "You entered:" $startIP "through" $endIP -ForegroundColor Yellow -BackgroundColor Black 
                Write-Host "creating range list..."
                $ipRangeArr = (New-IPRange -start $startIP  -end $endIP)

                #parameter isolation due to escaping issues
                #$netArg = ('use ' + '\\' + $_ + '\ipc$' + ' "" ' + '/user:""')
                $ipRangeArr | ForEach-Object {
                        $netArg0 = 'use'
                        $netArg1 = 'view'
                        $netArg2 = '\\' + $_ + '\ipc$'
                        $netArg3 = '"" /u:""'
                        $netArg4 = '\\' + $_
                        Write-Host "Running net.exe" $netArg0 $netArg2 $netArg3;
                        write-Host "Please wait, there is no timeout modification..." -ForegroundColor Yellow -BackgroundColor Black
                        $nullSession = (net.exe $netArg0 $netArg2 $netArg4 2>&1)
                        Write-Host $nullSession
                        if($nullSession -like "*error*")
                        {
                            Write-Host "Could not connect to $_"
                        }
                        elseif($nullSession -like "*the command completed*")
                        {
                            Write-Host $_ -ForegroundColor Green -BackgroundColor Black
                            net.exe $netArg1 $netArg4
                            #Get-SmbShare -Name $_ | Get-SmbShareAccess <-- applies only to PSSessions
                        }                                      
                    } | Tee-Object -Append anonymous-shares.log
                Write-Host "Output of info to anonymous-shares.log" -ForegroundColor Green -BackgroundColor Black
            }
        "2"
            {
                #grab secure string compatible credentials
                Write-Host "grabbing your credentials"
                $ntCredential = (Get-Credential -Message "Enter domain\user Credentials")
                Write-Host "Note: Your file input list should be in the form of \\host\\unc per line" -ForegroundColor Yellow -BackgroundColor Black
                $fileName = Read-Host "Please specify c:\path\path.txt to your formatted list"
                $uncTargets = (Get-Content $fileName)

                $uncTargets | ForEach-Object {
                    New-PSDrive -Name Z -PSProvide FileSystem -Root $_ -Credential $ntCredential; Get-Acl "Z:"; Remove-PSDrive -Name Z
                    } | Tee-Object -Append  credentialed-permissions.log
                Write-Host "Output of info to UNC-credentialed-permissions.log" -ForegroundColor Green -BackgroundColor Black
            }
        "3"
            {
                #provide list of hosts or cidr ranges to try
                $startIP = Read-Host "Enter start IP address in range to try".ToString()
                $endIP = Read-Host "Enter end IP addresss in range to try".ToString()
                Write-Host "You entered:" $startIP "through" $endIP -ForegroundColor Yellow -BackgroundColor Black 
                Write-Host "creating range list..."
                $ipRangeArr = (New-IPRange -start $startIP  -end $endIP)
                #grab AD style username
                $readADuser = Read-Host "Enter in Domain\username".ToString()
                #IPC does not request password in Win10
                #$readADPass = Read-Host "Enter password".ToString()

                #parameter isolation due to escaping issues
                $ipRangeArr | ForEach-Object {
                        $netArg0 = 'use'
                        $netArg1 = 'view'
                        $netArg2 = '\\' + $_ + '\ipc$'
                        $netArg3 = '/user:' + $readADUser
                        $netArg4 = '\\' + $_
                        Write-Host "Running net.exe" $netArg0 $netArg2 $netArg3;
                        write-Host "Please wait, there is no timeout modification..." -ForegroundColor Yellow -BackgroundColor Black
                        $nullSession = (net.exe $netArg0 $netArg2 $netArg4 2>&1)
                        Write-Host $nullSession | Tee-Object -Append credentialed-shares.log
                        if($nullSession -like "*error*")
                        {
                            Write-Host "Could not connect to $_"
                        }
                        elseif($nullSession -like "*the command completed*")
                        {
                            Write-Host $_ -ForegroundColor Green -BackgroundColor Black
                            net.exe $netArg1 $netArg4
                        }
                } | Tee-Object -Append credentialed-shares.log
                Write-Host "Output of info to credentialed-shares.log" -ForegroundColor Green -BackgroundColor Black
            }
        "4"
            {
                #Use Winrm/WS-Management style PS enabled session support cmdlets
                #provide list of hosts or cidr ranges to try
                $startIP = Read-Host "Enter start IP address in range to try".ToString()
                $endIP = Read-Host "Enter end IP addresss in range to try".ToString()
                Write-Host "You entered:" $startIP "through" $endIP -ForegroundColor Yellow -BackgroundColor Black 
                Write-Host "creating range list..."
                $ipRangeArr = (New-IPRange -start $startIP  -end $endIP)

                Write-Host "grabbing your credentials"
                $ntCredential = (Get-Credential -Mnewessage "Enter your Domain\AD credentials")

                #For this to work you need WinRM enabled
                $ipRangeArr | ForEach-Object {
                    Invoke-Command -Credential $ntCredential -ComputerName $_ -ScriptBlock `
                        {
                            Get-SmbShare | Get-SmbShareAccess
                        }    
                } | Tee-Object -Append WinRM-Enabledcredentialed-shares.log
                Write-Host "Output of info to WinRM-Enabledcredentialed-shares.log" -ForegroundColor Green -BackgroundColor Black
            }
        "5"
            {
                exit
            }
    
    }


}

Else
{
    Write-Host "You need PS version 3 or higher." -foregroundcolor red -backgroundcolor yellow
    Write-Host "Download WMF v5 here: https://www.microsoft.com/en-us/download/details.aspx?id=50395 "
    Write-Host "Exiting..."
}