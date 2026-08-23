@echo off
chcp 65001 > nul

:: Automatic Administrator Privilege Check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
:: Check Hibernate Status
powercfg /a | findstr /i "Hibernation has not been enabled" >nul
if %errorLevel% == 0 (
    set "HIB_STATUS=Disabled"
) else (
    set "HIB_STATUS=Enabled"
)

echo ===================================================
echo             System Maintenance Tool
echo ===================================================
echo [1] Scan and Repair Disk (CHKDSK)
echo [2] Full System Repair (DISM + SFC /Scannow)
echo [3] Clean Temp Files / System Cache / Update Cache
echo [4] Toggle Hibernate Status [Current: %HIB_STATUS%]
echo [5] Run All Tasks (1 - 4)
echo [6] Exit
echo ===================================================
set /p choice="Please select an option (1-6): "

if "%choice%"=="1" goto opt1
if "%choice%"=="2" goto opt2
if "%choice%"=="3" goto opt3
if "%choice%"=="4" goto opt4
if "%choice%"=="5" goto opt5
if "%choice%"=="6" exit
goto menu

:opt1
cls
echo [Running CHKDSK C: /f /r...]
chkdsk C: /f /r
pause
goto menu

:opt2
cls
echo [Step 1/2: Running DISM to repair system image...]
DISM.exe /Online /Cleanup-image /Restorehealth
echo.
echo [Step 2/2: Running SFC /Scannow...]
sfc /scannow
pause
goto menu

:opt3
cls
echo [Deleting Temp Files and System Cache...]
del /s /f /q %temp%\* >nul 2>&1
del /s /f /q C:\Windows\Temp\* >nul 2>&1

echo [Clearing Windows Update Cache...]
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rd /s /q C:\Windows\SoftwareDistribution\Download >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo [Launching Disk Cleanup...]
cleanmgr /sagerun:1

echo.
echo Temp files and cache cleaned successfully!
pause
goto menu

:opt4
cls
if "%HIB_STATUS%"=="Disabled" (
    echo [Enabling Hibernate...]
    powercfg /hibernate on
    echo Hibernate has been enabled!
) else (
    echo [Disabling Hibernate...]
    powercfg /hibernate off
    echo Hibernate has been disabled! (Disk space reclaimed)
)
pause
goto menu

:opt5
cls
echo [Running All Tasks...]
echo.
echo 1/4 Disabling Hibernate...
powercfg /hibernate off

echo 2/4 Deleting Temp Files and Update Cache...
del /s /f /q %temp%\* >nul 2>&1
del /s /f /q C:\Windows\Temp\* >nul 2>&1
net stop wuauserv >nul 2>&1
rd /s /q C:\Windows\SoftwareDistribution\Download >nul 2>&1
net start wuauserv >nul 2>&1

echo 3/4 Repairing System Files via DISM and SFC...
DISM.exe /Online /Cleanup-image /Restorehealth
sfc /scannow

echo 4/4 Scheduling Disk Check...
chkdsk C: /f /r

echo ===================================================
echo All maintenance tasks completed!
pause
goto menu
