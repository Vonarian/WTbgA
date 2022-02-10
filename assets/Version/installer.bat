@echo off
SET currentDirectory=%~dp0
PUSHD %CD%
CD ..
CD ..
CD ..
SET MNIST_DIR=%CD%
POPD
ECHO %MNIST_DIR%
  @timeout 2 /nobreak >NUL
  @echo Proceeding to update the application, please do not close the window!
taskkill /F /IM wtbgassistant.exe
@echo on
powershell.exe Add-AppPackage -path %MNIST_DIR%\out\WTbgA.msix
timeout 5
