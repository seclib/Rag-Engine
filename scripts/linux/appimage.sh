#!/bin/bash
# Seclib AI Desktop - AppImage Build Script
# Creates a self-contained AppImage for Linux distribution

set -e

echo "Building Seclib AI Desktop AppImage..."

# Requirements check
command -v appimagetool >/dev/null 2>&1 || {
    echo "ERROR: appimagetool not found. Install it first:"
    echo "wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    echo "chmod +x appimagetool-x86_64.AppImage"
    echo "sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool"
    exit 1
}

# Build the Electron app first
echo "Building Electron application..."
cd frontend
npm run build
cd ..

# Create AppDir structure
APPDIR="AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/512x512/apps"

# Copy application files
echo "Copying application files..."
cp -r frontend/dist-electron/linux-unpacked/* "$APPDIR/usr/bin/"
cp scripts/linux/postinstall.sh "$APPDIR/usr/bin/"
cp requirements.txt "$APPDIR/usr/bin/"

# Copy Python runtime (embedded)
echo "Bundling Python runtime..."
python3 -c "
import sys
import os
import shutil

# Get Python library paths
lib_paths = []
for path in sys.path:
    if 'site-packages' in path or 'dist-packages' in path:
        lib_paths.append(path)

# Copy Python libraries
for lib_path in lib_paths:
    if os.path.exists(lib_path):
        dest = '$APPDIR/usr/lib/python' + os.path.basename(lib_path)
        shutil.copytree(lib_path, dest, symlinks=True, ignore=shutil.ignore_patterns('*.pyc', '__pycache__'))
        break
"

# Create desktop file
cat > "$APPDIR/usr/share/applications/seclib-ai-desktop.desktop" << EOF
[Desktop Entry]
Name=Seclib AI Desktop
Exec=Seclib AI Desktop
Icon=seclib-ai-desktop
Type=Application
Categories=Development;Utility;
Terminal=false
EOF

# Copy icon
cp frontend/build/icon.png "$APPDIR/usr/share/icons/hicolor/512x512/apps/seclib-ai-desktop.png"

# Create AppRun script
cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
# AppRun script for Seclib AI Desktop AppImage

set -e

# Get the AppImage directory
APPDIR="$(dirname "$(readlink -f "$0")")"

# Set up environment
export PATH="$APPDIR/usr/bin:$PATH"
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$LD_LIBRARY_PATH"
export PYTHONPATH="$APPDIR/usr/lib/python:$PYTHONPATH"

# Run post-install if first run
FIRST_RUN_FILE="$HOME/.seclib-ai-desktop.first-run"
if [ ! -f "$FIRST_RUN_FILE" ]; then
    echo "First run setup..."
    "$APPDIR/usr/bin/postinstall.sh"
    touch "$FIRST_RUN_FILE"
fi

# Launch the application
exec "$APPDIR/usr/bin/Seclib AI Desktop" "$@"
EOF

chmod +x "$APPDIR/AppRun"

# Build AppImage
echo "Creating AppImage..."
VERSION="1.0.0"
OUTPUT="Seclib-AI-Desktop-$VERSION-x86_64.AppImage"

appimagetool "$APPDIR" "$OUTPUT"

echo "AppImage created: $OUTPUT"
echo "Size: $(du -h "$OUTPUT" | cut -f1)"

# Cleanup
rm -rf "$APPDIR"

echo "Build completed successfully!"