@echo off
SETLOCAL EnableDelayedExpansion

:: ===========================================================
::   AI Expression Analyzer - Enterprise Installer
:: ===========================================================

:: --- CRITICAL FIX: Change to the directory where this script lives ---
cd /d "%~dp0"

:: --- STEP 0: REQUEST ADMIN RIGHTS ---
echo [SYSTEM] Checking for Administrator Privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [SYSTEM] Requesting elevated permissions...
    powershell -Command "Start-Process cmd -ArgumentList '/c cd /d ""%~dp0"" && ""%~f0""' -Verb RunAs"
    exit /b
)

echo ===========================================================
echo   AI Expression Analyzer - High-Performance Setup
echo ===========================================================
echo.

:: --- STEP 1: CHECK/INSTALL PYTHON ---
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ALERT] Python is not installed on this system.
    echo [SYSTEM] Initiating automated Python 3.10 installation...
    
    set "PYTHON_URL=https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe"
    set "INSTALLER_NAME=%TEMP%\python_installer.exe"
    
    echo [DOWNLOAD] Fetching Python installer from official servers...
    curl -L "%PYTHON_URL%" -o "%INSTALLER_NAME%"
    
    echo [INSTALL] Running silent installation (Pre-pending to PATH)...
    start /wait "%INSTALLER_NAME%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    
    del "%INSTALLER_NAME%"
    
    echo [SUCCESS] Python installed. RESTARTING script to refresh system PATH...
    timeout /t 3
    start "" "%~f0"
    exit /b
)

:: --- STEP 2: CREATE VIRTUAL ENVIRONMENT ---
if not exist "venv\" (
    echo [STEP 1/3] Creating isolated AI Virtual Environment...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create virtual environment. Exiting.
        pause
        exit /b 1
    )
)

:: --- STEP 3: INSTALL DEPENDENCIES ---
echo [STEP 2/3] Downloading Deep Learning Dependencies...
echo This may take several minutes depending on your internet speed.
echo.

:: Use the venv Python/pip directly to avoid activation issues
set "VENV_PYTHON=%~dp0venv\Scripts\python.exe"
set "VENV_PIP=%~dp0venv\Scripts\pip.exe"

"%VENV_PYTHON%" -m pip install --upgrade pip
if %errorlevel% neq 0 (
    echo [ERROR] Failed to upgrade pip. Exiting.
    pause
    exit /b 1
)

"%VENV_PIP%" install -r requirements.txt
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies. Check your internet connection.
    pause
    exit /b 1
)

:: --- STEP 4: RUN APPLICATION ---
echo.
echo [STEP 3/3] Launching Production Neural Network Server...
echo.
echo ===========================================================
echo   DASHBOARD READY: http://127.0.0.1:8005
echo ===========================================================
echo.

:: Launch browser automatically (slight delay so the server starts first)
timeout /t 3 /nobreak >nul
start "" "http://127.0.0.1:8005"

:: Run uvicorn through the venv Python
"%VENV_PYTHON%" -m uvicorn main:app --host 127.0.0.1 --port 8005

pause
