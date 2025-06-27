# CKAN Docker Local Development

A comprehensive Docker setup for running CKAN locally with all dependencies.

## Quick Start

The fastest way to get CKAN running locally:

```bash
# Initialize the project (first time only)
make setup

# Start the entire CKAN stack in one command
make up
```

Your CKAN instance will be available at the configured URL (check your `.env` file for the exact port).

## How to Use the Stack

### First Time Setup

1. **Initialize the project**:
   ```bash
   make setup
   ```
   This sets up git submodules required for the CKAN base images.

2. **Start the stack**:
   ```bash
   make up
   ```
   This will automatically:
   - Create a `.env` file from `.env.example` if it doesn't exist
   - Start all services (CKAN, PostgreSQL, Solr, Redis, DataPusher, Nginx)
   - Set up databases and initialize CKAN

3. **Access your CKAN instance**:
   - Production mode: `https://localhost` (or configured NGINX_SSLPORT_HOST)
   - Development mode: `http://localhost:5000` (or configured CKAN_PORT_HOST)

4. **Create your first admin user**:
   ```bash
   # Access the CKAN container
   docker compose exec ckan bash
   
   # Create admin user
   ckan user add admin email=admin@example.com name=admin
   ckan sysadmin add admin
   ```

### Daily Development Workflow

#### For Extension Development
```bash
# Start in development mode with live code editing
make dev

# Place your extensions in the src/ directory
# They will be automatically mounted and available

# Monitor logs while developing
make logs

# Restart services when needed
make restart
```

#### For Production Testing
```bash
# Start full production stack with nginx
make up

# Test your configuration
make status

# View logs if needed
make logs
```

### Working with Extensions

1. **Add an extension** to the `src/` directory:
   ```bash
   cd src/
   git clone https://github.com/ckan/ckanext-example.git
   ```

2. **Install the extension** (development mode):
   ```bash
   # Access the CKAN container
   docker compose exec ckan-dev bash
   
   # Install the extension
   pip install -e /srv/app/src_extensions/ckanext-example
   
   # Add to CKAN configuration
   ckan config-tool /srv/app/ckan.ini "ckan.plugins = datastore datapusher example"
   ```

3. **Restart CKAN** to load the extension:
   ```bash
   make restart
   ```

### Configuration Management

Your CKAN instance is configured through the `.env` file:

```bash
# View current environment
cat .env

# Edit configuration
nano .env

# Apply changes (restart required)
make restart
```

**Key configuration options**:
- `CKAN_SITE_URL`: Your CKAN site URL
- `CKAN_PORT_HOST`: Port for development mode
- `NGINX_SSLPORT_HOST`: Port for production mode with SSL
- Database credentials and names
- Extension settings

### Database Operations

```bash
# Access PostgreSQL directly
docker compose exec db psql -U ckan

# Backup database
docker compose exec db pg_dump -U ckan ckan > backup.sql

# Restore database
docker compose exec -T db psql -U ckan ckan < backup.sql

# Reset database (WARNING: destroys all data)
make stop
docker volume rm ckan-docker_pg_data
make up
```

### Managing Data

#### DataStore and File Uploads
- **File storage**: Persistent in `ckan_storage` volume
- **Database**: Persistent in `pg_data` volume
- **Search index**: Persistent in `solr_data` volume

#### Backup Important Data
```bash
# Backup file uploads
docker run --rm -v ckan-docker_ckan_storage:/data -v $(pwd):/backup alpine tar czf /backup/ckan_files.tar.gz -C /data .

# Backup search index
docker run --rm -v ckan-docker_solr_data:/data -v $(pwd):/backup alpine tar czf /backup/solr_data.tar.gz -C /data .
```

### Troubleshooting Common Issues

#### Services Won't Start
```bash
# Check service status
make status

# View detailed logs
make logs

# Check specific service
docker compose logs ckan
```

#### Port Conflicts
```bash
# Check what's using your ports
sudo netstat -tulpn | grep :5000
sudo netstat -tulpn | grep :443

# Update ports in .env file
nano .env
make restart
```

#### Database Connection Issues
```bash
# Check database is running
docker compose ps db

# Test database connection
docker compose exec db pg_isready -U ckan

# Reset database connection
make restart
```

#### Extension Issues
```bash
# Check if extension is installed
docker compose exec ckan-dev pip list | grep ckanext

# Reinstall extension
docker compose exec ckan-dev pip install -e /srv/app/src_extensions/your-extension

# Check CKAN configuration
docker compose exec ckan-dev cat /srv/app/ckan.ini | grep plugins
```

## Available Commands

Use `make help` to see all available commands:

### Stack Management
- `make up` - Start CKAN stack in production mode (creates .env automatically)
- `make dev` - Start CKAN stack in development mode (creates .env automatically)
- `make restart` - Restart the CKAN stack
- `make stop` - Stop the CKAN stack and remove containers
- `make logs` - Show logs from all services (follows log output)
- `make status` - Show status of all services

### Configuration
- `make env` - Copy .env.example to .env for configuration
- `make setup` - Initialize git submodules (required for first-time setup)

## Stack Components

### Production Mode (`make up`)
- **CKAN**: Main application behind nginx reverse proxy
- **Nginx**: Reverse proxy with SSL support, handles static files
- **PostgreSQL**: Main database + DataStore database
- **Solr**: Search and indexing engine
- **Redis**: Caching and session storage
- **DataPusher**: Automatic data processing service

### Development Mode (`make dev`)
- **CKAN-Dev**: Direct access with live code reloading
- **PostgreSQL**: Same as production
- **Solr**: Same as production
- **Redis**: Same as production
- **DataPusher**: Same as production

**Key differences in dev mode**:
- No nginx (direct access to CKAN)
- Volume mounts for `src/` directory
- Live code reloading
- Debug mode enabled

## Advanced Usage

### Custom Docker Images
If you need to build custom CKAN images:
```bash
# Build base image
make build-base

# Build development image  
make build-dev

# Build both
make build-all
```

### Environment Variables
Key variables you might want to customize in `.env`:
- `CKAN_VERSION`: CKAN version to use
- `CKAN_SITE_URL`: Your site's public URL
- `CKAN__SITE_TITLE`: Site title
- `CKAN__PLUGINS`: Space-separated list of plugins
- Database connection settings
- Email configuration for notifications

### SSL Certificates
For production with custom SSL:
1. Place your certificates in `nginx/setup/`
2. Update nginx configuration in `nginx/setup/default.conf`
3. Restart: `make restart`

## File Structure

- `docker-compose.yml` - Production stack configuration
- `docker-compose.dev.yml` - Development stack configuration  
- `Makefile` - Build and management commands
- `.env` - Environment configuration (auto-created from `.env.example`)
- `src/` - Your CKAN extensions (mounted in dev mode)
- `ckan/` - CKAN Docker image configuration and patches
- `nginx/` - Nginx configuration and SSL certificates
- `postgresql/` - Database initialization scripts
- `bin/` - Utility scripts for development

## Getting Help

1. Check the logs: `make logs`
2. Verify service status: `make status`  
3. Review the original documentation: `README-original.md`
4. Check CKAN documentation: https://docs.ckan.org/

## Next Steps After Setup

1. Create your admin user (see "First Time Setup" above)
2. Configure your organization and datasets
3. Install and configure extensions as needed
4. Customize the theme and branding
5. Set up your data workflows with DataPusher
6. Configure email notifications and user management
