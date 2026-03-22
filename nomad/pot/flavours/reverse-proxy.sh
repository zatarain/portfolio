#!/bin/sh
# Nginx Reverse Proxy Jail Bootstrap - Potluck-based
# Potluck nginx-nomad base already has Nginx installed
# This script configures Nginx for our reverse proxy needs

set -e

# Disable rc.d startup for Nginx (will be managed by Nomad)
sysrc nginx_enable="NO" 2>/dev/null || true

# Create custom Nginx configuration directory
mkdir -p /usr/local/etc/nginx/conf.d

# Ensure permissions on nginx configuration staged by copy-in
if [ -f "/usr/local/etc/nginx/nginx.conf" ]; then
  chown root:wheel /usr/local/etc/nginx/nginx.conf
  chmod 644 /usr/local/etc/nginx/nginx.conf
fi

echo "✓ Nginx reverse proxy configuration ready"
