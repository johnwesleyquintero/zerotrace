@echo off
setlocal enabledelayedexpansion
title ZeroTrace v1.1

:: =====================================================
:: ZeroTrace v1.1
:: A sovereign Windows cleanup utility — leaves zero trace.
:: https://github.com/johnwesleyquintero/zerotrace
:: =====================================================

:: ANSI Color Codes
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESC=%%E"
set "RESET=!ESC![0m"
set "BOLD=!ESC![1m"
set "CYAN=!ESC![36m"
set "GREEN=!ESC![32m"
set "YELLOW=!ESC![33m"
set "RED=!ESC![31m"
set "GRAY=!ESC![90m"

:: Check for administrative privileges
fltmc >nul 2>&1
if errorlevel 1 (
    echo.
    echo !RED![!] ZeroTrace requires Administrator privileges.!RESET!
    echo     Please right-click and select "Run as administrator".
    echo.
    pause
    exit /b
)

:: Clear screen and show header
cls
echo !CYAN!!BOLD!==================================================!RESET!
echo !CYAN!!BOLD!  ZeroTrace v1.1 - Leaving Zero Trace!RESET!
echo !GRAY!  https://github.com/johnwesleyquintero/zerotrace!RESET!
echo !CYAN!!BOLD!==================================================!RESET!
echo !YELLOW![*] Initializing system cleanup...!RESET!
echo.

:: Start Timer
for /f "tokens=1-4 delims=:., " %%i in ("%TIME%") do (
    set /a "start_seconds=(((%%i*60)+1%%j%%100)*60)+1%%k%%100"
)

:: Get initial disk space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A
echo !GREEN![+] Initial free space: !INITIAL_SPACE_MB! MB!RESET!

:: ==================================================
:: [1/16] Temp Files
:: ==================================================
echo.
echo !CYAN![1/16] Cleaning temporary files...!RESET!
for /f "usebackq delims=" %%F in (`dir "%TEMP%\*" /a-d /b 2^>nul`) do (
    if exist "%TEMP%\%%F" (
        del /f /q "%TEMP%\%%F" >nul 2>&1
    )
)
for /d %%p in ("%TEMP%\*.*") do (
    if exist "%%p" (
        rmdir "%%p" /s /q >nul 2>&1
    )
)
echo !GRAY![OK] Temp files cleaned.!RESET!
call :ProgressBar 1 16

:: ==================================================
:: [2/16] Browser Caches
:: ==================================================
echo.
echo !CYAN![2/16] Clearing browser caches...!RESET!

:: Close browsers if running
echo !YELLOW![!] Closing browsers to ensure deep clean...!RESET!
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im firefox.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im brave.exe >nul 2>&1
taskkill /f /im opera.exe >nul 2>&1

:: Chrome
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
)

:: Firefox
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*") do (
        if exist "%%p\cache2\entries" (
            rd /s /q "%%p\cache2\entries" >nul 2>&1
        )
    )
)

:: Edge
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
)

:: Brave
if exist "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" >nul 2>&1
)

:: Opera
if exist "%APPDATA%\Opera Software\Opera Stable\Cache" (
    rd /s /q "%APPDATA%\Opera Software\Opera Stable\Cache" >nul 2>&1
)

echo !GRAY![OK] Browser caches cleared.!RESET!
call :ProgressBar 2 16

:: ==================================================
:: [3/16] Windows Update Cleanup
:: ==================================================
echo.
echo !CYAN![3/16] Cleaning Windows Update files...!RESET!
dism /online /Cleanup-Image /StartComponentCleanup /NoRestart >nul 2>&1
dism /online /Cleanup-Image /SPSuperseded /NoRestart >nul 2>&1

net stop wuauserv >nul 2>&1
net stop cryptSvc >nul 2>&1
net stop bits >nul 2>&1
net stop msiserver >nul 2>&1

if exist "C:\Windows\SoftwareDistribution\Download" (
    rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
)

net start wuauserv >nul 2>&1
net start cryptSvc >nul 2>&1
net start bits >nul 2>&1
net start msiserver >nul 2>&1

echo !GRAY![OK] Windows Update debris removed.!RESET!
call :ProgressBar 3 16

:: ==================================================
:: [4/16] Windows.old & Upgrade Debris
:: ==================================================
echo.
echo !CYAN![4/16] Removing Windows.old and upgrade debris...!RESET!
if exist "C:\Windows.old" (
    takeown /F "C:\Windows.old" /R /D Y >nul 2>&1
    icacls "C:\Windows.old" /grant administrators:F /T >nul 2>&1
    rd /s /q "C:\Windows.old" >nul 2>&1
)
if exist "C:\$Windows.~BT" rd /s /q "C:\$Windows.~BT" >nul 2>&1
if exist "C:\$Windows.~WS" rd /s /q "C:\$Windows.~WS" >nul 2>&1
echo !GRAY![OK] Upgrade debris removed.!RESET!
call :ProgressBar 4 16

:: ==================================================
:: [5/16] Event Logs
:: ==================================================
echo.
echo !CYAN![5/16] Clearing Event Logs...!RESET!
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1
echo !GRAY![OK] Event logs cleared.!RESET!
call :ProgressBar 5 16

:: ==================================================
:: [6/16] Windows Logs
:: ==================================================
echo.
echo !CYAN![6/16] Cleaning Windows logs...!RESET!
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)
echo !GRAY![OK] Windows logs cleaned.!RESET!
call :ProgressBar 6 16

:: ==================================================
:: [7/16] Prefetch
:: ==================================================
echo.
echo !CYAN![7/16] Clearing Prefetch...!RESET!
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)
echo !GRAY![OK] Prefetch files removed.!RESET!
call :ProgressBar 7 16

:: ==================================================
:: [8/16] Recycle Bin
:: ==================================================
echo.
echo !CYAN![8/16] Emptying Recycle Bin...!RESET!
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo !GRAY![OK] Recycle Bin emptied.!RESET!
call :ProgressBar 8 16

:: ==================================================
:: [9/16] Store Cache + Network
:: ==================================================
echo.
echo !CYAN![9/16] Resetting Store cache and network...!RESET!
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
echo !GRAY![OK] Store and network reset complete.!RESET!
call :ProgressBar 9 16

:: ==================================================
:: [10/16] Privacy: Recent Files & Jump Lists
:: ==================================================
echo.
echo !CYAN![10/16] Clearing Recent Files and Jump Lists...!RESET!
del /f /q /s "%AppData%\Microsoft\Windows\Recent\*" >nul 2>&1
del /f /q /s "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q /s "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
echo !GRAY![OK] Privacy trails removed.!RESET!
call :ProgressBar 10 16

:: ==================================================
:: [11/16] System Maintenance: Cache & Error Reports
:: ==================================================
echo.
echo !CYAN![11/16] Cleaning system caches and error reports...!RESET!
:: Thumbnail Cache
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
:: Icon Cache
del /f /s /q "%LocalAppData%\IconCache.db" >nul 2>&1
:: Windows Error Reporting
if exist "%ProgramData%\Microsoft\Windows\WER\ReportArchive" rd /s /q "%ProgramData%\Microsoft\Windows\WER\ReportArchive" >nul 2>&1
if exist "%ProgramData%\Microsoft\Windows\WER\ReportQueue" rd /s /q "%ProgramData%\Microsoft\Windows\WER\ReportQueue" >nul 2>&1
if exist "%LocalAppData%\Microsoft\Windows\WER\ReportArchive" rd /s /q "%LocalAppData%\Microsoft\Windows\WER\ReportArchive" >nul 2>&1
if exist "%LocalAppData%\Microsoft\Windows\WER\ReportQueue" rd /s /q "%LocalAppData%\Microsoft\Windows\WER\ReportQueue" >nul 2>&1
:: Delivery Optimization
if exist "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache" rd /s /q "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache" >nul 2>&1
echo !GRAY![OK] System maintenance complete.!RESET!
call :ProgressBar 11 16

:: ==================================================
:: [12/16] VS Code & Discord Caches
:: ==================================================
echo.
echo !CYAN![12/16] Cleaning VS Code and Discord caches...!RESET!
:: Close apps if running
taskkill /f /im Code.exe >nul 2>&1
taskkill /f /im Discord.exe >nul 2>&1

:: VS Code
if exist "%AppData%\Code\Cache" rd /s /q "%AppData%\Code\Cache" >nul 2>&1
if exist "%AppData%\Code\CachedData" rd /s /q "%AppData%\Code\CachedData" >nul 2>&1
if exist "%AppData%\Code\GPUCache" rd /s /q "%AppData%\Code\GPUCache" >nul 2>&1
if exist "%AppData%\Code\logs" rd /s /q "%AppData%\Code\logs" >nul 2>&1

:: Discord
if exist "%AppData%\discord\Cache" rd /s /q "%AppData%\discord\Cache" >nul 2>&1
if exist "%AppData%\discord\Code Cache" rd /s /q "%AppData%\discord\Code Cache" >nul 2>&1
if exist "%AppData%\discord\GPUCache" rd /s /q "%AppData%\discord\GPUCache" >nul 2>&1

echo !GRAY![OK] Dev/Social caches cleared.!RESET!
call :ProgressBar 12 16

:: ==================================================
:: [13/16] Spotify Media Cache
:: ==================================================
echo.
echo !CYAN![13/16] Clearing Spotify media cache...!RESET!
taskkill /f /im Spotify.exe >nul 2>&1
if exist "%LocalAppData%\Spotify\Storage" rd /s /q "%LocalAppData%\Spotify\Storage" >nul 2>&1
if exist "%LocalAppData%\Spotify\Users" (
    for /d %%u in ("%LocalAppData%\Spotify\Users\*") do (
        if exist "%%u\Cache" rd /s /q "%%u\Cache" >nul 2>&1
    )
)
echo !GRAY![OK] Spotify cache cleared.!RESET!
call :ProgressBar 13 16

:: ==================================================
:: [14/16] GPU Shader Caches (NVIDIA/AMD)
:: ==================================================
echo.
echo !CYAN![14/16] Cleaning GPU shader caches...!RESET!
:: NVIDIA
if exist "%LocalAppData%\NVIDIA\DXCache" rd /s /q "%LocalAppData%\NVIDIA\DXCache" >nul 2>&1
if exist "%LocalAppData%\NVIDIA\GLCache" rd /s /q "%LocalAppData%\NVIDIA\GLCache" >nul 2>&1
if exist "%AppData%\NVIDIA\ComputeCache" rd /s /q "%AppData%\NVIDIA\ComputeCache" >nul 2>&1
:: AMD
if exist "%LocalAppData%\AMD\DxCache" rd /s /q "%LocalAppData%\AMD\DxCache" >nul 2>&1
if exist "%LocalAppData%\AMD\OglCache" rd /s /q "%LocalAppData%\AMD\OglCache" >nul 2>&1
echo !GRAY![OK] GPU shader caches cleared.!RESET!
call :ProgressBar 14 16

:: ==================================================
:: [15/16] Advanced Space Reclamation
:: ==================================================
echo.
echo !CYAN![15/16] Reclaiming advanced disk space...!RESET!
:: DirectX Shader Cache (Legacy/System)
if exist "%LocalAppData%\D3DSCache" rd /s /q "%LocalAppData%\D3DSCache" >nul 2>&1
if exist "%LocalAppData%\Microsoft\DirectX\ShaderCache" rd /s /q "%LocalAppData%\Microsoft\DirectX\ShaderCache" >nul 2>&1
:: Windows Crash Dumps
if exist "%SystemRoot%\Minidump" del /f /q /s "%SystemRoot%\Minidump\*" >nul 2>&1
if exist "%LocalAppData%\CrashDumps" del /f /q /s "%LocalAppData%\CrashDumps\*" >nul 2>&1
:: BranchCache
netsh branchcache flush >nul 2>&1
:: Cryptography SVC Task
certutil -setreg chain\ChainCacheResyncFiletime @now >nul 2>&1
echo !GRAY![OK] Advanced space reclaimed.!RESET!
call :ProgressBar 15 16

:: ==================================================
:: [16/16] Deep Trace Removal (Registry & Shell)
:: ==================================================
echo.
echo !CYAN![16/16] Performing deep trace removal...!RESET!
:: ShellBags (Explorer folder view history)
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
:: UserAssist (App execution history)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f >nul 2>&1
:: Restart Explorer to apply changes
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul 2>&1
echo !GRAY![OK] Deep traces removed (Explorer restarted).!RESET!
call :ProgressBar 16 16

:: ==================================================
:: Summary
:: ==================================================
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
for /f "usebackq" %%A in (`powershell -Command "$i=%INITIAL_SPACE_MB%; $f=%FINAL_SPACE_MB%; [math]::Round($f - $i)"`) do set SPACE_FREED=%%A
for /f "usebackq" %%A in (`powershell -Command "[math]::Round((Get-PSDrive C).Free / 1GB, 2)"`) do set FINAL_SPACE_GB=%%A
for /f "usebackq" %%A in (`powershell -Command "$d=Get-PSDrive C; [math]::Round(($d.Free + $d.Used) / 1GB, 2)"`) do set TOTAL_SPACE_GB=%%A

:: Calculate Timer
for /f "tokens=1-4 delims=:., " %%i in ("%TIME%") do (
    set /a "end_seconds=(((%%i*60)+1%%j%%100)*60)+1%%k%%100"
)
set /a "duration=end_seconds-start_seconds"

echo.
echo !CYAN!!BOLD!==================================================!RESET!
echo !GREEN!!BOLD!  ZERO TRACE COMPLETE.!RESET!
echo !CYAN!!BOLD!==================================================!RESET!
echo  Initial free space: !YELLOW!%INITIAL_SPACE_MB% MB!RESET!
echo  Final free space:   !YELLOW!%FINAL_SPACE_MB% MB!RESET!
echo  Space freed:        !GREEN!!BOLD!%SPACE_FREED% MB!RESET!
echo  Time elapsed:       !CYAN!%duration% seconds!RESET!
echo !GRAY!--------------------------------------------------!RESET!
echo  Available Storage:  !CYAN!!BOLD!%FINAL_SPACE_GB% GB of %TOTAL_SPACE_GB% GB!RESET!
echo !CYAN!!BOLD!==================================================!RESET!
echo.
echo !GREEN![OK] System cleaned. Zero trace left behind.!RESET!
echo.
echo !GRAY!Sovereign Systems ^| Built by Wesley ^& WesAI!RESET!
echo.
echo Press any key to exit...
pause >nul

exit /b

:: ==================================================
:: Function: ProgressBar
:: ==================================================
:ProgressBar
set CURRENT_STEP=%1
set TOTAL_STEPS=%2
set /a PERCENT=(CURRENT_STEP*100)/TOTAL_STEPS
set BAR=!GRAY![!RESET!
set /a FILLED=(PERCENT*30)/100
for /L %%i in (1,1,!FILLED!) do set BAR=!BAR!!GREEN!#!RESET!
for /L %%i in (!FILLED!,1,30) do set BAR=!BAR!!GRAY!-!RESET!
set BAR=!BAR!!GRAY!]!RESET!
echo Progress !CURRENT_STEP!/!TOTAL_STEPS! !BAR! !GREEN!!PERCENT!%% complete!RESET!
exit /b
