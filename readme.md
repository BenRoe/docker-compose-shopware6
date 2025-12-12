# Docker Compose Example for Shopware 6

🚧 Diese Anleitung ist noch in der Bearbeitung!!!

## What You Get

- ✅ MariaDB 11.4 - optimized for Shopware
- ✅ Redis Cache - 512MB for app cache
- ✅ Redis Session - 256MB for user sessions
- ✅ RabbitMQ - message queue with management UI
- ✅ Worker - process background jobs
- ✅ Scheduler - runs scheduled tasks

## URL-Encode script for the MAILER_DSN environment variable

1. Make the script executable

    ```bash
    chmod +x encode-mailer-dsn.sh
    ```

2. Run the script in interactive mode

    ```bash
    ./encode-mailer-dsn.sh
    ```

    or with arguments

    ```bash
    ./encode-mailer-dsn.sh "admin@yourDomain.de" "Pass@word#123" "mx.yourDomain.de" "465"    
    ```

3. Follow the steps

## Setup Steps in Coolify

1. Create new project in Coolify
2. Add Docker Compose resource
3. Paste the compose file above
4. Add environment variables
5. Set URL for Shopware container to https://myDomain.de:8000
6. Deploy
7. Wait for all services to be healthy (check logs)
8. Connect to shopware container terminal and run:

    ```bash
    # Install Shopware
    #shopware-cli project create .
    bin/console system:install --create-database --basic-setup
    composer require symfony/amqp-messenger
    # Create admin user
    bin/console user:create admin \
      --admin \
      --email="your-email@example.com" \
      --firstName="Admin" \
      --lastName="User" \
      --password="YourStrongPassword123"

    # Clear cache
    bin/console cache:clear
    ```

## How to Access RabbitMQ Management UI

- Method 1: SSH Tunnel (Easiest)

    ```bash
    bash# From your local machine
    ssh -L 15672:localhost:15672 your-user@your-coolify-server.com

    # Keep terminal open, then browse to:
    # http://localhost:15672
    # Username: shopware
    # Password: (your RABBITMQ_PASSWORD)
    ```

- Method 2: VS Code Remote SSH
  If you use VS Code:
  - Install ["Remote - SSH"](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension
  - Connect to your server
  - Forward port 15672
  - Access via http://localhost:15672