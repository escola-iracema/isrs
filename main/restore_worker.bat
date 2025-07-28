@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: =================================================================================
:: restore_worker
:: Version: 1.0
:: Task: Perform all cleaning and restoration routines.
:: =================================================================================

set "WORKER_VERSION=1.0"
set "REG_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/HKCU_GoldenState.reg"
set "REG_HASH_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/HKCU_GoldenState_hash.txt"
set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "secretRegFile=HKCU_GoldenState.reg"

set "GOLDEN_REG_HASH_OBFUSCATED="
curl -sL "%REG_HASH_URL%" -o "%secretPath%\rh.tmp" --connect-timeout 5 2>nul
if exist "%secretPath%\rh.tmp" (
    set /p GOLDEN_REG_HASH_OBFUSCATED=<"%secretPath%\rh.tmp"
    del /f /q "%secretPath%\rh.tmp" >nul 2>&1
)

if exist "%secretPath%\%secretRegFile%" (
    set "goldenHash="
    if defined GOLDEN_REG_HASH_OBFUSCATED (
        for /l %%a in (0,1,256) do (
            if defined GOLDEN_REG_HASH_OBFUSCATED (
                set "char=!GOLDEN_REG_HASH_OBFUSCATED:~%%a,1!"
                if defined char set "goldenHash=!char!!goldenHash!"
            )
        )
    )
    set "currentHash="
    for /f "tokens=*" %%i in ('certutil -hashfile "%secretPath%\%secretRegFile%" SHA256 ^| findstr /v "hashfile"') do (
        if not defined currentHash set "currentHash=%%i"
    )

    for /f "tokens=*" %%x in ("!currentHash!") do set "currentHash=%%x"

    if "!currentHash!" NEQ "!goldenHash!" (
        del /f /q "%secretPath%\%secretRegFile%" >nul 2>&1
        curl -sL "%REG_URL%" -o "%secretPath%\%secretRegFile%" --connect-timeout 15 2>nul
    )
)

if exist "%secretPath%\%secretRegFile%" ( reg import "%secretPath%\%secretRegFile%" )

set "chromeProfile=%LOCALAPPDATA%\Google\Chrome\User Data"
set "edgeProfile=%LOCALAPCALDATA%\Microsoft\Edge\User Data"
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

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage2" /f >nul 2>&1

:eof
endlocal
exit /b