@echo off
title ZeroGuard v1.2.0 – Privacy & Tracker Audit
color 0a
setlocal enabledelayedexpansion

:: ======== Globals ========
set flaggedAutoStart=0
set totalAutoStart=0
set totalTelemetry=0

set chromeCleaned=0
set edgeCleaned=0
set firefoxCleaned=0

:menu
cls
echo ===========================
echo ZeroGuard v1.2.0 – Privacy Audit
echo ===========================
echo.
echo 1. Scan System
echo 2. Scan Browsers
echo 3. Clean All Flagged Items
echo 4. Exit
echo.
set /p choice="Choose an option [1-4]: "

if "%choice%"=="1" goto scanSystem
if "%choice%"=="2" goto scanBrowsers
if "%choice%"=="3" goto cleanAll
if "%choice%"=="4" goto exit
echo Invalid choice, try again...
pause
goto menu

:scanSystem
cls
echo ===========================
echo [SYSTEM SCAN] Background apps & telemetry
echo ===========================
echo.

:: --- Auto-Start Programs ---
echo --- Auto-Start Programs (Registry) ---
for /f "skip=2 tokens=1,*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 2^>nul') do (
    set "value=%%B"
    if defined value (
        set /a totalAutoStart+=1
        echo !value! | findstr /i "Microsoft Edge Chrome Teams Viber" >nul
        if errorlevel 1 (
            set /a flaggedAutoStart+=1
            echo [FLAGGED] !value!
        ) else (
            echo !value!
        )
    )
)

for /f "skip=2 tokens=1,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2^>nul') do (
    set "value=%%B"
    if defined value (
        set /a totalAutoStart+=1
        echo !value! | findstr /i "Microsoft" >nul
        if errorlevel 1 (
            set /a flaggedAutoStart+=1
            echo [FLAGGED] !value!
        ) else (
            echo !value!
        )
    )
)

echo.

:: --- Telemetry / Diagnostics Logs ---
echo --- Telemetry / Diagnostics Logs ---
for /f "delims=" %%L in ('dir /b /s "%windir%\System32\winevt\Logs\*" ^| findstr /i "Diag"') do (
    set /a totalTelemetry+=1
    echo %%L
)

echo.
echo [SYSTEM SCAN COMPLETE]
echo ---------------------------
echo Total Auto-Start Programs: !totalAutoStart!
echo Flagged Auto-Start Programs: !flaggedAutoStart!
echo Total Telemetry Logs Found: !totalTelemetry!
pause
goto menu

:scanBrowsers
cls
echo ============================
echo [BROWSER SCAN] Caches
echo ============================
set chromeSize=0
set edgeSize=0
set firefoxSize=0

:: Chrome
set "chromeCache=%LOCALAPPDATA%\Google\Chrome\User Data"
if exist "!chromeCache!" (
    for /d %%p in ("!chromeCache!\*") do (
        if exist "%%p\Cache" (
            for /f "usebackq" %%s in ('dir /s /a /b "%%p\Cache" 2^>nul ^| find /c /v ""') do (
                set /a chromeSize+=%%s
            )
        )
    )
    if !chromeSize! EQU 0 (echo Chrome Cache: None) else (echo Chrome Cache: !chromeSize! files found)
) else (echo Chrome Cache: Not Installed)

:: Edge
set "edgeCache=%LOCALAPPDATA%\Microsoft\Edge\User Data"
if exist "!edgeCache!" (
    for /d %%p in ("!edgeCache!\*") do (
        if exist "%%p\Cache" (
            for /f "usebackq" %%s in ('dir /s /a /b "%%p\Cache" 2^>nul ^| find /c /v ""') do (
                set /a edgeSize+=%%s
            )
        )
    )
    if !edgeSize! EQU 0 (echo Edge Cache: None) else (echo Edge Cache: !edgeSize! files found)
) else (echo Edge Cache: Not Installed)

:: Firefox
set "firefoxCache=%APPDATA%\Mozilla\Firefox\Profiles"
if exist "!firefoxCache!" (
    for /d %%p in ("!firefoxCache!\*") do (
        if exist "%%p\cache2" (
            for /f "usebackq" %%s in ('dir /s /a /b "%%p\cache2" 2^>nul ^| find /c /v ""') do (
                set /a firefoxSize+=%%s
            )
        )
    )
    if !firefoxSize! EQU 0 (echo Firefox Cache: None) else (echo Firefox Cache: !firefoxSize! files found)
) else (echo Firefox Cache: Not Installed)

echo.
echo Browser scan complete
echo ============================
pause
goto menu

:cleanAll
cls
echo ===========================
echo [CLEANUP] Removing browser caches
echo ===========================

:: Chrome
set "chromeCache=%LOCALAPPDATA%\Google\Chrome\User Data"
if exist "!chromeCache!" (
    for /d %%p in ("!chromeCache!\*") do (
        if exist "%%p\Cache" (
            rmdir /s /q "%%p\Cache" >nul 2>&1
            set /a chromeCleaned+=1
        )
    )
)

:: Edge
set "edgeCache=%LOCALAPPDATA%\Microsoft\Edge\User Data"
if exist "!edgeCache!" (
    for /d %%p in ("!edgeCache!\*") do (
        if exist "%%p\Cache" (
            rmdir /s /q "%%p\Cache" >nul 2>&1
            set /a edgeCleaned+=1
        )
    )
)

:: Firefox
set "firefoxCache=%APPDATA%\Mozilla\Firefox\Profiles"
if exist "!firefoxCache!" (
    for /d %%p in ("!firefoxCache!\*") do (
        if exist "%%p\cache2" (
            rmdir /s /q "%%p\cache2" >nul 2>&1
            set /a firefoxCleaned+=1
        )
    )
)

echo.
echo Cleanup complete!
echo ---------------------------
echo Chrome profiles cleaned: !chromeCleaned!
echo Edge profiles cleaned: !edgeCleaned!
echo Firefox profiles cleaned: !firefoxCleaned!
echo ===========================
pause
goto menu

:exit
cls
echo ===========================
echo ZeroGuard v1.2.0 – Session Complete
echo ===========================
echo Total Auto-Start Programs: !totalAutoStart!
echo Flagged Auto-Start Programs: !flaggedAutoStart!
echo Total Telemetry Logs Found: !totalTelemetry!
echo Chrome profiles cleaned: !chromeCleaned!
echo Edge profiles cleaned: !edgeCleaned!
echo Firefox profiles cleaned: !firefoxCleaned!
echo ===========================
pause
exit
