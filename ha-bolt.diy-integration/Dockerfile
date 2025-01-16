FROM node:18-alpine

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers du projet
COPY . .

# Installer pnpm et les dépendances
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Exposer le port pour Ingress
ENV PORT=5173
EXPOSE 5173

# Script d'exécution
CMD ["/app/run.sh"]
