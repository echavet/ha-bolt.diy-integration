#!/usr/bin/env bash
set -e

# Fixer le chemin pour Ingress
export BASE_PATH=/ingress

# Lancer le serveur
pnpm run dev -- --host 0.0.0.0 --port 5173
