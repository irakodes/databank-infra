# PostgreSQL Infrastructure

This repository contains the Docker-based PostgreSQL infrastructure setup with pgAdmin.

## Directory Structure

```
project-root/
│
├── docker/
│   ├── postgres/
│   │   ├── docker-compose.yml       # PostgreSQL service configuration
│   │   ├── postgres.conf            # PostgreSQL configuration
│   │   ├── init/                    # Database initialization scripts
│   │   │   ├── 01-extensions.sql   # Extensions setup
│   │   │   └── 02-roles.sql        # Roles and permissions
│   │   └── .env.postgres           # PostgreSQL-specific variables
│   │
│   └── pgadmin/
│       └── docker-compose.yml       # pgAdmin service configuration
│
├── env/
│   ├── .env.shared                  # Shared environment variables
│   ├── .env.dev                     # Development environment
│   ├── .env.prod                    # Production environment
│   └── .env.secrets                 # Secrets (not committed)
│
├── .gitignore
└── README.md
```

## Setup

### Prerequisites

- Docker and Docker Compose installed
- Sufficient disk space for database volumes

### Environment Configuration

1. Copy the secrets template:
   ```bash
   cp env/.env.secrets env/.env.secrets.local
   ```

2. Update `env/.env.secrets.local` with your actual credentials

3. Choose your environment by linking the appropriate env file or modifying docker-compose.yml

### Running PostgreSQL

```bash
cd docker/postgres
docker-compose up -d
```

### Running pgAdmin

```bash
cd docker/pgadmin
docker-compose up -d
```

Access pgAdmin at: http://localhost:5050

### Running Both Services

Create a root docker-compose file or use:
```bash
docker-compose -f docker/postgres/docker-compose.yml -f docker/pgadmin/docker-compose.yml up -d
```

## Database Initialization

Init scripts in `docker/postgres/init/` run automatically when the database is first created:
- `01-extensions.sql`: Installs PostgreSQL extensions
- `02-roles.sql`: Creates database roles and permissions

## Configuration

### PostgreSQL

Modify `docker/postgres/postgres.conf` for database tuning.

### Environment Variables

- **Shared** (`env/.env.shared`): Common variables across environments
- **Dev** (`env/.env.dev`): Development-specific settings
- **Prod** (`env/.env.prod`): Production-specific settings
- **Secrets** (`env/.env.secrets`): Passwords and sensitive data

## Security Notes

- Never commit `env/.env.secrets` or `*.local` files
- Change default passwords before deploying to production
- Restrict network access in production environments
- Regularly update PostgreSQL and pgAdmin images

## Maintenance

### Backup

```bash
docker exec pgsql pg_dump -U postgres dbname > backup.sql
```

### Restore

```bash
docker exec -i pgsql psql -U postgres dbname < backup.sql
```

### Logs

```bash
docker logs pgsql
docker logs pgadmin
```
