#This script works for PS version 3 and above tested on Windows 10
#GPL v2
#author: Dennis Chow 20-March-2020 <dchow[AT]xtecsystems.com>

while($true)
{
    $domains = @("www.google.com", "www.yahoo.com", "www.cnn.com", "www.xfinity.com", "dl.google.com")
    $useragent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36"
    $getwebpage = Invoke-WebRequest -Uri $domains[$(Get-Random -Minimum 0 -Maximum $domains.Count)] -TimeoutSec 5 -UserAgent $useragent
    Start-sleep -Seconds 1
    #$inetstatus = Test-NetConnection -ComputerName $domains[$(Get-Random -Minimum 0 -Maximum $domains.Count)] -Port 443 
    $inetstatus = Test-NetConnection -ComputerName "dl.google.com" -Port 443
        if ($inetstatus.TcpTestSucceeded -ne 0) 
        { 
            Write-Host "$i works"
        } 
        elseif ($inetstatus.TcpTestSucceeded -eq 0)
        { 
            Write-Host "$i failed"; "failed" | Out-File -Append status.txt
        }
    $randomint = Get-random -Minimum 120 -Maximum 300
    Start-Sleep -Seconds $randomint


}
