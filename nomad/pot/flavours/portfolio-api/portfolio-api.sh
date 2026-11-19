#!/bin/sh
# Rails API Jail Bootstrap - Potluck-based
# Using ssl-bootstrap base (Node.js and Ruby installed here)
# This script installs Rails dependencies

set -e

# Set Ruby 4.0 as the default Ruby for any ports built in this pot
echo "DEFAULT_VERSIONS+=ruby=4.0" >> /etc/make.conf

# Install Ruby, PostgreSQL client, and build tools
ASSUME_ALWAYS_YES=yes pkg install -y ruby40 git gmake readline postgresql15-client

# Clone ports into /tmp since /usr is read-only on multi-type pots
git clone --depth=1 --branch 2026Q4 https://git.freebsd.org/ports.git /tmp/ports

# Build ruby40-gems (which will also pull/configure unversioned symlinks if needed)
make -C /tmp/ports/devel/ruby-gems \
  PORTSDIR=/tmp/ports \
  DISTDIR=/tmp/distfiles \
  BATCH=yes \
  install clean

# Clean up
rm -rf /tmp/ports /tmp/distfiles
ASSUME_ALWAYS_YES=yes pkg autoremove -y

echo "✓ Rails API environment ready - waiting for code deployment"
