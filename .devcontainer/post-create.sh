#!/usr/bin/env bash
# Runs once after the container is first created. Installs project
# dependencies for whichever stacks this workspace uses.

set -euo pipefail
cd /workspace

if [ -f package-lock.json ]; then
  echo "post-create: npm ci"
  npm ci
elif [ -f package.json ]; then
  echo "post-create: npm install"
  npm install
fi

if [ -f pyproject.toml ]; then
  echo "post-create: uv sync"
  uv sync || true
elif [ -f requirements.txt ]; then
  echo "post-create: pip install -r requirements.txt"
  python3 -m pip install --user -r requirements.txt
fi

echo "post-create: done"
