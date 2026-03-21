#!/bin/sh
# Nginx Reverse Proxy Jail Bootstrap

set -e

# Update package manager
[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap

# Install Nginx
pkg install -y nginx

# Disable rc.d startup (will be managed by Nomad)
sysrc nginx_enable="NO"

# Clean up
pkg clean -y
