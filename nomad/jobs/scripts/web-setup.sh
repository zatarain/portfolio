#!/bin/sh
set -e

WEB_DIR="/web"
cd "$WEB_DIR"

# Install Node dependencies
echo "Installing Node dependencies..."
npm ci --only=production || npm install --production

# Build Next.js application
echo "Building Next.js application..."
npm run build

echo "Web application build complete"
