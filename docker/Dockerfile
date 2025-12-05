FROM php:8.4-fpm-alpine

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
    jq \
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
COPY --from=ghcr.io/shopware/shopware-cli:bin /shopware-cli /usr/local/bin/shopware-cli
# RUN curl -1sLf 'https://dl.cloudsmith.io/public/friendsofshopware/stable/setup.alpine.sh' | bash && \
#     apk add shopware-cli

# RUN curl -L -o shopware-cli https://github.com/shopware/shopware-cli/releases/latest/download/shopware-cli-linux-amd64
# RUN chmod +x shopware-cli
# RUN mv shopware-cli /usr/local/bin/

# Installing PHP Redis extension
RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} \
  && pecl install redis \
  && docker-php-ext-enable redis \
  && apk del pcre-dev ${PHPIZE_DEPS} \
  && rm -rf /tmp/pear

# PHP Konfiguration
COPY docker/php/php.ini /usr/local/etc/php/conf.d/shopware.ini

# Working Directory
WORKDIR /var/www/html

# User für bessere Sicherheit
RUN adduser -D -u 1000 shopware && \
    chown -R shopware:shopware /var/www

USER shopware

EXPOSE 9000