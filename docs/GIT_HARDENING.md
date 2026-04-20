# Git Hardening for Seclib AI Desktop

This repository uses production-hardened Git practices to prevent common mistakes and maintain code quality.

## 🚫 Problems Prevented

- **node_modules commits** - Dependencies should never be committed
- **Large binaries** - Files >50MB are blocked (use Git LFS if needed)
- **.env leaks** - Environment files contain secrets
- **Broken rebase states** - Merge conflicts and diverged branches
- **Uncommitted changes** - Dirty working directory on push

## 🛡️ Git Hooks

Pre-commit hooks automatically run on every commit:

```bash
# Install hooks (run once after cloning)
./scripts/setup_hooks.sh

# Hooks prevent:
- node_modules in commits
- .env files
- Files >50MB
- Binary files
- Merge conflict markers
```

## 🔒 Safe Push Script

Use the safe push script instead of `git push`:

```bash
# Basic push
./scripts/safe_push.sh

# Push to specific remote/branch
./scripts/safe_push.sh origin main

# Force push (with confirmation)
./scripts/safe_push.sh origin main true
```

The script checks:
- Clean working directory
- No untracked files
- Correct branch
- Remote exists
- No large files
- Branch status (ahead/behind)
- User confirmation

## 📋 Workflow Rules

### Committing
1. Stage changes: `git add <files>`
2. Commit: `git commit -m "message"`
3. Hooks run automatically and block bad commits

### Pushing
1. Use `./scripts/safe_push.sh` instead of `git push`
2. Script ensures clean state and gets confirmation
3. Never use `git push --force` directly

### Branching
- Work on feature branches
- Merge via pull requests
- Never force push to main/master

### Large Files
- Files >50MB are blocked
- Use Git LFS for large assets:
  ```bash
  git lfs install
  git lfs track "*.model"
  git add .gitattributes
  ```

## 🔧 Bypassing (Emergency Only)

In rare cases, bypass hooks with:
```bash
git commit --no-verify  # Skip pre-commit
```

**⚠️ Use with extreme caution - only for hotfixes**

## 📊 Monitoring

Check repository health:
```bash
# Find large files
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print substr($0, 6)}' | sort -k2nr | head -10

# Check for secrets
git log --all --full-history -- <file> | grep -i "password\|secret\|key"
```

## 🎯 Best Practices

- **Never commit secrets** - Use environment variables
- **Keep commits small** - Logical, focused changes
- **Use descriptive messages** - Clear commit history
- **Review before push** - Use safe_push.sh confirmations
- **Backup important work** - Stash or branch for safety

This hardening ensures production-ready code quality and prevents catastrophic mistakes.