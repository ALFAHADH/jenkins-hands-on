#!/bin/bash
set -e

APP_DIR="/opt/myapp"
LOG_FILE="$APP_DIR/myapp.log"
PID_FILE="$APP_DIR/myapp.pid"

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

echo "[3/5] Setting up virtual environment..."
cd $APP_DIR

# Create venv if not exists
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# Install dependencies without activating
venv/bin/pip install --upgrade pip --quiet
venv/bin/pip install flask --quiet

echo "[4/5] Restarting application..."

# Stop existing app if running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat $PID_FILE)
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo "Stopping existing app (PID $OLD_PID)..."
        kill $OLD_PID || true
        sleep 1
    fi
fi

# Start new app
echo "Starting application..."
nohup venv/bin/python app/app.py > $LOG_FILE 2>&1 &
echo $! > $PID_FILE

echo "[5/5] Verifying deployment..."
sleep 2

if curl -s http://localhost:5000/health | grep -q "healthy"; then
    echo "✅ App is running and healthy!"
else
    echo "⚠️ WARNING: Health check failed — check logs at $LOG_FILE"
fi

echo "Deploy complete!"
