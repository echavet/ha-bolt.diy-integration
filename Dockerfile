ARG BUILD_FROM
FROM ${BUILD_FROM}

# Synchronize with homeassistant/core.py:async_stop
ENV S6_SERVICES_GRACETIME=220000

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copier les fichiers de documentation
COPY *.md /

# Créer le répertoire de l'application et se placer dedans
RUN mkdir /app
WORKDIR /app

# Installer git, nodejs et npm
RUN apk add --no-cache git nodejs npm

# Installer pnpm globalement
RUN npm install -g pnpm

# Cloner la branche stable de bolt.diy dans /app
RUN git clone -b stable https://github.com/stackblitz-labs/bolt.diy.git .

# Configurer l'application pour écouter sur le port 80 (convention HA)
ENV PORT=80

# Installer les dépendances du projet avec pnpm
RUN pnpm install

# Détection de l'architecture
# Si TARGETARCH n'est pas défini, on le définit avec uname -m.
# Sur Raspberry Pi (arm64), uname -m retourne généralement "aarch64".
RUN if [ -z "$TARGETARCH" ]; then export TARGETARCH=$(uname -m); fi && \
    if [ "$TARGETARCH" = "aarch64" ] || [ "$TARGETARCH" = "arm64" ]; then \
       echo "Running on ARM64 ($TARGETARCH), keeping workerd-linux-arm64"; \
    else \
       echo "Non ARM64 ($TARGETARCH): Skipping workerd binary fix"; \
    fi

# Lancer la build de l'application
RUN pnpm run build

# Exposer le port interne 80
EXPOSE 80

# Commande de démarrage en production
CMD [ "pnpm", "run", "dockerstart" ]
