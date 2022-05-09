<#
##################
## Creator Info ##
##################
Nick Stanovic
Premium Tech Support
Created: May 8, 2022
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
    cls
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
    elseif ($EdgeRunning)
    {
        $EdgeRunning | Stop-Process -Force
    }
    elseif ($FirefoxRunning)
    {
        $FirefoxRunning | Stop-Process -Force
    }
}

function DisplayDiskSpaceBeforeCleaning ()
{
    Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } |
    Select-Object SystemName,
                    @{ Name = "Drive"; Expression = { ($_.DeviceID) } },
                    @{ Name = "Size (MB)"; Expression = { "{0:N1}" -f ($_.Size / 1mb) } },
                    @{ Name = "FreeSpace (MB)"; Expression = { "{0:N1}" -f ($_.Freespace / 1mb) } } |
    Format-Table -AutoSize
}

function RunDiskCleanup ()
{
    cleanmgr /verylowdisk
    Read-Host "When Disk Cleanup is complete, click OK then press the Enter key to continue"
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

function CleanupTempFiles ()
{
    Write-Host "Deleting Temp Files..." -ForegroundColor Yellow
    Remove-Item -Path C:\Windows\Temp\* -Recurse -Force  -ErrorAction SilentlyContinue
    Write-Host "    Temp Files Deleted." -ForegroundColor Green
    

    Write-Host "Removing Prefetch Data..." -ForegroundColor Yellow
    Remove-Item -Path C:\Windows\Prefetch\*.pf -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "    Prefetch Data Removed." -ForegroundColor Green
    

    Write-Host "Removing Font Cache..." -ForegroundColor Yellow
    Remove-Item C:\Windows\ServiceProfiles\LocalService\AppData\Local\FontCache* -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "    Font Cache Cleared." -ForegroundColor Green
}

function DisplayDiskSpaceAfter ()
{
    Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } |
    Select-Object SystemName,
                    @{ Name = "Drive"; Expression = { ($_.DeviceID) } },
                    @{ Name = "Size (MB)"; Expression = { "{0:N1}" -f ($_.Size / 1mb) } },
                    @{ Name = "FreeSpace (MB)"; Expression = { "{0:N1}" -f ($_.Freespace / 1mb) } } |
    Format-Table -AutoSize
}

function CleanupWindows ()
{
    DisplayOperatingSystem
    DisplayDiskSpaceBeforeCleaning
    Start-Sleep -Seconds 5
    CloseOpenBrowsers
    Start-Sleep -Seconds 5
    RunDiskCleanup
    Start-Sleep -Seconds 5
    FlushDNS
    Start-Sleep -Seconds 5
    CleanupBrowsers
    Start-Sleep -Seconds 5
    CleanupTempFiles
    Start-Sleep -Seconds 5
    DisplayDiskSpaceAfter
    Start-Sleep -Seconds 5

    Write-Host "Congratulations! The computer cleanup has finished." -ForegroundColor Cyan
}
    
##########################
## Start main code here ##
##########################
CleanupWindows
