#!/bin/sh
# Rails API Jail Bootstrap - Potluck-based
# Using ssl-bootstrap base (Node.js and Ruby installed here)
# This script installs Rails dependencies

set -e

# Install Node.js, Ruby, PostgreSQL client, and build tools
ASSUME_ALWAYS_YES=yes pkg install -y ruby40 git gmake readline postgresql15-client
git clone --depth 1 --branch 2026Q4 https://git.FreeBSD.org/ports.git /usr/ports
make -C /usr/ports/devel/ruby-gems RUBY_VER=4.0 install clean
echo "✓ Rails API environment ready - waiting for code deployment"
