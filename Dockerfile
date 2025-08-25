# Use Python base image
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    neovim \
    ripgrep \
    gcc \
    luarocks \
    neovim \
    git \
    fd-find \
    fzf \
    tree-sitter-cli \
    lazygit

# Copy requirements.txt if present
COPY requirements.txt /tmp/requirements.txt
RUN if [ -f /tmp/requirements.txt ]; then pip install --no-cache-dir -r /tmp/requirements.txt; fi

# Default working directory
WORKDIR /repo
