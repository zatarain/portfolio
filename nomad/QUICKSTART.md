# ⚡ Quick-Start Checklist for Nomad + Pot + Jails Deployment

## 📋 Pre-Deployment Checklist

### System Requirements
- [ ] FreeBSD 13.2+ installed and updated
- [ ] Root/sudo access verified
- [ ] ZFS pool available (`zfs list`)
- [ ] Network connectivity confirmed

### Package Installation
```sh
# Run these as root
sudo pkg update
sudo pkg install -y nomad pot postgresql14-client
```
- [ ] Nomad installed (`which nomad`)
- [ ] Pot installed (`which pot`)

## 🔧 Preparation Phase (Sequential Order)

### 1. Setup Pot Jails
```sh
cd portfolio/nomad/pot
sudo sh setup-jails.sh
```
- [ ] All four jails created (reverse-proxy, databases, portfolio-api, portfolio-web)
- [ ] ZFS datasets created at /data/portfolio-*
- [ ] Jails can be listed: `pot list`

### 2. Configure Nomad Agent
```sh
# Copy example config
sudo cp portfolio/nomad/pot/nomad-config-example.hcl /etc/nomad.d/nomad.hcl

# Verify paths
ls -la /var/lib/nomad
ls -la /etc/nomad.d/
```
- [ ] Nomad config file exists at `/etc/nomad.d/nomad.hcl`
- [ ] Host volumes configured correctly
- [ ] raw_exec driver enabled

### 3. Start Nomad
```sh
# Option A: Using service (if rc.d script exists)
sudo sysrc nomad_enable="YES"
sudo sysrc nomad_config="/etc/nomad.d"
sudo service nomad start

# Option B: Manual startup
sudo mkdir -p /var/log/nomad
sudo nomad agent -config /etc/nomad.d/nomad.hcl &

# Verify startup
sleep 3
nomad node status
```
- [ ] Nomad agent started without errors
- [ ] Node appears in `nomad node status`
- [ ] Nomad UI accessible at http://localhost:4646

### 4. Prepare Environment
```sh
# Copy and edit environment file
cp portfolio/nomad/pot/env.sh ~/.env.nomad
# Edit ~/.env.nomad with your credentials
source ~/.env.nomad
```
- [ ] Environment variables set (`echo $POSTGRES_PASSWORD`)
- [ ] Database password configured (don't use 'changeme')
- [ ] AWS credentials configured (if needed for CV upload)
- [ ] Instagram tokens configured (if needed)

### 5. Deploy Applications
```sh
cd portfolio

# Make deploy script executable
chmod +x nomad/deploy.sh

# Run deployment (Nginx → PostgreSQL → API → Web)
./nomad/deploy.sh
```
- [ ] Nginx reverse proxy deployed
- [ ] PostgreSQL job submitted
- [ ] API job submitted
- [ ] Web job submitted
- [ ] All allocations running: `nomad job status`

## ✅ Post-Deployment Verification

### Check Job Status
```sh
nomad job status
nomad job status portfolio-nginx
nomad job status portfolio-postgres
nomad job status portfolio-api
nomad job status portfolio-web
```
- [ ] All jobs listed
- [ ] All jobs show as "running"
- [ ] No failed allocations
- [ ] All jobs show as "running"
- [ ] No failed allocations

### Check Service Ports
```sh
# From host
sockstat -l | grep -E '80|443|3000|5000|5432'

# Verify connectivity
curl http://localhost/                    # Redirects to HTTPS
curl https://localhost/ -k                # Frontend (self-signed cert)
curl https://localhost/api -k             # API (self-signed cert)
psql -h localhost -U portfolio -d portfolio
```
- [ ] Nginx listening on 80 & 443
- [ ] Rails API listening on 3000 (via Nginx)
- [ ] Next.js frontend listening on 5000 (via Nginx)
- [ ] PostgreSQL listening on 5432

### Check Jail Connectivity
```sh
pot list
pot show databases
pot show portfolio-api
pot show portfolio-web

# Execute commands in jails
pot exec databases ps aux | grep postgres
pot exec portfolio-api ps aux | grep ruby
pot exec portfolio-web ps aux | grep node
```
- [ ] All jails running
- [ ] Services active inside jails
- [ ] Network interfaces assigned

### Check Logs
```sh
# View Nomad logs
tail -f /var/log/nomad/nomad.log

# View allocation logs
nomad alloc logs -f <allocation-id>

# View from inside jail
pot exec portfolio-api tail -f /var/log/production.log
```
- [ ] No errors in Nomad logs
- [ ] Services starting correctly
- [ ] Database migrations completed (API logs)

### Database Verification
```sh
# Connect to database
psql -h localhost -U portfolio -d portfolio

# In psql:
> SELECT 1;
> \dt
> SELECT PostGIS_Version();
```
- [ ] Database connection successful
- [ ] Tables exist (if database was initialized)
- [ ] PostGIS extension loaded

## 🔍 Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| Nomad won't start | Check `/etc/nomad.d/nomad.hcl` syntax: `nomad config validate /etc/nomad.d/nomad.hcl` |
| Jobs won't submit | Ensure Nomad is running: `nomad server members` |
| Services can't connect to database | Check jail networking, verify POSTGRES_HOST in env |
| Database won't initialize | Check PostgreSQL is running in jail: `pot exec databases service postgresql status` |
| Port already in use | Check for conflicts: `sockstat -l \| grep 80` or `sockstat -l \| grep 443` |
| SSL certificate not valid | Using self-signed for testing. Use Let's Encrypt for production |
| Out of memory | Increase Nomad memory allocation or reduce resource requirements in .hcl files |

## ↩️ Rollback Plan

If anything goes wrong:

```sh
# Stop all jobs gracefully
nomad job stop portfolio-web
nomad job stop portfolio-api
nomad job stop portfolio-postgres

# Destroy jails (WARNING: deletes all data)
pot stop portfolio-web portfolio-api databases
pot destroy portfolio-web portfolio-api databases

# Clean up ZFS datasets (WARNING: deletes all data)
# zfs destroy zroot/portfolio-db (if needed)

# Restart Nomad
service nomad restart
```

## 🎯 Next Steps After Successful Deployment

1. **Set up monitoring**
   - Install Prometheus + Grafana for metrics
   - Configure Nomad telemetry endpoints

2. **Configure backups**
   - Schedule PostgreSQL backups via ZFS snapshots
   - `zfs snapshot zroot/databases@backup-$(date +%s)`

3. **Set up TLS/Security**
   - Configure Nomad TLS
   - Set up ACLs

4. **Load testing**
   - Test API endpoints
   - Verify frontend renders correctly
   - Load test with tools like wrk or ab

5. **Production hardening**
   - Configure resource limits more strictly
   - Set up health checks and auto-restarts
   - Monitor disk usage and clean up periodically

## 📚 Useful Commands Reference

```sh
# Nomad
nomad node status                           # View all nodes
nomad job status                            # View all jobs
nomad alloc status <id>                     # View allocation details
nomad alloc logs -f <id>                    # Follow allocation logs
nomad job stop <job>                        # Stop a job

# Pot
pot list                                    # List all jails
pot show <name>                             # Show jail details
pot exec <name> <cmd>                       # Run command in jail
pot start <name>                            # Start jail
pot stop <name>                             # Stop jail
pot console <name>                          # Interactive jail shell

# FreeBSD
jls                                         # List all jails (native)
jexec <jid> <cmd>                          # Run command in jail (native)

# Database
psql -h <host> -U <user> -d <dbname>      # Connect to PostgreSQL
pg_dump -h <host> -U <user> <db>          # Backup database
```

## 🆘 Support Resources

- [Nomad Documentation](https://www.nomadproject.io/docs)
- [Pot Documentation](https://pot.pizzamig.dev/)
- [FreeBSD Jails Handbook](https://docs.freebsd.org/en/books/handbook/jails/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

**Last Updated:** March 2026
**Created for:** Portfolio Application (Rails API + Next.js Frontend)
