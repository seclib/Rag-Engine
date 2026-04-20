#!/bin/bash
# Seclib AI Desktop - Build Pipeline
# Orchestrates the complete build and packaging process

set -e

echo "🚀 Seclib AI Desktop Build Pipeline"
echo "==================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Configuration
VERSION="${1:-1.0.0}"
TARGET="${2:-all}"  # all, win, linux, mac

print_info "Building version: $VERSION"
print_info "Target platforms: $TARGET"

# Check prerequisites
print_info "Checking prerequisites..."

command -v node >/dev/null 2>&1 || print_error "Node.js not found"
command -v npm >/dev/null 2>&1 || print_error "npm not found"
command -v python3 >/dev/null 2>&1 || print_error "Python 3 not found"

if [[ "$TARGET" == "win" ]] || [[ "$TARGET" == "all" ]]; then
    command -v makensis >/dev/null 2>&1 || print_warning "NSIS not found (required for Windows installer)"
fi

if [[ "$TARGET" == "linux" ]] || [[ "$TARGET" == "all" ]]; then
    command -v appimagetool >/dev/null 2>&1 || print_warning "appimagetool not found (required for AppImage)"
fi

print_status "Prerequisites check complete"

# Clean previous builds
print_info "Cleaning previous builds..."
rm -rf frontend/dist
rm -rf frontend/dist-electron
rm -rf build-artifacts

# Build React frontend
print_info "Building React frontend..."
cd frontend
npm install
npm run build
print_status "Frontend build complete"

# Build Electron app
print_info "Building Electron application..."

if [[ "$TARGET" == "win" ]] || [[ "$TARGET" == "all" ]]; then
    print_info "Building Windows installer..."
    npm run dist:win
    print_status "Windows build complete"
fi

if [[ "$TARGET" == "linux" ]] || [[ "$TARGET" == "all" ]]; then
    print_info "Building Linux packages..."
    npm run dist:linux

    # Build AppImage if appimagetool is available
    if command -v appimagetool >/dev/null 2>&1; then
        print_info "Building AppImage..."
        ../scripts/linux/appimage.sh
        print_status "AppImage build complete"
    else
        print_warning "Skipping AppImage build (appimagetool not found)"
    fi
fi

if [[ "$TARGET" == "mac" ]] || [[ "$TARGET" == "all" ]]; then
    print_info "Building macOS package..."
    npm run dist:all  # This will include mac if on macOS
    print_status "macOS build complete"
fi

cd ..
print_status "All builds complete"

# Organize artifacts
print_info "Organizing build artifacts..."
mkdir -p build-artifacts

# Move Windows artifacts
if [[ -d "frontend/dist-electron" ]]; then
    mv frontend/dist-electron/* build-artifacts/ 2>/dev/null || true
fi

# Move AppImage
if [[ -f "frontend/Seclib-AI-Desktop-$VERSION-x86_64.AppImage" ]]; then
    mv "frontend/Seclib-AI-Desktop-$VERSION-x86_64.AppImage" build-artifacts/
fi

print_status "Artifacts organized in build-artifacts/"

# Generate checksums
print_info "Generating checksums..."
cd build-artifacts
for file in *; do
    if [[ -f "$file" ]]; then
        sha256sum "$file" > "$file.sha256"
    fi
done
cd ..
print_status "Checksums generated"

# Create release notes
print_info "Creating release notes..."
cat > build-artifacts/RELEASE_NOTES.md << EOF
# Seclib AI Desktop v$VERSION

## What's New
- Complete rewrite with React UI
- Autonomous coding agent
- Enhanced RAG capabilities
- Production-ready installer

## Installation

### Windows
Run the .exe installer and follow the setup wizard.

### Linux
Run the AppImage or install the .deb package:
\`\`\`bash
chmod +x Seclib-AI-Desktop-$VERSION-x86_64.AppImage
./Seclib-AI-Desktop-$VERSION-x86_64.AppImage
\`\`\`

## System Requirements
- Windows 10+ / Ubuntu 18.04+ / macOS 10.15+
- 4GB RAM minimum
- 2GB disk space
- Docker (recommended for full functionality)

## First Run
The installer will set up Python dependencies and create shortcuts automatically.
EOF

print_status "Release notes created"

echo ""
print_status "🎉 Build pipeline completed successfully!"
echo ""
echo "Build artifacts are in: build-artifacts/"
echo ""
echo "Contents:"
ls -la build-artifacts/
echo ""
echo "Next steps:"
echo "1. Test the installers on target platforms"
echo "2. Create GitHub release with artifacts"
echo "3. Update documentation with new version"