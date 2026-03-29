#!/bin/sh
set -e

API_DIR="/opt/custom/var/api"
cd "$API_DIR"

# Load Nomad-rendered environment file if present
if [ -f "$API_DIR/.env" ]; then
	set -a
	. "$API_DIR/.env"
	set +a
fi

# Ensure puma pid directory exists
mkdir -p tmp/pids

# Install Ruby dependencies
bundle config set deployment true
bundle config --global silence_root_warning true
bundle config set path "vendor/bundle"
bundle config set without "test development"
bundle install

# Prepare database
bundle exec rake db:create 2>/dev/null || true
bundle exec rake db:migrate 2>/dev/null || true

# Run application server
exec bundle exec puma -b tcp://0.0.0.0:3000
