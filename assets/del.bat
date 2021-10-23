@echo off

@echo Loading...


for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr [') do set NetworkIP=%%a
@echo Network IP: %NetworkIP%

@echo Starting Server...

start cmd /k .\data\flutter_assets\assets\mona\MonaTiny.exe
@echo Starting Stream...
timeout 3
.\data\flutter_assets\assets\ffmpeg.exe -f dshow -rtbufsize 100M -i video="screen-capture-recorder":audio="virtual-audio-capturer" -vf "scale=1280:720" -r 35 -preset fast -vcodec libx264 -tune zerolatency -b 900k -b:v 900k -ab 128k -ac 2 -ar 44100 -f flv "rtmp://%NetworkIP%:1935"


timeout 3
exit /f