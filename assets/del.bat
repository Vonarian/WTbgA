del /f %~dp0output.mkv
%~dp0ffmpeg.exe -f dshow -i video="screen-capture-recorder" %~dp0\output.mkv
exit /b