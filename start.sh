#!/bin/bash
# ==============================================================================
# Seclib AI Desktop - High Reliability Production Startup & Watchdog
# ==============================================================================

# Configuration
API_PORT=8000
QDRANT_URL="http://localhost:6333/healthz"
BACKEND_URL="http://localhost:8000/"
LOG_DIR="backend/logs"
CHECK_INTERVAL=5

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🛡️  Seclib AI Desktop: High Reliability Mode${NC}"

# 1. PRE-FLIGHT
echo -e "${BLUE}[1/4] Running pre-flight checks...${NC}"
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker missing.${NC}"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo -e "${RED}NPM missing.${NC}"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo -e "${RED}Python missing.${NC}"; exit 1; }

# 2. START DATABASE
echo -e "${BLUE}[2/4] Starting database stack...${NC}"
docker compose up -d qdrant --remove-orphans >/dev/null 2>&1

# 3. START BACKEND ENGINE
start_backend() {
    echo -e "${YELLOW}⚙️  Starting AI Backend...${NC}"
    source backend/env/bin/activate
    PYTHONPATH=. uvicorn backend.main:app --host 0.0.0.0 --port $API_PORT --log-level warning > "$LOG_DIR/api.log" 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > .backend.pid
}

echo -e "${BLUE}[3/4] Initializing AI Engine...${NC}"
mkdir -p "$LOG_DIR"
if [ ! -d "backend/env" ]; then
    python3 -m venv backend/env
    source backend/env/bin/activate
    pip install -r backend/requirements.txt >/dev/null 2>&1
fi
start_backend

# 4. START WATCHDOG & UI
echo -e "${BLUE}[4/4] Launching Desktop UI & Watchdog...${NC}"
./scripts/watchdog.sh &
WATCHDOG_PID=$!

cd frontend && npm start >/dev/null 2>&1 &
UI_PID=$!

echo -e "${GREEN}✅ Seclib AI Desktop is healthy and monitored.${NC}"

cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down...${NC}"
    kill $BACKEND_PID 2>/dev/null
    kill $UI_PID 2>/dev/null
    kill $WATCHDOG_PID 2>/dev/null
    docker compose stop qdrant >/dev/null 2>&1
    exit 0
}

trap cleanup SIGINT SIGTERM
wait $UI_PID
cleanup
