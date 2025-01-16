#!/bin/bash

# Charger les variables d'environnement
export $(grep -v '^#' .env.local | xargs)

# Démarrer l'application
exec pnpm run dockerstart
