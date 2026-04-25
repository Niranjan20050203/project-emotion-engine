"""WSGI entry point for Gunicorn production server"""
import os
import sys
from pathlib import Path

# Add the production_app directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

from main import app

if __name__ == "__main__":
    # For direct execution (not recommended in production)
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8005,
        reload=False,
        access_log=True,
        log_level="info"
    )
