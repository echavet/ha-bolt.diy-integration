ARG BUILD_FROM
FROM ${BUILD_FROM}

# Synchronize with homeassistant/core.py:async_stop
ENV S6_SERVICES_GRACETIME=220000

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copier les fichiers de documentation
COPY *.md /

# Créer le répertoire de l'application
RUN mkdir /app
WORKDIR /app

# Installer git, nodejs et npm
RUN apk add --no-cache git nodejs npm

# Installer pnpm globalement
RUN npm install -g pnpm


# install runtime dependencies
RUN npm i @remix-run/node @remix-run/react @remix-run/serve isbot@4 react react-dom

# install dev dependencies
RUN npm i -D @remix-run/dev vite

# Cloner la branche stable de bolt.diy dans /app
RUN git clone -b stable https://github.com/stackblitz-labs/bolt.diy.git .

#RUN git clone https://github.com/echavet/bolt.diy.git .

# Configurer l'application pour écouter sur le port 80 (convention HA)
ENV PORT=5173

# Installer les dépendances du projet avec pnpm, en autorisant l'exécution des scripts postinstall
RUN pnpm install --unsafe-perm 


# Détection de l'architecture avec TARGETARCH
ARG TARGETARCH
RUN if [ -z "$TARGETARCH" ]; then export TARGETARCH=$(uname -m); fi && \
    if [ "$TARGETARCH" = "aarch64" ] || [ "$TARGETARCH" = "arm64" ]; then \
       echo "Running on ARM64 ($TARGETARCH), keeping workerd-linux-arm64"; \
    else \
       echo "Non ARM64 ($TARGETARCH): Skipping workerd binary fix"; \
    fi

# Lancer la build de l'application
RUN pnpm run build

# Exposer le port interne (5173)
EXPOSE 5173

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]

#CMD [ "pnpm", "run", "dev", "--host 0.0.0.0"]

