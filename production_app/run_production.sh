#!/bin/bash

# ===========================================================
# AI Expression Analyzer - Production Server Launcher
# Linux/macOS Version
# ===========================================================

set -e

echo "============================================================="
echo "  AI Expression Analyzer - Production Deployment"
echo "============================================================="
echo ""

# Change to script directory
cd "$(dirname "$0")"

# ============= STEP 1: Check Python =============
echo "[STEP 1/4] Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 is not installed."
    echo "[INFO] Please install Python 3.10+ from https://www.python.org"
    exit 1
fi
PYTHON_VERSION=$(python3 --version | awk '{print $2}')
echo "[SUCCESS] Python $PYTHON_VERSION found"
echo ""

# ============= STEP 2: Setup Virtual Environment =============
echo "[STEP 2/4] Setting up virtual environment..."
if [ ! -d "venv" ]; then
    echo "[INFO] Creating new virtual environment..."
    python3 -m venv venv
else
    echo "[INFO] Virtual environment already exists"
fi

# Activate venv
source venv/bin/activate
echo "[SUCCESS] Virtual environment activated"
echo ""

# ============= STEP 3: Install Dependencies =============
echo "[STEP 3/4] Installing production dependencies..."
echo "[INFO] This may take 5-10 minutes..."
echo ""

pip install --upgrade pip setuptools wheel 2>&1 | tail -5
pip install -r requirements-production.txt 2>&1 | tail -10

echo ""
echo "[SUCCESS] Dependencies installed"
echo ""

# ============= STEP 4: Setup Environment File =============
echo "[STEP 4/4] Configuring environment..."
if [ ! -f ".env" ]; then
    echo "[WARNING] .env file not found"
    echo "[INFO] Creating .env from template..."
    cp .env.example .env
    echo "[WARNING] Please edit .env with your settings:"
    echo "    - CORS_ORIGINS for your domain"
    echo "    - DEVICE_TYPE (auto/cuda/cpu/mps)"
    echo "    - WORKERS based on your CPU cores"
    echo ""
else
    echo "[SUCCESS] .env file found"
fi
echo ""

# ============= LAUNCH PRODUCTION SERVER =============
echo "============================================================="
echo "  LAUNCHING PRODUCTION SERVER"
echo "============================================================="
echo ""

echo "Configuration:"
echo "  Host: $(grep '^HOST=' .env | cut -d= -f2 || echo '0.0.0.0')"
echo "  Port: $(grep '^PORT=' .env | cut -d= -f2 || echo '8005')"
echo "  Workers: $(grep '^WORKERS=' .env | cut -d= -f2 || echo '4')"
echo "  Log Level: $(grep '^LOG_LEVEL=' .env | cut -d= -f2 || echo 'info')"
echo ""

echo "Starting Gunicorn with uvicorn workers..."
echo "Dashboard: http://localhost:8005"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Get config from .env
HOST=$(grep '^HOST=' .env | cut -d= -f2 || echo '0.0.0.0')
PORT=$(grep '^PORT=' .env | cut -d= -f2 || echo '8005')
WORKERS=$(grep '^WORKERS=' .env | cut -d= -f2 || echo '4')
LOG_LEVEL=$(grep '^LOG_LEVEL=' .env | cut -d= -f2 || echo 'info')

# Launch Gunicorn
gunicorn \
    --workers=$WORKERS \
    --worker-class=uvicorn.workers.UvicornWorker \
    --bind=$HOST:$PORT \
    --log-level=$LOG_LEVEL \
    --access-logfile=- \
    --error-logfile=- \
    --timeout=30 \
    --graceful-timeout=30 \
    wsgi:app
