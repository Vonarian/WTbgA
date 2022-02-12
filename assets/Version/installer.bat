@echo off
SET currentDirectory=%~dp0
PUSHD %CD%
CD ..
CD ..
CD ..
SET MNIST_DIR=%CD%
ECHO %MNIST_DIR%
  @timeout 2 /nobreak >NUL
  @echo Proceeding to update the application, please do not close the window!
taskkill /F /IM wtbgassistant.exe
@echo "%MNIST_DIR%\out\WTbgA.msix"
powershell.exe Add-AppPackage -Path '%MNIST_DIR%\out\WTbgA.msix'
@echo Installation process complete

timeout 10