#!/bin/bash
set -e

APP_DIR="/opt/myapp"

echo "============================================"
echo "  DEPLOY STAGE"
echo "============================================"

echo "[1/5] Preparing system dependencies..."

# Install python venv if missing
if ! python3 -m venv testenv 2>/dev/null; then
    echo "[FIX] Installing python3-venv..."
    sudo apt update
    sudo apt install -y python3-venv
else
    echo "[OK] python3-venv already installed"
fi
rm -rf testenv

echo "[2/5] Creating app directory..."
mkdir -p $APP_DIR

echo "[3/5] Installing dependencies..."
cd $APP_DIR

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip --quiet
pip install flask --quiet

echo "[4/5] Restarting application..."
pkill -f "python3.*app.py" 2>/dev/null || true
sleep 1

nohup python3 app/app.py > /tmp/myapp.log 2>&1 &
echo $! > /tmp/myapp.pid

echo "[5/5] Verifying deployment..."
sleep 2

if curl -s http://localhost:5000/health | grep -q "healthy"; then
    echo "✅ App is running and healthy!"
else
    echo "⚠️ WARNING: Health check failed — check /tmp/myapp.log"
fi

echo "Deploy complete!"
