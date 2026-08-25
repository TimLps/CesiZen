# Nginx en frontal de php-fpm.
# Le dossier public/ est copié dans l'image pour que la prod soit autonome ;
# en dev, compose.dev.yml le recouvre par un bind mount sur le code local.
FROM nginx:alpine

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY src/public /var/www/html/public
