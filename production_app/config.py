import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Production Configuration"""
    # Server
    HOST = os.getenv('HOST', '0.0.0.0')
    PORT = int(os.getenv('PORT', 8005))
    WORKERS = int(os.getenv('WORKERS', 4))
    
    # FastAPI
    DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'info')
    
    # CORS
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', '*').split(',')
    
    # Device
    DEVICE_TYPE = os.getenv('DEVICE_TYPE', 'auto')
    
    # Model paths
    EMOTION_MODEL_PATH = os.getenv('EMOTION_MODEL_PATH', './models/best_model_dcnn_dam.pth')
    YOLO_MODEL = os.getenv('YOLO_MODEL', 'yolov8n.pt')
    AGE_MODEL = os.getenv('AGE_MODEL', 'nateraw/vit-age-classifier')
    
    # Performance
    MAX_UPLOAD_SIZE = int(os.getenv('MAX_UPLOAD_SIZE', 10485760))  # 10MB
    REQUEST_TIMEOUT = int(os.getenv('REQUEST_TIMEOUT', 30))
