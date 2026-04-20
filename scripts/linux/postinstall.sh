#!/bin/bash
# Seclib AI Desktop - Linux Post-Installation Setup
# This script runs after installation to set up the environment

set -e

echo "Setting up Seclib AI Desktop..."

# Get the installation directory
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

cd "$INSTALL_DIR"

# Create Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv env
source env/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Set up data directories
echo "Setting up data directories..."
mkdir -p data/qdrant_storage
mkdir -p data/ollama_storage
mkdir -p logs

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "WARNING: Docker not found. Please install Docker for full functionality."
    echo "On Ubuntu/Debian: sudo apt install docker.io"
    echo "On Fedora: sudo dnf install docker"
else
    echo "Docker found."
fi

# Check for Ollama
if ! command -v ollama &> /dev/null; then
    echo "INFO: Ollama not found. Installing Ollama..."
    # Install Ollama
    curl -fsSL https://ollama.ai/install.sh | sh
else
    echo "Ollama found."
fi

# Create desktop shortcut
echo "Creating desktop shortcut..."
DESKTOP_FILE="$HOME/.local/share/applications/seclib-ai-desktop.desktop"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Seclib AI Desktop
Exec=$INSTALL_DIR/Seclib AI Desktop
Icon=$INSTALL_DIR/resources/icon.png
Type=Application
Categories=Development;Utility;
Terminal=false
EOF

chmod +x "$DESKTOP_FILE"

# Make the main executable runnable
chmod +x "$INSTALL_DIR/Seclib AI Desktop"

echo "Setup completed successfully!"
echo ""
echo "You can now launch Seclib AI Desktop from your applications menu."
echo "The application has been added to your desktop environment."