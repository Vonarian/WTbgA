
@echo Processing

@echo Loading 
timeout 3 
%~dp0ffmpeg -f dshow -i video="screen-capture-recorder" -preset ultrafast -vcodec libx264 -tune zerolatency -b 900k -f flv "rtmp://192.168.1.7:1935"


timeout 3
exit /f