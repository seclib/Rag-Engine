#!/bin/bash
# Backend startup script

echo "Starting FastAPI Backend..."
cd backend
# Check if python env exists, if not just run python3
if [ -d "env" ]; then
    source env/bin/activate
fi

# Ensure default skills exist
python3 ../engine/skills.py

# Start Uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000 --log-level warning
