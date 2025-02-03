ARG BUILD_FROM
FROM ${BUILD_FROM}

# Synchronize with homeassistant/core.py:async_stop
ENV S6_SERVICES_GRACETIME=220000

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Documentation files (DOCS.md, README, etc.)
COPY *.md /

# Création du répertoire de l'application
RUN mkdir /app
WORKDIR /app

# Installation des dépendances : git, nodejs, npm
RUN apk add --no-cache git nodejs npm

# Installation de pnpm globalement
RUN npm install -g pnpm

# Clonage de la branche stable de bolt.diy dans /app
RUN git clone -b stable https://github.com/stackblitz-labs/bolt.diy.git .

# Force bolt.diy à écouter sur le port 80 (interne)
ENV PORT=80

# Installation des dépendances du projet avec pnpm
RUN pnpm install

# Construction de l'application
RUN pnpm run build

# Expose le port interne (80) que HA mappe ensuite
EXPOSE 80

# Commande de démarrage (en production)
CMD [ "pnpm", "run", "dockerstart" ]
