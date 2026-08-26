@echo off
chcp 65001 > nul
:: Automatic Administrator Privilege Check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "LOGFILE=C:\MaintenanceLog.txt"

:menu
cls
:: Check Hibernate Status via Registry (language-independent)
for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v HibernateEnabled 2^>nul ^| findstr HibernateEnabled') do set "HIB_VAL=%%a"
if "%HIB_VAL%"=="0x1" (
    set "HIB_STATUS=Enabled"
) else (
    set "HIB_STATUS=Disabled"
)

echo ===================================================
echo             System Maintenance Tool
echo ===================================================
echo [1] Schedule Disk Scan on Next Reboot (CHKDSK C:)
echo [2] Full System Repair (DISM + SFC /Scannow)
echo [3] Clean Temp Files / System Cache / Update Cache
echo [4] Toggle Hibernate Status [Current: %HIB_STATUS%]
echo [5] Run All Tasks [1,2,3,4]
echo [6] Create System Restore Point
echo [7] Check Disk Space
echo [8] Reset Network (Fix Internet Issues)
echo [9] Restart Computer Now
echo [10] Exit
echo ===================================================
set /p choice="Please select an option (1-10): "
if "%choice%"=="1" goto opt1
if "%choice%"=="2" goto opt2
if "%choice%"=="3" goto opt3
if "%choice%"=="4" goto opt4
if "%choice%"=="5" goto opt5
if "%choice%"=="6" goto opt8
if "%choice%"=="7" goto opt9
if "%choice%"=="8" goto opt10
if "%choice%"=="9" goto opt6
if "%choice%"=="10" exit
echo.
echo [!] Invalid option. Please select 1-10.
pause
goto menu

:opt1
cls
echo [Setting up Disk Check for Next Reboot...]
fsutil dirty set C:
echo %date% %time% - CHKDSK scheduled on C: >> "%LOGFILE%"
echo.
echo Disk C: has been marked for repair.
echo Please RESTART your computer to start the disk check process.
pause
goto menu

:opt2
cls
echo [Step 1/2: Running DISM to repair system image...]
DISM.exe /Online /Cleanup-image /Restorehealth
echo %date% %time% - DISM RestoreHealth completed with exit code %errorLevel% >> "%LOGFILE%"
echo.
echo [Step 2/2: Running SFC /Scannow...]
sfc /scannow
echo %date% %time% - SFC Scannow completed with exit code %errorLevel% >> "%LOGFILE%"
echo.
echo Done. Check %LOGFILE% for exit codes (0 = success).
pause
goto menu

:opt3
cls
echo [Deleting Temp Files and System Cache...]
del /s /f /q "%temp%\*" >nul 2>&1
for /d %%i in ("%temp%\*") do rd /s /q "%%i" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" >nul 2>&1

echo [Clearing Windows Update Cache...]
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rd /s /q C:\Windows\SoftwareDistribution\Download >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo [Configuring and Launching Disk Cleanup...]
:: Silently configure sageset profile 1 (temp files, recycle bin, thumbnails, update cache, etc.)
cleanmgr /sageset:1 /verylowdisk >nul 2>&1
cleanmgr /sagerun:1

echo %date% %time% - Temp/cache cleanup executed >> "%LOGFILE%"
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
    echo %date% %time% - Hibernate enabled >> "%LOGFILE%"
) else (
    echo [Disabling Hibernate...]
    powercfg /hibernate off
    echo Hibernate has been disabled! ^(Disk space reclaimed^)
    echo %date% %time% - Hibernate disabled >> "%LOGFILE%"
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
del /s /f /q "%temp%\*" >nul 2>&1
for /d %%i in ("%temp%\*") do rd /s /q "%%i" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" >nul 2>&1
net stop wuauserv >nul 2>&1
rd /s /q C:\Windows\SoftwareDistribution\Download >nul 2>&1
net start wuauserv >nul 2>&1

echo 3/4 Repairing System Files via DISM and SFC...
DISM.exe /Online /Cleanup-image /Restorehealth
sfc /scannow

echo 4/4 Scheduling Disk Check for next reboot...
fsutil dirty set C:

echo %date% %time% - Run-all maintenance completed >> "%LOGFILE%"
echo ===================================================
echo All tasks completed!
echo NOTE: Please RESTART your computer now to perform the scheduled Disk Check.
pause
goto menu

:opt6
cls
echo [!] The computer will restart in 5 seconds.
set /p confirm="Are you sure? Save your work! (Y/N): "
if /i "%confirm%"=="Y" (
    echo %date% %time% - Restart initiated by user >> "%LOGFILE%"
    shutdown /r /t 5
) else (
    echo Restart cancelled.
    pause
)
goto menu

:opt8
cls
echo [Creating System Restore Point...]
echo This may take a minute, please wait...
powershell -Command "Enable-ComputerRestore -Drive 'C:\'; Checkpoint-Computer -Description 'Manual Maintenance Checkpoint' -RestorePointType 'MODIFY_SETTINGS'"
if %errorLevel% == 0 (
    echo.
    echo Restore point created successfully!
    echo %date% %time% - System Restore Point created >> "%LOGFILE%"
) else (
    echo.
    echo [!] Failed to create restore point. System Protection may be disabled for drive C:.
    echo     You can enable it via: Control Panel ^> System ^> System Protection
    echo %date% %time% - Restore Point creation FAILED >> "%LOGFILE%"
)
pause
goto menu

:opt9
cls
echo [Checking Disk Space...]
echo.
powershell -Command "Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} | Select-Object Name, @{N='Used(GB)';E={[math]::Round($_.Used/1GB,2)}}, @{N='Free(GB)';E={[math]::Round($_.Free/1GB,2)}}, @{N='Total(GB)';E={[math]::Round(($_.Used+$_.Free)/1GB,2)}}, @{N='%%Free';E={[math]::Round(($_.Free/($_.Used+$_.Free))*100,1)}} | Format-Table -AutoSize"
echo %date% %time% - Disk space checked >> "%LOGFILE%"
pause
goto menu

:opt10
cls
echo [Resetting Network Settings...]
echo.
echo [1/4] Flushing DNS cache...
ipconfig /flushdns
echo [2/4] Releasing and renewing IP address...
ipconfig /release
ipconfig /renew
echo [3/4] Resetting Winsock catalog...
netsh winsock reset
echo [4/4] Resetting TCP/IP stack...
netsh int ip reset
echo.
echo %date% %time% - Network reset performed >> "%LOGFILE%"
echo ===================================================
echo Network reset complete!
echo NOTE: A RESTART is required for all changes to take effect.
echo ===================================================
pause
goto menu
