# Étape 1 : Builder l'image pour l'environnement de production
FROM node:18-alpine AS builder

# Définir le répertoire de travail
WORKDIR /app

# Copier uniquement les fichiers nécessaires pour installer les dépendances
COPY package.json pnpm-lock.yaml ./

# Installer pnpm globalement et les dépendances du projet
RUN npm install -g pnpm && pnpm install --frozen-lockfile

# Copier les fichiers sources
COPY . .

# Construire le projet en mode production
RUN pnpm run build

# Étape 2 : Image finale pour exécution
FROM node:18-alpine

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers depuis l'étape de build
COPY --from=builder /app /app

# Exposer le port défini par l'application
ENV PORT=5173
EXPOSE 5173

# Ajouter un fichier d'entrée pour exécuter l'application
CMD ["pnpm", "run", "preview"]
