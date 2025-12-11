#syntax=docker/dockerfile:1.4

ARG PHP_VERSION=8.4
FROM ghcr.io/shopware/docker-base:$PHP_VERSION-fpm AS base-image
FROM ghcr.io/shopware/shopware-cli:latest-php-$PHP_VERSION AS shopware-cli

FROM shopware-cli AS build

ADD . /src
WORKDIR /src

RUN --mount=type=secret,id=packages_token,env=SHOPWARE_PACKAGES_TOKEN \
    --mount=type=secret,id=composer_auth,dst=/src/auth.json \
    --mount=type=cache,target=/root/.composer \
    --mount=type=cache,target=/root/.npm \
    /usr/local/bin/entrypoint.sh shopware-cli project ci /src

FROM base-image AS final

COPY --from=build --chown=82 --link /src /var/www/html

# Working Directory
WORKDIR /var/www/html

# User für bessere Sicherheit
RUN adduser -D -u 1000 shopware && \
    chown -R shopware:shopware /var/www

USER shopware

EXPOSE 9000