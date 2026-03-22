#!/bin/sh
# Next.js Web Jail Bootstrap

set -e

# Update package manager
[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap

# Install CA certificates (fixes SSL verification)
ASSUME_ALWAYS_YES=yes pkg install -y ca_root_nss

# Install Node.js
pkg install -y node npm

# Clean up
pkg clean -y
