#!/bin/bash

PRJ_PATH=$(dirname "$(readlink -f "$0")")
PROJECT_NAME=$(basename "$PRJ_PATH")
REPO_PATH=$(dirname "$PRJ_PATH")
cd $PRJ_PATH

# Create docker-compose.yaml with correct paths
cat >docker-compose.yaml <<EOF
services:
  python-dev:
    build:
      context: ${PRJ_PATH}
      dockerfile: Dockerfile
    container_name: python-dev-env
    working_dir: /repo
    volumes:
      - ${REPO_PATH}:/repo
      - ~/.ssh:/home/\${HOST_USER}/.ssh
      - ${PRJ_PATH}/nvim-config:/home/\${HOST_USER}/.config/nvim
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
    command: bash
    networks:
      - dev-network

networks:
  dev-network:
    driver: bridge
EOF

# Install dev script
mkdir -p ~/bin
cat dev | sed "s,PRJ_PATH,${PRJ_PATH},g" >~/bin/dev
chmod u+x ~/bin/dev

echo "Setup complete!"
echo "Project path: ${PRJ_PATH}"
echo "Repo path (mounted as /repo): ${REPO_PATH}"
echo "Docker compose file created at: ${PRJ_PATH}/docker-compose.yaml"
echo "Neovim config will be mounted from: ${PRJ_PATH}/nvim-config"
