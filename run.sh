#!/bin/sh
    set -e

    # Install Node.js
    NODE_VERSION=$(jq -r '.options.node_version.default' /data/options.json)
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt-get install -y nodejs

    # Install pnpm
    npm install -g pnpm

    # Create app directory
    mkdir -p /app
    cd /app

    # Install Bolt.diy
    git clone https://github.com/stackblitz-labs/bolt.diy.git .
    pnpm install

    # Copy environment file
    ENV_FILE=$(jq -r '.options.env_file.default' /data/options.json)
    if [ -f "$ENV_FILE" ]; then
      cp "$ENV_FILE" /app/.env
    fi

    # Start Bolt.diy
    pnpm run dev -- --host 0.0.0.0 --port 5173
