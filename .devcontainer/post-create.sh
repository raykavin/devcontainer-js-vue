#!/bin/sh
set -e

# HELPERS
log() { echo "> $*"; }
info() { echo "  $*"; }

# GIT
log "Configuring Git"

if [ ! -d ".git" ]; then
  info "Initializing repository (branch: $GIT_INIT_DEFAULT_BRANCH)"
  git init --initial-branch="$GIT_INIT_DEFAULT_BRANCH"
else
  info "Repository already exists, skipping init"
fi

git config --global --add safe.directory "/workspaces/app"
git config --global user.name  "$GIT_CONFIG_DEV_USERNAME"
git config --global user.email "$GIT_CONFIG_DEV_EMAIL"

if git remote | grep -q "^origin$"; then
  CURRENT_URL="$(git remote get-url origin)"
  if [ "$CURRENT_URL" != "$GIT_REPO_ADDRESS" ]; then
    info "Updating origin URL"
    git remote set-url origin "$GIT_REPO_ADDRESS"
  else
    info "Origin already configured correctly"
  fi
else
  info "Adding origin remote"
  git remote add origin "$GIT_REPO_ADDRESS"
fi

if git show-ref --verify --quiet "refs/heads/$GIT_INIT_DEFAULT_BRANCH"; then
  git branch --set-upstream-to="origin/$GIT_INIT_DEFAULT_BRANCH" "$GIT_INIT_DEFAULT_BRANCH" 2>/dev/null || true
fi

# NODE ENVIRONMENT
log "Installing Node dependencies"
if [ -f "package.json" ]; then
  info "Running npm install"
  npm install
else
  info "No package.json found, skipping npm install"
fi

# VUE TOOLS
log "Installing Vue development tools"
npm install -g @vue/language-server typescript

log "Verifying installed tools"
node --version
npm --version

log "Running initial lint"
npm run lint || true

# BRANCH SETUP
log "Checking out develop branch"
if git show-ref --verify --quiet "refs/heads/develop"; then
  if git rev-parse --abbrev-ref HEAD | grep -q "^develop$"; then
    info "Already on develop branch"
  else
    info "Switching to develop branch"
    git checkout develop
  fi
fi

echo ""
log "Post-create completed successfully"
