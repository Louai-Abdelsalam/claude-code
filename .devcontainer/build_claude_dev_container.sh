#!/bin/bash

# https://code.claude.com/docs/en/devcontainer#run-without-permission-prompts

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docker build \
  --network host \
  -f "$WORKSPACE_ROOT/.devcontainer/Dockerfile" \
  -t claude-code-sandbox \
  --build-arg TZ="America/Toronto" \
  --build-arg CLAUDE_CODE_VERSION=latest \
  --build-arg GIT_DELTA_VERSION=0.18.2 \
  --build-arg ZSH_IN_DOCKER_VERSION=1.2.0 \
  "$WORKSPACE_ROOT/.devcontainer"

OVERRIDE_CMD=(zsh)
# Uncomment to run the firewall script on container startup
# (also re-add --cap-add=NET_ADMIN and --cap-add=NET_RAW to the docker run flags below;
# these grant the container permission to manage iptables rules and manipulate raw network
# packets, which the firewall script requires to set up network restrictions):
# OVERRIDE_CMD=(zsh -c "sudo /usr/local/bin/init-firewall.sh && exec zsh")

# POWERLEVEL9K_DISABLE_GITSTATUS: disables git status computation in the zsh prompt (p10k),
# which is slow on bind-mounted workspaces since git has to traverse the host filesystem through the mount
docker run -it --rm \
  --network host \
  -e NODE_OPTIONS="--max-old-space-size=4096" \
  -e CLAUDE_CONFIG_DIR="/home/node/.claude" \
  -e POWERLEVEL9K_DISABLE_GITSTATUS="true" \
  --mount type=bind,source="$WORKSPACE_ROOT",target=/workspace \
  --mount type=volume,source=claude-code-bashhistory,target=/commandhistory \
  --mount type=volume,source=claude-code-config,target=/home/node/.claude \
  -w /workspace \
  -u node \
  claude-code-sandbox "${OVERRIDE_CMD[@]}"
