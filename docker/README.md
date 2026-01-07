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

---

## Database Operations

### Reset Database (Development Only)

⚠️ **WARNING**: These commands will DELETE all data. Only use in development!

```bash
# Method 1: Using docker-compose (recommended)
docker-compose down -v
docker-compose up -d

# Method 2: Using Prisma inside container
docker-compose exec backend npx prisma migrate reset --force
```

### Apply Migrations

```bash
# Apply pending migrations
docker-compose exec backend npx prisma migrate deploy

# Create new migration (development)
docker-compose exec backend npx prisma migrate dev --name your_migration_name
```

### Seed Task Templates

Task templates must be seeded for new users to get default tasks. Run this after:

- Fresh database setup
- Database reset
- Adding new templates

```bash
# Seed task templates (20 templates with EN/VI translations)
docker-compose exec backend npx ts-node prisma/seeds/seed-templates.ts
```

**What this does:**

- Creates 20 household task templates (Vacuuming, Mopping, Cooking, etc.)
- Adds English and Vietnamese translations for each template
- Sets METs values, default durations, icons, and colors

### Complete Database Setup (Fresh Start)

```bash
# 1. Stop all services and remove volumes
docker-compose down -v

# 2. Start services (runs migrations automatically)
docker-compose up -d

# 3. Wait for backend to be ready
docker-compose logs -f backend
# (Wait until you see "Nest application successfully started")

# 4. Seed task templates
docker-compose exec backend npx ts-node prisma/seeds/seed-templates.ts
```

### Verify Data

```bash
# Check task templates count
docker-compose exec postgres psql -U ergolife -d ergolife_db -c "SELECT COUNT(*) FROM task_templates;"

# View all templates
docker-compose exec postgres psql -U ergolife -d ergolife_db -c "SELECT t.id, tr.name, t.mets_value FROM task_templates t JOIN task_template_translations tr ON t.id = tr.template_id WHERE tr.locale = 'en';"

# Check users and their seeding status
docker-compose exec postgres psql -U ergolife -d ergolife_db -c "SELECT id, display_name, has_seeded_tasks FROM users;"
```

### Reset User Tasks (For Testing)

To make a user receive default tasks again:

```bash
# Reset hasSeededTasks flag for a specific user
docker-compose exec postgres psql -U ergolife -d ergolife_db -c "UPDATE users SET has_seeded_tasks = false WHERE id = 'user-uuid-here';"

# Delete all custom tasks for a user
docker-compose exec postgres psql -U ergolife -d ergolife_db -c "DELETE FROM custom_tasks WHERE user_id = 'user-uuid-here';"
```

---

## Production Deployment

### Initial Setup

```bash
# 1. Set production environment variables
export NODE_ENV=production
# Set proper JWT_SECRET, database credentials, etc.

# 2. Start services
docker-compose -f docker-compose.prod.yml up -d

# 3. Apply migrations
docker-compose exec backend npx prisma migrate deploy

# 4. Seed task templates (first-time only)
docker-compose exec backend npx ts-node prisma/seeds/seed-templates.ts
```

### Update Deployment

```bash
# 1. Pull latest code
git pull origin main

# 2. Rebuild and restart backend
docker-compose up -d --build backend

# 3. Apply new migrations (if any)
docker-compose exec backend npx prisma migrate deploy
```

### Production Best Practices

1. **Never use** `prisma migrate reset` in production
2. **Always backup** before running migrations
3. Use proper secrets for `JWT_SECRET` and database credentials
4. Set `NODE_ENV=production`
5. Remove volume mounts for code
6. Use `yarn start:prod` instead of `yarn start:dev`

---

## Development Mode

The backend service is configured to run in development mode with:

- Hot reload enabled via `yarn start:dev`
- Volume mounting for live code changes
- Automatic Prisma client generation and migration on startup

---

## Accessing Services

- Backend API: http://localhost:3000
- PostgreSQL: localhost:5433
- API Documentation (Swagger): http://localhost:3000/api

---

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

### Task templates not found

- Verify templates are seeded: `docker-compose exec postgres psql -U ergolife -d ergolife_db -c "SELECT COUNT(*) FROM task_templates;"`
- If count is 0, run: `docker-compose exec backend npx ts-node prisma/seeds/seed-templates.ts`

### New users don't see tasks

- Check if `hasSeededTasks` is false for the user
- Verify the app is calling `GET /api/tasks/needs-seeding`
- Check backend logs for seeding errors
- Ensure task templates exist in database

