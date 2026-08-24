# Image PHP-FPM de l'API CESIZen.
# Deux cibles : "dev" (code monté depuis l'hôte) et "prod" (code copié dans l'image).

# ── Socle commun ──────────────────────────────────────────────────────────────
FROM php:8.3-fpm AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql mbstring zip exif pcntl bcmath gd opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ── Développement ─────────────────────────────────────────────────────────────
# Pas de COPY : le code arrive par le bind mount déclaré dans compose.dev.yml.
FROM base AS dev

CMD ["php-fpm"]

# ── Production ────────────────────────────────────────────────────────────────
# Le code est copié dans l'image : le conteneur est immuable et autonome.
FROM base AS prod

COPY src/ /var/www/html/

RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress \
    && mkdir -p storage/framework/cache/data \
                storage/framework/sessions \
                storage/framework/views \
                storage/logs \
                bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

CMD ["php-fpm"]
