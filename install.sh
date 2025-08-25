#!/bin/bash

PRJ_PATH=$(dirname "$(readlink -f "$0")")
PROJECT_NAME=$(basename "$PRJ_PATH")
REPO_PATH=$(dirname "$PRJ_PATH")
cd $PRJ_PATH

# Create docker-compose.yaml with correct paths
cat > docker-compose.yaml << EOF
services:
  python-dev:
    image: python:3.11-slim
    container_name: python-dev-env
    working_dir: /repo
    volumes:
      - ${REPO_PATH}:/repo
      - ~/.ssh:/home/\$HOST_USER/.ssh
      - ${PRJ_PATH}/nvim-config:/home/\$HOST_USER/.config/nvim
    environment:
      - TERM=xterm-256color
      - HOST_UID=\${HOST_UID}
      - HOST_GID=\${HOST_GID}
      - HOST_USER=\${HOST_USER}
      - DEV_CONTAINER_PATH=${PROJECT_NAME}
    stdin_open: true
    tty: true
    healthcheck:
      test: ["CMD", "test", "-f", "/tmp/container_ready"]
      interval: 5s
      timeout: 3s
      retries: 10
      start_period: 30s
    command: /bin/bash -c "
      groupadd -g \$HOST_GID \$HOST_USER || true;
      useradd -u \$HOST_UID -g \$HOST_GID -M -s /bin/bash \$HOST_USER || true;
      echo '\$HOST_USER ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers &&
      chown -R \$HOST_UID:\$HOST_GID /repo &&
      mkdir -p /home/\$HOST_USER/.config /home/\$HOST_USER/.local/share/nvim /home/\$HOST_USER/.local/state/nvim /home/\$HOST_USER/.cache/nvim &&
      chown -R \$HOST_UID:\$HOST_GID /home/\$HOST_USER/.config /home/\$HOST_USER/.local /home/\$HOST_USER/.cache &&
      apt update && 
      apt install -y 
        neovim 
        git &&
      pip install --upgrade pip &&
      if [ -f \"/repo/\$DEV_CONTAINER_PATH/requirements.txt\" ]; then
        pip install -r \"/repo/\$DEV_CONTAINER_PATH/requirements.txt\"
      else
        echo \"No base requirements.txt found in \$DEV_CONTAINER_PATH\"
      fi &&
      echo 'CONTAINER SETUP COMPLETE' &&
      touch /tmp/container_ready &&
      su - \$HOST_USER -c 'cd /repo && exec /bin/bash'
      "
    networks:
      - dev-network

networks:
  dev-network:
    driver: bridge
EOF

# make the `dev` script available to the user
mkdir -p ~/bin
cat dev|sed "s,PRJ_PATH,${PRJ_PATH},g" > ~/bin/dev
chmod u+x ~/bin/dev

echo "Setup complete!"
echo "Project path: ${PRJ_PATH}"
echo "Repo path (mounted as /repo): ${REPO_PATH}"
echo "Docker compose file created at: ${PRJ_PATH}/docker-compose.yaml"
echo "Neovim config will be mounted from: ${PRJ_PATH}/nvim-config"
echo ""
echo "Usage:"
echo "  dev                              - General development environment"
echo "  dev <project-name>               - Project-specific development environment"
echo "  dev <project-name> --env prod    - Project with production dependencies"
echo "  dev <project-name> --env test    - Project with test dependencies"
echo ""
echo "Requirements file structure (recommended):"
echo "  python-dev-container/requirements.txt    - Base dev tools (pynvim, etc.)"
echo "  project/requirements.txt                 - Default/production dependencies"
echo "  project/requirements-dev.txt             - Development dependencies"
echo "  project/requirements-test.txt            - Test dependencies"
echo ""
echo "Available projects:"
ls -la "${REPO_PATH}" | grep "^d" | awk '{print "  - " $9}' | grep -v "  - \.$" | grep -v "  - \.\.$"