FROM php:8.2-fpm-alpine

# Installiere Abhängigkeiten
RUN apk add --no-cache \
    bash \
    git \
    curl \
    zip \
    unzip \
    libzip-dev \
    libpng-dev \
    libwebp-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    nodejs \
    npm

# PHP Extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) \
    pdo pdo_mysql \
    mysqli \
    zip \
    gd \
    intl \
    opcache \
    bcmath \
    soap \
    mbstring

# Composer installieren
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Shopware CLI (optional)
# RUN curl -1sLf 'https://dl.cloudsmith.io/public/friendsofshopware/stable/setup.alpine.sh' | bash && \
#     apk add shopware-cli

RUN curl -1sLf \
  'https://dl.cloudsmith.io/public/friendsofshopware/stable/setup.deb.sh' \
  | sudo -E bash
sudo apt install shopware-cli

# PHP Konfiguration
COPY docker/php/php.ini /usr/local/etc/php/conf.d/shopware.ini

# Working Directory
WORKDIR /var/www/html

# User für bessere Sicherheit
RUN adduser -D -u 1000 shopware && \
    chown -R shopware:shopware /var/www

USER shopware

EXPOSE 9000