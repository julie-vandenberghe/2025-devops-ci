FROM node:LTS

# Installer pnpm
RUN npm install -g pnpm

# Passer à l'utilisateur non-root
USER node