@echo off
:: BatchGotAdmin
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

@for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr [') do set NetworkIP=%%a
@echo Network IP: %NetworkIP%

@echo FOUND FFMPEG.EXE
  @timeout 1 /nobreak >NUL
  @echo Loading...

  @timeout 1 /nobreak >NUL

@echo Starting Server...

start cmd.exe /c "%~dp0\mona\MonaTiny.exe"
@timeout 1 /nobreak >NUL
@echo Starting Stream...
@timeout 2 /nobreak >NUL
start cmd.exe /c "%~dp0ffmpeg.exe" -f gdigrab -framerate 45 -i desktop -c:v libx264 -b:v 2M -maxrate 4M -bufsize 3M -crf 18 -pix_fmt yuv420p -tune zerolatency -preset ultrafast -f flv rtmp://%NetworkIP%:1935