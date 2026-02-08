# Docker Setup Guide

This project includes Docker containerization for the backend API and PostgreSQL database.

## Components

- **Backend**: Node.js Express API (port 3001)
- **PostgreSQL**: Database (port 5432)
- **Frontend**: React + Vite (port 3000) - *requires separate build due to TypeScript issues*

## Prerequisites

- Docker Desktop installed and running
- Docker Compose v2+

## Running Locally with Docker

### 1. Build the Images

```bash
docker-compose build --no-cache
```

### 2. Start the Services

```bash
docker-compose up
```

This will start:
- PostgreSQL on `localhost:5432`
- Backend API on `localhost:3001`

### 3. Health Checks

- Backend health: `http://localhost:3001/health`
- API endpoint: `http://localhost:3001/api/v1`

## Running the Frontend Separately

The frontend has TypeScript compilation errors in the page components that need to be fixed. For now, run the frontend in development mode:

```bash
cd src/frontend
npm install
npm run dev
```

This will start the frontend on `http://localhost:5173` and it will connect to the backend API at `http://localhost:3001`.

## Docker Compose Configuration

### Services

#### PostgreSQL
- Image: `postgres:15-alpine`
- Database: `schemajeli_dev`
- User: `postgres`
- Password: `postgres`
- Port: `5432`
- Volume: `postgres_data:/var/lib/postgresql/data` (persists data)

#### Backend API
- Build context: `./src/backend`
- Environment:
  - `NODE_ENV`: development
  - `DATABASE_URL`: `postgresql://postgres:postgres@postgres:5432/schemajeli_dev`
  - `CORS_ORIGIN`: `http://localhost:3000`
- Port: `3001:3000` (host:container)
- Health check: Checks `/health` endpoint every 30s
- Volumes:
  - `./src/backend/src` → `/app/src` (live reload)
  - `./src/backend/logs` → `/app/logs`

## Common Commands

### View Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs backend
docker-compose logs postgres

# Follow logs (tail -f equivalent)
docker-compose logs -f backend
```

### Stop Services

```bash
docker-compose down
```

### Stop and Remove Volumes

```bash
docker-compose down -v
```

### Rebuild Specific Service

```bash
docker-compose build --no-cache backend
docker-compose up backend postgres
```

### Access Database

```bash
# Using psql inside container
docker exec -it schemajeli-postgres psql -U postgres -d schemajeli_dev

# Or use a database GUI tool on localhost:5432
```

## Troubleshooting

### Services won't start
- Ensure ports 3001 and 5432 are not in use
- Check Docker Desktop is running
- Run `docker-compose logs` to see error messages

### PostgreSQL won't connect
- Check database credentials in docker-compose.yml
- Verify PostgreSQL container is healthy: `docker-compose ps`
- Wait 10-15 seconds for PostgreSQL to fully initialize

### Backend health check failing
- Check `docker-compose logs backend` for startup errors
- Verify node_modules are installed: `docker-compose build --no-cache`
- Ensure DATABASE_URL is correct

## Frontend Build Issues

The frontend TypeScript files (`ServersPage.tsx`, `DatabasesPage.tsx`, `TableDetailPage.tsx`) have syntax errors that prevent Docker build:

**To fix:**
1. Review JSX syntax in mentioned files
2. Ensure all JSX elements are properly closed
3. Check for unclosed tags or missing imports
4. Run `npm run build` in `src/frontend` to validate locally

For now, run frontend separately in development mode.
