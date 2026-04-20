#!/bin/bash
# ==============================================================================
# Seclib AI Desktop - Safe Push Script
# ==============================================================================
# Ensures clean, safe pushes to production repositories
# Prevents broken states, uncommitted changes, and deployment issues

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Configuration
REMOTE="${1:-origin}"
BRANCH="${2:-main}"
FORCE_PUSH="${3:-false}"

echo "🔒 Seclib AI Desktop - Safe Push Script"
echo "======================================"

# Check 1: Ensure we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a Git repository!"
    exit 1
fi

# Check 2: Check for uncommitted changes
if ! git diff --quiet || ! git diff --staged --quiet; then
    print_error "You have uncommitted changes!"
    print_info "Staged changes:"
    git diff --staged --name-only | head -10
    print_info "Unstaged changes:"
    git diff --name-only | head -10
    print_error "Commit or stash changes before pushing."
    exit 1
fi

# Check 3: Check for untracked files (excluding ignored)
UNTRACKED=$(git ls-files --others --exclude-standard | wc -l)
if [ "$UNTRACKED" -gt 0 ]; then
    print_warning "You have $UNTRACKED untracked files."
    print_info "Untracked files:"
    git ls-files --others --exclude-standard | head -10
    if [ "$UNTRACKED" -gt 10 ]; then
        echo "... and $(($UNTRACKED - 10)) more"
    fi
    echo
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Push cancelled."
        exit 0
    fi
fi

# Check 4: Ensure we're on the correct branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    print_warning "Not on branch '$BRANCH' (currently on '$CURRENT_BRANCH')"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Push cancelled."
        exit 0
    fi
fi

# Check 5: Check if remote exists
if ! git remote get-url "$REMOTE" > /dev/null 2>&1; then
    print_error "Remote '$REMOTE' does not exist!"
    print_info "Available remotes:"
    git remote -v
    exit 1
fi

# Check 6: Check for large files in recent commits
print_info "Checking for large files in recent commits..."
LARGE_FILES=$(git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print substr($0, 6)}' | sort -k2nr | head -10 | awk '$2 > 52428800 {print $3 ": " $2/1024/1024 "MB"}')

if [ -n "$LARGE_FILES" ]; then
    print_warning "Large files detected in repository:"
    echo "$LARGE_FILES"
    print_warning "Consider using Git LFS for files >50MB"
fi

# Check 7: Verify remote branch exists or can be created
if git ls-remote --heads "$REMOTE" "$BRANCH" | grep -q "$BRANCH"; then
    print_info "Remote branch '$BRANCH' exists."
else
    print_warning "Remote branch '$BRANCH' does not exist."
    read -p "Create new remote branch? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Push cancelled."
        exit 0
    fi
fi

# Check 8: Check if push is fast-forward
if git rev-list --count "$REMOTE/$BRANCH"..HEAD > /dev/null 2>&1; then
    AHEAD=$(git rev-list --count "$REMOTE/$BRANCH"..HEAD 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count HEAD.."$REMOTE/$BRANCH" 2>/dev/null || echo "0")

    if [ "$BEHIND" -gt 0 ]; then
        print_warning "Your branch is $BEHIND commits behind remote."
        print_info "Consider pulling first: git pull $REMOTE $BRANCH"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Push cancelled."
            exit 0
        fi
    fi

    if [ "$AHEAD" -gt 10 ]; then
        print_warning "You're about to push $AHEAD commits."
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Push cancelled."
            exit 0
        fi
    fi
fi

# Check 9: Warn about force push
if [ "$FORCE_PUSH" = "true" ] || git status | grep -q "Your branch is ahead"; then
    if git status | grep -q "Your branch and .* have diverged"; then
        print_warning "Branches have diverged. Force push may be needed."
        read -p "Use force push? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            FORCE_PUSH="true"
        fi
    fi
fi

# Final confirmation
echo
print_info "Push Summary:"
echo "  Remote: $REMOTE"
echo "  Branch: $BRANCH"
echo "  Force: $FORCE_PUSH"
echo "  Current branch: $CURRENT_BRANCH"
echo

read -p "Proceed with push? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Push cancelled."
    exit 0
fi

# Execute push
print_info "Pushing to $REMOTE/$BRANCH..."
if [ "$FORCE_PUSH" = "true" ]; then
    git push --force-with-lease "$REMOTE" "$BRANCH"
else
    git push "$REMOTE" "$BRANCH"
fi

if [ $? -eq 0 ]; then
    print_success "Push completed successfully!"
else
    print_error "Push failed!"
    exit 1
fi
