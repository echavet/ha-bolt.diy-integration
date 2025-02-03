ARG BUILD_FROM
FROM ${BUILD_FROM}

# Synchronize with homeassistant/core.py:async_stop
ENV S6_SERVICES_GRACETIME=220000

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copier les fichiers de documentation
COPY *.md /

# Création du répertoire de l'application
RUN mkdir /app
WORKDIR /app

# Installer git, nodejs et npm
RUN apk add --no-cache git nodejs npm

# Installer pnpm globalement
RUN npm install -g pnpm

# Cloner la branche stable de bolt.diy dans /app
RUN git clone -b stable https://github.com/stackblitz-labs/bolt.diy.git .

# Configurer l'application pour écouter sur le port 80
ENV PORT=80

# Installer les dépendances du projet avec pnpm
RUN pnpm install

# Supprimer le binaire pour arm64 (incompatible avec amd64)
RUN rm -rf node_modules/.pnpm/@cloudflare+workerd-linux-arm64*

# La commande suivante était prévue pour installer le binaire amd64,
# mais le package "@cloudflare/workerd-linux-amd64" n'est pas disponible dans le registre npm.
# Si nécessaire, vous pouvez chercher une alternative ou fournir le binaire vous-même.
# RUN pnpm add @cloudflare/workerd-linux-amd64@1.20241106.1

# Construire l'application
RUN pnpm run build

# Exposer le port interne (80)
EXPOSE 80

# Lancer l'application en production
CMD [ "pnpm", "run", "dockerstart" ]
