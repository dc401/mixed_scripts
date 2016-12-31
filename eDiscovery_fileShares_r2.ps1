#dchow[AT]xtecsystems.com
#Warning: This tool is meant to be used as a last resort. Consider eDiscovery specific tools.
#Notice: This tool is limited by the .NET objects of 260 characters within NTFS
#There is NO warranty on this tool.
<#eDiscovery String Search and Copy files to a specific destination that Match
 For PS v3 and higher. Recommended on PS v5 however 20161227 dc
 *Notice* IOPS performance runs best when not ran from a cmd.exe wrapper
 vR1 (1.1) - Changelog 20161228 dc
    Added file date creation range search
    Fixed 'InputStream' odd string from EOF before processing
    Changed Hashing to MD5 for performance purposes
    Added check to see if PS v5 is installed

 vR2 (1.2) - Changelog 20161229 dc
    Fixed memory exhaustion problem that not loading recurse dir in memory. (May impact indexing performance though)
    Changed copy mechanism to robocopy.exe

#>

#Version Check
If ( $PSVersionTable.PSVersion.Major -ge 3)
{
    #Collect user input
    [string]$stringInput = Read-Host -prompt "Enter string or regex to search for e.g. foo"
    Write-Host "You entered $stringInput" -foregroundcolor green -backgroundcolor black
    [string]$startDateInput = Read-Host -prompt "Enter START search date range (CREATED DATE) MM/DD/YYYY"
    Write-Host "You entered $startDateInput" -foregroundcolor green -backgroundcolor black
    [string]$endDateInput = Read-Host -prompt "Enter END search date range (CREATED DATE) MM/DD/YYYY"
    Write-Host "You entered $endDateInput" -foregroundcolor green -backgroundcolor black
    [string]$pathInput = Read-Host -Prompt "Enter the base path to start search from e.g. H:\*.* or \\foo\bar"
    Write-Host "You entered $pathInput" -foregroundcolor green -backgroundcolor black
    [string]$logsOut = Read-host -Prompt "Enter the output path to export log results to e.g. c:\foo\log.txt"
    Write-Host "You entered $logsOut" -foregroundcolor green -backgroundcolor black
    [string]$copyDest = Read-Host -prompt "Enter the destination path for found files e.g. \\foo\bar"
    Write-Host "You entered $copyDest" -foregroundcolor green -backgroundcolor black
    [string]$hashFile = Read-Host -prompt "Enter the output path to export hash results to e.g. c:\foo\hash.txt"
    Write-Host "You entered $hashFile" -foregroundcolor green -backgroundcolor black

    #Enumerate files with conditions
    Try
    {
        Write-Host "Searching for $stringInput in files starting in $pathInput" -foregroundcolor green -backgroundcolor black
        Write-Host "Constraints Create Date Range: $startDateInput through $endDateInput" -foregroundcolor green -backgroundcolor black
        <#
        Get-ChildItem -Path "$pathInput" -Recurse |Where-Object { $_.CreationTime -gt "$startDateInput" -and $_.CreationTime -le "$endDateInput" } `
        | Select-String -Pattern $stringInput | ForEach { $_.Path } | Get-Unique | Tee-Object -FilePath $logsOut -Append
        #>

        #ForEach-Object stream to memory rather that front load. I/O performance may suffer
        #However the trade up is optimization so you do not exhaust the default 1 GB allocated to each PS console instance
        Get-ChildItem -Path "$pathInput" -Recurse | ForEach-Object {
            If ( ($_.CreationTime -gt "$startDateInput" -and $_.CreationTime -le "$endDateInput"))
            {
                $_ | Select-String -Pattern $stringInput | ForEach { $_.Path } | Get-Unique | Tee-Object -FilePath $logsOut -Append
            }
        }
    }
    Catch
    {
        Write-Host "An error condition has occured. Please check your inputs." -foregroundcolor red -backgroundcolor yellow
        echo $_.Exception | Format-List -Force
    }


    #Copy files enumerated from list to destination
    Try
    {
        Write-Host "Copying responsive files to $copyDest" -foregroundcolor green -backgroundcolor black
        
        ForEach ($x in (Get-Content $logsOut))
        {
  
            <#
            Will Change MAC "date created" times on the copied folder. Does not save attributes
            Robocopy.exe only requires the source directory listed with the filename separated to work
            #>
            #Copy-Item -Path $x -Destination $copyDest -ErrorAction Continue
            
            $resultsBasePath = Split-Path -Path $x
            $fileNamePath = $x | Split-Path -Leaf

            robocopy.exe $resultsBasePath $copyDest $fileNamePath '/COPY:DAT'

        } 
    }
    Catch
    {
        Write-Host "An error condition has occured. Please check your inputs." -foregroundcolor red -backgroundcolor yellow
        echo $_.Exception | Format-List -Force
    }

    #Calculate MD5 hashes 
    Try
    {
        Write-Host "Calculating Hashes to $hashFile" -foregroundcolor green -backgroundcolor black
        ForEach ($y in (Get-Content $logsOut))
        {
            echo (Get-FileHash $y -Algorithm MD5 | Format-List)  >> $hashFile
        }
    }
    Catch
    {
        Write-Host "An error condition has occured. Please check your inputs." -foregroundcolor red -backgroundcolor yellow
        echo $_.Exception | Format-List -Force
    }

    Write-Host "Copies and hashing completed." -foregroundcolor green -backgroundcolor black
    Write-Host "Your files are located in the following locations:"
    Write-Host $logsOut
    Write-Host $copyDest
    Write-Host $hashFile

#Exit PS to clear out memory
exit
}
Else
    {
    Write-Host "You need PS version 3 or higher." -foregroundcolor red -backgroundcolor yellow
    Write-Host "Download WMF v5 here: https://www.microsoft.com/en-us/download/details.aspx?id=50395 "
    Write-Host "Exiting..."
    exit
    }
