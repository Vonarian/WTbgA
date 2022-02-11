@echo off
@for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr [') do set NetworkIP=%%a
@echo Network IP: %NetworkIP%

@echo FOUND FFMPEG.EXE
  @timeout 1 /nobreak >NUL
  @echo Loading...

  @timeout 1 /nobreak >NUL

@echo Starting Server...

start cmd.exe /c  "%~dp0\mona\MonaTiny.exe"
@timeout 1 /nobreak >NUL
@echo Starting Stream...
@timeout 2 /nobreak >NUL
"%~dp0/ffmpeg.exe" -f gdigrab -framerate 45 -i desktop -c:v libx264 -b:v 2M -maxrate 4M -bufsize 3M -crf 18 -pix_fmt yuv420p -tune zerolatency -preset ultrafast -f flv rtmp://%NetworkIP%:1935