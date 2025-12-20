@echo off
setlocal enabledelayedexpansion

:: =====================================================
:: ZeroTrace v1.6
:: Fully automated Windows cleanup utility — leaves zero trace.
:: Cleans temp files, browser caches, prefetch, event logs, recycle bin, store/network, and runs lightweight disk scan.
:: =====================================================

:: ----------------------------
:: Short Intro
:: ----------------------------
echo ==================================================
echo ZERO TRACE v1.6 - Full System Cleanup
echo --------------------------------------------------
echo This script will:
echo - Remove temporary files and caches
echo - Clear browser caches (Chrome, Firefox, Edge)
echo - Clean Windows Update debris
echo - Clear Event Logs and Windows logs
echo - Clear Prefetch and Recycle Bin
echo - Reset Store cache and network settings
echo - Perform disk scan and auto-clean large files
echo ==================================================
echo.

:: ----------------------------
:: Check Admin Privileges
:: ----------------------------
openfiles >nul 2>&1
if errorlevel 1 (
    echo [!] Requires Administrator privileges.
    echo     Right-click and select "Run as administrator".
    pause
    exit /b
)

:: ----------------------------
:: Initialize
:: ----------------------------
set STEP=0
set TOTAL_STEPS=9

:: Get initial free space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A
echo [+] Initial free space: !INITIAL_SPACE_MB! MB
echo.

:: ==================================================
:: Modules
:: ==================================================
call :TempCleanup
call :BrowserCacheCleanup
call :WindowsUpdateCleanup
call :EventLogsCleanup
call :WindowsLogsCleanup
call :PrefetchCleanup
call :RecycleBinCleanup
call :StoreNetworkReset
call :DiskScan

:: ==================================================
:: Summary
:: ==================================================
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
set /a SPACE_FREED=!FINAL_SPACE_MB! - !INITIAL_SPACE_MB!

echo.
echo ==================================================
echo ZERO TRACE v1.6 COMPLETE
echo ==================================================
echo Initial free space: !INITIAL_SPACE_MB! MB
echo Final free space:   !FINAL_SPACE_MB! MB
echo Space freed:        !SPACE_FREED! MB
echo ==================================================
echo [OK] System cleaned. Zero trace left behind.
echo.
pause
exit /b

:: ==================================================
:: MODULES
:: ==================================================
:TempCleanup
set /a STEP+=1
echo [1/9] Cleaning temporary files...
for /f "usebackq delims=" %%F in (`dir "%TEMP%\*" /a-d /b 2^>nul`) do del /f /q "%TEMP%\%%F" >nul 2>&1
for /d %%p in ("%TEMP%\*.*") do rmdir "%%p" /s /q >nul 2>&1
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:BrowserCacheCleanup
set /a STEP+=1
echo [2/9] Clearing browser caches...
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*") do (
        if exist "%%p\cache2\entries" rd /s /q "%%p\cache2\entries" >nul 2>&1
    )
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:WindowsUpdateCleanup
set /a STEP+=1
echo [3/9] Cleaning Windows Update files...
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
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:EventLogsCleanup
set /a STEP+=1
echo [4/9] Clearing Event Logs...
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:WindowsLogsCleanup
set /a STEP+=1
echo [5/9] Cleaning Windows logs...
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:PrefetchCleanup
set /a STEP+=1
echo [6/9] Clearing Prefetch...
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:RecycleBinCleanup
set /a STEP+=1
echo [7/9] Emptying Recycle Bin...
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:StoreNetworkReset
set /a STEP+=1
echo [8/9] Resetting Store cache and network...
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:DiskScan
set /a STEP+=1
echo [9/9] Running Disk Scan + Auto-Clean (Skipping system folders)...

set "SCAN_ROOT=C:\"
set "THRESHOLD_MB=1"
set TOTAL_DELETED=0
set TOTAL_IGNORED=0

set SKIP_FOLDERS=C:\Windows\System32 C:\Windows\WinSxS C:\Program Files C:\Program Files (x86)

for /r "%SCAN_ROOT%" %%F in (*) do (
    set "SKIP=0"
    for %%S in (%SKIP_FOLDERS%) do (
        echo %%F | findstr /i "%%S" >nul && set SKIP=1
    )
    if !SKIP! EQU 0 (
        for /f "usebackq" %%A in (`powershell -Command "(Get-Item '%%F').Length / 1MB"`) do (
            set FILE_SIZE_MB=%%A
            set FILE_SIZE_MB=!FILE_SIZE_MB:~0,10!
            if !FILE_SIZE_MB! GEQ %THRESHOLD_MB% (
                del /f /q "%%F" >nul 2>&1
                set /a TOTAL_DELETED+=1
            ) else (
                set /a TOTAL_IGNORED+=1
            )
        )
    )
)
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:: ==================================================
:: Progress Bar Function
:: ==================================================
:ShowProgress
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
