#!/bin/bash

set -e  # Exit on any error

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
NC="\033[0m" # No Color

# Helper functions
print_status() {
  echo -e "${GREEN}[✔]${NC} $1"
}

print_error() {
  echo -e "${RED}[✘]${NC} $1"
  exit 1
}

print_warning() {
  echo -e "${YELLOW}[!]${NC} $1"
}

# Step 1: Detect OS
print_status "Detecting operating system..."
if [ "$(uname)" != "Linux" ]; then
  print_error "This installer only supports Linux. Detected: $(uname)"
fi
print_status "Linux detected. Proceeding..."

# Step 2: Install dependencies
print_status "Checking and installing dependencies..."

# Docker
if ! command -v docker &> /dev/null; then
  print_status "Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
  print_warning "Docker installed. You may need to log out and back in for Docker group changes to take effect."
else
  print_status "Docker already installed."
fi

# Node.js
if ! command -v node &> /dev/null; then
  print_status "Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get update
  sudo apt-get install -y nodejs
else
  print_status "Node.js already installed."
fi

# Python venv
if ! python3 -c "import venv" 2>/dev/null; then
  print_status "Installing python3-venv..."
  sudo apt-get install -y python3-venv
else
  print_status "python3-venv already available."
fi

print_status "All dependencies installed."

# Step 3: Clone repository
REPO_URL="https://github.com/fatsio/rag-engine.git"
INSTALL_DIR="seclib-ai-desktop"

if [ -d "$INSTALL_DIR" ]; then
  print_warning "Directory '$INSTALL_DIR' already exists. Skipping clone."
else
  print_status "Cloning Seclib AI Desktop repository..."
  git clone "$REPO_URL" "$INSTALL_DIR"
  if [ $? -ne 0 ]; then
    print_error "Failed to clone repository."
  fi
fi

cd "$INSTALL_DIR"
print_status "Repository cloned and ready."

# Step 4: Setup backend environment
print_status "Setting up backend Python environment..."
python3 -m venv env
source env/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
if [ $? -ne 0 ]; then
  print_error "Failed to install Python requirements."
fi
print_status "Backend environment set up."

# Step 5: Setup frontend
print_status "Setting up frontend..."
cd frontend
npm install
if [ $? -ne 0 ]; then
  print_error "Failed to install npm dependencies."
fi
cd ..
print_status "Frontend set up."

# Step 6: Prepare Docker volumes
print_status "Preparing Docker volumes..."
mkdir -p data/qdrant_storage
mkdir -p data/ollama_storage
print_status "Docker volumes prepared."

# Step 7: Start the application
print_status "Starting Seclib AI Desktop..."
print_warning "This will start the Docker containers, backend, and frontend. The application will run in the background."
print_warning "To stop, use Ctrl+C or kill the processes."
exec ./start.sh</content>
<parameter name="filePath">/home/fatsio/rag-engine/install.sh