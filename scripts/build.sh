#!/bin/bash
set -e   # Exit immediately on any error

echo "============================================"
echo "  BUILD STAGE"
echo "============================================"

echo "[1/3] Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "[2/3] Installing dependencies..."
pip install flask pytest --quiet

echo "[3/3] Creating deployment package..."
mkdir -p dist
zip -r dist/app-package.zip app/ scripts/ requirements.txt \
    --exclude "*.pyc" --exclude "__pycache__/*"

echo "Build complete — dist/app-package.zip created"
