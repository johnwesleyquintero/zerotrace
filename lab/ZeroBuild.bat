@echo off
title ZeroBuild v1.0 – Dev Environment Reset
color 0b
setlocal enabledelayedexpansion

:: ======== Globals ========
set resetNodeModules=1
set resetTempFiles=1
set resetVSCodeCache=1
set resetPythonEnv=1
set resetGitStash=1
set logFile=%~dp0ZeroBuild_log.txt

:: Clear previous log
if exist "%logFile%" del "%logFile%"

:: ======== Menu ========
:menu
cls
echo ===========================
echo ZeroBuild v1.0 – Dev Environment Reset
echo ===========================
echo.
echo 1. Run Full Reset
echo 2. Reset Node Modules
echo 3. Reset Temp Build Files
echo 4. Reset VS Code Cache
echo 5. Reset Python Virtualenvs
echo 6. Drop Git Stashes
echo 7. Exit
echo.
set /p choice="Choose an option [1-7]: "

if "%choice%"=="1" goto fullReset
if "%choice%"=="2" goto nodeModules
if "%choice%"=="3" goto tempFiles
if "%choice%"=="4" goto vscodeCache
if "%choice%"=="5" goto pythonEnv
if "%choice%"=="6" goto gitStash
if "%choice%"=="7" goto exit
echo Invalid choice, try again...
pause
goto menu

:: ======== Functions ========

:fullReset
call :nodeModules
call :tempFiles
call :vscodeCache
call :pythonEnv
call :gitStash
echo.
echo Full reset complete! All selected environments cleaned.
pause
goto menu

:nodeModules
echo --- Removing node_modules folders ---
for /d /r %%d in (node_modules) do (
    rmdir /s /q "%%d" >nul 2>&1
    if not errorlevel 1 echo Deleted: %%d | tee -a "%logFile%"
)
pause
goto :eof

:tempFiles
echo --- Removing temp build files (dist, build, *.tmp) ---
for /d /r %%d in (dist,build) do (
    rmdir /s /q "%%d" >nul 2>&1
    if not errorlevel 1 echo Deleted folder: %%d | tee -a "%logFile%"
)
for /r %%f in (*.tmp) do (
    del /q "%%f" >nul 2>&1
    if not errorlevel 1 echo Deleted file: %%f | tee -a "%logFile%"
)
pause
goto :eof

:vscodeCache
echo --- Removing VS Code cache and workspace storage ---
set "vscodeCache=%APPDATA%\Code\Cache"
set "vscodeStorage=%APPDATA%\Code\User\workspaceStorage"
if exist "!vscodeCache!" rmdir /s /q "!vscodeCache!" & echo Deleted VS Code cache | tee -a "%logFile%"
if exist "!vscodeStorage!" rmdir /s /q "!vscodeStorage!" & echo Deleted workspace storage | tee -a "%logFile%"
pause
goto :eof

:pythonEnv
echo --- Removing Python virtual environments ---
for /d /r %%d in (venv,env) do (
    rmdir /s /q "%%d" >nul 2>&1
    if not errorlevel 1 echo Deleted: %%d | tee -a "%logFile%"
)
pause
goto :eof

:gitStash
echo --- Dropping all git stashes in repo folders ---
for /d /r %%d in (.) do (
    if exist "%%d\.git" (
        pushd "%%d"
        git stash clear >nul 2>&1
        echo Cleared stashes in %%d | tee -a "%logFile%"
        popd
    )
)
pause
goto :eof

:exit
cls
echo ===========================
echo ZeroBuild v1.0 – Session Complete
echo ===========================
pause
exit
