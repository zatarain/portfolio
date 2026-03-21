#!/bin/sh
# Next.js Web Jail Bootstrap

set -e

# Update package manager
[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf
ASSUME_ALWAYS_YES=yes pkg bootstrap

# Install Node.js
pkg install -y node npm

# Clean up
pkg clean -y
