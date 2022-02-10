@echo off
@for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr [') do set NetworkIP=%%a
@echo Network IP: %NetworkIP%
goto main
:main
IF EXIST "%~dp0\ffmpeg.exe" (
@echo FOUND FFMPEG.EXE
  @timeout 1 /nobreak >NUL
  @echo Loading...


@echo Starting Server...

start /IM  %~dp0\mona\MonaTiny.exe
@timeout 1 /nobreak >NUL
@echo Starting Stream...
@timeout 2 /nobreak >NUL
%~dp0/ffmpeg -f gdigrab -framerate 30 -i desktop -c:v libx264 -b:v 2M -maxrate 4M -bufsize 3M -crf 18 -pix_fmt yuv420p -tune zerolatency -preset ultrafast -f flv rtmp://%NetworkIP%:1935


@timeout 2 /nobreak >NUL
exit /f
) ELSE (
@echo FFMPEG.EXE NOT FOUND, COPYING
    xcopy /s /y "%SystemDrive%\Program Files (x86)\Screen Capturer Recorder\configuration_setup_utility\vendor\ffmpeg\bin\ffmpeg.exe" .\data\flutter_assets\assets\
@timeout 2 /nobreak >NUL
goto main
)
