#!/bin/sh
# Next.js Web Jail Bootstrap - Potluck-based
# Using ssl-bootstrap base (Node.js installed here)
# This script prepares the application environment

set -e

# Install Node.js and the CA bundle; npm is not required for pnpm or the app.
ASSUME_ALWAYS_YES=yes pkg install -y node26 ca_root_nss

# Install the official standalone FreeBSD x64 pnpm binary without running
# package lifecycle scripts.
PNPM_VERSION=12.21.0
PNPM_SHA256=52abce8d50e39322e0602ff1d5ce8e23e94c3e6030e98e46bcf58d64bb5cfff3
PNPM_ARCHIVE="/tmp/pnpm-freebsd-x64-${PNPM_VERSION}.tar.gz"
fetch -o "$PNPM_ARCHIVE" "https://github.com/pnpm/pnpm/releases/download/v${PNPM_VERSION}/pnpm-freebsd-x64.tar.gz"
if [ "$(sha256 -q "$PNPM_ARCHIVE")" != "$PNPM_SHA256" ]; then
	echo "pnpm archive checksum verification failed" >&2
	exit 1
fi
tar -xzf "$PNPM_ARCHIVE" -C /usr/local/bin pnpm
chmod 755 /usr/local/bin/pnpm
rm -f "$PNPM_ARCHIVE"
test "$(pnpm --version)" = "$PNPM_VERSION"

# Clean up unnecessary packages
pkg autoremove -y

echo "✓ Next.js application environment ready - waiting for code deployment"
