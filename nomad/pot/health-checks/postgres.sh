#!/bin/sh
# PostgreSQL health check - verify database is accepting connections

su - postgres -c "psql -U postgres -d postgres -c 'SELECT 1;'" >/dev/null 2>&1
