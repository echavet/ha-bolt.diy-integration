# Étape 1 : Builder l'image
FROM node:16-alpine AS builder

WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Étape 2 : Image finale pour le runtime
FROM node:16-alpine

WORKDIR /app
COPY --from=builder /app /app

# Rendre le script exécutable
RUN chmod +x /app/run.sh

ENV NODE_ENV=production
ENV PORT=5173

EXPOSE 5173

CMD ["/app/run.sh"]
