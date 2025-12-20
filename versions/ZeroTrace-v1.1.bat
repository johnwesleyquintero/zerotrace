@echo off
setlocal enabledelayedexpansion

:: =====================================================
:: ZeroTrace v1.1 - Corrected
:: A sovereign Windows cleanup utility — leaves zero trace.
:: https://github.com/johnwesleyquintero/zerotrace
:: =====================================================

:: --- Configuration ---
for /f "tokens=2 delims==" %%i in ('wmic OS Get LocalDateTime /value') do set DATETIME=%%i
set LOG_FILE=zero_trace_%DATETIME:~0,4%-%DATETIME:~4,2%-%DATETIME:~6,2%_%DATETIME:~8,2%-%DATETIME:~10,2%-%DATETIME:~12,2%.log
set TOTAL_CLEANUP_STEPS=9 :: Updated for new App Caches step

:: --- Function: Log to Console AND File ---
:LogAndEcho
echo %~1
echo %~1 >> "%LOG_FILE%"
exit /b

:: --- Function: ProgressBar (Now correctly calls LogAndEcho for visibility) ---
:ProgressBar
set CURRENT_STEP=%1
set TOTAL_STEPS=%2
set /a PERCENT=(CURRENT_STEP*100)/TOTAL_STEPS
set BAR=[
set /a FILLED=(PERCENT*30)/100
for /L %%i in (1,1,!FILLED!) do set BAR=!BAR!#
for /L %%i in (!FILLED!,1,30) do set BAR=!BAR!-
set BAR=!BAR!]
call :LogAndEcho Progress !CURRENT_STEP!/!TOTAL_STEPS! !BAR! !PERCENT!%% complete
exit /b

:: --- Initialization ---
openfiles >nul 2>&1
if errorlevel 1 (
    echo.
    echo [!] ZeroTrace requires Administrator privileges.
    echo     Please right-click and select "Run as administrator".
    echo.
    pause
    exit /b
)

call :LogAndEcho ==================================================
call :LogAndEcho ZeroTrace v1.1 - Leaving Zero Trace
call :LogAndEcho https://github.com/johnwesleyquintero/zerotrace
call :LogAndEcho ==================================================
call :LogAndEcho Starting system cleanup...
call :LogAndEcho.

:: Get initial disk space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A
call :LogAndEcho [+] Initial free space: !INITIAL_SPACE_MB! MB

:: ==================================================
:: [1/%TOTAL_CLEANUP_STEPS%] Temp Files
:: ==================================================
call :LogAndEcho.
call :LogAndEcho [1/%TOTAL_CLEANUP_STEPS%] Cleaning temporary files...
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
call :LogAndEcho [+] Temp files cleaned.
call :ProgressBar 1 %TOTAL_CLEANUP_STEPS%

:: ==================================================
:: [2/%TOTAL_CLEANUP_STEPS%] Browser Caches
:: ==================================================
call :LogAndEcho.
call :LogAndEcho [2/%TOTAL_CLEANUP_STEPS%] Clearing browser caches...
:: (Browser cleanup logic remains the same as detailed before...)
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" ( rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1 )
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" ( for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*") do ( if exist "%%p\cache2\entries" ( rd /s /q "%%p\cache2\entries" >nul 2>&1 ) ) )
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" ( rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1 )
if exist "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" ( rd /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" >nul 2>&1 )
if exist "%LOCALAPPDATA%\Programs\Opera\User Data\Default\Cache" ( rd /s /q "%LOCALAPPDATA%\Programs\Opera\User Data\Default\Cache" >nul 2>&1 )
if exist "%APPDATA%\Opera Software\Opera Stable\Cache" ( rd /s /q "%APPDATA%\Opera Software\Opera Stable\Cache" >nul 2>&1 )
if exist "%LOCALAPPDATA%\Vivaldi\User Data\Default\Cache" ( rd /s /q "%LOCALAPPDATA%\Vivaldi\User Data\Default\Cache" >nul 2>&1 )

call :LogAndEcho [+] Browser caches cleared.
call :ProgressBar 2 %TOTAL_CLEANUP_STEPS%

:: ==================================================
:: [3/%TOTAL_CLEANUP_STEPS%] Common Application Caches
:: ==================================================
call :LogAndEcho.
call :LogAndEcho [3/%TOTAL_CLEANUP_STEPS%] Clearing common application caches...
if exist "%APPDATA%\Discord\Cache" ( rd /s /q "%APPDATA%\Discord\Cache" >nul 2>&1 )
if exist "%APPDATA%\Discord\Code Cache" ( rd /s /q "%APPDATA%\Discord\Code Cache" >nul 2>&1 )
if exist "%APPDATA%\Spotify\Browser\Cache" ( rd /s /q "%APPDATA%\Spotify\Browser\Cache" >nul 2>&1 )
if exist "%LOCALAPPDATA%\Spotify\Data" ( rd /s /q "%LOCALAPPDATA%\Spotify\Data" >nul 2>&1 )

call :LogAndEcho [+] Common application caches cleared.
call :ProgressBar 3 %TOTAL_CLEANUP_STEPS%

:: ==================================================
:: [4/%TOTAL_CLEANUP_STEPS%] Windows Update Cleanup
:: ==================================================
call :LogAndEcho.
call :LogAndEcho [4/%TOTAL_CLEANUP_STEPS%] Cleaning Windows Update files...
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

call :LogAndEcho [+] Windows Update debris removed.
call :ProgressBar 4 %TOTAL_CLEANUP_STEPS%

:: ==================================================
:: [5/%TOTAL_CLEANUP_STEPS%] Event Logs
:: ==================================================
call :LogAndEcho.
call :LogAndEcho [5/%TOTAL_CLEANUP_STEPS%] Clearing Event Logs...
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1
call :LogAndEcho [+] Event logs cleared.
call :ProgressBar 5 %TOTAL_CLEANUP_STEPS%

:: ==================================================
:: [6/%TOTAL_CLEANUP_STEPS%] Windows Logs (Expanded)
:: ==================================================
call :LogAndEcho.
call :LogAndEcho [6/%TOTAL_CLEANUP_STEPS%] Cleaning Windows logs (expanded)...
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)
if exist "C:\Windows\System32\LogFiles" (
    for /d %%p in ("C:\Windows\System32\LogFiles\*.*") do (
        if exist "%%p" (
            rmdir "%%p" /s /q >nul 2>&1
        )
    )
)
if exist "C:\ProgramData\Microsoft\Windows\WER" (
    for /d %%p in ("C:\ProgramData\Microsoft\Windows\WER\*.*") do (
        if exist "%%p" (
            rmdir "%%p" /s /q >nul 2>&1
        )
    )
)
call :LogAndEcho [+] Windows logs cleaned.
call :ProgressBar 6 %TOTAL_CLEANUP_STEPS%

:: ==================================================
:: [7/%TOTAL_CLEANUP_STEPS%] Prefetch
:: ==================================================
call :LogAndEcho.
call :LogAndEcho [7/%TOTAL_CLEANUP_STEPS%] Clearing Prefetch...
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)
call :LogAndEcho [+] Prefetch files removed.
call :ProgressBar 7 %TOTAL_CLEANUP_STEPS%

:: ==================================================
:: [8/%TOTAL_CLEANUP_STEPS%] Recycle Bin
:: ==================================================
call :LogAndEcho.
call :LogAndEcho [8/%TOTAL_CLEANUP_STEPS%] Emptying Recycle Bin...
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
call :LogAndEcho [+] Recycle Bin emptied.
call :ProgressBar 8 %TOTAL_CLEANUP_STEPS%

:: ==================================================
:: [9/%TOTAL_CLEANUP_STEPS%] Store Cache + Network
:: ==================================================
call :LogAndEcho.
call :LogAndEcho [9/%TOTAL_CLEANUP_STEPS%] Resetting Store cache and network...
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
call :LogAndEcho [+] Store and network reset complete.
call :ProgressBar 9 %TOTAL_CLEANUP_STEPS%

:: ==================================================
:: Summary (Using LogAndEcho for guaranteed logging)
:: ==================================================
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
for /f "usebackq" %%A in (`powershell -Command "$i=%INITIAL_SPACE_MB%; $f=%FINAL_SPACE_MB%; [math]::Round($f - $i)"`) do set SPACE_FREED=%%A

call :LogAndEcho.
call :LogAndEcho ==================================================
call :LogAndEcho ZERO TRACE COMPLETE.
call :LogAndEcho ==================================================
call :LogAndEcho Initial free space: %INITIAL_SPACE_MB% MB
call :LogAndEcho Final free space:   %FINAL_SPACE_MB% MB
call :LogAndEcho Space freed:        %SPACE_FREED% MB
call :LogAndEcho Log file generated: %LOG_FILE%
call :LogAndEcho ==================================================
call :LogAndEcho.
call :LogAndEcho [OK] System cleaned. Zero trace left behind.
call :LogAndEcho.
call :LogAndEcho Press any key to exit...
timeout /t -1 >nul

exit /b
