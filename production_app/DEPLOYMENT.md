# Deployment Guide: AI Expression Analyzer

## Table of Contents
1. [Quick Start](#quick-start)
2. [Local Deployment](#local-deployment)
3. [Docker Deployment](#docker-deployment)
4. [Cloud Deployment](#cloud-deployment)
5. [Configuration](#configuration)
6. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Windows
```batch
cd production_app
run_production.bat
```

### Linux/macOS
```bash
cd production_app
chmod +x run_production.sh
./run_production.sh
```

### Docker (Recommended)
```bash
docker-compose up -d
```

---

## Local Deployment

### Windows Production Setup

1. **Run the production script**:
   ```batch
   cd production_app
   run_production.bat
   ```

2. **Configure environment** (edit `.env` file):
   ```env
   HOST=0.0.0.0
   PORT=8005
   WORKERS=4
   CORS_ORIGINS=https://yourdomain.com
   DEVICE_TYPE=cuda  # or cpu, auto, mps
   ```

3. **Access the application**:
   - Dashboard: `http://localhost:8005`
   - API Docs: `http://localhost:8005/docs`
   - ReDoc: `http://localhost:8005/redoc`

### Linux/macOS Production Setup

1. **Run the production script**:
   ```bash
   cd production_app
   chmod +x run_production.sh
   ./run_production.sh
   ```

2. **Configure environment**:
   ```bash
   cp .env.example .env
   nano .env  # Edit as needed
   ```

3. **Restart the service**:
   ```bash
   ./run_production.sh
   ```

### Performance Tuning

**Number of Workers**: Set based on your CPU cores
```bash
WORKERS=$(nproc)  # Linux: auto-detect CPU cores
WORKERS=4         # Default: 4 workers
WORKERS=8         # High-traffic: 8+ workers
```

**Device Selection**:
```env
DEVICE_TYPE=auto   # Automatically select CUDA > MPS > CPU
DEVICE_TYPE=cuda   # NVIDIA GPU (fastest)
DEVICE_TYPE=mps    # Apple Metal Performance Shaders
DEVICE_TYPE=cpu    # CPU only (slowest)
```

---

## Docker Deployment

### Build and Run with Docker Compose

```bash
# Navigate to production_app directory
cd production_app

# Build image
docker-compose build

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f emotion-engine

# Stop
docker-compose down
```

### With Nginx Proxy (SSL/TLS)

```bash
# Start with Nginx proxy
docker-compose --profile proxy up -d

# Generate SSL certificates (Let's Encrypt)
from production_app root:
certbot certonly --standalone -d yourdomain.com

# Copy certificates
mkdir -p ssl
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem

# Restart Nginx
docker-compose --profile proxy restart nginx
```

### Docker Commands Reference

```bash
# View running containers
docker-compose ps

# Execute command in container
docker-compose exec emotion-engine bash

# View resource usage
docker stats emotion-engine

# Scale workers (in docker-compose.yml, change WORKERS env var)
docker-compose restart emotion-engine
```

---

## Cloud Deployment

### AWS EC2

#### Step 1: Launch Instance
1. Go to [AWS EC2 Console](https://console.aws.amazon.com/ec2/)
2. Click "Launch Instance"
3. Select:
   - AMI: Ubuntu 22.04 LTS (Free tier eligible)
   - Instance Type: t3.medium (or t3.small for dev)
   - Storage: 50 GB gp3
4. Configure Security Group:
   - Allow SSH (Port 22) from your IP
   - Allow HTTP (Port 80)
   - Allow HTTPS (Port 443)

#### Step 2: Connect & Deploy

```bash
# SSH into instance
ssh -i your-key.pem ubuntu@your-ec2-instance.com

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Clone repository
git clone https://github.com/Niranjan20050203/project-emotion-engine.git
cd project-emotion-engine/production_app

# Configure environment
cp .env.example .env
nano .env  # Edit with your settings

# Start with Docker Compose
docker-compose up -d

# Verify
curl http://localhost:8005/docs
```

#### Step 3: Setup SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Generate certificate
sudo certbot certonly --standalone -d yourdomain.com

# Copy to docker volume
mkdir -p ssl
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem

# Enable Nginx proxy
docker-compose --profile proxy up -d
```

#### Step 4: Auto-renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Add to crontab (runs daily)
sudo crontab -e
# Add: 0 12 * * * certbot renew --quiet && cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem /path/to/ssl/cert.pem
```

#### Estimated Costs
- **EC2 t3.small**: ~$8/month
- **Data Transfer**: ~$1-5/month
- **Total**: $10-15/month

---

### Heroku Deployment

#### Step 1: Setup Heroku CLI

```bash
# Install Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# Login
heroku login

# Create app
heroku create your-emotion-engine
```

#### Step 2: Configure Procfile

Create `production_app/Procfile`:
```
web: gunicorn --workers=4 --worker-class=uvicorn.workers.UvicornWorker --bind=0.0.0.0:$PORT wsgi:app
```

#### Step 3: Deploy

```bash
# Add remote
git remote add heroku https://git.heroku.com/your-emotion-engine.git

# Deploy
git push heroku main

# View logs
heroku logs -t
```

#### Estimated Costs
- **Dyno (1x)**: $7/month (free tier available)
- **Total**: $7+/month

---

### Railway Deployment (Simplest!)

#### Step 1: Connect Repository

1. Go to [Railway.app](https://railway.app)
2. Click "Deploy from GitHub"
3. Select your repository
4. Authorize Railway

#### Step 2: Configure

```yaml
# railway.toml in project root
[build]
builder = "dockerfile"
dockerfilePath = "production_app/Dockerfile"

[deploy]
startCommand = "gunicorn --workers=4 --worker-class=uvicorn.workers.UvicornWorker --bind=0.0.0.0:$PORT wsgi:app"
port = 8005
```

#### Step 3: Environment Variables

In Railway Dashboard:
```env
HOST=0.0.0.0
PORT=8005
WORKERS=4
CORS_ORIGINS=*.railway.app
DEVICE_TYPE=cpu
```

#### Step 4: Deploy

- Railway auto-deploys on git push
- View logs in dashboard
- App runs at `https://your-project.railway.app`

#### Estimated Costs
- **Railway**: $5/month (free tier: limited)
- **Total**: $5+/month

---

### Google Cloud Run (Serverless)

#### Step 1: Setup

```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash

# Initialize
gcloud init

# Set project
gcloud config set project YOUR_PROJECT_ID
```

#### Step 2: Build & Deploy

```bash
# From project root
cd production_app

# Build
gcloud builds submit --tag gcr.io/$PROJECT_ID/emotion-engine

# Deploy
gcloud run deploy emotion-engine \
  --image gcr.io/$PROJECT_ID/emotion-engine \
  --platform managed \
  --region us-central1 \
  --memory=4Gi \
  --timeout=60 \
  --set-env-vars="WORKERS=4,DEVICE_TYPE=cpu"
```

#### Estimated Costs
- **Cloud Run**: $0.40/million requests + compute
- **Storage**: ~$0.05/GB/month
- **Total**: $5-50/month (usage-dependent)

---

## Configuration

### Environment Variables

```env
# Server
HOST=0.0.0.0                    # Listen address
PORT=8005                        # Port number
WORKERS=4                        # Number of workers
LOG_LEVEL=info                   # Logging level

# CORS
CORS_ORIGINS=*                   # Allowed origins (comma-separated)

# Device
DEVICE_TYPE=auto                 # auto, cuda, cpu, mps

# Models
EMOTION_MODEL_PATH=./models/best_model_dcnn_dam.pth
YOLO_MODEL=yolov8n.pt
AGE_MODEL=nateraw/vit-age-classifier

# Performance
MAX_UPLOAD_SIZE=10485760         # Max upload 10MB
REQUEST_TIMEOUT=30               # Request timeout (seconds)
```

### SSL/TLS Certificates

#### Self-Signed (Testing)
```bash
openssl req -x509 -newkey rsa:4096 -nodes -out ssl/cert.pem -keyout ssl/key.pem -days 365
```

#### Let's Encrypt (Production)
```bash
sudo apt-get install certbot
sudo certbot certonly --standalone -d yourdomain.com
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
```

---

## Troubleshooting

### Port Already in Use
```bash
# Find process using port 8005
lsof -i :8005

# Kill process
kill -9 <PID>

# Or use different port
PORT=8006 ./run_production.sh
```

### Model Loading Fails
```bash
# Check model path
ls -lah models/

# Download if missing
python -c "from transformers import pipeline; pipeline('image-classification', model='nateraw/vit-age-classifier')"
```

### CUDA Not Detected
```bash
# Test CUDA availability
python -c "import torch; print(torch.cuda.is_available())"

# Use CPU instead
DEVICE_TYPE=cpu ./run_production.sh
```

### Out of Memory
```bash
# Reduce workers
WORKERS=2 ./run_production.sh

# Or reduce model batch size in main.py
```

### Docker Container Exits
```bash
# View logs
docker-compose logs emotion-engine

# Rebuild
docker-compose build --no-cache

# Restart
docker-compose restart emotion-engine
```

---

## Monitoring

### Application Health
```bash
# Check endpoint
curl http://localhost:8005/docs

# Monitor logs
for production: tail -f logs/app.log
for docker: docker-compose logs -f
```

### Performance Metrics

```bash
# CPU/Memory usage
for production: top
for docker: docker stats emotion-engine

# Request performance
curl -w "\nTime: %{time_total}s\n" http://localhost:8005/api/predict
```

### Uptime Monitoring

Use external monitoring service:
- [UptimeRobot](https://uptimerobot.com) - Free
- [Pingdom](https://www.pingdom.com) - Paid
- [New Relic](https://newrelic.com) - Paid

---

## Production Checklist

- [ ] Environment variables configured
- [ ] SSL/TLS certificates installed
- [ ] Worker count optimized for CPU cores
- [ ] Model weights downloaded and verified
- [ ] CORS origins restricted to your domain
- [ ] Logging configured and monitored
- [ ] Health checks passing
- [ ] Database backed up (if applicable)
- [ ] Rate limiting enabled
- [ ] Security headers configured
- [ ] Monitoring alerts set up
- [ ] Auto-scaling configured (cloud)

---

## Support

For issues:
1. Check logs: `docker-compose logs emotion-engine`
2. Review troubleshooting section above
3. Check GitHub issues: [project-emotion-engine/issues](https://github.com/Niranjan20050203/project-emotion-engine/issues)
4. Create new issue with logs attached

---

**Happy deploying! 🚀**
