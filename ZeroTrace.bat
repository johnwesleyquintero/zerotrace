::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFBFbRAqVAHG/FLoI+un46taGsV4YQPEDYorJ1fmaMuEQ7wvtdplN
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdFe5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdFe5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSTk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+IeA==
::cxY6rQJ7JhzQF1fEqQImeVUELA==
::ZQ05rAF9IBncCkqN+0xwdVtCHUrSXA==
::ZQ05rAF9IAHYFVzEqQIKLQlbeBaDP27a
::eg0/rx1wNQPfEVWB+kM9LVsJDD6HLmSOFLQf7ab57v7n
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQIRaBddSwyWK26zAb0IpKjv/euJsV0cRucxbM/s07qKL/cAqkbocJcjw2oajd8FABJMZ1K/Zg4g6WJHt3KAJIeGth3uClyb50g1W2dxj2reiGVb
::dhA7uBVwLU+EWGqH9U41GxZVXhDi
::YQ03rBFzNR3SWATEx0ExJB5nQQWQKCv3RoIZ+8nSjw==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFBFbRAqVAHG/FLoI+un46taGsV4YQPEDQorJ1YCcIeMWpED8cPY=
::YB416Ek+ZW8=
::
::
::978f952a14a936cc963da21a135fa983
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

:: Get initial disk space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A
echo [+] Initial free space: !INITIAL_SPACE_MB! MB

:: ==================================================
:: [1/8] Temp Files
:: ==================================================
echo.
echo [1/8] Cleaning temporary files...
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
call :ProgressBar 1 8

:: ==================================================
:: [2/8] Browser Caches
:: ==================================================
echo.
echo [2/8] Clearing browser caches...

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
call :ProgressBar 2 8

:: ==================================================
:: [3/8] Windows Update Cleanup
:: ==================================================
echo.
echo [3/8] Cleaning Windows Update files...
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
call :ProgressBar 3 8

:: ==================================================
:: [4/8] Event Logs
:: ==================================================
echo.
echo [4/8] Clearing Event Logs...
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1
echo [+] Event logs cleared.
call :ProgressBar 4 8

:: ==================================================
:: [5/8] Windows Logs
:: ==================================================
echo.
echo [5/8] Cleaning Windows logs...
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)
echo [+] Windows logs cleaned.
call :ProgressBar 5 8

:: ==================================================
:: [6/8] Prefetch
:: ==================================================
echo.
echo [6/8] Clearing Prefetch...
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)
echo [+] Prefetch files removed.
call :ProgressBar 6 8

:: ==================================================
:: [7/8] Recycle Bin
:: ==================================================
echo.
echo [7/8] Emptying Recycle Bin...
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo [+] Recycle Bin emptied.
call :ProgressBar 7 8

:: ==================================================
:: [8/8] Store Cache + Network
:: ==================================================
echo.
echo [8/8] Resetting Store cache and network...
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
echo [+] Store and network reset complete.
call :ProgressBar 8 8

:: ==================================================
:: Summary
:: ==================================================
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
for /f "usebackq" %%A in (`powershell -Command "[math]::Round(%FINAL_SPACE_MB% - %INITIAL_SPACE_MB%)") do set SPACE_FREED=%%A

echo.
echo ==================================================
echo ZeroTrace Complete!
echo Initial free space: !INITIAL_SPACE_MB! MB
echo Final free space:   !FINAL_SPACE_MB! MB
echo Space freed:        !SPACE_FREED! MB
echo ==================================================

pause
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
