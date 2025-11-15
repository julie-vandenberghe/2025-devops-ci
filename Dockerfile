# ---------- Étape 1 : compilation + migrations
FROM node:20-alpine AS builder

# Crée un dossier de travail (définit où toutes les commandes suivantes seront exec)
WORKDIR /app

COPY package.json pnpm-lock.yaml ./

# Installer pnpm via corepack (utilise exactement la version définie dans pnpm-lock.yaml)
RUN corepack enable

# Installer les dépendances
RUN pnpm install

# Copier le reste du code
COPY . .

# On lance le build
RUN pnpm build


# ---------- Étape 2 : execution
FROM node:20-alpine as runner

WORKDIR /app

# Utiliser la version exacte du projet
RUN corepack enable

# Copie uniquement le build + package.json + drizzle config + schema dans l'img finale
COPY package.json ./
COPY --from=builder /app/.output ./.output
COPY --from=builder /app/drizzle.config.* ./
COPY --from=builder /app/src ./src


# Installer les dépendances de prod
RUN pnpm install

# Passer à l'utilisateur non-root
USER node

# Démarrage du serveur
CMD ["node", ".output/server/index.mjs"]