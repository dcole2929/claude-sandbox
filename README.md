# claude-sandbox

Run [Claude Code](https://docs.anthropic.com/en/docs/claude-code) in an isolated Docker container so you can use `--dangerously-skip-permissions` without risking your host system.

## What it does

- Spins up a Docker container with Claude Code, Docker CLI, and common dev tools pre-installed
- Mounts your project directory, Claude data dir (`~/.claude`), and main config (`~/.claude.json`) into the container
- On macOS, extracts the OAuth credential from Keychain at startup so Claude inside the container is authenticated without re-login
- Aligns the container's group with the Docker socket's GID at runtime, so `docker`, `supabase`, and other daemon clients work as the non-root `dev` user
- Auto-detects `docker-compose.yml` in your project and wires up services so they're reachable by hostname
- Mounts the Docker socket so Claude can manage sibling containers from inside the sandbox

## Prerequisites

- Docker with the Compose plugin
- An existing Claude Code auth config (`~/.claude` and `~/.claude.json`)
- On macOS, on first run you'll see a Keychain prompt to allow reading the Claude credential — click **Always Allow** to avoid future prompts

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
| `--claude-config PATH` | Path to host `.claude.json` to mount | `~/.claude.json` |
| `-c, --compose FILE` | Compose file to extend | Auto-detected |
| `--no-compose` | Skip project compose file | |
| `-n, --name NAME` | Container name | `sandbox-<dirname>` |
| `--memory LIMIT` | Memory limit | `8g` |
| `--cpus LIMIT` | CPU limit | `4` |
| `--build` | Force rebuild the base image | |

## Persistent defaults

To avoid repeating flags every run, create `~/.claude-sandbox/config.json`:

```json
{
  "claudeConfig": "/Users/you/.claude.json",
  "account": "personal",
  "memory": "8g",
  "cpus": "4"
}
```

Precedence: built-in defaults → `~/.claude-sandbox/config.json` → CLI flags.

## Networking

The sandbox runs with `network_mode: host` — it shares the host's network stack directly. Any port a service binds inside the container is immediately accessible on the host without explicit port mapping.

## How it works

The CLI builds a base Docker image (`claude-sandbox-base`) from `base/Dockerfile` containing Node 20, Docker CLI + Compose, pnpm, ripgrep, and Claude Code. At runtime it generates a temporary compose overlay that mounts your project and Claude config, then launches an interactive bash session inside the container.

If your project has a `docker-compose.yml`, the sandbox service is wired up with `depends_on` so all your project's services start first and are reachable by service name.

## License

MIT
