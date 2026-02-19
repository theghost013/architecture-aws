#!/bin/bash -xe

# L'AMI ECS-optimisée a déjà Docker installé et démarré !
# On a juste besoin de se connecter à ECR et lancer le conteneur.

# Connexion à ECR grâce au rôle IAM de l'instance
aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin $(echo ${ecr_image_uri} | cut -d'/' -f1)

# Téléchargement et démarrage de l'image
docker pull ${ecr_image_uri}

docker run -d \
  --name student-app \
  --restart always \
  -p 80:3000 \
  -e APP_DB_HOST=${rds_endpoint} \
  -e APP_PORT=3000 \
  ${ecr_image_uri}
