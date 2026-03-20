# 🔧 Troubleshooting Guide for Nomad + Pot + Jails Deployment

## ⚠️ Common Issues and Solutions

### 🌐 Network & Connectivity Issues

#### "Cannot connect to Nomad" or "connection refused"
```sh
# Check if Nomad is running
ps aux | grep nomad

# Check if Nomad is listening on correct port
sockstat -l | grep 4646

# Verify Nomad configuration
nomad config validate /etc/nomad.d/nomad.hcl

# Start Nomad manually to see errors
nomad agent -config /etc/nomad.d/nomad.hcl

# Check Nomad logs
tail -f /var/log/nomad/nomad.log
```

**Solution:**
- Ensure Nomad package is installed: `pkg install nomad`
- Check `/etc/nomad.d/nomad.hcl` is syntactically correct
- Verify port 4646 is not in use by another service
- Run Nomad with debug logging: `NOMAD_LOG_LEVEL=debug nomad agent -config ...`

#### Database connection refused in API
```sh
# Check PostgreSQL is running in jail
pot exec portfolio-db ps aux | grep postgres

# Check PostgreSQL is listening
pot exec portfolio-db netstat -an | grep 5432

# Check database connectivity from API jail
pot exec portfolio-api psql -h portfolio-db -U portfolio -d portfolio -c "SELECT 1;"

# Check credentials
echo $POSTGRES_PASSWORD
echo $POSTGRES_USERNAME
```

**Solution:**
- Ensure `POSTGRES_HOST` environment variable is correct (likely `portfolio-db` for jail hostname)
- Verify credentials in `env.sh` match database initialization
- Check database permissions: `psql -U postgres -c "SELECT * FROM pg_user;"`
- Initialize database if not done: `nomad job restart portfolio-postgres`

#### Frontend can't reach API
```sh
# Check API is actually running
nomad job status portfolio-api

# Test API from host
curl http://localhost:3000/health

# Check API URL in Next.js config
pot exec portfolio-web env | grep API_URL
```

**Solution:**
- Ensure `NEXT_PUBLIC_API_URL` matches API location (typically `http://localhost:3000`)
- Check API is responding to requests: `curl -v http://localhost:3000/health`
- Verify ports are exposed correctly in Nomad job definitions
- Check Next.js build includes correct API URL

#### "Cannot reach jail from host"
```sh
# List jails and check network
pot list
pot show portfolio-db

# Check jail routing
netstat -rn | grep 172.16

# Ping jail (if VNET enabled)
ping <jail-ip>

# Check firewall rules
pfctl -s rules | head -20
```

**Solution:**
- Verify jails are using VNET networking: `POT_VNET=1` in pot.conf
- Check if firewall (pf) is blocking traffic: `pfctl -d` to disable temporarily
- Ensure host volumes are mounted inside jails: `pot exec <jail> ls -la /data`

### 💾 PostgreSQL Specific Issues

#### "psql: error: could not connect to server"
```sh
# Check PostgreSQL data directory permissions
ls -la /data/portfolio-db/

# Check PostgreSQL is initialized
pot exec portfolio-db ls -la /var/lib/postgresql/data/pgdata/

# Check PostgreSQL configuration
pot exec portfolio-db cat /var/lib/postgresql/data/pgdata/postgresql.conf | grep listen_addresses
```

**Solution:**
- Ensure `/data/portfolio-db` has correct permissions (700 for postgres user)
- Re-initialize if corrupted: `pot exec portfolio-db rm -rf /var/lib/postgresql/data/pgdata/*`
- Then restart job: `nomad job restart portfolio-postgres`

#### Database won't initialize
```sh
# Check Nomad job logs
nomad alloc logs <postgres-allocation-id>

# Check if initialization script ran
pot exec portfolio-db ls -la /tmp/init-postgres.sh

# Manually initialize
pot exec portfolio-db su - postgres -c "initdb -D /var/lib/postgresql/data/pgdata"
```

**Solution:**
- Check that PostgreSQL package installed correctly: `pot exec portfolio-db pkg list | grep postgresql`
- Verify initialization script in postgres.hcl template section
- Manual initialization may be needed for first setup

#### "FATAL: remaining connection slots are reserved"
```sh
# Check current connections
psql -h localhost -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# Increase pool size in postgres.hcl or database.yml
# max_connections in postgresql.conf
```

**Solution:**
- Reduce RAILS_MAX_THREADS in api.hcl (or environment)
- Increase PostgreSQL `max_connections` in postgresql.conf
- Close idle connections and restart

### 🜠 Rails/API Specific Issues

#### "Rails can't find gem bundler"
```sh
# Check Ruby version in API jail
pot exec portfolio-api ruby --version

# Check if bundler is installed
pot exec portfolio-api gem list | grep bundler

# Check Gemfile.lock exists
ls -la /api/Gemfile.lock
```

**Solution:**
- Install bundler: `pot exec portfolio-api gem install bundler`
- Verify Gemfile is present: `/api/Gemfile`
- Regenerate Gemfile.lock: `bundle install` (on host, then commit)

#### "Could not locate Gemfile"
```sh
# Check source volume is mounted
pot exec portfolio-api ls -la /api/

# Check volume in Nomad job
nomad job inspect portfolio-api | grep -A5 volume_mount
```

**Solution:**
- Verify `api_source` host volume points to `/home/ulises/projects/portfolio/api`
- Check Nomad client configuration has host_volume defined
- Restart Nomad client or resubmit job

#### Rails migrations fail
```sh
# Check database connection first
pot exec portfolio-api psql -h portfolio-db -U portfolio -d portfolio -c "\dt"

# Run migrations manually
pot exec portfolio-api /bin/sh -c "cd /api && bundle exec rake db:migrate"

# Check migration status
pot exec portfolio-api /bin/sh -c "cd /api && bundle exec rake db:migrate:status"
```

**Solution:**
- Ensure database is initialized first
- Check database credentials in POSTGRES_* environment variables
- Run migrations manually before starting API if needed

### 💞 Next.js/Frontend Specific Issues

#### "next: command not found"
```sh
# Check Node installation
pot exec portfolio-web node --version
pot exec portfolio-web npm --version

# Check if next is installed
pot exec portfolio-web npm list next
```

**Solution:**
- Reinstall Node: `pot exec portfolio-web pkg install -y node`
- Install npm dependencies: `pot exec portfolio-web npm ci --only=production`

#### Frontend shows 404 for API calls
```sh
# Check environment variables in next job
nomad alloc logs <web-allocation-id>

# Verify API_URL is set
pot exec portfolio-web env | grep API_URL

# Check .next build includes API URL
pot exec portfolio-web ls -la /web/.next/
```

**Solution:**
- Ensure `NEXT_PUBLIC_API_URL` is set in web.hcl template
- Rebuild Next.js: `npm run build`
- Check API is actually accessible at that URL

### 🚀 Nomad Job Submission Issues

#### "Job failed to validate"
```sh
# Validate job file syntax
nomad job validate jobs/postgres.hcl
nomad job validate jobs/api.hcl
nomad job validate jobs/web.hcl

# Check specific errors
nomad job plan jobs/postgres.hcl
```

**Solution:**
- Fix HCL syntax errors reported by validate command
- Check variable interpolation (${...})
- Verify all required fields are present

#### "No suitable nodes"
```sh
# Check available nodes
nomad node status

# Check node compatibility
nomad node status -verbose <node-id>

# Check job constraints
nomad job inspect portfolio-api | grep -A3 constraint
```

**Solution:**
- Ensure node meets job constraints (e.g., FreeBSD required)
- Verify node has enough resources (CPU, memory)
- Remove restrictive constraints if testing

#### Jobs pending/stuck
```sh
# Check job status in detail
nomad job status portfolio-api
nomad alloc status <allocation-id>

# Check node drain status
nomad node status -verbose <node-id> | grep Drain

# Force job placement
nomad job restart portfolio-api
```

**Solution:**
- Check if node is in drain mode: `nomad node drain -disable <node-id>`
- Verify resources available: `nomad node status -self`
- Increase job resource requests or add nodes

### 💾 Storage & Persistence Issues

#### "No such file or directory" for volumes
```sh
# Verify ZFS datasets created
zfs list | grep portfolio

# Check mountpoints
df -h | grep portfolio

# Check in Nomad config
cat /etc/nomad.d/nomad.hcl | grep -A5 host_volume
```

**Solution:**
- Create missing ZFS datasets: `zfs create zroot/portfolio-db`
- Make sure mountpoints exist: `mkdir -p /data/portfolio-db`
- Ensure Nomad client has been restarted after config changes

#### Data disappears after restart
```sh
# Check if data persists in ZFS
zfs list -s creation -r zroot/portfolio
zfs get mounted zroot/portfolio-db

# Check if ZFS snapshot exists
zfs list -t snapshot | grep portfolio
```

**Solution:**
- Ensure volume_mount is configured in job definitions
- Use `read_only = false` for volumes that need writes
- Consider ZFS snapshots for backups before troubleshooting

### ⚡ Performance Issues

#### High CPU/Memory usage
```sh
# Monitor real-time usage
top

# Check Nomad metrics
curl http://localhost:4646/v1/agent/metrics | jq .

# Check per-allocation usage
nomad alloc status -verbose <allocation-id>
```

**Solution:**
- Increase resource allocation in job definitions
- check for memory leaks in application
- Reduce worker count or thread pool size

#### Slow database queries
```sh
# Check PostgreSQL slow query log
pot exec portfolio-db tail -f /var/log/postgresql/postgresql.log

# Check table statistics
pot exec portfolio-api /bin/sh -c "psql -h portfolio-db -U portfolio -d portfolio -c 'ANALYZE;'"

# Create indexes if needed
pot exec portfolio-api /bin/sh -c "psql -h portfolio-db -U portfolio -d portfolio -c 'CREATE INDEX ...'"
```

**Solution:**
- Run VACUUM and ANALYZE on database
- Create indexes on frequently queried columns
- Increase shared_buffers in postgresql.conf

### 🔍 Logging & Debugging

#### Enable debug logging
```sh
# Nomad debug logging
export NOMAD_LOG_LEVEL=debug
nomad job status

# Application logging
nomad alloc logs -stderr -f <allocation-id>

# System logging
tail -f /var/log/messages
```

#### Capture full diagnostic information
```sh
#!/bin/sh
echo "=== Nomad Status ===" > /tmp/diagnostics.txt
nomad node status >> /tmp/diagnostics.txt
nomad job status >> /tmp/diagnostics.txt
echo "=== Jails ===" >> /tmp/diagnostics.txt
pot list >> /tmp/diagnostics.txt
echo "=== Network ===" >> /tmp/diagnostics.txt
netstat -rn >> /tmp/diagnostics.txt
echo "=== ZFS ===" >> /tmp/diagnostics.txt
zfs list >> /tmp/diagnostics.txt
# Send to support
cat /tmp/diagnostics.txt
```

---

## 🆘 When to Seek Help

If issues persist, gather this information:

1. Output of `nomad job status` for affected job
2. Full allocation logs: `nomad alloc logs -stderr <allocation-id>`
3. Nomad agent logs: `/var/log/nomad/nomad.log`
4. Jail status: `pot show <jail-name>`
5. System logs: `/var/log/messages`
6. Nomad configuration: `/etc/nomad.d/nomad.hcl`
7. Job file being submitted: `jobs/*.hcl`

## 📈 Additional Resources

- FreeBSD Handbook: https://docs.freebsd.org/en/books/handbook/
- Nomad Troubleshooting: https://www.nomadproject.io/docs/troubleshoot
- Pot GitHub Issues: https://github.com/pizzamig/pot/issues
- PostgreSQL Documentation: https://www.postgresql.org/docs/
