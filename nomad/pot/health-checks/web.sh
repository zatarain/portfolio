#!/bin/sh
# Next.js frontend health check - verify frontend is responding

curl -f http://127.0.0.1:5000/ >/dev/null 2>&1
