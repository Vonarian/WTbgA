@echo off
@for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr [') do set NetworkIP=%%a
@echo Network IP: %NetworkIP%
goto main
:main
IF EXIST ".\data\flutter_assets\assets\ffmpeg.exe" (
@echo FOUND FFMPEG.EXE
  @timeout 1 /nobreak >NUL
  @echo Loading...


@echo Starting Server...

@start cmd /k .\data\flutter_assets\assets\mona\MonaTiny.exe
@timeout 1 /nobreak >NUL
@echo Starting Stream...
@timeout 2 /nobreak >NUL
.\data\flutter_assets\assets\ffmpeg.exe -f dshow -rtbufsize 150M -filter:v fps=fps=30 -i video="screen-capture-recorder":audio="virtual-audio-capturer" -vf "scale=1600:900" -r 30 -preset ultrafast -vcodec libx264 -tune zerolatency -b 2M -b:v 2M -ab 128k -ac 2 -ar 44100 -async 44100 -f flv "rtmp://%NetworkIP%:1935"


@timeout 2 /nobreak >NUL
exit /f
) ELSE (
@echo FFMPEG.EXE NOT FOUND, COPYING
    xcopy /s /y "C:\Program Files (x86)\Screen Capturer Recorder\configuration_setup_utility\vendor\ffmpeg\bin\ffmpeg.exe" .\data\flutter_assets\assets\
goto main
)
