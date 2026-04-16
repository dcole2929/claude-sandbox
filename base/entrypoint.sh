#!/bin/bash
set -euo pipefail

# Copy host gitconfig so git can modify it freely (bind-mounted files can't be rewritten)
if [[ -f /home/dev/.gitconfig.host ]]; then
  cp /home/dev/.gitconfig.host /home/dev/.gitconfig
fi

# Use gh as git credential helper (HTTPS auth via GitHub CLI token)
if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
  gh auth setup-git
fi

# Rewrite SSH remote URLs to HTTPS so gh credential helper works
git config --global url."https://github.com/".insteadOf "git@github.com:"

exec /bin/bash "$@"
