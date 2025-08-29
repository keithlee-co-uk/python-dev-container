#!/bin/bash

# Dynamically create the user inside the container to match the host user
if [ -z "$HOST_UID" ] || [ -z "$HOST_GID" ] || [ -z "$HOST_USER" ]; then
    echo "HOST_UID, HOST_GID, or HOST_USER environment variables are missing!"
    exit 1
fi

groupadd -g $HOST_GID $HOST_USER || true
useradd -u $HOST_UID -g $HOST_GID -M -s /bin/bash $HOST_USER || true
echo "$HOST_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set permissions for the mounted volumes
chown -R $HOST_UID:$HOST_GID /repo /home/$HOST_USER

# Set up Neovim directories for the user
mkdir -p /home/$HOST_USER/.config/nvim /home/$HOST_USER/.local/share/nvim /home/$HOST_USER/.local/state/nvim /home/$HOST_USER/.cache/nvim
chown -R $HOST_UID:$HOST_GID /home/$HOST_USER

# Switch to the user and execute the provided command
echo "Container setup for user $HOST_USER ($HOST_UID:$HOST_GID) is complete!"
su - $HOST_USER -c "$@"