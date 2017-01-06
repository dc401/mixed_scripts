<#
dchow[AT]xtecsystems.com
Interactive PowerShell script to do a lookup of emails from a CSV file and then add in renamed
properties from Get-ADUsers information. It spits out to a new CSV file. Very simple, useful
for 'reverse' searching of other AD attributes for users.
Requirements: PowerShell v3 or higher and the Powershell Active Directory Module Installed

v1.0 20170105

Visit us online at: www.scissecurity.com
Xtec Systems is now SCIS Security

#>
#Version Check
If ( $PSVersionTable.PSVersion.Major -ge 3)
{
#Make sure AD Module is Installed
    If ( (Get-Module -ListAvailable -Name ActiveDirectory) )
    {
        Try
        {
            [string]$inFile = Read-Host "Enter filename CSOP CSV User Export Ex:team-foo.csv" 

            $list = Import-Csv $inFile
            $outFile = "$inFile" + "_" + "SSO" + "_" + "Dump" + ".csv"

            $listArr = $list | Select-Object "Email"

            ForEach($x in $listArr)
            {
    
                $emailAddr = $x.Email
                #Utilizing label and expressions for Select-Object to "rename" CSV columns to match for excel vlookup matching
                Get-ADUser -Filter {EmailAddress -eq $emailAddr} `
                |Select-Object @{ expression = {$_.GivenName}; label="First Name"} , @{ expression = {$_.Surname}; label="Last Name"} `
                , @{ expression = {$_.UserPrincipalName}; label = "Email"}, @{ expression = {$_.SamAccountName}; label = "SSO"} `
                | Export-Csv $outFile -Append -NoTypeInformation
                #| Select-Object "GivenName", "Surname", "UserPrincipalName", "SamAccountName"
            }

            Write-Host "Output exported to $outFile"
        }
        Catch
        {
        Write-Host "An error condition has occured. Please check your inputs." -foregroundcolor red -backgroundcolor yellow
        echo $_.Exception | Format-List -Force
        }
    exit
    }
    Else
    {
        Write-Host "You need Powershell v3 or higher installed"
    }
}
Else
{
    Write-Host "Install the Active Directory PowerShell Module"
}
