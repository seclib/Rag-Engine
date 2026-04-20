#!/bin/bash
# ==============================================================================
# Seclib AI Desktop - Git Hooks Setup
# ==============================================================================
# Installs production-hardened Git hooks to prevent common mistakes

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🔧 Setting up Git hooks for Seclib AI Desktop..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a Git repository!"
    exit 1
fi

HOOKS_DIR=".git/hooks"
PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Install pre-commit hook
if [ -f "$PRE_COMMIT_HOOK" ]; then
    print_warning "Pre-commit hook already exists. Backing up..."
    mv "$PRE_COMMIT_HOOK" "$PRE_COMMIT_HOOK.backup.$(date +%Y%m%d_%H%M%S)"
fi

cp "scripts/hooks/pre-commit" "$PRE_COMMIT_HOOK"
chmod +x "$PRE_COMMIT_HOOK"

print_success "Pre-commit hook installed!"

# Verify hook is executable
if [ -x "$PRE_COMMIT_HOOK" ]; then
    print_success "Hook is executable and ready."
else
    print_error "Failed to make hook executable!"
    exit 1
fi

echo
print_success "Git hooks setup complete!"
echo
echo "🎯 Hooks will prevent:"
echo "  • node_modules commits"
echo "  • .env file leaks"
echo "  • Files larger than 50MB"
echo "  • Binary/executable files"
echo "  • Merge conflict markers"
echo
echo "💡 Use './scripts/safe_push.sh' for safe pushes"
echo "💡 Use 'git commit --no-verify' to bypass hooks (use with caution)"