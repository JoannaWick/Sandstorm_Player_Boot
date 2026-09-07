@echo off

:: Created by: Joanna Wick (Sandy D)
:: Core Code: from Sandstorm Mod Mover
:: Date: 2026/09/06

Powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Player_Mod_Update.ps1"

start "" %1 %2 %3 %4 %5 %6 %7 %8

:: Finished