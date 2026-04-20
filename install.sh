#!/bin/bash
# ==============================================================================
# Seclib AI Desktop - Automated Production Installer
# ==============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}   🛡️  Seclib AI Desktop: Installer     ${NC}"
echo -e "${BLUE}==========================================${NC}"

# 1. PLATFORM CHECK
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}❌ This installer is currently optimized for Linux (Debian/Ubuntu).${NC}"
    exit 1
fi

# 2. SYSTEM DEPENDENCIES
echo -e "\n${BLUE}[1/5] Verifying system dependencies...${NC}"

# Check for Sudo
if [ "$EUID" -ne 0 ] && ! command -v sudo >/dev/null 2>&1; then
    echo -e "${RED}❌ Sudo is required but not found.${NC}"
    exit 1
fi

pkg_install() {
    echo -e "${YELLOW}📦 Installing $1...${NC}"
    sudo apt-get update -qq && sudo apt-get install -y -qq $2 >/dev/null
}

command -v curl >/dev/null || pkg_install "curl" "curl"
command -v git >/dev/null || pkg_install "git" "git"
command -v python3 >/dev/null || pkg_install "python3" "python3-venv python3-pip"

if ! command -v docker >/dev/null; then
    echo -e "${YELLOW}📦 Installing Docker...${NC}"
    curl -fsSL https://get.docker.com | sh >/dev/null
    sudo usermod -aG docker "$USER"
fi

if ! command -v npm >/dev/null; then
    echo -e "${YELLOW}📦 Installing Node.js...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y -qq nodejs >/dev/null
fi

# 3. SOURCE RETRIEVAL
echo -e "\n${BLUE}[2/5] Retrieving application source...${NC}"
REPO_DIR="rag-engine"
if [ ! -d "$REPO_DIR" ]; then
    # In a real production scenario:
    # git clone https://github.com/seclib-ai/desktop.git "$REPO_DIR"
    mkdir -p "$REPO_DIR"
    echo -e "${GREEN}✅ Project directory initialized.${NC}"
else
    echo -e "${GREEN}✅ Project directory exists.${NC}"
fi
cd "$REPO_DIR"

# 4. ENVIRONMENT & VOLUMES
echo -e "\n${BLUE}[3/5] Preparing volumes and environments...${NC}"
mkdir -p data/knowledge data/qdrant_storage backend/logs
chmod -R 755 data

# Backend Environment
if [ ! -d "backend/env" ]; then
    echo -e "${YELLOW}🐍 Setting up Python venv...${NC}"
    python3 -m venv backend/env
    source backend/env/bin/activate
    pip install --upgrade pip -q
    pip install -r backend/requirements.txt -q
fi

# Frontend Environment
if [ ! -d "frontend/node_modules" ]; then
    echo -e "${YELLOW}⚛️  Building Frontend...${NC}"
    (cd frontend && npm install --silent)
fi

# 5. PERMISSIONS
echo -e "\n${BLUE}[4/5] Finalizing permissions...${NC}"
chmod +x start.sh scripts/*.sh 2>/dev/null || true

# 6. LAUNCH
echo -e "\n${GREEN}[5/5] Installation Complete!${NC}"
echo -e "${BLUE}==========================================${NC}"
echo -en "${YELLOW}Would you like to start Seclib AI Desktop now? (y/n): ${NC}"
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./start.sh
else
    echo -e "To start later, run: ${GREEN}cd $REPO_DIR && ./start.sh${NC}"
fi
echo -e "${BLUE}==========================================${NC}"
