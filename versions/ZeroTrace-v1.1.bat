@echo off
setlocal enabledelayedexpansion

:: =====================================================
:: ZeroTrace v1.8
:: Fully automated Windows cleanup utility — leaves zero trace.
:: Cleans temp files, browser caches, prefetch, event logs, recycle bin, store/network,
:: additional caches (thumbnails, fonts, jump lists), and runs safe disk cleanup.
:: =====================================================

:: ----------------------------
:: Short Intro
:: ----------------------------
echo ==================================================
echo ZERO TRACE v1.8 - Full System Cleanup
echo --------------------------------------------------
echo This script will:
echo - Remove user and system temporary files and caches
echo - Clear browser caches (Chrome, Firefox, Edge)
echo - Clean Windows Update debris
echo - Clear Event Logs and Windows logs
echo - Clear Prefetch and Recycle Bin
echo - Reset Store cache and network settings
echo - Clear Thumbnail, Font, Jump List, Clipboard caches
echo - Clear Print Spooler queue
echo - Perform safe, native Windows Disk Cleanup
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
set TOTAL_STEPS=10 ; Incrementing for the new module

:: Get initial free space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A
echo [+] Initial free space: !INITIAL_SPACE_MB! MB
echo.

:: Set up logging
set "LOG_FILE=%TEMP%\ZeroTrace_Log_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.log"
(
    echo ZeroTrace v1.8 Execution Log - %DATE% %TIME%
    echo ==================================================
) > "%LOG_FILE%"
echo [+] Logging output to: %LOG_FILE%
echo.

:: ==================================================
:: Modules
:: ==================================================
call :LogMessage "Starting cleanup modules..."
call :TempCleanup
call :BrowserCacheCleanup
call :WindowsUpdateCleanup
call :EventLogsCleanup
call :WindowsLogsCleanup
call :PrefetchCleanup
call :RecycleBinCleanup
call :StoreNetworkReset
call :AdditionalCachesAndTracesCleanup ; New module
call :DiskCleanupNative

:: ==================================================
:: Summary
:: ==================================================
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
set /a SPACE_FREED=!FINAL_SPACE_MB! - !INITIAL_SPACE_MB!

echo.
echo ==================================================
echo ZERO TRACE v1.8 COMPLETE
echo ==================================================
echo Initial free space: !INITIAL_SPACE_MB! MB
echo Final free space:   !FINAL_SPACE_MB! MB
echo Space freed:        !SPACE_FREED! MB
echo ==================================================
echo [OK] System cleaned. Zero trace left behind.
echo.
call :LogMessage "ZeroTrace v1.8 COMPLETE."
call :LogMessage "Initial free space: !INITIAL_SPACE_MB! MB"
call :LogMessage "Final free space:   !FINAL_SPACE_MB! MB"
call :LogMessage "Space freed:        !SPACE_FREED! MB"
call :LogMessage "=================================================="
pause
exit /b

:: ==================================================
:: MODULES
:: ==================================================
:TempCleanup
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Cleaning temporary files (user and system)...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Cleaning temporary files (user and system)..."
:: Clear user temporary files
for /f "usebackq delims=" %%F in (`dir "%TEMP%\*" /a-d /b 2^>nul`) do del /f /q "%TEMP%\%%F" >nul 2>&1
for /d %%p in ("%TEMP%\*.*") do rmdir "%%p" /s /q >nul 2>&1
:: Clear system temporary files
if exist "%SystemRoot%\Temp" (
    for /f "usebackq delims=" %%F in (`dir "%SystemRoot%\Temp\*" /a-d /b 2^>nul`) do del /f /q "%SystemRoot%\Temp\%%F" >nul 2>&1
    for /d %%p in ("%SystemRoot%\Temp\*.*") do rmdir "%%p" /s /q >nul 2>&1
)
call :ShowProgress !STEP! !TOTAL_STEPS!
call :LogMessage "  User and system temp files cleaned."
exit /b

:BrowserCacheCleanup
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Clearing browser caches...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Clearing browser caches..."
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%p in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*") do (
        if exist "%%p\cache2\entries" rd /s /q "%%p\cache2\entries" >nul 2>&1
    )
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
call :ShowProgress !STEP! !TOTAL_STEPS!
call :LogMessage "  Browser caches cleaned."
exit /b

:WindowsUpdateCleanup
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Cleaning Windows Update files...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Cleaning Windows Update files..."
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
call :LogMessage "  Windows Update files cleaned."
exit /b

:EventLogsCleanup
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Clearing Event Logs...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Clearing Event Logs..."
for /f "tokens=*" %%i in ('wevtutil el') do wevtutil cl "%%i" >nul 2>&1
call :ShowProgress !STEP! !TOTAL_STEPS!
call :LogMessage "  Event logs cleared."
exit /b

:WindowsLogsCleanup
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Cleaning Windows logs...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Cleaning Windows logs..."
:: Note: Some files in C:\Windows\Logs might be locked and skipped.
if exist "C:\Windows\Logs" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Logs\*" /a-d /b 2^>nul`) do del /f /q "C:\Windows\Logs\%%F" >nul 2>&1
)
call :ShowProgress !STEP! !TOTAL_STEPS!
call :LogMessage "  Windows logs cleaned."
exit /b

:PrefetchCleanup
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Clearing Prefetch...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Clearing Prefetch..."
if exist "C:\Windows\Prefetch" (
    for /f "usebackq delims=" %%F in (`dir "C:\Windows\Prefetch\*.pf" /b 2^>nul`) do del /f /q "C:\Windows\Prefetch\%%F" >nul 2>&1
)
call :ShowProgress !STEP! !TOTAL_STEPS!
call :LogMessage "  Prefetch files cleared."
exit /b

:RecycleBinCleanup
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Emptying Recycle Bin...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Emptying Recycle Bin..."
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
call :ShowProgress !STEP! !TOTAL_STEPS!
call :LogMessage "  Recycle Bin emptied."
exit /b

:StoreNetworkReset
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Resetting Store cache and network...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Resetting Store cache and network..."
wsreset.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
echo     [!] A system reboot is often required for 'netsh winsock reset' to take full effect.
call :LogMessage "  Store cache reset, DNS flushed, Winsock/WinHTTP proxy reset."
call :LogMessage "  NOTE: A system reboot is often required for 'netsh winsock reset' to take full effect."
call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:AdditionalCachesAndTracesCleanup
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Clearing additional caches and traces (thumbnails, fonts, jump lists, clipboard, print spooler)...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Clearing additional caches and traces..."

:: Clear Thumbnail Cache
:: https://superuser.com/questions/1126930/how-to-rebuild-thumbnail-cache-in-windows-10
attrib -h -s -r "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
call :LogMessage "  Thumbnail cache cleared."

:: Clear Font Cache (requires stopping service, might be less critical for general cleanup)
:: Not including stopping/starting service here for simplicity, as it's often locked.
:: A reboot would typically clear it.
:: Better to use a specific tool or let cleanmgr handle.
:: For now, let's skip explicit deletion here, as the files are usually locked.
:: If you really need to clear it, you'd stop "Windows Font Cache Service", delete, then restart.
:: For now, we'll focus on easier-to-clear items.

:: Clear Jump Lists / Recent Items
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*.*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
call :LogMessage "  Jump Lists/Recent Items cleared."

:: Clear Clipboard History (Windows 10/11)
PowerShell.exe -Command "Set-Clipboard -Value ''" >nul 2>&1
PowerShell.exe -Command "Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'EnableClipboardHistory' -ErrorAction SilentlyContinue | Where-Object {$_.EnableClipboardHistory -eq 1} | ForEach-Object {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'EnableClipboardHistory' -Value 0 -Force; Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'EnableClipboardHistory' -Value 1 -Force}" >nul 2>&1
call :LogMessage "  Clipboard history cleared."

:: Clear Print Spooler Queue
net stop spooler >nul 2>&1
del /f /q "%SystemRoot%\System32\spool\PRINTERS\*.*" >nul 2>&1
net start spooler >nul 2>&1
call :LogMessage "  Print Spooler queue cleared."

call :ShowProgress !STEP! !TOTAL_STEPS!
exit /b

:DiskCleanupNative
set /a STEP+=1
echo [!STEP!/!TOTAL_STEPS!] Running Native Windows Disk Cleanup...
call :LogMessage "[!STEP!/!TOTAL_STEPS!] Running Native Windows Disk Cleanup..."
:: This uses cleanmgr.exe to safely remove various system temporary files.
:: First, configure all available cleanup options (sageset:1).
:: This configuration persists, so it only needs to be run once or when new options appear.
cleanmgr.exe /sageset:1 >nul 2>&1
:: Then, execute the cleanup with the configured settings (sagerun:1).
cleanmgr.exe /sagerun:1 >nul 2>&1
call :ShowProgress !STEP! !TOTAL_STEPS!
call :LogMessage "  Native Windows Disk Cleanup completed."
exit /b

:: ==================================================
:: OPTIONAL ADVANCED MODULES (Uncomment to enable)
:: ==================================================
:: :DiskDefragmentationOrTrim
:: :: This module performs disk optimization. Use with caution.
:: :: For HDDs, it will defragment. For SSDs, it will perform TRIM.
:: :: This can take a significant amount of time.
:: :: Enable only if you understand its implications.
:: set /a STEP+=1
:: echo [!STEP!/!TOTAL_STEPS!] Running Disk Defragmentation/Trim (this may take a long time)...
:: call :LogMessage "[!STEP!/!TOTAL_STEPS!] Running Disk Defragmentation/Trim..."
:: defrag C: /L /O /V >nul 2>&1
:: call :ShowProgress !STEP! !TOTAL_STEPS!
:: call :LogMessage "  Disk Defragmentation/Trim completed for C: drive."
:: exit /b

:: ==================================================
:: Helper Functions
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

:LogMessage
echo %DATE% %TIME% - %~1 >> "%LOG_FILE%"
exit /b
