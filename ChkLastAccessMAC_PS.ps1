#20150610 dc - Checks the last access time of a specific directory or file and loops in a monitoring fashion
$oldArr = Get-ChildItem ./ | Select-Object Name, LastAccessTime
$x = 0
DO {
    Start-Sleep -s 60
    $newArr = Get-ChildItem ./ | Select-Object Name, LastAccessTime
    #Compare-Object $oldArr $newArr -IncludeEqual
    $x++
    IF (diff $oldArr $newArr)
        {
            Write-Host "Access time changed."
        }
    ELSE
        {
            Write-Host "No change within $x seconds"
        }
    }
#loop for 8 hours
WHILE ($x -le 1728000)
exit
