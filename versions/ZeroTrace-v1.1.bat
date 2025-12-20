@echo off
setlocal enabledelayedexpansion

:: =====================================================
:: ZeroTrace v1.3 Ninja Mode
:: Fully automated Windows cleanup — leaves ZERO trace
:: https://github.com/johnwesleyquintero/zerotrace
:: =====================================================

:: Check for admin
openfiles >nul 2>&1
if errorlevel 1 (
    echo [!] Requires Admin privileges. Run as administrator.
    pause
    exit /b
)

echo ==================================================
echo ZeroTrace v1.3 Ninja Mode
echo Cleaning system automatically...
echo ==================================================

:: Initial free space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A

:: ------------------------------
:: Cleanup Functions
:: ------------------------------
set TOTAL_DELETED=0

:: Temp files
for /f "usebackq delims=" %%F in (`dir "%TEMP%\*" /a-d /b 2^>nul`) do del /f /q "%TEMP%\%%F" >nul 2>&1
for /d %%p in ("%TEMP%\*.*") do rmdir "%%p" /s /q >nul 2>&1

:: Browser caches
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*") do (
        if exist "%%p\cache2\entries" rd /s /q "%%p\cache2\entries" >nul 2>&1
    )
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1

:: Windows Update
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

:: Event logs
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1

:: Windows logs
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)

:: Prefetch
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)

:: Recycle Bin
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: Store & Network
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1

:: Lightweight Disk Scan Auto-Clean ≥1MB
set SCAN_ROOT=C:\
set THRESHOLD_MB=1
set TOTAL_DELETED=0

for /r "%SCAN_ROOT%" %%F in (*) do (
    set FILE=%%F
    for %%A in ("%%F") do (
        set SIZE=%%~zA
        set /a SIZE_MB=SIZE/1048576
        if !SIZE_MB! GEQ %THRESHOLD_MB% (
            del /f /q "%%F" >nul 2>&1
            set /a TOTAL_DELETED+=1
        )
    )
)

:: Final free space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
set /a SPACE_FREED=FINAL_SPACE_MB - INITIAL_SPACE_MB

:: Summary
echo.
echo ==================================================
echo ZERO TRACE v1.3 COMPLETE
echo ==================================================
echo Initial free space: %INITIAL_SPACE_MB% MB
echo Final free space:   %FINAL_SPACE_MB% MB
echo Space freed:        %SPACE_FREED% MB
echo Files deleted:      %TOTAL_DELETED%
echo ==================================================
pause
exit /b
