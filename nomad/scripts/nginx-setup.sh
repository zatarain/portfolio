#!/bin/sh
set -e

# Copy main Nginx config
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure nginx config directory exists
mkdir -p /usr/local/etc/nginx/conf.d

# Copy portfolio configuration
cp "${SCRIPT_DIR}/nginx.conf" /usr/local/etc/nginx/conf.d/portfolio.conf

# Verify nginx configuration
nginx -t

# Create log directory if it doesn't exist
mkdir -p /var/log/nginx
chown -R nginx:nginx /var/log/nginx

# Create certbot directory for ACME challenges
mkdir -p /var/www/certbot
chown -R nginx:nginx /var/www/certbot

echo "Nginx setup complete"
