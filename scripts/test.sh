#!/bin/bash
set -e

echo "============================================"
echo "  TEST STAGE"
echo "============================================"

source venv/bin/activate

echo "[1/2] Running unit tests..."
python3 -m pytest tests/ -v --tb=short

echo "[2/2] Checking syntax..."
python3 -m py_compile app/app.py
echo "Syntax check passed"

echo "All tests passed!"
