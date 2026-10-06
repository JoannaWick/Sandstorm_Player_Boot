@echo off

rem Created by: Joanna Wick (Sandy D)
rem Core Code: from Sandstorm Mod Mover
rem Date: 2026/09/06

setlocal DisableDelayedExpansion

rem Set up the configuration file path
set "cfgFile=%~dp0config\batchFirstRun.cfg"
set "cfgValue=0"

rem Read the config file if it exists
if exist "%cfgFile%" set /p cfgValue=<"%cfgFile%"

rem Clean up the read value
set "cfgValue=%cfgValue: =%"
if "%cfgValue%"=="ECHOisoff." set "cfgValue=0"
if "%cfgValue%"=="" set "cfgValue=0"

rem Jump straight to launching the game if it's not the first run
if not "%cfgValue%"=="0" goto LaunchGame

echo.
echo ---=== FIRST RUN SETUP OF DOWNLOADED FILES ===---
echo.

rem Query file system filters (requires true Admin privileges on Win 10 and Win 11)
fltmc >nul 2>&1

rem Checks if the previous command returned an error (1 or higher)
if errorlevel 1 (
    echo Must be in Administration Mode to UnBlock downloaded files.
    echo This will allow Scripts to execute without User being asked for Permissions.
    echo Administration mode will not be needed after this unless Script explicitly
    echo asks for it.
    pause
    exit /b
)

echo First run detected. Elevated Administrator rights confirmed.
echo Unblocking files...
echo.
echo All downloaded files should be UnBlocked and allowed to run without
echo asking User for permission to run from this point on.
echo.
echo No need to run this Batch (.bat) file in Administrator Mode unless required.

rem This line safe now that the outer parentheses are gone
powershell -NoProfile -Command "Get-ChildItem -Path '%~dp0' -File -Recurse | Unblock-File"

rem Safely write '1' using set /p
<nul set /p "=1" >"%cfgFile%"

echo.
echo Done! Configuration batchFirstRun.cfg updated.
echo User will not see this again.
echo.
pause

:LaunchGame

echo.
echo "---===>>> Insurgency Sandstorm Downloading Server mods... Dirty Fix <<<===---"
echo.
echo The line below has been copied to your Clipboard and you can now paste it
echo.
echo "%~dp0Start_Player_Mod_Update.ps1" %%COMMAND%% 

<nul set /p =""%~dp0Start_Player_Mod_Update.ps1" %%COMMAND%% "| clip

echo.
echo In Steam Right-Click on Insurgency Sandstorm and select Properties.
echo Under Launch Options use CTRL-V to Paste the copied line at the front of the options (if any).
echo.
echo Example Before: -dx12 -NOFORCEFEEDBACK -USEALLAVAILABLECORES -NoGlobalInvalidation -malloc=tbbmalloc/system
echo.
echo Example After: "%~dp0Start_Player_Mod_Update.ps1" %%COMMAND%% -dx12 -NOFORCEFEEDBACK -USEALLAVAILABLECORES -NoGlobalInvalidation -malloc=tbbmalloc/system
echo.
echo When you Paste make sure there is a SPACE between %%COMMAND%% and any Launch Options. 
echo Close the Properties.  Sandstorm will now download any files from Mod.io before launching the game.
echo This way you will ALWAYS get updated files.
echo.
echo If you join a server and seem to be stuck on the 'Downloading Server mods...' screen you can CANCEL
echo and then EXIT the game completely.  Select 'Play' again and all of the mods/maps from the server you
echo tried to join will now download.  You were automatically subscribed too all of that server's mods
echo when you tried to join it.  When playing again all of those new mods will be downloaded before the game
echo even launches.  Once they have all been downloaded the game will start.  If there are no mods to
echo download or update the process will be finished in a second or two.
echo.

Pause

