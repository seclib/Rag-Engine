#!/bin/bash
# Electron startup script

echo "Starting Electron UI..."
cd frontend
# Check for node_modules, if missing, warn or install (assuming electron is installed globally or in project)
# For this skeleton, we assume 'electron' is available.
electron main.js
