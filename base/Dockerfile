FROM node:20-bookworm

# System essentials (run as root)
RUN apt-get update && apt-get install -y \
    git curl wget jq ripgrep fd-find build-essential \
    sudo tmux zsh python3 python3-pip \
    ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# Docker CLI + Compose plugin (client only, no daemon)
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Language tooling
RUN corepack enable && corepack prepare pnpm@latest --activate

# Dev user with sudo + docker socket access
RUN usermod -u 1001 node && \
    useradd -m -s /bin/bash -u 1000 dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    groupadd -f docker && usermod -aG docker dev

# Claude Code (native install as dev user so it lands in ~dev/)
USER dev
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/dev/.local/bin:${PATH}"

# Entrypoint
COPY --chown=dev:dev entrypoint.sh /home/dev/entrypoint.sh
RUN chmod +x /home/dev/entrypoint.sh

WORKDIR /home/dev/project
ENTRYPOINT ["/home/dev/entrypoint.sh"]
