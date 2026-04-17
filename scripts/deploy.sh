#!/bin/bash
set -e

APP_DIR="/opt/myapp"
SERVICE_NAME="myapp"

echo "============================================"
echo "  DEPLOY STAGE"
echo "============================================"

echo "[1/4] Creating app directory..."
mkdir -p $APP_DIR
mkdir -p $APP_DIR/app

echo "[2/4] Copying application files..."
cp -r app/ $APP_DIR/
cp scripts/build.sh $APP_DIR/ 2>/dev/null || true

echo "[3/4] Installing dependencies..."
cd $APP_DIR
python3 -m venv venv
source venv/bin/activate
pip install flask --quiet

echo "[4/4] Restarting application..."
pkill -f "python3.*app.py" 2>/dev/null || true
sleep 1
nohup python3 app/app.py > /tmp/myapp.log 2>&1 &
echo $! > /tmp/myapp.pid

sleep 2
if curl -s http://localhost:5000/health | grep -q "healthy"; then
    echo "App is running and healthy!"
else
    echo "WARNING: Health check failed — check /tmp/myapp.log"
fi

echo "Deploy complete!"
