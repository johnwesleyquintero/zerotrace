@echo off
setlocal enabledelayedexpansion

:: =====================================================
:: ZeroTrace v1.0
:: A sovereign Windows cleanup utility — leaves zero trace.
:: https://github.com/johnwesleyquintero/zerotrace
:: =====================================================

:: Check for administrative privileges
openfiles >nul 2>&1
if errorlevel 1 (
    echo.
    echo [!] ZeroTrace requires Administrator privileges.
    echo     Please right-click and select "Run as administrator".
    echo.
    pause
    exit /b
)

echo ==================================================
echo ZeroTrace v1.0 - Leaving Zero Trace
echo https://github.com/johnwesleyquintero/zerotrace
echo ==================================================
echo Starting system cleanup...
echo.

:: Start Timer
for /f "tokens=1-4 delims=:., " %%i in ("%TIME%") do (
    set /a "start_seconds=(((%%i*60)+1%%j%%100)*60)+1%%k%%100"
)

:: Get initial disk space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A
echo [+] Initial free space: !INITIAL_SPACE_MB! MB

:: ==================================================
:: [1/16] Temp Files
:: ==================================================
echo.
echo [1/16] Cleaning temporary files...
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
echo [+] Temp files cleaned.
call :ProgressBar 1 16

:: ==================================================
:: [2/16] Browser Caches
:: ==================================================
echo.
echo [2/16] Clearing browser caches...

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

echo [+] Browser caches cleared.
call :ProgressBar 2 16

:: ==================================================
:: [3/16] Windows Update Cleanup
:: ==================================================
echo.
echo [3/16] Cleaning Windows Update files...
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

echo [+] Windows Update debris removed.
call :ProgressBar 3 16

:: ==================================================
:: [4/16] Windows.old & Upgrade Debris
:: ==================================================
echo.
echo [4/16] Removing Windows.old and upgrade debris...
if exist "C:\Windows.old" (
    takeown /F "C:\Windows.old" /R /D Y >nul 2>&1
    icacls "C:\Windows.old" /grant administrators:F /T >nul 2>&1
    rd /s /q "C:\Windows.old" >nul 2>&1
)
if exist "C:\$Windows.~BT" rd /s /q "C:\$Windows.~BT" >nul 2>&1
if exist "C:\$Windows.~WS" rd /s /q "C:\$Windows.~WS" >nul 2>&1
echo [+] Upgrade debris removed.
call :ProgressBar 4 16

:: ==================================================
:: [5/16] Event Logs
:: ==================================================
echo.
echo [5/16] Clearing Event Logs...
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1
echo [+] Event logs cleared.
call :ProgressBar 5 16

:: ==================================================
:: [6/16] Windows Logs
:: ==================================================
echo.
echo [6/16] Cleaning Windows logs...
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)
echo [+] Windows logs cleaned.
call :ProgressBar 6 16

:: ==================================================
:: [7/16] Prefetch
:: ==================================================
echo.
echo [7/16] Clearing Prefetch...
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)
echo [+] Prefetch files removed.
call :ProgressBar 7 16

:: ==================================================
:: [8/16] Recycle Bin
:: ==================================================
echo.
echo [8/16] Emptying Recycle Bin...
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo [+] Recycle Bin emptied.
call :ProgressBar 8 16

:: ==================================================
:: [9/16] Store Cache + Network
:: ==================================================
echo.
echo [9/16] Resetting Store cache and network...
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
echo [+] Store and network reset complete.
call :ProgressBar 9 16

:: ==================================================
:: [10/16] Privacy: Recent Files & Jump Lists
:: ==================================================
echo.
echo [10/16] Clearing Recent Files and Jump Lists...
del /f /q /s "%AppData%\Microsoft\Windows\Recent\*" >nul 2>&1
del /f /q /s "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q /s "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
echo [+] Privacy trails removed.
call :ProgressBar 10 16

:: ==================================================
:: [11/16] System Maintenance: Cache & Error Reports
:: ==================================================
echo.
echo [11/16] Cleaning system caches and error reports...
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
echo [+] System maintenance complete.
call :ProgressBar 11 16

:: ==================================================
:: [12/16] VS Code & Discord Caches
:: ==================================================
echo.
echo [12/16] Cleaning VS Code and Discord caches...
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

echo [+] Dev/Social caches cleared.
call :ProgressBar 12 16

:: ==================================================
:: [13/16] Spotify Media Cache
:: ==================================================
echo.
echo [13/16] Clearing Spotify media cache...
taskkill /f /im Spotify.exe >nul 2>&1
if exist "%LocalAppData%\Spotify\Storage" rd /s /q "%LocalAppData%\Spotify\Storage" >nul 2>&1
if exist "%LocalAppData%\Spotify\Users" (
    for /d %%u in ("%LocalAppData%\Spotify\Users\*") do (
        if exist "%%u\Cache" rd /s /q "%%u\Cache" >nul 2>&1
    )
)
echo [+] Spotify cache cleared.
call :ProgressBar 13 16

:: ==================================================
:: [14/16] GPU Shader Caches (NVIDIA/AMD)
:: ==================================================
echo.
echo [14/16] Cleaning GPU shader caches...
:: NVIDIA
if exist "%LocalAppData%\NVIDIA\DXCache" rd /s /q "%LocalAppData%\NVIDIA\DXCache" >nul 2>&1
if exist "%LocalAppData%\NVIDIA\GLCache" rd /s /q "%LocalAppData%\NVIDIA\GLCache" >nul 2>&1
if exist "%AppData%\NVIDIA\ComputeCache" rd /s /q "%AppData%\NVIDIA\ComputeCache" >nul 2>&1
:: AMD
if exist "%LocalAppData%\AMD\DxCache" rd /s /q "%LocalAppData%\AMD\DxCache" >nul 2>&1
if exist "%LocalAppData%\AMD\OglCache" rd /s /q "%LocalAppData%\AMD\OglCache" >nul 2>&1
echo [+] GPU shader caches cleared.
call :ProgressBar 14 16

:: ==================================================
:: [15/16] Advanced Space Reclamation
:: ==================================================
echo.
echo [15/16] Reclaiming advanced disk space...
:: DirectX Shader Cache
if exist "%LocalAppData%\D3DSCache" rd /s /q "%LocalAppData%\D3DSCache" >nul 2>&1
if exist "%LocalAppData%\Microsoft\DirectX\ShaderCache" rd /s /q "%LocalAppData%\Microsoft\DirectX\ShaderCache" >nul 2>&1
:: Windows Crash Dumps
if exist "%SystemRoot%\Minidump" del /f /q /s "%SystemRoot%\Minidump\*" >nul 2>&1
if exist "%LocalAppData%\CrashDumps" del /f /q /s "%LocalAppData%\CrashDumps\*" >nul 2>&1
:: BranchCache
netsh branchcache flush >nul 2>&1
:: Cryptography SVC Task
certutil -setreg chain\ChainCacheResyncFiletime @now >nul 2>&1
echo [+] Advanced space reclaimed.
call :ProgressBar 15 16

:: ==================================================
:: [16/16] Deep Trace Removal (Registry & Shell)
:: ==================================================
echo.
echo [16/16] Performing deep trace removal...
:: ShellBags (Explorer folder view history)
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
:: UserAssist (App execution history)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f >nul 2>&1
:: Restart Explorer to apply changes
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul 2>&1
echo [+] Deep traces removed (Explorer restarted).
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
echo ==================================================
echo ZERO TRACE COMPLETE.
echo ==================================================
echo Initial free space: %INITIAL_SPACE_MB% MB
echo Final free space:   %FINAL_SPACE_MB% MB
echo Space freed:        %SPACE_FREED% MB
echo Time elapsed:       %duration% seconds
echo --------------------------------------------------
echo Available Storage:  %FINAL_SPACE_GB% GB of %TOTAL_SPACE_GB% GB
echo ==================================================
echo.
echo [OK] System cleaned. Zero trace left behind.
echo.
echo Sovereign Systems ^| Built by Wesley ^& WesAI
echo.
echo Press any key to exit...
timeout /t -1 >nul

exit /b

:: ==================================================
:: Function: ProgressBar
:: ==================================================
:ProgressBar
set CURRENT_STEP=%1
set TOTAL_STEPS=%2
set /a PERCENT=(CURRENT_STEP*100)/TOTAL_STEPS
set BAR=[
set /a FILLED=(PERCENT*30)/100
for /L %%i in (1,1,!FILLED!) do set BAR=!BAR!#
for /L %%i in (!FILLED!,1,30) do set BAR=!BAR!-
set BAR=!BAR!]
echo Progress !CURRENT_STEP!/!TOTAL_STEPS! !BAR! !PERCENT!%% complete
exit /b
