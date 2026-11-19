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

# Install Node dependencies. Use the committed lockfile; fail rather than
# silently resolving a different dependency graph.
echo "Installing Node dependencies..."
pnpm install --frozen-lockfile

# Build Next.js application
echo "Building Next.js application..."
pnpm run build

# Keep only runtime dependencies for the production server.
pnpm prune --prod

echo "Web application build complete"

# Run the Next.js server
exec pnpm run start
