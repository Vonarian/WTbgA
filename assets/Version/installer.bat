@echo off
taskkill /F /IM WTbgA.exe
set arg1=%1
powershell.exe Add-AppPackage -Path '%arg1%\out\WTbgA.msix'
timeout 3
if exist '%userprofile%\Start Menu\Programs\Startup\WTbgA.lnk' (
SET currentDirectory=%~dp0
PUSHD %currentDirectory%
CD ..
CD ..
CD ..
CD ..
SET MNIST_DIR=%CD%
SET appExeDir=%MNIST_DIR%
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Start Menu\Programs\Startup\WTbgA.lnk');$s.TargetPath='%appExeDir%\WTbgA.exe';$s.Arguments='connect';$s.IconLocation='%userprofile%\Start Menu\Programs\WTbgA.lnk';$s.WorkingDirectory='%appExeDir%';$s.WindowStyle=7;$s.Save()"
)
powershell.exe Start-Process -FilePath 'WTbgA.exe' -WorkingDirectory "(Get-AppxPackage -Name 'WTbgA').InstallLocation"