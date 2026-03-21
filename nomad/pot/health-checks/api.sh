#!/bin/sh
# Rails API health check - verify API is responding

curl -f http://127.0.0.1:3000/health >/dev/null 2>&1
