# Utilise une image Node.js officielle légère
FROM node:18-alpine

# Définit le dossier de travail dans le conteneur
WORKDIR /usr/src/app

# Copie d'abord les fichiers de dépendances (optimisation cache Docker)
COPY package*.json ./

# Installe les dépendances de production uniquement
RUN npm install --omit=dev

# Copie le reste du code de l'application
COPY . .

# Expose le port sur lequel l'application écoute
EXPOSE 3000

# Lance l'application
CMD ["node", "index.js"]
