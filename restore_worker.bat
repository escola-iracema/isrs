@echo off
setlocal enabledelayedexpansion

:: =================================================================================
:: restore_worker
:: Version: 1.2
:: Task: Perform all cleaning and restoration routines.
:: =================================================================================

set "WORKER_VERSION=1.2"
set "WORKER_VERSION_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/restore_worker_version.txt"
set "WORKER_SCRIPT_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/restore_worker.bat"

set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "secretRegFile=HKCU_GoldenState.reg"
set "workerScriptPath=%secretPath%\restore_worker.bat"
set "vbsLauncherPath=%secretPath%\launcher_invisible.vbs"

reg import "%secretPath%\%secretRegFile%"
regedit.exe /s "%secretPath%\%secretRegFile%"

set "chromeProfile=%LOCALAPPDATA%\Google\Chrome\User Data"
set "edgeProfile=%LOCALAPPDATA%\Microsoft\Edge\User Data"
set "firefoxProfile=%APPDATA%\Mozilla\Firefox\Profiles"

:: Lógica para aguardar o fechamento dos navegadores
:wait_for_browsers_to_close
powershell -ExecutionPolicy Bypass -Command "if (Get-Process -Name 'chrome','msedge','firefox' -ErrorAction SilentlyContinue) { exit 1 } else { exit 0 }"
if %errorlevel% equ 1 (
    echo Navegadores ainda abertos. Aguardando...
    timeout /t 5 /nobreak > nul
    goto :wait_for_browsers_to_close
)

:: Limpeza de perfis de navegador (todos os perfis)
:: Adicionando limpeza explícita para o perfil 'Default' do Chrome
set "psCmdCleanChromeProfiles=Get-ChildItem -Path '%chromeProfile%' -Directory | ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue }"
set "psCmdCleanEdgeProfiles=Get-ChildItem -Path '%edgeProfile%' -Directory | ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue }"
set "psCmdCleanFirefoxProfiles=Get-ChildItem -Path '%firefoxProfile%' -Directory | ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue }"

set "psCmdCleanDesktop=Get-ChildItem -Path '%USERPROFILE%\Desktop\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue"
set "psCmdCleanDownloads=Get-ChildItem -Path '%USERPROFILE%\Downloads\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue"
set "psCmdCleanDocuments=Get-ChildItem -Path '%USERPROFILE%\Documents\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue"
set "psCmdCleanPictures=Get-ChildItem -Path '%USERPROFILE%\Pictures\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue"
set "psCmdCleanVideos=Get-ChildItem -Path '%USERPROFILE%\Videos\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue"

set "psCmdCleanTemp=Get-ChildItem -Path '%TEMP%\*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"

set "mmcProfile=%APPDATA%\Microsoft\MMC"
set "psCmdCleanMMC=Remove-Item -Path '%mmcProfile%' -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue"

:: Executar limpeza após navegadores fechados
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanChromeProfiles%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanEdgeProfiles%}"
powershell -ExecutionPolicy Bypass -Command "& {%psCmdCleanFirefoxProfiles%}"

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
powershell -ExecutionPolicy Bypass -Command "& {Get-ChildItem -Path '%USERPROFILE%\Videos' -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName -Recurse | Measure-Object).Count -eq 0 } | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue}"
powershell -ExecutionPolicy Bypass -Command "& {Get-ChildItem -Path '%TEMP%' -Directory -Recurse | Where-Object { (Get-ChildItem $_.FullName -Recurse | Measure-Object).Count -eq 0 } | Remove-Item -Force -ErrorAction SilentlyContinue}"

:: Renomear e esvaziar a Lixeira
powershell -Command "& {Clear-RecycleBin -Force -ErrorAction SilentlyContinue}"

:: Lógica de atualização automática para restore_worker
curl -sL "%WORKER_VERSION_URL%" -o "%secretPath%\wv.tmp" --connect-timeout 300 2>nul
if exist "%secretPath%\wv.tmp" (
    set /p LATEST_WORKER_VERSION=<"%secretPath%\wv.tmp"
    del /f /q "%secretPath%\wv.tmp" >nul 2>&1
    if !WORKER_VERSION! LSS !LATEST_WORKER_VERSION! (
        curl -sL "%WORKER_SCRIPT_URL%" -o "%secretPath%\restore_worker.bat.new" --connect-timeout 300 2>nul
        if exist "%secretPath%\restore_worker.bat.new" (
            (
                echo @echo off
                echo timeout /t 2 /nobreak ^> nul
                echo move /Y "%secretPath%\restore_worker.bat.new" "%workerScriptPath%"
                echo attrib +h +s "%workerScriptPath%"
                echo del /f /d "%%~f0"
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

