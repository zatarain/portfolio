# Portfolio Infrastructure - Pot Flavours Architecture

## Overview

This is a **distinguished engineering approach** using Pot flavours—the proper way to manage FreeBSD jail configurations. Instead of imperative shell scripts with workarounds, we use **declarative, reusable flavour definitions**.

## Architecture

```
┌─────────────────────────────────────────────────┐
│ Pot Flavours (/usr/local/etc/pot/flavours/)     │
├─────────────────────────────────────────────────┤
│ • portfolio-databases & bootstrap                │
│ • portfolio-api & bootstrap                      │
│ • portfolio-web & bootstrap                      │
│ • portfolio-reverse-proxy & bootstrap            │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ Setup Script (setup-jails-flavours.sh)          │
│ Creates jails using flavours                    │
│ • pot create -f portfolio-databases ...         │
│ • pot create -f portfolio-api ...               │
│ • Mounts ZFS datasets                           │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ Deploy Script (deploy-flavours.sh)              │
│ • Copies application code                       │
│ • Runs bundle install, npm install, etc.        │
│ • Ready for Nomad orchestration                 │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ Nomad Jobs (nomad/jobs/*.hcl)                   │
│ Orchestrates service startup/management         │
└─────────────────────────────────────────────────┘
```

## Flavour Structure

Each service has **3 files**:

### 1. Configuration File (no extension)
Contains Pot commands:
- `set-attribute` - Jail behavior (no-rc-script, persistent)
- `set-environment` - Environment variables
- `set-resource-set` - Resource limits

Example: `portfolio-databases`
```
set-attribute -A no-rc-script -V YES
set-attribute -A persistent -V YES
set-env -e POSTGRES_INITDB_ARGS="-c max_connections=200"
```

### 2. Bootstrap Script (.sh)
Shell script executed inside jail during creation:
- Updates package manager
- Installs packages
- Performs initial configuration
- **No pot commands** - just shell

Example: `portfolio-databases.sh`
```bash
#!/bin/sh
ASSUME_ALWAYS_YES=yes pkg bootstrap
pkg install -y postgresql14-server
mkdir -p /var/lib/postgresql/data/pgdata
su postgres -c "/usr/local/bin/initdb -D /var/lib/postgresql/data/pgdata"
```

### 3. Command File (-cmd)
Sets the main startup command:

Example: `portfolio-databases-cmd`
```
set-cmd -c "su postgres -c 'postgres -D /var/lib/postgresql/data/pgdata'"
```

## Deployment Workflow

### Phase 1: Install Flavours
```bash
# From Linux machine
./nomad/pot/install-flavours.sh root@freebsd-server

# Verifies: ls -la /usr/local/etc/pot/flavours/portfolio-*
```

### Phase 2: Create Infrastructure
```bash
# On FreeBSD server
sudo ./nomad/pot/setup-jails-flavours.sh

# Creates:
# ✓ reverse-proxy jail (Nginx)
# ✓ databases jail (PostgreSQL)
# ✓ portfolio-api jail (Rails)
# ✓ portfolio-web jail (Next.js)
# ✓ ZFS datasets mounted at /data/
```

### Phase 3: Deploy Code
```bash
# Copy code to server, then:
sudo ./nomad/pot/deploy-flavours.sh

# Deploys:
# ✓ API code to /data/portfolio-api
# ✓ Web code to /data/portfolio-web
# ✓ Runs bundle install, npm install
# ✓ Creates databases, runs migrations
```

### Phase 4: Start with Nomad
```bash
nomad job run nomad/jobs/postgres.hcl
nomad job run nomad/jobs/nginx.hcl
nomad job run nomad/jobs/api.hcl
nomad job run nomad/jobs/web.hcl
```

## File Structure

```
nomad/
├── pot/
│   ├── flavours/                    ← Pot flavour definitions
│   │   ├── portfolio-databases
│   │   ├── portfolio-databases.sh
│   │   ├── portfolio-databases-cmd
│   │   ├── portfolio-api
│   │   ├── portfolio-api.sh
│   │   ├── portfolio-api-cmd
│   │   ├── portfolio-web
│   │   ├── portfolio-web.sh
│   │   ├── portfolio-web-cmd
│   │   ├── portfolio-reverse-proxy
│   │   ├── portfolio-reverse-proxy.sh
│   │   └── portfolio-reverse-proxy-cmd
│   ├── setup-jails-flavours.sh      ← Infrastructure setup
│   ├── deploy-flavours.sh            ← Code deployment
│   └── install-flavours.sh           ← Flavour installation
├── jobs/
│   ├── postgres.hcl
│   ├── api.hcl
│   ├── web.hcl
│   ├── nginx.hcl
│   └── scripts/                     ← Application scripts (optional now)
└── SETUP.md
```

## Key Advantages

✅ **Declarative**: Flavours are definitions, not imperative commands
✅ **Reusable**: Create multiple instances from same flavour
✅ **Version-controlled**: Flavours live in repository
✅ **No workarounds**: Works with Pot's intended design
✅ **Reproducible**: Same flavour creates identical jails
✅ **Clean**: No `pot copy-in` hacks, bootstrap scripts run naturally

## Troubleshooting

### Flavour not found
```bash
# Verify installation
ssh root@server ls /usr/local/etc/pot/flavours/portfolio-*

# Re-install
./install-flavours.sh root@freebsd-server
```

### Jail creation fails
```bash
# Check pot is initialized
sudo pot config

# View detailed logs
tail -f /tmp/portfolio-setup.log

# Manual verification
sudo pot list
sudo pot show reverse-proxy
```

### Bootstrap script errors
```bash
# Check bootstrap output in logs
pot exec -p databases cat /var/log/manifest.log

# Re-run bootstrap (if needed)
pot stop databases
pot destroy databases
pot create -p databases -b 14.3 -t multi -f portfolio-databases -f portfolio-databases-cmd
```

## Future Enhancements

- **Update flavours**: Modify files in `nomad/pot/flavours/`, re-run `install-flavours.sh`
- **Create new services**: Add new flavour triplet for new service type
- **Export jails as images**: `pot export -p databases -t 1.0` → distribute as container image
- **Multi-region**: Deploy same flavours to multiple FreeBSD servers

## References

- [Pot Documentation](https://pot.pizzamig.dev/)
- [Flavours Guide](https://pot.pizzamig.dev/Images/#images-creation-automated-with-flavours)
- [Nomad Pot Integration](https://github.com/trivago/nomad-pot-driver)
