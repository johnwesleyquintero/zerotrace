@echo off
setlocal enabledelayedexpansion

:: =====================================================
:: ZeroTrace Space Hack v1.0
:: Scan + Clean largest safe folders/files
:: =====================================================
echo ==================================================
echo ZeroTrace Space Hack v1.0
echo Automated max free space cleanup
echo ==================================================
echo Starting scan & cleanup...
echo.

:: --- Initial free space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set INITIAL_SPACE_MB=%%A

:: --- Initialize counters
set TOTAL_DELETED=0
set TOTAL_IGNORED=0

:: --- Threshold in MB (files larger than this will be auto-cleaned)
set THRESHOLD_MB=50

:: --- Safe-to-clean folders list
set FOLDERS_TO_CLEAN=%TEMP%;C:\Windows\Temp;%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache;%LOCALAPPDATA%\Mozilla\Firefox\Profiles;%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache;C:\Windows\SoftwareDistribution\Download;C:\Windows\Prefetch;C:\Windows\Logs

:: --- Scan and delete
for %%F in (%FOLDERS_TO_CLEAN%) do (
    if exist "%%F" (
        for /r "%%F" %%G in (*) do (
            for /f "usebackq" %%S in (`powershell -Command "(Get-Item '%%G').Length / 1MB"`) do (
                set FILE_SIZE_MB=%%S
                set FILE_SIZE_MB=!FILE_SIZE_MB:~0,10!
                if !FILE_SIZE_MB! GEQ %THRESHOLD_MB% (
                    del /f /q "%%G" >nul 2>&1
                    set /a TOTAL_DELETED+=1
                ) else (
                    set /a TOTAL_IGNORED+=1
                )
            )
        )
    )
)

:: --- Recycle Bin
PowerShell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
set /a TOTAL_DELETED+=1

:: --- Optional Hibernation (comment/uncomment)
:: powercfg -h off
:: set /a TOTAL_DELETED+=1

:: --- Final free space
for /f "usebackq" %%A in (`powershell -Command "(Get-PSDrive C).Free / 1MB"`) do set FINAL_SPACE_MB=%%A
set /a SPACE_FREED=%FINAL_SPACE_MB% - %INITIAL_SPACE_MB%

:: --- Summary
echo.
echo ==================================================
echo SPACE HACK CLEANUP COMPLETE
echo ==================================================
echo Initial free space: %INITIAL_SPACE_MB% MB
echo Final free space:   %FINAL_SPACE_MB% MB
echo Space freed:        %SPACE_FREED% MB
echo Files/folders deleted: %TOTAL_DELETED%
echo Files ignored (smaller than %THRESHOLD_MB% MB): %TOTAL_IGNORED%
echo ==================================================
echo Press any key to exit...
pause >nul
exit /b
