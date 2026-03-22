#!/bin/sh
# Nginx Reverse Proxy Jail Bootstrap

set -e

# Disable SSL verification for initial pkg bootstrap (will be fixed after ca_root_nss install)
export SSL_NO_VERIFY_PEER=1
export SSL_NO_VERIFY_HOST=1

# Update package manager
[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap

# Install CA certificates (fixes SSL verification)
ASSUME_ALWAYS_YES=yes pkg install -y ca_root_nss

# Unset SSL bypass - now we have proper certs
unset SSL_NO_VERIFY_PEER SSL_NO_VERIFY_HOST

# Install Nginx
pkg install -y nginx

# Disable rc.d startup (will be managed by Nomad)
sysrc nginx_enable="NO"

# Clean up
pkg clean -y
