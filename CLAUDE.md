# claude-sandbox

Isolated Docker dev container for running Claude Code with `--dangerously-skip-permissions` safely.

## How it works

- `bin/claude-sandbox` — CLI entry point. Spins up a Docker container with Claude Code + Docker CLI installed.
- `base/Dockerfile` — Base image built on `node:20-bookworm`. Includes Docker CLI + Compose plugin, pnpm, ripgrep, and Claude Code.
- Mounts the target project dir and Claude auth config (`~/.claude`) into the container.
- Auto-detects `docker-compose.yml` in the project root and merges it so services are reachable by hostname from inside the sandbox.
- Docker socket is mounted so Claude can manage sibling containers from inside.

## Usage

```
claude-sandbox [options] [path]
```

The CLI supports `-a work` / `-a personal` to switch Claude accounts (maps to `~/.claude-work` or `~/.claude`), `--build` to force-rebuild the base image, and `-c` to specify a custom compose file.

## Development notes

- The base image uses the native Claude installer (`curl -fsSL https://claude.ai/install.sh | bash`) run as the `dev` user.
- The `dev` user has passwordless sudo and is in the `docker` group.
- The sandbox overlay compose file is generated at runtime as a tempfile and cleaned up on exit.
- When a project has its own compose file, the sandbox service gets `depends_on` wired up to all project services.
