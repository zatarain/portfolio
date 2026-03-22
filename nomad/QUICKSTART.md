# Quick Start - Pot Flavours Approach

## Prerequisites

- FreeBSD 14.4 server with Pot 0.15.0+ installed
- ZFS pool initialized (`zfs list`)
- Nomad 1.9.6+ running
- SSH access to FreeBSD server

## Step 1: Install Pot Flavours (Linux)

```bash
cd /path/to/portfolio
./nomad/pot/install-flavours.sh root@your-freebsd-server
```

Verifies and copies all flavours to `/usr/local/etc/pot/flavours/` on the server.

## Step 2: Create Infrastructure (FreeBSD)

```bash
ssh root@your-freebsd-server
cd /path/to/portfolio

sudo ./nomad/pot/setup-jails-flavours.sh
```

**Output:**
```
✓ Pot framework initialized
✓ ZFS datasets created:
  • zroot/reverse-proxy → /data/reverse-proxy
  • zroot/databases → /data/databases
  • zroot/portfolio-api → /data/portfolio-api
  • zroot/portfolio-web → /data/portfolio-web
✓ Jails created:
  • reverse-proxy (Nginx)
  • databases (PostgreSQL 14)
  • portfolio-api (Rails 7)
  • portfolio-web (Next.js)
```

## Step 3: Deploy Application Code (from Linux or FreeBSD)

```bash
# Copy code to server (if not already there)
scp -r api/ web/ root@freebsd-server:/path/to/portfolio/

# Then on server:
ssh root@your-freebsd-server
cd /path/to/portfolio

sudo ./nomad/pot/deploy-flavours.sh
```

**Output:**
```
✓ Application code deployed
✓ Rails dependencies installed
✓ Next.js dependencies installed and built
✓ Ready for Nomad orchestration
```

## Step 4: Start Services with Nomad (FreeBSD)

```bash
# From portfolio directory:
nomad job run nomad/jobs/postgres.hcl
nomad job run nomad/jobs/nginx.hcl
nomad job run nomad/jobs/api.hcl
nomad job run nomad/jobs/web.hcl

# Monitor
nomad job status
nomad alloc logs -f <alloc-id>
```

## Verification

### Check jails are running
```bash
pot list
pot show databases
pot show reverse-proxy
pot show portfolio-api
```

### Check services inside jails
```bash
# PostgreSQL
pot exec -p databases psql -U postgres -d postgres -c "SELECT 1;"

# Rails
pot exec -p portfolio-api ps aux | grep puma

# Next.js
pot exec -p portfolio-web ps aux | grep node

# Nginx
pot exec -p reverse-proxy ps aux | grep nginx
```

### Check logs
```bash
# Nomad logs
nomad alloc logs -stderr <alloc-id>

# Inside jails
pot exec -p portfolio-api tail -f /var/app/log/production.log
pot exec -p portfolio-web tail -f /var/web/.next/...
```

## Next Steps

- Configure SSL/TLS with Let's Encrypt
- Set up monitoring and alerting
- Configure external DNS (DuckDNS)
- Set up CI/CD pipeline

## Troubleshooting

**Q: "Flavour not found" error**
```bash
# Check flavours are installed
ssh root@server ls /usr/local/etc/pot/flavours/portfolio-*

# Re-install if needed
./nomad/pot/install-flavours.sh root@server
```

**Q: Jail creation fails**
```bash
# Check detailed log
tail -f /tmp/portfolio-setup.log

# Verify Pot configuration
ssh root@server sudo pot config
```

**Q: PostgreSQL won't start**
```bash
# Check inside jail
pot exec -p databases service postgresql status

# Initialize manually if needed
pot exec -p databases su postgres -c "/usr/local/bin/initdb -D /var/lib/postgresql/data/pgdata"
```

## Additional Resources

- [Pot Flavours Guide](../FLAVOURS.md)
- [Pot Documentation](https://pot.pizzamig.dev/)
- [Nomad Integration](../jobs/)

---

**This is the distinguished engineering approach.** Flavours are declarative, reusable, version-controlled configurations—not imperative workarounds.
