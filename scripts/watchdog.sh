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

# Exponential backoff function
backoff() {
  local attempt=$1
  echo $((2 ** attempt))
}

# Monitor and restart Docker containers
monitor_docker() {
  local container_name=$1
  local attempt=0
  while true; do
    if ! docker ps --filter "name=$container_name" --filter "status=running" | grep -q "$container_name"; then
      print_warning "$container_name is not running. Attempting to restart..."
      docker restart $container_name
      if [ $? -eq 0 ]; then
        print_status "$container_name restarted successfully."
        attempt=0
      else
        print_error "Failed to restart $container_name. Retrying..."
        sleep $(backoff $attempt)
        attempt=$((attempt + 1))
      fi
    fi
    sleep 5
  done
}

# Monitor and restart FastAPI backend
monitor_backend() {
  local attempt=0
  while true; do
    if ! pgrep -f "uvicorn app.main:app" > /dev/null; then
      print_warning "FastAPI backend is not running. Attempting to restart..."
      cd backend
      nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 &> ../logs/backend.log &
      cd ..
      if [ $? -eq 0 ]; then
        print_status "FastAPI backend restarted successfully."
        attempt=0
      else
        print_error "Failed to restart FastAPI backend. Retrying..."
        sleep $(backoff $attempt)
        attempt=$((attempt + 1))
      fi
    fi
    sleep 5
  done
}

# Start monitoring services
print_status "Starting watchdog..."
monitor_docker qdrant &
monitor_backend &
wait
