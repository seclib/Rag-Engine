#!/bin/bash
# Seclib AI Desktop - High Reliability Launcher

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Initializing Seclib AI Desktop System...${NC}"

# --- STEP 1: Check Docker ---
echo -e "${BLUE}[1/5] Checking Docker daemon...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker is active.${NC}"

# --- STEP 2: Start Qdrant ---
echo -e "${BLUE}[2/5] Starting Qdrant Vector Database...${NC}"
docker compose up -d qdrant

echo -e "${YELLOW}⏳ Waiting for Qdrant health check...${NC}"
for i in {1..30}; do
    HEALTH=$(docker inspect --format='{{json .State.Health.Status}}' seclib-qdrant 2>/dev/null)
    if [ "$HEALTH" == "\"healthy\"" ]; then
        echo -e "${GREEN}✅ Qdrant is healthy.${NC}"
        break
    fi
    sleep 2
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ Qdrant failed to become healthy.${NC}"
        docker compose logs qdrant
        exit 1
    fi
done

# --- STEP 3: Check Ollama ---
echo -e "${BLUE}[3/5] Verifying Ollama local service...${NC}"
if ! curl -s http://localhost:11434/api/tags > /dev/null; then
    echo -e "${RED}❌ Ollama service not found at localhost:11434.${NC}"
    echo -e "${YELLOW}💡 Tip: Run 'ollama serve' in another terminal.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Ollama detected.${NC}"

# --- STEP 4: Start Backend ---
echo -e "${BLUE}[4/5] Starting Seclib Backend API...${NC}"
# Setup env if missing
if [ ! -d "backend/env" ]; then
    python3 -m venv backend/env
    source backend/env/bin/activate
    pip install -r backend/requirements.txt
fi

./scripts/backend_start.sh > backend/logs/out.log 2>&1 &
BACKEND_PID=$!

echo -e "${YELLOW}⏳ Waiting for Backend to be ready...${NC}"
for i in {1..20}; do
    if curl -s http://localhost:8000/ > /dev/null; then
        echo -e "${GREEN}✅ Backend is up.${NC}"
        break
    fi
    sleep 1
    if [ $i -eq 20 ]; then
        echo -e "${RED}❌ Backend failed to start.${NC}"
        kill $BACKEND_PID
        exit 1
    fi
done

# --- STEP 5: Launch UI ---
echo -e "${BLUE}[5/5] Launching Desktop Application...${NC}"
./scripts/electron_start.sh

# Cleanup
echo -e "${BLUE}🛑 Shutting down Seclib AI Desktop...${NC}"
kill $BACKEND_PID
docker compose stop qdrant
echo -e "${GREEN}👋 Shutdown complete.${NC}"
