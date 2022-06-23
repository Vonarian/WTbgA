@echo off
taskkill /F /IM wtbgassistant.exe
set arg1=%1
powershell.exe Add-AppPackage -Path '%arg1%\out\WTbgA.msix'
timeout 3
powershell.exe Start-Process -FilePath 'wtbgassistant.exe' -WorkingDirectory "(Get-AppxPackage -Name 'WTbgA').InstallLocation"