@echo off
tasklist /fi "ImageName eq aces.exe" /fo csv 2>NUL | find /I "aces.exe">NUL
IF "%ERRORLEVEL%"=="0" (
echo aces.exe
) ELSE (
echo omg
)
