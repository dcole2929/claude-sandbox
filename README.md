# claude-sandbox

Run [Claude Code](https://docs.anthropic.com/en/docs/claude-code) in an isolated Docker container so you can use `--dangerously-skip-permissions` without risking your host system.

## What it does

- Spins up a Docker container with Claude Code, Docker CLI, and common dev tools pre-installed
- Mounts your project directory and Claude auth config into the container
- Auto-detects `docker-compose.yml` in your project and wires up services so they're reachable by hostname
- Mounts the Docker socket so Claude can manage sibling containers from inside the sandbox

## Prerequisites

- Docker with the Compose plugin
- An existing Claude Code auth config (`~/.claude`)

## Installation

```bash
git clone https://github.com/dcole2929/claude-sandbox.git
export PATH="$HOME/dev/claude-sandbox/bin:$PATH"
```

Add the `export` line to your `~/.zshrc` or `~/.bashrc` to make it permanent.

## Usage

```bash
# Current directory, personal Claude account
claude-sandbox

# Specific project directory
claude-sandbox ~/dev/my-api

# Use work Claude account
claude-sandbox -a work ~/dev/project

# Custom compose file
claude-sandbox -c compose.dev.yml .

# Force rebuild the base image
claude-sandbox --build
```

## Options

| Option | Description | Default |
|---|---|---|
| `path` | Project directory to mount | Current directory |
| `-a, --account NAME` | Claude account: `personal` or `work` | `personal` |
| `-c, --compose FILE` | Compose file to extend | Auto-detected |
| `-n, --name NAME` | Container name | `sandbox-<dirname>` |
| `--memory LIMIT` | Memory limit | `8g` |
| `--cpus LIMIT` | CPU limit | `4` |
| `--build` | Force rebuild the base image | |

## How it works

The CLI builds a base Docker image (`claude-sandbox-base`) from `base/Dockerfile` containing Node 20, Docker CLI + Compose, pnpm, ripgrep, and Claude Code. At runtime it generates a temporary compose overlay that mounts your project and Claude config, then launches an interactive bash session inside the container.

If your project has a `docker-compose.yml`, the sandbox service is wired up with `depends_on` so all your project's services start first and are reachable by service name.

## License

MIT
