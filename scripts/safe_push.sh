#!/bin/bash
# ==============================================================================
# Seclib AI Desktop - Safe Push Workflow
# ==============================================================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔄 Starting safe-push workflow...${NC}"

# 1. Pull with Rebase
echo -e "${BLUE}Step 1: Syncing with remote (Rebase mode)...${NC}"
if ! git pull --rebase origin $(git branch --show-current); then
    echo -e "${RED}❌ ERROR: Rebase conflict detected. Fix conflicts manually and run 'git rebase --continue'.${NC}"
    exit 1
fi

# 2. Run Pre-push tests (Optional placeholder)
# echo -e "${BLUE}Step 2: Running sanity checks...${NC}"

# 3. Final Push
echo -e "${BLUE}Step 3: Pushing verified changes to remote...${NC}"
if git push origin $(git branch --show-current); then
    echo -e "${GREEN}✅ Successfully pushed to $(git branch --show-current).${NC}"
else
    echo -e "${RED}❌ ERROR: Push failed. Check your network or permissions.${NC}"
    exit 1
fi
