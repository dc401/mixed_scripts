<#
20141204 dc - v1.0 Converts emails to various AD attribute outputs and provides basic stats
Parses user to managers/supervisor titles in a sep output
Requires remote admin tools: http://www.microsoft.com/en-us/download/details.aspx?id=7887

Input Requirements: List of emails must be single line by line list in a text file

Syntax: email2adinfo.ps1 -i listofEmailsIn.txt -o UsersOutFile.csv -m ManagersOutFile.csv

Modified from old one liner
Get-ADUser -searchbase "OU=FOO,DC=BAR,DC=local" -filter * -Properties sAMAccountName, department | Select-Object SamAccountName,Department | Where-Object {$_.Department -match "FOO*" } | Export-Csv .\foo.csv

#>

#Argument check
param([string]$i , [string]$o, [string]$m)
Write-Host "Reading from: $i"
Write-Host "Writing to: $o"
Write-Host "Writing to: $m"

IF (Test-Path -isvalid $i)
{
    #Lookup emails from file and expand dsquer/dsget properties to an array and export
    import-module ActiveDirectory
    Get-Content $i | Get-Unique | ForEach-Object {Get-ADUser -searchbase "OU=FOO,DC=BAR,DC=local" -filter { EmailAddress -eq $_ } `
    -Properties mail, sAMAccountName, department, title | Select-Object mail, SamAccountName,Department, title} | Export-Csv -notype $o
    
    #Count emails list unique
    $TotalUsers =  Get-Content $i | Get-Unique | Measure-Object | Select-Object "Count"
    Write-Host "# Confirmed Users:" $TotalUsers -foregroundcolor red -backgroundcolor yellow
    
    #Parse the managerial positions and export
    Get-Content $i | Get-Unique | ForEach-Object {Get-ADUser -searchbase "OU=FOO,DC=BAR,DC=local" -filter { EmailAddress -eq $_ } `
    -Properties mail, sAMAccountName, department, title | Select-Object mail, SamAccountName,Department, title} | `
    Where-Object {$_.title -match "(Mgr|Manager|Dir|Director|Supervisor|President|VP|Chief)" } | Export-Csv -notype $m
    
    #Count manager emails list unique
    $TotalManagers = Get-Content $m | Get-Unique | Measure-Object | Select-Object "Count"
    Write-Host "# Confirmed Managers:" $TotalManagers -foregroundcolor red -backgroundcolor yellow
    
    Write-Host "Done."
    #Beep to get your attention
    $([char]7)
}

ELSE
{
    Write-Host "Syntax: email2adinfo.ps1 -i listofEmailsIn.txt -o UsersOutFile.csv -m ManagersOutFile.csv"
    exit;
}
