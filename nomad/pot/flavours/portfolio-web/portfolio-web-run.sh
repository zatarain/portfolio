#!/bin/sh
set -e

WEB_DIR="/opt/custom/var/web"
cd "$WEB_DIR"

# Load Nomad-rendered environment file if present
if [ -f "$WEB_DIR/.env" ]; then
	set -a
	. "$WEB_DIR/.env"
	set +a
fi

# Install Node dependencies
echo "Installing Node dependencies..."
npm ci --omit=dev || npm install --omit=dev

# Build Next.js application
echo "Building Next.js application..."
npm run build

echo "Web application build complete"

# Run the Next.js server
node run start
