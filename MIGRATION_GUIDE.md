# Database Migration Guide

This guide explains the different approaches for running database migrations in SkimSafe Blog to avoid SQLite database locking issues.

## Overview

SQLite database locking can occur when multiple processes try to access the database simultaneously. This project provides several approaches to handle migrations safely.

## Migration Options

### 1. Mix Task (Development) - `mix db.migrate`

Use this for development and when Mix is available:

```bash
# Run all pending migrations
mix db.migrate

# Check migration status
mix db.migrate --status

# Run migrations up to a specific version
mix db.migrate --to 20250919140443

# Show help
mix db.migrate --help
```

**Advantages:**
- Uses the same connection pool as your application
- Prevents database locking issues
- Provides detailed feedback and error handling
- Available in development environment

**When to use:** Development, CI/CD pipelines, any environment with Mix available.

### 2. Separate Migration Script (Production) - `./migrate`

Run migrations separately before starting the server:

```bash
# In production
./migrate
./server_no_migrate
```

**Advantages:**
- Migrations complete before server starts
- No concurrent database access
- Simple and reliable
- Clear separation of concerns

**When to use:** Production deployments where you want explicit control over migration timing.

### 3. Enhanced Server Script - `./server`

The default server script now includes smart migration handling:

```bash
# Normal startup (runs migrations if needed)
./server

# Skip migrations entirely
SKIP_MIGRATIONS=true ./server
```

**Features:**
- Checks for pending migrations before running them
- Includes timeout protection (120 seconds)
- Graceful fallback if migrations fail
- Can be disabled with environment variable

**When to use:** Production environments where you want automated migration handling with safety features.

### 4. Shared Connection Script - `./server_shared_connection`

Experimental approach that runs migrations using the server's database connection:

```bash
./server_shared_connection
```

**Features:**
- Server starts first, establishing database connections
- Migrations run using shared connection pool
- Both processes use the same database handle

**When to use:** Testing environments or when you need both processes running simultaneously.

## Production Recommendations

### Option A: Separate Migration (Recommended)

```bash
# 1. Run migrations first
./migrate

# 2. Start server without migrations
./server_no_migrate
```

### Option B: Enhanced Server with Environment Control

```bash
# For zero-downtime deployments, skip migrations on server startup
SKIP_MIGRATIONS=true ./server

# Run migrations separately when ready
./migrate
```

### Option C: Default Enhanced Server

```bash
# Let the server handle migrations automatically with safety features
./server
```

## SQLite Optimizations Applied

The following optimizations have been applied to prevent database locking:

1. **WAL Mode Enabled:** Write-Ahead Logging allows concurrent readers and writers
2. **Connection Pragmas:** Optimized SQLite settings for concurrent access
3. **Extended Timeouts:** 60-second timeouts to handle potential delays
4. **Connection Pool Management:** Proper pool configuration for all environments

## Environment Variables

- `SKIP_MIGRATIONS=true` - Skip migrations during server startup
- `DATABASE_NAME` - Custom database name (production)

## Troubleshooting

### Database Lock Errors

If you still encounter database lock errors:

1. Ensure only one migration process runs at a time
2. Use the separate migration approach (`./migrate` then `./server_no_migrate`)
3. Check that no other processes are accessing the database file
4. Verify WAL mode is enabled (should be automatic with our configuration)

### Migration Timeouts

If migrations timeout:

1. Increase timeout in Release.migrate options
2. Run migrations separately with `./migrate`
3. Check database file permissions and disk space

### Development Issues

For development database issues:

```bash
# Use the Mix task which uses shared connection pools
mix db.migrate

# Or reset the database if needed
mix ecto.reset
```

## File Overview

- `lib/mix/tasks/db.migrate.ex` - Mix task for development migrations
- `lib/skimsafe_blogg/release.ex` - Enhanced release module with async options
- `rel/overlays/bin/migrate` - Standalone migration script
- `rel/overlays/bin/server` - Enhanced server script with migration logic
- `rel/overlays/bin/server_no_migrate` - Server-only script (no migrations)
- `rel/overlays/bin/server_shared_connection` - Experimental shared connection approach

This setup provides flexibility for different deployment scenarios while preventing SQLite database locking issues.