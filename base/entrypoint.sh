#!/bin/bash
set -euo pipefail

# Grant dev user access to the Docker socket. The socket's GID varies by host
# (e.g. 0/root on macOS Docker Desktop) and often doesn't match the container's
# docker group, so align groups at runtime and re-exec to pick up membership.
if [[ -S /var/run/docker.sock && -z "${_SANDBOX_SOCK_READY:-}" ]]; then
  SOCK_GID=$(stat -c '%g' /var/run/docker.sock)
  if ! id -G | tr ' ' '\n' | grep -qx "$SOCK_GID"; then
    GROUP_NAME=$(getent group "$SOCK_GID" | cut -d: -f1 || true)
    if [[ -z "$GROUP_NAME" ]]; then
      sudo groupadd -g "$SOCK_GID" docker-sock >/dev/null
      GROUP_NAME=docker-sock
    fi
    sudo usermod -aG "$GROUP_NAME" dev >/dev/null
    export _SANDBOX_SOCK_READY=1
    exec sg "$GROUP_NAME" -c "exec $0 ${*@Q}"
  fi
fi

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
