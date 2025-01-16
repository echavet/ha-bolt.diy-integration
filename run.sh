#!/bin/sh
    set -e

    # Install Node.js
    NODE_VERSION=$(jq -r '.options.node_version.default' /data/options.json)
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt-get install -y nodejs

    # Install Bolt.diy
    git clone https://github.com/stackblitz-labs/bolt.diy.git /app
    cd /app
    npm install

    # Start Bolt.diy
    npm run dev -- --host 0.0.0.0 --port 5173
