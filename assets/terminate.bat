@echo off
@echo Stopping Stream
taskkill /f /im MonaTiny.exe  >NUL
taskkill /f /im del.bat  >NUL
taskkill /f /im ffmpeg.exe  >NUL
@timeout 1 /nobreak >NUL
exit /f