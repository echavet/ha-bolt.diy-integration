ARG BUILD_FROM
FROM ${BUILD_FROM}

# Synchronize with homeassistant/core.py:async_stop
ENV S6_SERVICES_GRACETIME=220000

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copier la documentation (DOCS.md, README, etc.)
COPY *.md /

# Créer le répertoire de l'application
RUN mkdir /app
WORKDIR /app

# Installer git, nodejs et npm
RUN apk add --no-cache git nodejs npm

# Installer pnpm globalement
RUN npm install -g pnpm

# Cloner la branche stable de bolt.diy dans /app
RUN git clone -b stable https://github.com/stackblitz-labs/bolt.diy.git .

# Configurer l’application pour qu’elle écoute sur le port interne 80
ENV PORT=80

# Installer les dépendances du projet via pnpm
RUN pnpm install

# Correction de l'architecture : suppression du binaire pour arm64 et ajout du binaire pour amd64
RUN rm -rf node_modules/.pnpm/@cloudflare+workerd-linux-arm64*
RUN pnpm add @cloudflare/workerd-linux-amd64@1.20241106.1

# Lancer la build de l'application (selon la commande indiquée dans la doc de bolt.diy)
RUN pnpm run build

# Exposer le port interne (80)
EXPOSE 80

# Commande de démarrage en production
CMD [ "pnpm", "run", "dockerstart" ]
