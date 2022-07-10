@echo off
taskkill /F /IM wtbgassistant.exe
set arg1=%1
powershell.exe Add-AppPackage -Path '%arg1%\out\WTbgA.msix'
timeout 3
powershell.exe start "shell:AppsFolder\$(Get-AppxPackage 'WTbgA' | select -ExpandProperty PackageFamilyName)!wtbgassistant"