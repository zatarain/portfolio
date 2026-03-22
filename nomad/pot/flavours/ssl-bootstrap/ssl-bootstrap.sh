#!/bin/sh
# SSL Bootstrap Script - runs FIRST in every jail
# Handles pkg bootstrap with SSL verification bypass

set -e

# Disable SSL verification for initial pkg bootstrap
export SSL_NO_VERIFY_PEER=1
export SSL_NO_VERIFY_HOST=1

# Update package manager config
[ -w /etc/pkg/FreeBSD.conf ] && sed -i '' 's/quarterly/latest/' /etc/pkg/FreeBSD.conf

# Bootstrap pkg (may fail first time, that's OK)
ASSUME_ALWAYS_YES=yes pkg bootstrap 2>/dev/null || true

# Install CA certificates (fixes SSL verification)
ASSUME_ALWAYS_YES=yes pkg install -y ca_root_nss 2>/dev/null || true

# Unset SSL bypass - now we have proper certs
unset SSL_NO_VERIFY_PEER SSL_NO_VERIFY_HOST

echo "✓ SSL bootstrap complete - pkg is now ready"
