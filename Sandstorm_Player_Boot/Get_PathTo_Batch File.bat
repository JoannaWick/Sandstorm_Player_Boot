@echo off

:: Created by: Joanna Wick (Sandy D)
:: Core Code: from Sandstorm Mod Mover
:: Date: 2026/09/06

echo.
echo "---===>>> Insurgency Sandstorm Downloading Server mods... Dirty Fix <<<===---"
echo.
echo The line below has been copied to your Clipboard and you can now paste it
echo.
echo "%~dp0Start_Player_Mod_Update.bat" %%COMMAND%% 

<nul set /p =""%~dp0Start_Player_Mod_Update.bat" %%COMMAND%% "| clip

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

