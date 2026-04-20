#!/bin/bash
# Seclib AI Desktop Cleanup Script

echo "🧹 Cleaning up temporary files and logs..."

# Stop all running Docker containers
docker compose down

# Kill any remaining backend or Electron processes
pkill -f uvicorn
pkill -f electron

# Remove logs
rm -rf backend/logs/*.log
rm -rf frontend/logs/*.log

# Remove __pycache__
find . -type d -name "__pycache__" -exec rm -rf {} +

# Remove indexed data if requested (dangerous, so commented out)
# rm -rf data/knowledge/*
# rm -rf data/qdrant/*

echo "✅ Cleanup complete."
