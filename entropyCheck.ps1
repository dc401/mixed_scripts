<#
20170519 dc - Ransomware Encrypted File Checker v1.0
Recurisvely mows through a unc or file path and inspects entropy against all file types
Any file that is greater than 7/8 scored entropy (randomness) will get passed to file 
magic for further inspecting 'unknown' signatures which raise a high suspicion of
potentially encrypted ransomware files. 

This is a re-write of the script from: https://isc.sans.edu/forums/diary/Using+File+Entropy+to+Identify+Ransomwared+Files/21351/
largely because I couldn't get the original author's script to work through functions.
While his functions seem correct, I could not get proper output returned from standard out variables

This script requires the use of the following:
PowerShell v3 or higher installed
Sysinternals SigCheck64.exe and dependencies in the same folder of script
Gnuwin32 File Magic + Magic DB in the same folder of script

Dennis Chow
dchow[AT]xtecsystems.com
www.xtecsystems.com

No warranties and licensed under GPLv2.

#>

#PS Version Check (Need v3 or higher)
If ( $PSVersionTable.PSVersion.Major -ge 3)
{
   #Check for dependent binaries
   If (( Test-Path .\file.exe -IsValid) -and (Test-Path .\sigcheck64.exe -IsValid) )
   {
        
        #Read path from user
        Write-Host "Ransomware Encrypted File Checker v1.0"
        $path = (Read-Host "Please enter path to check. Ex: c:\ \\foo\bar" )


        #Use sigcheck for entropy calculation
        Try
        {
            Write-Host "Scanning and calculating entropy under "$path" " -ForegroundColor Green -BackgroundColor Black
            Write-Host "Please wait..." -ForegroundColor Green -BackgroundColor Black
            .\sigcheck64.exe -a -s -c -nobanner $path | Out-File -Append entropy-results.csv

   
        }
        Catch
        {
            Write-Host "An error condition has occured. Please check your inputs." -foregroundcolor red -backgroundcolor yellow
            echo $_.Exception | Format-List -Force
        }

        Try
        {
            #Perform file magic examination per file
            #Zero out counters
            [int]$position = 0
            [int]$totalCount = 0

            #Stream count Entropy results
            Get-Content .\entropy-results.csv | ForEach-Object { $totalCount++ }

            Import-Csv .\entropy-results.csv | ForEach-Object `
            {
                If ($_.Entropy -gt 7 )
                {
                    #Write-Host $_.Path $_.Entropy
                    $fileMagic = (.\file.exe -m .\magic -p -N -F "," $_.Path)
                    $suspectResults = $fileMagic + ',' + $_.Entropy
                    Write-Host $suspectResults
                    $suspectResults | Out-File -Append 'HighEntropyResults.csv'
                    #Increase status counter
                    $position++ 
                    Write-Progress -Activity "Examining file magic headers" -Status "Progress:" `
                    -PercentComplete ( ($position / $totalCount) * 100 )
                }
            }
        }

        Catch
        {
            Write-Host "An error condition has occured. Please check your inputs." -foregroundcolor red -backgroundcolor yellow
            echo $_.Exception | Format-List -Force
        }


        Try
        {
            #Zero out counters (again reuse)
            [int]$position = 0
            [int]$totalCount = 0

            #Stream count Entropy results
            Get-Content .\HighEntropyResults.csv | ForEach-Object { $totalCount++ }

            #Extrapolate unknown fileypes
            Import-Csv .\HighEntropyResults.csv -Header Path,Type,Entropy | ForEach-Object `
            {
                If ( $_.Type -like "*unknown*" )
                {
                    #Write-Host $_.Path $_.Type "SUSPICIOUS"
                    $SuspiciousEncryptedFiles = $_.Path + ',' + $_Type + ',' + $_.Entropy
                    Write-Host $SuspiciousEncryptedFiles
                    $SuspiciousEncryptedFiles | Out-File -Appends 'SuspectRansomEncryptedFiles.csv'
                    $position++
                    Write-Progress -Activity "Looking unknown data magic types" -Status "Progress:" `
                    -PercentComplete ( ($position / $totalCount) * 100 )
                }
            }
        }
    
        Catch
        {
            Write-Host "An error condition has occured. Please check your inputs." -foregroundcolor red -backgroundcolor yellow
            echo $_.Exception | Format-List -Force
        }

    #Cleanup
    rm .\entropy-results.csv

    Write-Host "Result log files are located in same directory as the following:" -ForegroundColor Yellow -BackgroundColor Black
    #Write-Host "entropy-results.csv" -ForegroundColor Green -BackgroundColor Black
    Write-Host "HighEntropyResults.csv" -ForegroundColor Green -BackgroundColor Black
    Write-Host "SuspectRansomEncryptedFiles.csv" -ForegroundColor Green -BackgroundColor Black

}
    #Else catch dependent files not met
    Else
    {
    Write-Host "You are missing file magic and or sigcheck"
    Write-Host "File Magic Gnuwin32: binary + dependencies: http://gnuwin32.sourceforge.net/packages/file.htm"
    Write-Host "Sysinternals SigCheck 64 bit: https://technet.microsoft.com/en-us/sysinternals/bb897441.aspx"
    }
    
}
#Need a higher version of PS
Else
{
Write-Host "You need PS version 3 or higher." -foregroundcolor red -backgroundcolor yellow
Write-Host "Download WMF v5 here: https://www.microsoft.com/en-us/download/details.aspx?id=50395 "
Write-Host "Exiting..."
exit
}

exit
