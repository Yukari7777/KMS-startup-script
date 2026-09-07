@echo off
setlocal EnableExtensions

set "MAPLE_DIR=E:\Nexon\Maple"
set "MAPLE=%MAPLE_DIR%\MapleStory.exe"
set "CACHE=%localappdata%\Nexon\Maple\NxOverlay\Cache\Cache_Data"

echo ============================================================
echo MapleStory Safe Launcher
echo ============================================================
echo.

rem ------------------------------------------------------------
rem Check MapleStory executable
rem ------------------------------------------------------------

if not exist "%MAPLE%" goto ERROR_MAPLE_NOT_FOUND

rem ------------------------------------------------------------
rem Do not launch if main MapleStory is already running
rem ------------------------------------------------------------

call :CHECK_PROCESS MapleStory.exe

if "%PROCESS_RUNNING%"=="1" goto MAPLE_ALREADY_RUNNING

rem ------------------------------------------------------------
rem Detect Test World
rem ------------------------------------------------------------

call :CHECK_PROCESS MapleStoryT.exe

if "%PROCESS_RUNNING%"=="1" goto TEST_WORLD_MODE

rem ------------------------------------------------------------
rem Normal mode
rem Stop DwarfAxe before deleting NxOverlay cache
rem ------------------------------------------------------------

call :CHECK_PROCESS DwarfAxe.exe

if "%PROCESS_RUNNING%"=="0" goto DWARF_READY

echo [INFO] DwarfAxe.exe is running.
echo [INFO] Stopping DwarfAxe.exe...

taskkill /F /T /IM DwarfAxe.exe

if errorlevel 1 goto ERROR_DWARF_KILL

set /a WAIT_COUNT=0


:WAIT_DWARF

call :CHECK_PROCESS DwarfAxe.exe

if "%PROCESS_RUNNING%"=="0" goto DWARF_READY

set /a WAIT_COUNT+=1

if %WAIT_COUNT% GEQ 5 goto ERROR_DWARF

echo [INFO] Waiting for DwarfAxe... %WAIT_COUNT%/5

timeout /t 1 /nobreak >nul

goto WAIT_DWARF


:DWARF_READY

echo [OK] DwarfAxe.exe is not running.

rem ------------------------------------------------------------
rem Delete NxOverlay cache
rem ------------------------------------------------------------

if not exist "%CACHE%" goto CACHE_NOT_FOUND

echo [INFO] Deleting NxOverlay cache...
echo [PATH] %CACHE%

set /a DELETE_COUNT=0


:DELETE_CACHE

rd /s /q "%CACHE%" 2>nul

if not exist "%CACHE%" goto CACHE_CLEARED

set /a DELETE_COUNT+=1

if %DELETE_COUNT% GEQ 3 goto ERROR_CACHE

echo [INFO] Retrying cache deletion... %DELETE_COUNT%/3

timeout /t 1 /nobreak >nul

goto DELETE_CACHE


:CACHE_NOT_FOUND

echo [OK] No NxOverlay cache found.

goto BEFORE_LAUNCH


:CACHE_CLEARED

echo [OK] NxOverlay cache cleared.

goto BEFORE_LAUNCH


rem ------------------------------------------------------------
rem Test World mode
rem ------------------------------------------------------------

:TEST_WORLD_MODE

echo [MODE] MapleStory Test World detected.
echo [INFO] MapleStoryT.exe is currently running.
echo [INFO] DwarfAxe.exe will NOT be terminated.
echo [INFO] NxOverlay cache cleanup will be skipped.
echo.

goto BEFORE_LAUNCH


rem ------------------------------------------------------------
rem Final safety check
rem ------------------------------------------------------------

:BEFORE_LAUNCH

call :CHECK_PROCESS MapleStory.exe

if "%PROCESS_RUNNING%"=="1" goto MAPLE_STARTED_DURING_CLEANUP

rem ------------------------------------------------------------
rem Launch main MapleStory
rem ------------------------------------------------------------

echo.
echo [INFO] Starting MapleStory with Above Normal priority...
echo.

start "" /abovenormal /d "%MAPLE_DIR%" "%MAPLE%" GameLaunching

if errorlevel 1 goto ERROR_LAUNCH

echo [OK] Launch command sent.
echo.
pause
exit /b 0


rem ============================================================
rem Stop / Error handling
rem ============================================================

:MAPLE_ALREADY_RUNNING

echo [STOP] MapleStory.exe is already running.
echo [STOP] No cleanup or duplicate launch will be performed.
echo.
pause
exit /b 0


:MAPLE_STARTED_DURING_CLEANUP

echo.
echo [STOP] MapleStory.exe started during cleanup.
echo [STOP] Duplicate launch prevented.
echo.
pause
exit /b 0


:ERROR_MAPLE_NOT_FOUND

echo [ERROR] MapleStory.exe was not found.
echo [PATH] %MAPLE%
echo.
pause
exit /b 1


:ERROR_DWARF_KILL

echo.
echo [ERROR] Failed to terminate DwarfAxe.exe.
echo [ERROR] Cache cleanup will not be attempted.
echo [ERROR] MapleStory will not be started.
echo.
pause
exit /b 1


:ERROR_DWARF

echo.
echo [ERROR] DwarfAxe.exe is still running after 5 seconds.
echo [ERROR] Cache cleanup is not safe.
echo [ERROR] MapleStory will not be started.
echo.
pause
exit /b 1


:ERROR_CACHE

echo.
echo [ERROR] Cache_Data could not be deleted.
echo [ERROR] Another process may still be using the files.
echo [PATH] %CACHE%
echo.
echo [ERROR] MapleStory will not be started.
echo.
pause
exit /b 1


:ERROR_LAUNCH

echo.
echo [ERROR] Failed to execute MapleStory launch command.
echo.
pause
exit /b 1


rem ============================================================
rem Subroutine
rem ============================================================

:CHECK_PROCESS

set "PROCESS_RUNNING=0"

tasklist /FI "IMAGENAME eq %~1" /NH 2>nul | find /I "%~1" >nul

if not errorlevel 1 set "PROCESS_RUNNING=1"

exit /b 0