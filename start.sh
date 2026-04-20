#!/bin/bash
# ==============================================================================
# Seclib AI Desktop - SMART START + AUTO-HEAL DOCKER EDITION
# ==============================================================================

set -e

API_PORT=8000
QDRANT_URL="http://localhost:6333/healthz"
LOG_DIR="backend/logs"
CHECK_INTERVAL=5

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧠 Seclib AI Desktop - SMART MODE${NC}"

# =========================
# 🧠 1. DOCKER AUTO-HEAL
# =========================
echo -e "${BLUE}[1/5] Checking Docker...${NC}"

if ! command -v docker &>/dev/null; then
    echo -e "${RED}❌ Docker not installed${NC}"
    exit 1
fi

if ! docker info &>/dev/null; then
    echo -e "${YELLOW}⚠️ Docker not running - trying to recover...${NC}"

    sudo systemctl start docker || true
    sleep 3

    if ! docker info &>/dev/null; then
        echo -e "${RED}❌ Docker recovery failed${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✔ Docker OK${NC}"

# =========================
# 📦 2. START INFRA (SAFE)
# =========================
echo -e "${BLUE}[2/5] Starting infrastructure...${NC}"

docker compose up -d --remove-orphans || {
    echo -e "${YELLOW}⚠️ Compose failed, retrying...${NC}"
    sleep 2
    docker compose up -d
}

# =========================
# 🧠 3. BACKEND HEALTH CHECK
# =========================
echo -e "${BLUE}[3/5] Starting backend...${NC}"

mkdir -p "$LOG_DIR"

if [ ! -d "backend/env" ]; then
    echo -e "${YELLOW}📦 Creating Python env...${NC}"
    python3 -m venv backend/env
fi

source backend/env/bin/activate
pip install -r backend/requirements.txt >/dev/null 2>&1 || true

start_backend() {
    PYTHONPATH=. uvicorn backend.main:app \
        --host 0.0.0.0 \
        --port $API_PORT \
        --log-level warning > "$LOG_DIR/api.log" 2>&1 &
    echo $! > .backend.pid
}

start_backend

sleep 3

if ! curl -s http://localhost:$API_PORT >/dev/null; then
    echo -e "${YELLOW}⚠️ Backend not responding - restarting...${NC}"
    kill $(cat .backend.pid) 2>/dev/null || true
    start_backend
fi

echo -e "${GREEN}✔ Backend running${NC}"

# =========================
# 🖥️ 4. FRONTEND CHECK
# =========================
echo -e "${BLUE}[4/5] Starting frontend...${NC}"

cd frontend

if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing frontend deps...${NC}"
    npm install
fi

npm start >/dev/null 2>&1 &
UI_PID=$!

cd ..

# =========================
# 🧩 5. WATCHDOG
# =========================
echo -e "${BLUE}[5/5] Starting watchdog...${NC}"

./scripts/watchdog.sh &
WATCHDOG_PID=$!

echo -e "${GREEN}🚀 SYSTEM FULLY OPERATIONAL${NC}"

# =========================
# 🛑 CLEAN EXIT
# =========================
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down system...${NC}"

    kill $WATCHDOG_PID 2>/dev/null || true
    kill $UI_PID 2>/dev/null || true
    kill $(cat .backend.pid) 2>/dev/null || true

    docker compose down >/dev/null 2>&1 || true

    echo -e "${GREEN}✔ Clean shutdown complete${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM
wait $UI_PID
cleanup