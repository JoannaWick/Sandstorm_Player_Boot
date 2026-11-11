# Sandstorm_Player_Boot

1. Automatically Downloads and Updates any mods that need it before the game launches.  Take less than 1 second to scan through over 100 mod subscriptions.  This displays a Download Progress for any mods being downloaded.  Avoids the Downloading Server Mods... screen on your regularly played servers.

2. Use the Steam Server Browser to join ANY Sandstorm Server and avoid using the slow, broken Server Browser in the game.  This is much faster and easier to use.  Just click on the Servers button on the Steam Taskbar to see all Sandstorm servers.  Even save your Favorites in the Steam Server Browser.  Just double-click on a server and the game will load and join the sever no waiting.

You can Ctrl+Click or Cmd+Click to open video in a new tab

Watch the Sandstorm Player Boot Installation Video (Click Image to view)

[![Watch the Sandstorm Player Boot Installation Video](https://img.youtube.com/vi/hYGCZSsFLFg/0.jpg)](https://www.youtube.com/watch?v=hYGCZSsFLFg)

Watch the Sandstorm Player Boot Installation Video (Click Image to view)

[![Watch the Sandstorm Player Boot Using Steam's Server Browser to join any Sandstorm Server Video](https://img.youtube.com/vi/Sgmn4FQk3eA/0.jpg)](https://www.youtube.com/watch?v=Sgmn4FQk3eA)

Joanna Wick's Sandstorm Website (Click image to go to website)

[![Joanna Wick's Sandstorm Website](http://sandstorm.dworks.work/images/banner3.jpg)](https://sandstorm.dworks.work)

Change Log
==========

2.0.0 (2026-11-11)

    1. [ADDED] You can now use Steam's Server List to join any Sandstorm Server completely bypassing the Server List in the game.  Set up your own Favorite list so the servers you always play on are handy.  Just Double-click on a server and Sandstorm will Launch and join the selected server as soon as the Main Menu in the game appears.
    2. [ADDED] If first run or an update the Start_Player_Mod_Update.bat will re-run itself in Admin mode to unblock all files.

1.2.2 (2026-10-25)

    1. [REMOVED]  Removed the Network Activity GUI as there were too many issues with Windows 11 systems.

1.2.1 (2026-10-22)

    1. [CHANGED]  Reduced the size of the window display.  Now closer to the Sandstorm Splash Screen size.

1.2.0 (2026-10-19)

    1. [CHANGED]  The Download Progress Code has been re-written.  Some people were experiencing 
                  red errors being displayed slowing down downloads.  This should fix those errors.

1.1.1 (2026-10-09)

    1. [CHANGED] There is now a unified ModList.json that is used by both Sandstorm Player Boot and Sandstorm Mod Manager
       This is stored in C:\Users\[ACCOUNTNAME]\appdata\local\JoannaWick\Sandstorm
       This way when either Sandstorm Player Boot or Mod Manager updates mods the other program will know what was updated.
    
1.1.0 (2026-10-07)

    1. [FIXED] Issues with Windows 11 window positioning and resize
    2. [FIXED] Code to add to Launch Options not being copied properly to clipboard
    3. [ADDED] When launching for the first time as Administrator all files should be unblocked
               You should only be asked ONCE if you would like to run this script.
    4. [ADDED] Network Activity Graph will open and display Download and Upload speeds
    5. [ADDED] When files are downloaded a Real Time Text Download Progress will display
               showing MB Downloaded, % Downloaded and ETA

1.0.2 (2026-09-12)

    1. [FIXED] Wrong extension and an Echo in wrong place in Get_Path_to_Batch_File.bat
    
1.0.1 (2026-09-08)

    1. [FIXED] Added check for Windows 11 for centering and positioning window 
       
