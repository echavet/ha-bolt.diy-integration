# Utilisation de l'image officielle Bolt.diy
    FROM ghcr.io/stackblitz-labs/bolt.diy:1.4

    # Configuration spécifique pour Home Assistant
    ENV PORT=5173
    EXPOSE 5173

    # Le CMD est déjà défini dans l'image de base
