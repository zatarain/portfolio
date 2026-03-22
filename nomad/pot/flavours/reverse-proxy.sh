#!/bin/sh
# Nginx Reverse Proxy Jail Bootstrap - Potluck-based
# Potluck nginx-nomad base already has Nginx installed
# This script configures Nginx for our reverse proxy needs

set -e

# Disable rc.d startup for Nginx (will be managed by Nomad)
sysrc nginx_enable="NO" 2>/dev/null || true

# Create custom Nginx configuration directory
mkdir -p /usr/local/etc/nginx/conf.d

# Configure Nginx as reverse proxy placeholder
cat > /usr/local/etc/nginx/nginx.conf <<'EOF'
user www;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /usr/local/etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    gzip on;

    include /usr/local/etc/nginx/conf.d/*.conf;
}
EOF

echo "✓ Nginx reverse proxy configuration ready"
