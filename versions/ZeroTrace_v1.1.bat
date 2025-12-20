@echo off
setlocal enabledelayedexpansion

:: =====================================================
:: ZeroTrace v1.1
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
echo ZeroTrace v1.1 - Leaving Zero Trace
echo https://github.com/johnwesleyquintero/zerotrace
echo ==================================================
echo Starting system cleanup...
echo.

:: Get initial disk space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A
echo [+] Initial free space: !INITIAL_SPACE_MB! MB

:: ==================================================
:: [1/11] Temp Files
:: ==================================================
echo.
echo [1/11] Cleaning temporary files...
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
call :ProgressBar 1 11

:: ==================================================
:: [2/11] Browser Caches
:: ==================================================
echo.
echo [2/11] Clearing browser caches...

:: Close browsers if running (optional but recommended for thorough cleaning)
echo [!] Closing browsers to ensure deep clean...
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

echo [+] Browser caches cleared.
call :ProgressBar 2 11

:: ==================================================
:: [3/11] Windows Update Cleanup
:: ==================================================
echo.
echo [3/11] Cleaning Windows Update files...
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
call :ProgressBar 3 11

:: ==================================================
:: [4/11] Event Logs
:: ==================================================
echo.
echo [4/11] Clearing Event Logs...
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1
echo [+] Event logs cleared.
call :ProgressBar 4 11

:: ==================================================
:: [5/11] Windows Logs
:: ==================================================
echo.
echo [5/11] Cleaning Windows logs...
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)
echo [+] Windows logs cleaned.
call :ProgressBar 5 11

:: ==================================================
:: [6/11] Prefetch
:: ==================================================
echo.
echo [6/11] Clearing Prefetch...
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)
echo [+] Prefetch files removed.
call :ProgressBar 6 11

:: ==================================================
:: [7/11] Recycle Bin
:: ==================================================
echo.
echo [7/11] Emptying Recycle Bin...
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo [+] Recycle Bin emptied.
call :ProgressBar 7 11

:: ==================================================
:: [8/11] Store Cache + Network
:: ==================================================
echo.
echo [8/11] Resetting Store cache and network...
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
echo [+] Store and network reset complete.
call :ProgressBar 8 11

:: ==================================================
:: [9/11] Privacy: Recent Files & Jump Lists
:: ==================================================
echo.
echo [9/11] Clearing Recent Files and Jump Lists...
del /f /q /s "%AppData%\Microsoft\Windows\Recent\*" >nul 2>&1
del /f /q /s "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q /s "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
echo [+] Privacy trails removed.
call :ProgressBar 9 11

:: ==================================================
:: [10/11] System Maintenance: Cache & Error Reports
:: ==================================================
echo.
echo [10/11] Cleaning system caches and error reports...
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
call :ProgressBar 10 11

:: ==================================================
:: [11/11] Deep Trace Removal (Registry & Shell)
:: ==================================================
echo.
echo [11/11] Performing deep trace removal...
:: ShellBags (Explorer folder view history)
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
:: UserAssist (App execution history)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f >nul 2>&1
:: Restart Explorer to apply changes
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul 2>&1
echo [+] Deep traces removed (Explorer restarted).
call :ProgressBar 11 11

:: ==================================================
:: Summary
:: ==================================================
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
for /f "usebackq" %%A in (`powershell -Command "$i=%INITIAL_SPACE_MB%; $f=%FINAL_SPACE_MB%; [math]::Round($f - $i)"`) do set SPACE_FREED=%%A

echo.
echo ==================================================
echo ZERO TRACE COMPLETE.
echo ==================================================
echo Initial free space: %INITIAL_SPACE_MB% MB
echo Final free space:   %FINAL_SPACE_MB% MB
echo Space freed:        %SPACE_FREED% MB
echo ==================================================
echo.
echo [OK] System cleaned. Zero trace left behind.
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
