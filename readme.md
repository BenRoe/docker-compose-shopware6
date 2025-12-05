# Vollständige Shopware 6 Docker-Umgebung

🚧 Diese Anleitung ist noch in der Bearbeitung!!!

[SOURCE](https://tutorialwelt.de/1294/docker-tutorial-9-praxis-shopware-6-entwicklungsumgebung-mit-docker.htm)

- [Vollständige Shopware 6 Docker-Umgebung](#vollständige-shopware-6-docker-umgebung)
  - [Projektstruktur](#projektstruktur)
  - [Installation](#installation)
    - [1 Docker-Umgebung starten](#1-docker-umgebung-starten)
    - [2 Shopware 6 installieren](#2-shopware-6-installieren)
    - [3. Frontend Build](#3-frontend-build)
    - [4 Zugriff](#4-zugriff)
  - [Entwickler-Workflow](#entwickler-workflow)
    - [Plugin-Entwicklung](#plugin-entwicklung)
    - [Theme-Entwicklung](#theme-entwicklung)
    - [Database Management](#database-management)
  - [Debugging](#debugging)
    - [Xdebug aktivieren](#xdebug-aktivieren)
    - [PHPStorm Konfiguration](#phpstorm-konfiguration)
  - [Production Deployment](#production-deployment)
    - [docker-compose.prod.yml](#docker-composeprodyml)
  - [Backup \& Restore](#backup--restore)
    - [Vollständiges Backup](#vollständiges-backup)
    - [Restore](#restore)
  - [Performance-Optimierung](#performance-optimierung)
    - [1 OpCache aktivieren](#1-opcache-aktivieren)
    - [2 Redis für Sessions](#2-redis-für-sessions)
    - [3 Redis für Cache](#3-redis-für-cache)
    - [HTTP Cache aktivieren](#http-cache-aktivieren)
    - [4 Asset Building optimieren](#4-asset-building-optimieren)
  - [Troubleshooting](#troubleshooting)
    - [Cache-Probleme](#cache-probleme)
    - [Permissions-Fehler](#permissions-fehler)
    - [MySQL Connection Error](#mysql-connection-error)


Eine produktionsreife Docker-Setup für Shopware 6 Development mit allen benötigten Services.

Projektstruktur
---------------

```
shopware-docker/
├── docker-compose.yml
├── docker/
│   ├── Dockerfile
│   ├── nginx/
│   │   └── default.conf
│   └── php/
│       ├── php.ini
│       └── php-fpm.conf
├── src/
│   └── (Shopware 6 Code)
└── .env

```

## Installation

### 1 Docker-Umgebung starten

```bash
docker compose up -d

```

### 2 Shopware 6 installieren

```bash
# In den App-Container
docker compose exec app bash

# Shopware per Composer installieren
# composer create-project shopware/production .
shopware-cli project create .

# Oder Clone von Git
git clone https://github.com/shopware/platform shopware6
cd shopware6
composer install

# Shopware Setup
bin/console system:install --basic-setup --create-database
shopware-cli project generate-jwt .
# bin/console plugin:refresh
# bin/console theme:refresh
bin/console assets:install

# Admin-User erstellen
bin/console user:create --admin --password johndoe123 --firstName John --lastName Doe --email john@doe.com john

```

### 3. Frontend Build

```bash
# Storefront bauen
./bin/build-storefront.sh

# Oder mit Node-Container
docker compose --profile dev up node

```

### 4 Zugriff

- Storefront: http://localhost:8000
- Admin: http://localhost:8000/admin

## Entwickler-Workflow

### Plugin-Entwicklung

```bash
# In den Container
docker compose exec app bash

# Plugin erstellen
bin/console plugin:create SwagExamplePlugin

# Plugin installieren
bin/console plugin:refresh
bin/console plugin:install SwagExamplePlugin --activate

# Cache leeren
bin/console cache:clear

```

### Theme-Entwicklung

```bash
# Theme erstellen
bin/console theme:create MyTheme

# Theme zuweisen
bin/console theme:change MyTheme

# Theme kompilieren
bin/console theme:compile

# Watch Mode mit Node
docker compose --profile dev up node

```

### Database Management

```bash
# SQL Import
docker compose exec -T mysql mysql -u shopware -pshopware shopware < backup.sql

# SQL Export
docker compose exec mysql mysqldump -u shopware -pshopware shopware > backup.sql

# Direkt in Container
docker compose exec mysql mysql -u shopware -pshopware shopware

```

## Debugging

### Xdebug aktivieren

`docker/php/php.ini` erweitern:

```ini
[xdebug]
zend_extension=xdebug.so
xdebug.mode=debug,develop
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.start_with_request=yes
xdebug.idekey=PHPSTORM

```

Dockerfile ergänzen:

```dockerfile
RUN apk add --no-cache $PHPIZE_DEPS && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug

```

### PHPStorm Konfiguration

1. Einstellungen → PHP → Servers
2. Name: `docker`
3. Host: `localhost`
4. Port: `8000`
5. Debugger: `Xdebug`
6. Path Mappings: `/var/www/html` → `./shopware`

## Production Deployment

### docker-compose.prod.yml

```yaml
services:
  app:
    environment:
      APP_ENV: prod
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G

  nginx:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M

  mysql:
    command: >
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_unicode_ci
      --innodb-buffer-pool-size=2G

```

Starten:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

```

## Backup & Restore

### Vollständiges Backup

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/$DATE"

mkdir -p $BACKUP_DIR

# Datenbank
docker compose exec -T mysql mysqldump -u shopware -pshopware shopware > $BACKUP_DIR/database.sql

# Files
docker compose exec app tar czf - /var/www/html/files /var/www/html/media > $BACKUP_DIR/files.tar.gz

echo "Backup erstellt: $BACKUP_DIR"

```

### Restore

```bash
#!/bin/bash
# restore.sh

BACKUP_DIR=$1

# Datenbank
docker compose exec -T mysql mysql -u shopware -pshopware shopware < $BACKUP_DIR/database.sql

# Files
cat $BACKUP_DIR/files.tar.gz | docker compose exec -T app tar xzf - -C /

```

## Performance-Optimierung

### 1 OpCache aktivieren

Bereits in `php.ini` konfiguriert.

### 2 Redis für Sessions

`config/packages/framework.yaml`:

```yaml
framework:
    session:
        handler_id: 'redis://redis:6379/0'

```

### 3 Redis für Cache

```bash
docker compose exec app bash
composer require predis/predis
```

`.env.local`:

```env
### Redis – Datenbanken ###
# 0 = HTTP Cache
REDIS_URL_HTTP_CACHE=redis://redis:6379/0

# 1 = Session Storage
REDIS_URL_SESSIONS=redis://redis:6379/1

# 2 = Increment Counter (z. B. User-Aktivität, Message Queue)
REDIS_URL_INCREMENT=redis://redis:6379/2

# 3 = Default Cache (App + System)
REDIS_URL_CACHE=redis://redis:6379/3

# 4 Message Queue
REDIS_URL_MESSENGER=redis://redis:6379/4
```

```yaml
# config/packages/cache.yaml
framework:
  cache:
    app: cache.adapter.redis_tag_aware
    system: cache.adapter.redis_tag_aware
    default_redis_provider: '%env(resolve:REDIS_URL_CACHE)%'

    # Nur zusätzliche Pools dürfen hier stehen (keine cache.app oder cache.system)
    pools:
      cache.custom:
        adapters:
          - cache.adapter.redis_tag_aware
          - cache.adapter.filesystem
          
```

```
docker compose exec app bin/console cache:clear
```


### HTTP Cache aktivieren

```bash
bin/console system:config:set core.httpCache.enabled true
bin/console system:config:set core.httpCache.warmUpEnabled true

```

### 4 Asset Building optimieren

```bash
# Production Build
./bin/build-storefront.sh

# Mit Optimierung
NODE_ENV=production npm run build

```

## Troubleshooting

### Cache-Probleme

```bash
docker compose exec app bin/console cache:clear
docker compose exec app bin/console cache:warmup

```

### Permissions-Fehler

```bash
docker compose exec -u root app chown -R shopware:shopware /var/www/html

```

### MySQL Connection Error

```bash
# Health Check
docker compose ps mysql

# Logs prüfen
docker compose logs mysql

# Verbindung testen
docker compose exec app nc -zv mysql 3306

```
