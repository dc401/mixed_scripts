#20150626 dc looks for files older than a specific 30 days and removes them

#Create array bypass formatting at the end
$oldFilesArr = Get-ChildItem ./ | Select-Object Name, LastWriteTime | `
Where-Object { $_.LastWriteTime -gt (Get-Date).addDays(-30) } | `
ForEach { $_.Name }

#ForEach that isn't piped is considered a statement
ForEach ($i in $oldFilesArr)
    {
        #Remove-Item $i
        Write-Host "Deleting" $i
        Remove-Item $i
        
    }
