#!/bin/bash

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
NC="\033[0m" # No Color

# Helper function to print status messages
print_status() {
  echo -e "${GREEN}[✔]${NC} $1"
}

print_error() {
  echo -e "${RED}[✘]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[!]${NC} $1"
}

# Step 1: Check system dependencies
print_status "Checking system dependencies..."
if ! command -v docker &> /dev/null; then
  print_error "Docker is not installed. Please install Docker and try again."
  exit 1
fi

if ! command -v node &> /dev/null; then
  print_error "Node.js is not installed. Please install Node.js and try again."
  exit 1
fi

if ! command -v python3 &> /dev/null; then
  print_error "Python3 is not installed. Please install Python3 and try again."
  exit 1
fi

if ! docker info &> /dev/null; then
  print_error "Docker is not running. Please start Docker and try again."
  exit 1
fi
print_status "All dependencies are installed and running."

# Step 2: Start Docker Compose stack
print_status "Starting Docker Compose stack..."
docker compose up -d
if [ $? -ne 0 ]; then
  print_error "Failed to start Docker Compose stack. Check your docker-compose.yml file."
  exit 1
fi

# Step 3: Wait for Qdrant readiness
QDRANT_HEALTH_URL="http://localhost:6333/healthz"
TIMEOUT=60
SECONDS=0
print_status "Waiting for Qdrant to become healthy..."
while ! curl -fs $QDRANT_HEALTH_URL &> /dev/null; do
  if [ $SECONDS -ge $TIMEOUT ]; then
    print_error "Qdrant did not become healthy within $TIMEOUT seconds."
    exit 1
  fi
  sleep 2
done
print_status "Qdrant is healthy."

# Step 4: Start FastAPI backend
print_status "Starting FastAPI backend..."
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
cd ..

# Step 5: Start Electron desktop application
print_status "Starting Electron desktop application..."
cd frontend
npm start &
ELECTRON_PID=$!
cd ..

# Wait for processes to finish
wait $BACKEND_PID
wait $ELECTRON_PID

print_status "Seclib AI Desktop started successfully."