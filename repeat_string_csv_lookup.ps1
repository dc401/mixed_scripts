<# 20141205 dc v1.0 - Checks across multiple files in a specified path for any duplicate strings

Primary usage is for looking up repeat strings based on emails using CSVs.
Import-CSV not used because it combined with a select statement adds too many blank lines and non-print chars
Objects are still created since they're single lines and we're not utilizing tokens.

Syntax: repeat_string_csv_lookup.ps1 -d PathToCSVFiles -o OutFile.txt

NOTE: You may receive the following errors: "You cannot call a method on a null-valued expression."
This usually occurs depending how windows concats the files with and did not strip out any spaces/null chars

Example 1: repeat_offender_csv_lookup.ps1 -d . -o foobar.txt
Example 2: repeat_offender_csv_lookup.ps1 -d C:\Users\foo\bar\ -o foobar.txt

Ref:
http://stackoverflow.com/questions/18847145/powershell-loop-through-files-in-directory
http://regexlib.com/Search.aspx?k=email

#>

#Argument check
param([string]$d , [string]$o)


IF (Test-Path -isvalid $d)
{
    Write-Host "Read from from dir: $d" -foregroundcolor red -backgroundcolor yellow
    Write-Host "Writing to: $o" -foregroundcolor red -backgroundcolor yellow

    #Unique content per file prior to concat so that users are not dinged multiple times per phish violation removing blank lines
    Get-ChildItem $d -Filter *.csv | `
    ForEach-Object{
        $FileContent = Get-Content $_.FullName
        #$FileContent | ForEach-Object {$_.Split(",")[0]} | Sort-Object -Unique | Set-Content ($_.BaseName+'_uniq.tmp')
        $FileContent | Where-Object {$_ -match '\S'} | ForEach-Object {$_.Split(",")[0]} | Sort-Object -Unique | Set-Content ($_.BaseName+'_uniq.tmp')
        }
                    
    #Concat the files and split based on Metasploit first column CSV email and remove one time offenders
    Get-Content $d\*.tmp | Foreach-Object {$_.Split(",")[0]} | Where-Object {$_ -match "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"} | `
    Group-Object |  Select-Object Count,Name | Where-Object {$_.Count -gt 1} | Export-Csv -notype $o
         
    #Display contents to std out
    Import-Csv $o
    
    #Cleanup
    rm *.tmp
	
    Write-Host " "
    Write-Host "Done." -foregroundcolor red -backgroundcolor yellow
    #Beep to get your attention
    $([char]7)
}

ELSE
{
    Write-Host "Parses CSVs for the first column only. This Script is meant for finding repeat phish offenders."
    Write-Host " "
    Write-Host "Something went wrong. Did you enter a valid path?"
    Write-Host " "
    Write-Host "Syntax: repeat_string_csv_lookup.ps1 -d PathToCSVFiles -o OutFile.txt" -foregroundcolor red -backgroundcolor yellow
    Write-Host "Example 1: repeat_string_csv_lookup.ps1 -d . -o foobar.txt"
    Write-Host "Example 2: repeat_string_csv_lookup.ps1 -d C:\Users\foo\bar\ -o foobar.txt"
    exit;
}
