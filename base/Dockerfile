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

# Language tooling
RUN corepack enable && corepack prepare pnpm@latest --activate

# Dev user with sudo + docker socket access
RUN useradd -m -s /bin/bash dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    groupadd -f docker && usermod -aG docker dev

# Claude Code (native install as dev user so it lands in ~dev/)
USER dev
RUN curl -fsSL https://claude.ai/install.sh | bash

WORKDIR /home/dev/project
ENTRYPOINT ["/bin/bash"]
