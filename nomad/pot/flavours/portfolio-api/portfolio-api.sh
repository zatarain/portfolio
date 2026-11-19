#!/bin/sh
# Rails API Jail Bootstrap - Potluck-based
# Using ssl-bootstrap base (Node.js and Ruby installed here)
# This script installs Rails dependencies

set -e

# Set Ruby 4.0 as the default Ruby for any ports built in this pot
echo "DEFAULT_VERSIONS+=ruby=4.0" >> /etc/make.conf

# Install Ruby, PostgreSQL client, and build tools
ASSUME_ALWAYS_YES=yes pkg install -y ruby40 git gmake readline postgresql15-client

# Create unversioned symlinks for the Ruby 4.0 binaries
for bin in erb irb racc rbs rdbg ri ruby typeprof; do
  if [ -x "/usr/local/bin/${bin}40" ]; then
    ln -sf "/usr/local/bin/${bin}40" "/usr/local/bin/${bin}"
  fi
done

# Clone ports into /tmp since /usr is read-only on multi-type pots
git clone --depth=1 --branch 2026Q4 https://git.freebsd.org/ports.git /tmp/ports

# Build ruby40-gems (which will also pull/configure unversioned symlinks if needed)
make -C /tmp/ports/devel/ruby-gems \
  PORTSDIR=/tmp/ports \
  DISTDIR=/tmp/distfiles \
  BATCH=yes \
  install clean

# Install Bundler (places /usr/local/bin/bundle and /usr/local/bin/bundler)
gem install bundler --no-document

# Clean up
rm -rf /tmp/ports /tmp/distfiles
ASSUME_ALWAYS_YES=yes pkg autoremove -y

echo "✓ Rails API environment ready - waiting for code deployment"
