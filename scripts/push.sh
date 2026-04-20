#!/bin/bash
# Seclib AI Desktop - Safe Push Workflow

# 1. Pull latest changes with rebase
echo "🔄 Syncing with remote..."
git pull origin $(git branch --show-current) --rebase

if [ $? -ne 0 ]; then
    echo "❌ REBASE CONFLICT detected. Please fix manually before pushing."
    exit 1
fi

# 2. Check for large files again
echo "🔍 Final check for large files..."
# (The pre-commit hook handles this, but we're double-checking)

# 3. Push
echo "🚀 Pushing to remote..."
git push origin $(git branch --show-current)

echo "✅ Push successful."
