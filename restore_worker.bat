@echo off
setlocal enabledelayedexpansion

:: =================================================================================
:: restore_worker
:: Version: 1.0
:: Task: Perform all cleaning and restoration routines.
:: =================================================================================

msg * oi

set "WORKER_VERSION=1.0"
set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "secretRegFile=HKCU_GoldenState.reg"

reg import "%secretPath%\%secretRegFile%"
regedit.exe /s "%secretPath%\%secretRegFile%"

set "chromeProfile=%LOCALAPPDATA%\Google\Chrome\User Data"
set "edgeProfile=%LOCALAPPDATA%\Microsoft\Edge\User Data"
set "firefoxProfile=%APPDATA%\Mozilla\Firefox\Profiles"

set "psCmdStopProc=Stop-Process -Name 'chrome','msedge','firefox' -Force -ErrorAction SilentlyContinue"

set "psCmdCleanChromeProfile=Remove-Item -Path '%chromeProfile%' -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanEdgeProfile=Remove-Item -Path '%edgeProfile%' -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanFirefoxProfile=Remove-Item -Path '%firefoxProfile%' -Recurse -Force -ErrorAction SilentlyContinue"

set "psCmdCleanDesktop=Get-ChildItem -Path '%USERPROFILE%\Desktop\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanDownloads=Get-ChildItem -Path '%USERPROFILE%\Downloads\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanDocuments=Get-ChildItem -Path '%USERPROFILE%\Documents\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanPictures=Get-ChildItem -Path '%USERPROFILE%\Pictures\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanVideos=Get-ChildItem -Path '%USERPROFILE%\Videos\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"

set "psCmdCleanTemp=Get-ChildItem -Path '%TEMP%\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"

set "mmcProfile=%APPDATA%\Microsoft\MMC"
set "psCmdCleanMMC=Remove-Item -Path '%mmcProfile%' -Recurse -Force -ErrorAction SilentlyContinue"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdStopProc%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanChromeProfile%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanEdgeProfile%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanFirefoxProfile%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanDesktop%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanDownloads%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanDocuments%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanPictures%}"
powershell -ExecutionPolicy Bypass -ErrorAction SilentlyContinue -Command "& {%psCmdCleanVideos%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanTemp%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanMMC%}"

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage2" /f >nul 2>&1

:eof
endlocal
exit /b


