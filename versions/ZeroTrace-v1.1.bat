@echo off
setlocal enabledelayedexpansion

:: =====================================================
:: ZeroTrace v1.1 - Fully Silent Version
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

:: Initial disk space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A

:: ==================================================
:: Cleanup Modules
:: ==================================================
if %FULL_RUN%==1 call :TempCleanup
if %FULL_RUN%==1 call :BrowserCacheCleanup
if %FULL_RUN%==1 call :WindowsUpdateCleanup
if %FULL_RUN%==1 call :EventLogsCleanup
if %FULL_RUN%==1 call :WindowsLogsCleanup
if %FULL_RUN%==1 call :PrefetchCleanup
if %FULL_RUN%==1 call :RecycleBinCleanup
if %FULL_RUN%==1 call :StoreNetworkReset

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
echo ZERO TRACE v1.1 COMPLETE
echo Initial free space: %INITIAL_SPACE_MB% MB
echo Final free space:   %FINAL_SPACE_MB% MB
echo Space freed:        %SPACE_FREED% MB
echo.
echo Press any key to exit...
timeout /t -1 >nul
exit /b

:: ==================================================
:: MODULES
:: ==================================================

:TempCleanup
for /f "usebackq delims=" %%F in (`dir "%TEMP%\*" /a-d /b 2^>nul`) do del /f /q "%TEMP%\%%F" >nul 2>&1
for /d %%p in ("%TEMP%\*.*") do rmdir "%%p" /s /q >nul 2>&1
call :ProgressBar 1 8
exit /b

:BrowserCacheCleanup
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*") do (
        if exist "%%p\cache2\entries" rd /s /q "%%p\cache2\entries" >nul 2>&1
    )
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
call :ProgressBar 2 8
exit /b

:WindowsUpdateCleanup
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
call :ProgressBar 3 8
exit /b

:EventLogsCleanup
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1
call :ProgressBar 4 8
exit /b

:WindowsLogsCleanup
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)
call :ProgressBar 5 8
exit /b

:PrefetchCleanup
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)
call :ProgressBar 6 8
exit /b

:RecycleBinCleanup
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
call :ProgressBar 7 8
exit /b

:StoreNetworkReset
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
call :ProgressBar 8 8
exit /b

:DiskScan
set "SCAN_ROOT=C:\"
set "THRESHOLD_MB=1"
set TOTAL_DELETED=0
set TOTAL_IGNORED=0
for /r "%SCAN_ROOT%" %%F in (*) do (
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
call :ProgressBar 9 9
exit /b

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
