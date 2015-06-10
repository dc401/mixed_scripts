#20150605 dc - Parses large files line-by-line via the io streamreader
#For when you don't have Gnuwin32 tools or the file is too big for Get-Content

#take in file path
$arg0 = Read-Host "Please enter filename.ext or full path (if file not in same dir) you wish to search"
Write-Host "Will read from: $arg0" -backgroundcolor "black" -foregroundcolor "green"
Write-Host " "
$arg1 = Read-Host "Please enter the REGEX or string to look for"
Write-Host " "
Write-Host "Looking for: $arg1" -backgroundcolor "black" -foregroundcolor "green"

IF (Test-Path -isvalid $arg0)
{
    $file = New-Object System.IO.StreamReader -Arg $arg0
    while ($line = $file.ReadLine()) `
    {
        $line | Select-String -Pattern ($arg1)
        
    }
    #Requires Powershell 4 to call File.ReadLines method
    <#
    ForEach ($l in [System.IO.File]::ReadLines($arg0)) `
        {
            Select-String -Pattern ('EXAMPLE-FOO')
        }
     #>
}
ELSE
{
    Write-Host "Check input file path."
}
