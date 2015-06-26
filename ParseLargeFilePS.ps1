#20150605 dc - Parses large files line-by-line


#take in file path
$arg0 = Read-Host "Please enter filename.ext or full path (if file not in same dir) you wish to search"

IF (Test-Path -isvalid $arg0)
{
    $file = New-Object System.IO.StreamReader -Arg $arg0
    while ($line = $file.ReadLine()) `
    {
        $line | Select-String -Pattern ('password|login|logon|pass')
        
    }
    #Requires Powershell 4
    <#
    ForEach ($l in [System.IO.File]::ReadLines($arg0)) `
        {
            Select-String -Pattern ('password\|login\|logon\|pass')
        }
     #>
}
ELSE
{
    Write-Host "Check input file path."
}
