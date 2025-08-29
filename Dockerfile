# Use Python base image
FROM python:3.11-slim

# Install system dependencies that are frequently used
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    gcc \
    luarocks \
    ripgrep \
    fd-find \
    fzf \
    tree-sitter-cli \
    neovim \
    lazygit \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Default working directory
WORKDIR /repo

# Create a non-root user to match the host user
RUN groupadd -r devgroup && useradd -r -g devgroup devuser

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]