# Documentation – ha-bolt.diy-integration

## Description
The **ha-bolt.diy-integration** add-on hosts an instance of [bolt.diy](https://stackblitz-labs.github.io/bolt.diy/), a Node.js application designed for integration and experimentation. This add-on leverages Home Assistant's add-on system to run bolt.diy inside a Docker container.

## Prerequisites
Before you begin, ensure the following:
- **Home Assistant is installed.**
- Your add-on base image (provided via BUILD_FROM) is compatible with Home Assistant.
- Node.js is required by bolt.diy. The add-on installs Node.js, npm, and pnpm.

## How It Works
1. **Source Retrieval and Build:**  
   The Dockerfile clones the stable branch of bolt.diy from GitHub.  
   It then installs dependencies using pnpm and builds the application.  
   The environment variable `PORT` is set to 80 so that bolt.diy listens on the internal port 80.

2. **Port Mapping:**  
   In the add-on configuration (`config.yaml`), the section `ports` declares:
   ```yaml
   ports:
     80/tcp: 5173
   ports_description:
     80/tcp: "Bolt.DIY Listen Port"
