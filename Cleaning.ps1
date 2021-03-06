<#
##################
## Creator Info ##
##################
Nick Stanovic
Premium Tech Support
Created: May 8, 2022

Disclaimer
---
If script not ran in Powershell as admin, the cleanmgr portion will not work correctly
Can copy and paste this entire code into Powershell prompt as admin and then press enter
No need to save a file on the pc first or bypass Powershell execution policy this way
This script does not generate any logs or add any files to a computer
Only use on Win10 and Win11 Home/Pro machines.
Do not run this code to clean your school or work computer!
Your IT department has a special setup to handle cleaning your device.
#>

###############
## Variables ##
###############
$OSName = (Get-CimInstance Win32_OperatingSystem).Caption

$Chrome = "$env:localappdata\Google\Chrome"
$ChromeExist = Test-Path $Chrome
$ChromeCache = "$Chrome\User Data\Default\Cache\Cache_Data\*.*"
$ChromeRunning = Get-Process chrome -ErrorAction SilentlyContinue

$Edge = "$env:localappdata\Microsoft\Edge"
$EdgeExist = Test-Path $Edge
$EdgeCache = "$Edge\User Data\Default\Cache\Cache_Data\*.*"
$EdgeRunning = Get-Process msedge -ErrorAction SilentlyContinue

$FirefoxLocal = "$env:localappdata\Mozilla\Firefox\Profiles\*.default-release"
$FirefoxRoaming = "$env:appdata\Mozilla\Firefox\Profiles\*.default-release"
$FirefoxExist = Test-Path $FirefoxLocal
$FirefoxRunning = Get-Process firefox -ErrorAction SilentlyContinue


###############
## Functions ##
###############
function DisplayOperatingSystem
{
    Clear-Host
    Write-Host "We are running on $OSName." -ForegroundColor Green
}

function CloseOpenBrowsers ()
{
    Write-Host "Closing any open browsers..."  -ForegroundColor Yellow
    Write-Host ""
   
   if ($ChromeRunning)
    {
        $ChromeRunning | Stop-Process -Force
    }
    
    if ($EdgeRunning)
    {
        $EdgeRunning | Stop-Process -Force
    }
    
    if ($FirefoxRunning)
    {
        $FirefoxRunning | Stop-Process -Force
    }
}

function DisplayDiskSpace ()
{
    Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" } |
    Select-Object SystemName,
                    @{ Name = "Drive"; Expression = { ($_.DeviceID) } },
                    @{ Name = "Size (MB)"; Expression = { "{0:N1}" -f ($_.Size / 1mb) } },
                    @{ Name = "FreeSpace (MB)"; Expression = { "{0:N1}" -f ($_.Freespace / 1mb) } } |
    Format-Table -AutoSize
}

function RunDiskCleanup ()
{
    cleanmgr /verylowdisk
    Write-Host "Running Windows Disk Cleanup..."  -ForegroundColor Yellow
    do 
        {
            
            Start-Sleep -Seconds 5
        } 
    until 
        (
            (Get-Process -Name cleanmgr).MainWindowTitle -eq 'Disk Space Notification'
        )
    Stop-Process -Name cleanmgr
    <#
            Disk Cleanup's WindowTitle is 'Disk Cleanup' when running, then 'Disk Space Notification' when finished
            Stopping cleanmgr once WindowTitle changes allows script to continue without needing user input
    #>
    Write-Host "    Disk Cleanup Finished." -ForegroundColor Green
}

function FlushDNS ()
{
    Write-Host "Flushing DNS..." -ForegroundColor Yellow
    Clear-DnsClientCache
    Write-Host "    DNS Flushed." -ForegroundColor Green
}

function CleanupBrowsers ()
{
    Write-Host "Clearing Browser Cache..." -ForegroundColor Yellow
    if ($ChromeExist)
        {
            Remove-Item -Path $ChromeCache -Recurse -Force 
            Write-Host "    Chrome Cache Cleared." -ForegroundColor Green
        }

    if ($EdgeExist)
        {
            Remove-Item -Path $EdgeCache -Recurse -Force 
            Write-Host "    Edge Cache Cleared." -ForegroundColor Green
        }
    
    if ($FirefoxExist)
        {
            Remove-Item -Path "$FirefoxLocal\cache2" -Recurse -Force
            Remove-Item -Path "$FirefoxLocal\thumbnails" -Recurse -Force
            Remove-Item -Path "$FirefoxRoaming\cache2" -Recurse -Force
            Remove-Item -Path "$FirefoxRoaming\thumbnails" -Recurse -Force

            Write-Host "    Firefox Cache Cleared." -ForegroundColor Green
        }
}

function ClearFontCache ()
{
    Write-Host "Removing Font Cache..." -ForegroundColor Yellow
    Remove-Item C:\Windows\ServiceProfiles\LocalService\AppData\Local\FontCache* -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "    Font Cache Cleared." -ForegroundColor Green
}

<# TODOs: 
    1. function to display a summary of free space (MB) created
    2. integrate dotnet stopwatch to time the cleaning
    3. function to display a summary that's easier to understand. 
        It's confusing to look at only starting and ending free space to determine how effective was the cleaning
        My brain hurts too much to even make the minimal effort to figure out the math or type one more line of code
    4. function to show how much space (MB) was cleared by comparing 'before' and 'after' folder sizes 
#>

function CleanupWindows ()
{
    DisplayOperatingSystem
    DisplayDiskSpace
    Start-Sleep -Seconds 5
    CloseOpenBrowsers
    Start-Sleep -Seconds 5
    RunDiskCleanup
    Start-Sleep -Seconds 5
    FlushDNS
    Start-Sleep -Seconds 5
    CleanupBrowsers
    Start-Sleep -Seconds 5
    ClearFontCache
    Start-Sleep -Seconds 5
    DisplayDiskSpace
    Start-Sleep -Seconds 5

    Write-Host "Congratulations! The computer cleanup has finished." -ForegroundColor Cyan
}

    
##########################
## Start main code here ##
##########################
CleanupWindows
