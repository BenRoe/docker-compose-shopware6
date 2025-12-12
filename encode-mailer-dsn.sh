#!/usr/bin/env bash

# ==============================================================================
# URL-encode MAILER_DSN credentials for Shopware
# ==============================================================================
# This script URL-encodes username and password for use in MAILER_DSN
# 
# Special characters that need encoding include:
#   @ # $ % & = + : / ? [ ] space and others
#
# Usage:
#   ./encode-mailer-dsn.sh
#   (Interactive prompts for input)
#
# Or with arguments:
#   ./encode-mailer-dsn.sh "admin@yourDomain.de" "Pass@word#123" "mx.yourDomain.de" "465"
# ==============================================================================

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# URL encode function
urlencode() {
    local string="$1"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) 
                o="${c}" 
                ;;
            * ) 
                printf -v o '%%%02x' "'$c"
                ;;
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Shopware MAILER_DSN Encoder${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get inputs
if [ $# -eq 4 ]; then
    # Arguments provided
    USERNAME="$1"
    PASSWORD="$2"
    HOST="$3"
    PORT="$4"
else
    # Interactive mode
    echo -e "${YELLOW}Enter your SMTP credentials:${NC}"
    echo ""
    
    read -p "Username (e.g., admin@example.de): " USERNAME
    read -sp "Password: " PASSWORD
    echo ""
    read -p "SMTP Host (e.g., mx.yourDomain.de): " HOST
    read -p "SMTP Port (e.g., 465, 587, 25): " PORT
fi

# Validate inputs
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$HOST" ] || [ -z "$PORT" ]; then
    echo -e "${RED}Error: All fields are required!${NC}"
    exit 1
fi

# URL encode username and password
ENCODED_USERNAME=$(urlencode "$USERNAME")
ENCODED_PASSWORD=$(urlencode "$PASSWORD")

# Determine encryption parameter based on port
ENCRYPTION=""
case "$PORT" in
    465)
        ENCRYPTION="?encryption=ssl"
        ;;
    587)
        ENCRYPTION="?encryption=tls"
        ;;
    25)
        ENCRYPTION=""
        echo -e "${YELLOW}Warning: Port 25 typically uses no encryption (not recommended for production)${NC}"
        ;;
    *)
        echo -e "${YELLOW}Warning: Unknown port. You may need to add ?encryption=ssl or ?encryption=tls manually${NC}"
        ;;
esac

# Build MAILER_DSN
MAILER_DSN="smtp://${ENCODED_USERNAME}:${ENCODED_PASSWORD}@${HOST}:${PORT}${ENCRYPTION}"

# Display results
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Results${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Original Username:${NC} $USERNAME"
echo -e "${BLUE}Encoded Username:${NC}  $ENCODED_USERNAME"
echo ""
echo -e "${BLUE}Original Password:${NC} [hidden]"
echo -e "${BLUE}Encoded Password:${NC}  $ENCODED_PASSWORD"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Your MAILER_DSN:${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "$MAILER_DSN"
echo ""
echo -e "${YELLOW}Copy this line to your .env or Coolify environment variables:${NC}"
echo ""
echo -e "${BLUE}MAILER_DSN=${NC}$MAILER_DSN"
echo ""
echo -e "${GREEN}✓ Done!${NC}"