@echo off
SETLOCAL EnableDelayedExpansion

REM ===========================================================
REM   AI Expression Analyzer - Production Server Launcher
REM   Windows Version
REM ===========================================================

REM Change to script directory
cd /d "%~dp0"

echo ===========================================================
echo   AI Expression Analyzer - Production Deployment
echo ===========================================================
echo.

REM --- STEP 0: REQUEST ADMIN RIGHTS ---
echo [SYSTEM] Checking for Administrator Privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [SYSTEM] Requesting elevated permissions...
    powershell -Command "Start-Process cmd -ArgumentList '/c cd /d ""%~dp0"" && ""%~f0""' -Verb RunAs"
    exit /b
)

REM --- STEP 1: CHECK PYTHON ---
echo [STEP 1/4] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH.
    echo [INFO] Please install Python 3.10+ from https://www.python.org
    echo [INFO] Make sure to check 'Add Python to PATH' during installation
    pause
    exit /b 1
)
python --version
echo [SUCCESS] Python found
echo.

REM --- STEP 2: CREATE VIRTUAL ENVIRONMENT ---
echo [STEP 2/4] Setting up virtual environment...
if not exist "venv\" (
    echo [INFO] Creating new virtual environment...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
) else (
    echo [INFO] Virtual environment already exists
)
echo [SUCCESS] Virtual environment ready
echo.

REM --- STEP 3: INSTALL DEPENDENCIES ---
echo [STEP 3/4] Installing production dependencies...
echo [INFO] This may take 5-10 minutes...
echo.

set "VENV_PYTHON=%~dp0venv\Scripts\python.exe"
set "VENV_PIP=%~dp0venv\Scripts\pip.exe"

"%VENV_PYTHON%" -m pip install --upgrade pip setuptools wheel
if %errorlevel% neq 0 (
    echo [ERROR] Failed to upgrade pip.
    pause
    exit /b 1
)

"%VENV_PIP%" install -r requirements-production.txt
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies.
    echo [INFO] Check your internet connection and try again.
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Dependencies installed
echo.

REM --- STEP 4: SETUP ENVIRONMENT ---
echo [STEP 4/4] Configuring environment...
if not exist ".env" (
    echo [WARNING] .env file not found
    echo [INFO] Creating .env from template...
    copy .env.example .env
    echo [WARNING] Please edit .env with your settings:
    echo   - CORS_ORIGINS for your domain
    echo   - DEVICE_TYPE (auto/cuda/cpu/mps)
    echo   - WORKERS based on your CPU cores
    echo.
) else (
    echo [SUCCESS] .env file found
)
echo.

REM --- LAUNCH PRODUCTION SERVER ---
echo ===========================================================
echo   LAUNCHING PRODUCTION SERVER (GUNICORN)
echo ===========================================================
echo.

echo Dashboard: http://localhost:8005
echo Press Ctrl+C to stop
echo.

REM Run Gunicorn through venv Python
"%VENV_PYTHON%" -m gunicorn ^^
    --workers=4 ^^
    --worker-class=uvicorn.workers.UvicornWorker ^^
    --bind=0.0.0.0:8005 ^^
    --log-level=info ^^
    --access-logfile=- ^^
    --error-logfile=- ^^
    --timeout=30 ^^
    wsgi:app

pause
