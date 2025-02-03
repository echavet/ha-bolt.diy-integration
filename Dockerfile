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

# Configurer l'application pour écouter sur le port 80
ENV PORT=80

# Installer les dépendances du projet avec pnpm
RUN pnpm install

# Utiliser l'argument TARGETARCH pour détecter l'architecture
ARG TARGETARCH
# Si l'architecture n'est pas arm64, supprimer le binaire pour arm64 et installer celui pour amd64
RUN if [ "$TARGETARCH" != "arm64" ]; then \
      echo "Non ARM64 ($TARGETARCH): Removing workerd-linux-arm64 and installing workerd-linux-amd64" && \
      rm -rf node_modules/.pnpm/@cloudflare+workerd-linux-arm64* && \
      pnpm add @cloudflare/workerd-linux-amd64@1.20241106.1; \
    else \
      echo "Running on arm64, keeping workerd-linux-arm64"; \
    fi

# Lancer la build de l'application
RUN pnpm run build

# Exposer le port interne (80)
EXPOSE 80

# Commande de démarrage en production
CMD [ "pnpm", "run", "dockerstart" ]
