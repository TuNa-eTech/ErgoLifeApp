# ErgoLife Docker Setup

This directory contains Docker configuration for running the ErgoLife application stack.

## Services

- **postgres**: PostgreSQL 15 database
- **backend**: NestJS backend API

## Quick Start

### 1. Start all services
```bash
docker-compose up -d
```

### 2. Start specific services
```bash
# Start only PostgreSQL
docker-compose up -d postgres

# Start backend (will also start postgres due to dependency)
docker-compose up -d backend
```

### 3. View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f postgres
```

### 4. Stop services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: This will delete all data)
docker-compose down -v
```

### 5. Rebuild services
```bash
# Rebuild backend after code changes
docker-compose up -d --build backend
```

## Environment Variables

All environment variables are defined in `.env` file. See `.env.example` for reference.

Key variables:
- `POSTGRES_USER`: PostgreSQL username (default: ergolife)
- `POSTGRES_PASSWORD`: PostgreSQL password (default: ergolife123)
- `POSTGRES_DB`: Database name (default: ergolife_db)
- `POSTGRES_PORT`: Host port for PostgreSQL (default: 5433)
- `BACKEND_PORT`: Host port for backend API (default: 3000)
- `JWT_SECRET`: Secret key for JWT tokens
- `CORS_ORIGIN`: Allowed CORS origins

## Network

All services run on a bridge network `ergolife-network` for inter-service communication.

## Volumes

- `postgres_data`: Persistent storage for PostgreSQL data

## Development Mode

The backend service is configured to run in development mode with:
- Hot reload enabled via `yarn start:dev`
- Volume mounting for live code changes
- Automatic Prisma client generation and migration on startup

## Production Deployment

For production, modify the backend service:
1. Remove volume mounts
2. Change command to `yarn start:prod`
3. Set `NODE_ENV=production`
4. Use proper secrets for `JWT_SECRET` and database credentials

## Accessing Services

- Backend API: http://localhost:3000
- PostgreSQL: localhost:5433
- API Documentation (Swagger): http://localhost:3000/api

## Troubleshooting

### Backend fails to start
- Check if PostgreSQL is healthy: `docker-compose ps`
- View logs: `docker-compose logs backend`
- Verify environment variables in `.env`

### Database connection issues
- Ensure PostgreSQL is running and healthy
- Check DATABASE_URL format in backend environment
- Verify network connectivity: `docker-compose exec backend ping postgres`

### Prisma migration errors
- Access backend container: `docker-compose exec backend sh`
- Run migrations manually: `yarn prisma:migrate`
- Reset database (development only): `yarn prisma migrate reset`
