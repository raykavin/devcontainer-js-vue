#!/bin/sh
set -e

echo "> Configuring Git"

# Initialize git repo if it does not exist
if [ ! -d ".git" ]; then
  echo "Initializing Git repository (branch: $GIT_INIT_DEFAULT_BRANCH)"
  git init --initial-branch="$GIT_INIT_DEFAULT_BRANCH"
else
  echo "Git repository already exists, skipping init"
fi

# Configure safe directory and user
git config --global --add safe.directory "/workspaces/app"
git config --global user.name "$DEVELOPER_NAME"
git config --global user.email "$DEVELOPER_EMAIL"

# Configure remote upstream
if git remote | grep -q "^origin$"; then
  CURRENT_URL="$(git remote get-url origin)"
  if [ "$CURRENT_URL" != "$GIT_REPO_ADDRESS" ]; then
    echo "Updating origin remote URL"
    git remote set-url origin "$GIT_REPO_ADDRESS"
  else
    echo "Origin remote already configured correctly"
  fi
else
  echo "Adding origin remote"
  git remote add origin "$GIT_REPO_ADDRESS"
fi

# Ensure branch tracks origin
if git show-ref --verify --quiet "refs/heads/$GIT_INIT_DEFAULT_BRANCH"; then
  git branch --set-upstream-to="origin/$GIT_INIT_DEFAULT_BRANCH" "$GIT_INIT_DEFAULT_BRANCH" 2>/dev/null || true
fi

echo "> Configuring npm global directory"

mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
export PATH="$PATH:$HOME/.npm-global/bin"

echo "> Node & npm versions"
node --version
npm --version

echo "> Ensuring Vue project exists"

if [ ! -f package.json ]; then
  echo "package.json not found"
  echo "Creating Vue 3 project in the workspace root"

  npm create vite@latest . -- \
    --template vue

  echo "Vue project created successfully"
else
  echo "package.json found, using existing project"
fi

echo "> Installing project dependencies"
npm install

echo "> Installing global frontend tools"

npm install -g vite

echo "> Installing ESLint / Prettier"
npm install -D eslint prettier eslint-plugin-vue eslint-config-prettier || true

echo "> Verifying installed tools"
vite --version || true
npx eslint --version || true

echo "> Running initial lint (if configured)"
if [ -f .eslintrc.js ] || [ -f .eslintrc.cjs ] || [ -f .eslintrc.json ]; then
  npx eslint . || true
else
  echo "ESLint not configured, skipping lint"
fi

echo "> Checking out a develop branch"
if git show-ref --verify --quiet "refs/heads/develop"; then
  if git rev-parse --abbrev-ref HEAD | grep -q "^develop$"; then
    echo "Already on develop branch"
  else
    echo "Switching to develop branch"
    git checkout develop
  fi
fi

echo "Post-create completed successfully"
