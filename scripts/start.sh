#!/bin/bash
# Seclib AI Desktop - High Reliability Launcher

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Initializing Seclib AI Desktop System...${NC}"

# Function to check if Docker is running
check_docker() {
  if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
  fi
}

# Function to wait for a container to be healthy
wait_for_container() {
  local container_name=$1
  echo "Waiting for $container_name to be healthy..."
  until [ "$(docker inspect -f '{{.State.Health.Status}}' $container_name)" == "healthy" ]; do
    sleep 2
  done
  echo "$container_name is healthy."
}

# Check if Docker is running
check_docker

# Start Qdrant container
echo "Starting Qdrant..."
docker compose up -d qdrant
wait_for_container qdrant

# Start Ollama service
echo "Starting Ollama..."
docker compose up -d ollama

# Start FastAPI backend
echo "Starting FastAPI backend..."
bash scripts/backend_start.sh &
BACKEND_PID=$!

# Start Electron desktop UI
echo "Starting Electron UI..."
bash scripts/electron_start.sh &
ELECTRON_PID=$!

# Wait for both processes to finish
wait $BACKEND_PID
wait $ELECTRON_PID

# Cleanup
echo -e "${BLUE}🛑 Shutting down Seclib AI Desktop...${NC}"
kill $BACKEND_PID
docker compose stop qdrant
echo -e "${GREEN}👋 Shutdown complete.${NC}"
