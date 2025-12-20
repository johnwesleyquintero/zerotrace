@echo off
setlocal enabledelayedexpansion

:: =====================================================
:: ZeroTrace v1.5 - Fully Automated + Parallel Cleanup
:: =====================================================
:: Purpose: Fully automated Windows cleanup (temp, caches, logs, Prefetch, Recycle Bin, Store cache, disk scan)
::          with parallel execution for faster performance.
:: =====================================================

:: ---------------------------
:: Check admin
:: ---------------------------
openfiles >nul 2>&1
if errorlevel 1 (
    echo [!] Please run this script as Administrator.
    pause
    exit /b
)

:: ---------------------------
:: Initialize counters
:: ---------------------------
set TOTAL_DELETED=0
set TOTAL_STEPS=9
set CURRENT_STEP=0

:: ---------------------------
:: Get initial free space
:: ---------------------------
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A

:: ---------------------------
:: Run parallel tasks
:: ---------------------------
call :AnimatedStep "Cleaning temporary files..." start /b cmd /c "%~f0 :TempCleanup"
call :AnimatedStep "Clearing browser caches..." start /b cmd /c "%~f0 :BrowserCacheCleanup"
call :AnimatedStep "Cleaning Windows Update debris..." start /b cmd /c "%~f0 :WindowsUpdateCleanup"
call :AnimatedStep "Clearing Event Logs..." start /b cmd /c "%~f0 :EventLogsCleanup"
call :AnimatedStep "Cleaning Windows logs..." start /b cmd /c "%~f0 :WindowsLogsCleanup"
call :AnimatedStep "Clearing Prefetch files..." start /b cmd /c "%~f0 :PrefetchCleanup"
call :AnimatedStep "Emptying Recycle Bin..." start /b cmd /c "%~f0 :RecycleBinCleanup"
call :AnimatedStep "Resetting Store cache + network..." start /b cmd /c "%~f0 :StoreNetworkReset"
call :AnimatedStep "Running Disk Scan + Auto-Clean..." start /b cmd /c "%~f0 :DiskScan"

:: ---------------------------
:: Wait for all background tasks
:: ---------------------------
echo Waiting for cleanup tasks to finish...
timeout /t 5 >nul

:: ---------------------------
:: Summary
:: ---------------------------
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
for /f "usebackq" %%A in (`powershell -Command "$i=%INITIAL_SPACE_MB%; $f=%FINAL_SPACE_MB%; [math]::Round($f - $i)"`) do set SPACE_FREED=%%A

:: Final progress bar
set CURRENT_STEP=%TOTAL_STEPS%
call :ProgressBar %CURRENT_STEP% %TOTAL_STEPS%

echo.
echo ==================================================
echo ZERO TRACE v1.5 COMPLETE
echo ==================================================
echo Initial free space: %INITIAL_SPACE_MB% MB
echo Final free space:   %FINAL_SPACE_MB% MB
echo Space freed:        %SPACE_FREED% MB
echo Total files deleted: %TOTAL_DELETED%
echo ==================================================
pause
exit /b

:: ==================================================
:: Function: AnimatedStep
:: ==================================================
:AnimatedStep
set MSG=%~1
set CMD=%~2
set /a CURRENT_STEP+=1
<nul set /p= %MSG%
for /L %%i in (1,1,3) do (
    <nul set /p= .
    ping -n 2 localhost >nul
)
call %CMD%
echo Done.
call :ProgressBar %CURRENT_STEP% %TOTAL_STEPS%
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

:: ==================================================
:: Cleanup Modules (same as v1.4)
:: ==================================================
:TempCleanup
for /f "usebackq delims=" %%F in (`dir "%TEMP%\*" /a-d /b 2^>nul`) do del /f /q "%TEMP%\%%F" >nul 2>&1 & set /a TOTAL_DELETED+=1
for /d %%p in ("%TEMP%\*.*") do rmdir "%%p" /s /q >nul 2>&1 & set /a TOTAL_DELETED+=1
exit /b

:BrowserCacheCleanup
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1 & set /a TOTAL_DELETED+=1
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*") do if exist "%%p\cache2\entries" rd /s /q "%%p\cache2\entries" >nul 2>&1 & set /a TOTAL_DELETED+=1
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1 & set /a TOTAL_DELETED+=1
exit /b

:WindowsUpdateCleanup
dism /online /Cleanup-Image /StartComponentCleanup /NoRestart >nul 2>&1
dism /online /Cleanup-Image /SPSuperseded /NoRestart >nul 2>&1
net stop wuauserv >nul 2>&1
net stop cryptSvc >nul 2>&1
net stop bits >nul 2>&1
net stop msiserver >nul 2>&1
if exist "C:\Windows\SoftwareDistribution\Download" rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1 & set /a TOTAL_DELETED+=1
net start wuauserv >nul 2>&1
net start cryptSvc >nul 2>&1
net start bits >nul 2>&1
net start msiserver >nul 2>&1
exit /b

:EventLogsCleanup
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1 & set /a TOTAL_DELETED+=1
exit /b

:WindowsLogsCleanup
if exist "C:\Windows\Logs" for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1 & set /a TOTAL_DELETED+=1
exit /b

:PrefetchCleanup
if exist "C:\Windows\Prefetch" for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1 & set /a TOTAL_DELETED+=1
exit /b

:RecycleBinCleanup
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1 & set /a TOTAL_DELETED+=1
exit /b

:StoreNetworkReset
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
exit /b

:DiskScan
set "SCAN_ROOT=C:\"
set "THRESHOLD_MB=1"
for /r "%SCAN_ROOT%" %%F in (*) do (
    for /f "usebackq" %%A in (`powershell -Command "(Get-Item '%%F').Length / 1MB"`) do (
        set FILE_SIZE_MB=%%A
        set FILE_SIZE_MB=!FILE_SIZE_MB:~0,10!
        if !FILE_SIZE_MB! GEQ %THRESHOLD_MB% del /f /q "%%F" >nul 2>&1 & set /a TOTAL_DELETED+=1
    )
)
exit /b
