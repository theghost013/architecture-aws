# Dockerfile simple pour une application Node.js
FROM node:18

# Créer le répertoire de travail
WORKDIR /usr/src/app

# Copier les fichiers de dépendances (si présents)
COPY package*.json ./

# Installer les dépendances
# RUN npm install

# Copier le reste du code de l'application
COPY . .

# Exposer le port de l'application
EXPOSE 80

# Commande pour démarrer l'application
CMD [ "npm", "start" ]
