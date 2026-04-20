@echo off
REM Seclib AI Desktop - Windows Post-Installation Setup
REM This script runs after installation to set up the environment

echo Setting up Seclib AI Desktop...

REM Change to installation directory
cd /d "%~dp0.."

REM Create virtual environment
echo Creating Python virtual environment...
python -m venv env
call env\Scripts\activate.bat

REM Install Python dependencies
echo Installing Python dependencies...
pip install --upgrade pip
pip install -r requirements.txt

REM Set up data directories
echo Setting up data directories...
if not exist data mkdir data
if not exist data\qdrant_storage mkdir data\qdrant_storage
if not exist data\ollama_storage mkdir data\ollama_storage
if not exist logs mkdir logs

REM Create desktop shortcut if it doesn't exist
echo Creating desktop shortcut...
if not exist "%USERPROFILE%\Desktop\Seclib AI Desktop.lnk" (
    powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%USERPROFILE%\Desktop\Seclib AI Desktop.lnk');$s.TargetPath='%~dp0..\Seclib AI Desktop.exe';$s.Save()"
)

REM Check for Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Docker not found. Please install Docker Desktop for full functionality.
    echo You can download it from: https://www.docker.com/products/docker-desktop
)

REM Check for Ollama
ollama --version >nul 2>&1
if %errorlevel% neq 0 (
    echo INFO: Ollama not found. Installing Ollama...
    REM Download and install Ollama
    powershell -Command "& {Invoke-WebRequest -Uri https://ollama.ai/download/OllamaSetup.exe -OutFile $env:TEMP\OllamaSetup.exe}"
    start /wait "" "%TEMP%\OllamaSetup.exe" /S
    del "%TEMP%\OllamaSetup.exe"
)

echo Setup completed successfully!
echo.
echo You can now launch Seclib AI Desktop from the desktop shortcut.
echo.
pause