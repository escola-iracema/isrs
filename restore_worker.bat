@echo off
setlocal enabledelayedexpansion

:: =================================================================================
:: restore_worker
:: Version: 1.1
:: Task: Perform all cleaning and restoration routines.
:: =================================================================================

set "WORKER_VERSION=1.1"
set "WORKER_VERSION_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/restore_worker_version.txt"
set "WORKER_SCRIPT_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/restore_worker.bat"

set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "secretRegFile=HKCU_GoldenState.reg"
set "workerScriptPath=%secretPath%\restore_worker.bat"
set "vbsLauncherPath=%secretPath%\launcher_invisible.vbs"

reg import "%secretPath%\%secretRegFile%"
regedit.exe /s "%secretPath%\%secretRegFile%"

set "chromeProfile=%LOCALAPDATA%\Google\Chrome\User Data"
set "edgeProfile=%LOCALAPPDATA%\Microsoft\Edge\User Data"
set "firefoxProfile=%APPDATA%\Mozilla\Firefox\Profiles"

set "psCmdStopProc=Stop-Process -Name 'chrome','msedge','firefox' -Force -ErrorAction SilentlyContinue"

:: Limpeza de perfis de navegador (todos os perfis)
set "psCmdCleanChromeProfiles=Get-ChildItem -Path '%chromeProfile%' -Directory | ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }"
set "psCmdCleanEdgeProfiles=Get-ChildItem -Path '%edgeProfile%' -Directory | ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }"
set "psCmdCleanFirefoxProfiles=Get-ChildItem -Path '%firefoxProfile%' -Directory | ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }"

set "psCmdCleanDesktop=Get-ChildItem -Path '%USERPROFILE%\Desktop\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanDownloads=Get-ChildItem -Path '%USERPROFILE%\Downloads\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanDocuments=Get-ChildItem -Path '%USERPROFILE%\Documents\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanPictures=Get-ChildItem -Path '%USERPROFILE%\Pictures\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"
set "psCmdCleanVideos=Get-ChildItem -Path '%USERPROFILE%\Videos\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"

set "psCmdCleanTemp=Get-ChildItem -Path '%TEMP%\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"

set "mmcProfile=%APPDATA%\Microsoft\MMC"
set "psCmdCleanMMC=Remove-Item -Path '%mmcProfile%' -Recurse -Force -ErrorAction SilentlyContinue"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdStopProc%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanChromeProfiles%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanEdgeProfiles%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanFirefoxProfiles%}"

:: Limpeza adicional de temas, extensões e histórico para todos os perfis
set "psCmdCleanChromeExtensions=Get-ChildItem -Path '%chromeProfile%' -Directory | ForEach-Object { Remove-Item -Path (Join-Path $_.FullName 'Extensions') -Recurse -Force -ErrorAction SilentlyContinue }"
set "psCmdCleanChromeThemes=Get-ChildItem -Path '%chromeProfile%' -Directory | ForEach-Object { Remove-Item -Path (Join-Path $_.FullName 'Themes') -Recurse -Force -ErrorAction SilentlyContinue }"
set "psCmdCleanChromeHistory=Get-ChildItem -Path '%chromeProfile%' -Directory | ForEach-Object { Remove-Item -Path (Join-Path $_.FullName 'History*') -Force -ErrorAction SilentlyContinue }"

set "psCmdCleanEdgeExtensions=Get-ChildItem -Path '%edgeProfile%' -Directory | ForEach-Object { Remove-Item -Path (Join-Path $_.FullName 'Extensions') -Recurse -Force -ErrorAction SilentlyContinue }"
set "psCmdCleanEdgeThemes=Get-ChildItem -Path '%edgeProfile%' -Directory | ForEach-Object { Remove-Item -Path (Join-Path $_.FullName 'Themes') -Recurse -Force -ErrorAction SilentlyContinue }"
set "psCmdCleanEdgeHistory=Get-ChildItem -Path '%edgeProfile%' -Directory | ForEach-Object { Remove-Item -Path (Join-Path $_.FullName 'History*') -Force -ErrorAction SilentlyContinue }"

set "psCmdCleanFirefoxExtensions=Get-ChildItem -Path '%firefoxProfile%' -Directory | ForEach-Object { Remove-Item -Path (Join-Path $_.FullName 'extensions') -Recurse -Force -ErrorAction SilentlyContinue }"
set "psCmdCleanFirefoxThemes=Get-ChildItem -Path '%firefoxProfile%' -Directory | ForEach-Object { Remove-Item -Path (Join-Path $_.FullName 'chrome') -Recurse -Force -ErrorAction SilentlyContinue }"
set "psCmdCleanFirefoxHistory=Get-ChildItem -Path '%firefoxProfile%' -Directory | ForEach-Object { Remove-Item -Path (Join-Path $_.FullName 'places.sqlite*') -Force -ErrorAction SilentlyContinue }"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanChromeExtensions%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanChromeThemes%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanChromeHistory%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanEdgeExtensions%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanEdgeThemes%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanEdgeHistory%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanFirefoxExtensions%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanFirefoxThemes%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanFirefoxHistory%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanDesktop%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanDownloads%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanDocuments%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanPictures%}"
powershell -ExecutionPolicy Bypass -ErrorAction SilentlyContinue -Command "& {%psCmdCleanVideos%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanTemp%}"

powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanMMC%}"

:: Remover pastas vazias após limpeza
powershell -ExecutionPolicy Bypass -Command "& {Get-ChildItem -Path '%USERPROFILE%\Desktop' -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName -Recurse | Measure-Object).Count -eq 0 } | Remove-Item -Force -ErrorAction SilentlyContinue}"
powershell -ExecutionPolicy Bypass -Command "& {Get-ChildItem -Path '%USERPROFILE%\Downloads' -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName -Recurse | Measure-Object).Count -eq 0 } | Remove-Item -Force -ErrorAction SilentlyContinue}"
powershell -ExecutionPolicy Bypass -Command "& {Get-ChildItem -Path '%USERPROFILE%\Documents' -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName -Recurse | Measure-Object).Count -eq 0 } | Remove-Item -Force -ErrorAction SilentlyContinue}"
powershell -ExecutionPolicy Bypass -Command "& {Get-ChildItem -Path '%USERPROFILE%\Pictures' -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName -Recurse | Measure-Object).Count -eq 0 } | Remove-Item -Force -ErrorAction SilentlyContinue}"
powershell -ExecutionPolicy Bypass -Command "& {Get-ChildItem -Path '%USERPROFILE%\Videos' -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName -Recurse | Measure-Object).Count -eq 0 } | Remove-Item -Force -ErrorAction SilentlyContinue}"
powershell -ExecutionPolicy Bypass -Command "& {Get-ChildItem -Path '%TEMP%' -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName -Recurse | Measure-Object).Count -eq 0 } | Remove-Item -Force -ErrorAction SilentlyContinue}"

:: Renomear e esvaziar a Lixeira
powershell -Command "& {Clear-RecycleBin -Force -ErrorAction SilentlyContinue}"

:: Lógica de atualização automática para restore_worker
curl -sL "%WORKER_VERSION_URL%" -o "%secretPath%\wv.tmp" --connect-timeout 300 2>nul
if exist "%secretPath%\wv.tmp" (
    set /p LATEST_WORKER_VERSION=<"%secretPath%\wv.tmp"
    del /f /q "%secretPath%\wv.tmp" >nul 2>&1
    if !WORKER_VERSION! LSS !LATEST_WORKER_VERSION! (
        curl -sL "%WORKER_SCRIPT_URL%" -o "%workerScriptPath%.new" --connect-timeout 300 2>nul
        if exist "%workerScriptPath%.new" (
            (
                echo @echo off
                echo timeout /t 2 /nobreak ^> nul
                echo move /Y "%workerScriptPath%.new" "%workerScriptPath%"
                echo attrib +h +s "%workerScriptPath%"
                echo del /f /q %%~f0
            ) > "%secretPath%\uw.bat"
            start "" /B wscript.exe "%vbsLauncherPath%" "%secretPath%\uw.bat"
            goto :eof
        )
    )
)

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage2" /f >nul 2>&1

:eof
endlocal
exit /b
