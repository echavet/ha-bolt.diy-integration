ARG BUILD_FROM
FROM ${BUILD_FROM}

# Synchronize with homeassistant/core.py:async_stop
ENV S6_SERVICES_GRACETIME=220000

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copier les fichiers de documentation (DOCS.md, README, etc.)
COPY *.md /

# Créer le répertoire de l'application et se positionner dedans
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

# Installer les dépendances du projet avec pnpm en forçant l'exécution des scripts postinstall
RUN pnpm install --unsafe-perm

# Détection de l'architecture
ARG TARGETARCH
RUN if [ -z "$TARGETARCH" ]; then export TARGETARCH=$(uname -m); fi && \
    if [ "$TARGETARCH" = "aarch64" ] || [ "$TARGETARCH" = "arm64" ]; then \
       echo "Running on ARM64 ($TARGETARCH), keeping workerd-linux-arm64"; \
    else \
       echo "Non ARM64 ($TARGETARCH): Skipping workerd binary fix"; \
    fi

# Optionnel : définir une variable pour signaler à workerd de ne pas lancer le binaire
ENV WORKERD_SKIP_BINARY=1

# Créer un binaire dummy pour workerd-linux-arm64 pour éviter l'erreur ENOENT
RUN mkdir -p /app/node_modules/.pnpm/@cloudflare+workerd-linux-arm64@1.20241106.1/node_modules/@cloudflare/workerd-linux-arm64/bin && \
    echo '#!/bin/sh' > /app/node_modules/.pnpm/@cloudflare+workerd-linux-arm64@1.20241106.1/node_modules/@cloudflare/workerd-linux-arm64/bin/workerd && \
    echo 'exit 0' >> /app/node_modules/.pnpm/@cloudflare+workerd-linux-arm64@1.20241106.1/node_modules/@cloudflare/workerd-linux-arm64/bin/workerd && \
    chmod +x /app/node_modules/.pnpm/@cloudflare+workerd-linux-arm64@1.20241106.1/node_modules/@cloudflare/workerd-linux-arm64/bin/workerd

# Construire l'application
RUN pnpm run build

# Exposer le port interne (80)
EXPOSE 80

# Commande de démarrage en production
CMD [ "pnpm", "run", "dockerstart" ]
