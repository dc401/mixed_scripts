#20150204 dc - remotely fetch event logs host list and save to CSV files
#Minimum powershell needed v2.0 or higher

#arguments check
param([string]$i)

#if you want to use multiple args
#param([string]$i , [string]$o)

#ensure output is a valid dir path
IF (Test-Path -isvalid $i)
{
    Write-Host "Reading from list: $i" -foregroundcolor red -backgroundcolor yellow
    
    #Grab the IP or FQDNs of hosts to remotely fetch events
    $rhostsArray = Get-Content $i
    
    #Iterate through rhostsArray. ForEach is different from ForEach-Object
    #x is just a variable assigned to each string object
    ForEach ($x in $rhostsArray)
        {
            #Use RPC to grab security event logs and strip metadata added from Export-Csv
            #Using after parameters with function method sequence for last 5 minutes present local
            #back tick allows multiple lines with same statement
            Get-WinEvent -FilterHashTable @{LogName="*"; StartTime=(Get-Date).AddMinutes(-5)} `
            -ComputerName $x | Export-Csv "$x.csv" -NoTypeInformation
        }
            
}
ELSE
{
    Write-Host "Invalid path or argument combination"
    #Beep to get your attention
    $([char]7)
    exit;
}
