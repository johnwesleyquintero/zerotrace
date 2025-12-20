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

:: Runtime options
set RUN_DISKSCAN=0
set FULL_RUN=1
for %%A in (%*) do (
    if /i "%%A"=="/diskscan" set RUN_DISKSCAN=1 & set FULL_RUN=0
    if /i "%%A"=="/auto" set AUTO_MODE=1
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
:: [1/8] Temp Files
:: ==================================================
if %FULL_RUN%==1 call :TempCleanup

:: ==================================================
:: [2/8] Browser Caches
:: ==================================================
if %FULL_RUN%==1 call :BrowserCacheCleanup

:: ==================================================
:: [3/8] Windows Update Cleanup
:: ==================================================
if %FULL_RUN%==1 call :WindowsUpdateCleanup

:: ==================================================
:: [4/8] Event Logs
:: ==================================================
if %FULL_RUN%==1 call :EventLogsCleanup

:: ==================================================
:: [5/8] Windows Logs
:: ==================================================
if %FULL_RUN%==1 call :WindowsLogsCleanup

:: ==================================================
:: [6/8] Prefetch
:: ==================================================
if %FULL_RUN%==1 call :PrefetchCleanup

:: ==================================================
:: [7/8] Recycle Bin
:: ==================================================
if %FULL_RUN%==1 call :RecycleBinCleanup

:: ==================================================
:: [8/8] Store Cache + Network
:: ==================================================
if %FULL_RUN%==1 call :StoreNetworkReset

:: ==================================================
:: [9/9] Lightweight Disk Audit (new for 1.1)
:: ==================================================
if %RUN_DISKSCAN%==1 (
    call :DiskScan
) else if %FULL_RUN%==1 (
    call :DiskScan
)

:: ==================================================
:: Summary
:: ==================================================
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
for /f "usebackq" %%A in (`powershell -Command "$i=%INITIAL_SPACE_MB%; $f=%FINAL_SPACE_MB%; [math]::Round($f - $i)"`) do set SPACE_FREED=%%A

echo.
echo ==================================================
echo ZERO TRACE v1.1 COMPLETE
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
:: MODULES
:: ==================================================
:TempCleanup
echo.
echo [1/8] Cleaning temporary files...
for /f "usebackq delims=" %%F in (`dir "%TEMP%\*" /a-d /b 2^>nul`) do del /f /q "%TEMP%\%%F" >nul 2>&1
for /d %%p in ("%TEMP%\*.*") do rmdir "%%p" /s /q >nul 2>&1
echo [+] Temp files cleaned.
call :ProgressBar 1 8
exit /b

:BrowserCacheCleanup
echo.
echo [2/8] Clearing browser caches...
:: Chrome
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
:: Firefox
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*") do (
        if exist "%%p\cache2\entries" rd /s /q "%%p\cache2\entries" >nul 2>&1
    )
)
:: Edge
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
echo [+] Browser caches cleared.
call :ProgressBar 2 8
exit /b

:WindowsUpdateCleanup
echo.
echo [3/8] Cleaning Windows Update files...
dism /online /Cleanup-Image /StartComponentCleanup /NoRestart >nul 2>&1
dism /online /Cleanup-Image /SPSuperseded /NoRestart >nul 2>&1
net stop wuauserv >nul 2>&1
net stop cryptSvc >nul 2>&1
net stop bits >nul 2>&1
net stop msiserver >nul 2>&1
if exist "C:\Windows\SoftwareDistribution\Download" rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
net start wuauserv >nul 2>&1
net start cryptSvc >nul 2>&1
net start bits >nul 2>&1
net start msiserver >nul 2>&1
echo [+] Windows Update debris removed.
call :ProgressBar 3 8
exit /b

:EventLogsCleanup
echo.
echo [4/8] Clearing Event Logs...
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1
echo [+] Event logs cleared.
call :ProgressBar 4 8
exit /b

:WindowsLogsCleanup
echo.
echo [5/8] Cleaning Windows logs...
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)
echo [+] Windows logs cleaned.
call :ProgressBar 5 8
exit /b

:PrefetchCleanup
echo.
echo [6/8] Clearing Prefetch...
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)
echo [+] Prefetch files removed.
call :ProgressBar 6 8
exit /b

:RecycleBinCleanup
echo.
echo [7/8] Emptying Recycle Bin...
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo [+] Recycle Bin emptied.
call :ProgressBar 7 8
exit /b

:StoreNetworkReset
echo.
echo [8/8] Resetting Store cache and network...
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
echo [+] Store and network reset complete.
call :ProgressBar 8 8
exit /b

:DiskScan
echo.
echo [9/9] Running Disk Scan...

set "SCAN_ROOT=C:\"
set "THRESHOLD_MB=1"
set TOTAL_IGNORED=0
set TOTAL_LARGE=0

for /r "%SCAN_ROOT%" %%F in (*) do (
    for /f "usebackq" %%A in (`powershell -Command "(Get-Item '%%F').Length / 1MB"`) do (
        set FILE_SIZE_MB=%%A
        set FILE_SIZE_MB=!FILE_SIZE_MB:~0,10!
        if !FILE_SIZE_MB! GEQ %THRESHOLD_MB% (
            echo Large file: %%F - !FILE_SIZE_MB! MB
            set /a TOTAL_LARGE+=1
        ) else (
            set /a TOTAL_IGNORED+=1
        )
    )
)

echo.
echo Scan complete. !TOTAL_LARGE! large files found, !TOTAL_IGNORED! files ignored (smaller than %THRESHOLD_MB% MB).
call :ProgressBar 9 9
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
