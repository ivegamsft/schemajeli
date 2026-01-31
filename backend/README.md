# SchemaJeli Backend

Backend API service for SchemaJeli - Database Metadata Repository

## Prerequisites

- Node.js 18+ and npm 9+
- PostgreSQL 14+
- TypeScript 5+

## Getting Started

### 1. Install Dependencies

```bash
npm install
```

### 2. Environment Configuration

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Edit `.env` with your database credentials and configuration:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/schemajeli"
JWT_SECRET="your-super-secret-jwt-key-change-this"
PORT=3000
```

### 3. Database Setup

Generate Prisma client:

```bash
npm run prisma:generate
```

Run migrations to create database schema:

```bash
npm run prisma:migrate
```

Seed the database with initial data:

```bash
npm run prisma:seed
```

This creates three default users:
- **Admin**: username: `admin`, password: `Admin@123`
- **Editor**: username: `editor`, password: `Editor@123`
- **Viewer**: username: `viewer`, password: `Viewer@123`

### 4. Run Development Server

```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm test` - Run tests
- `npm run test:coverage` - Run tests with coverage report
- `npm run lint` - Lint code
- `npm run lint:fix` - Fix linting errors
- `npm run format` - Format code with Prettier
- `npm run prisma:generate` - Generate Prisma client
- `npm run prisma:migrate` - Run database migrations
- `npm run prisma:studio` - Open Prisma Studio GUI
- `npm run prisma:seed` - Seed database with initial data

## API Documentation

### Health Check

```
GET /health
```

Returns server health status.

### Authentication Endpoints

```
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
GET  /api/v1/auth/me
```

### User Management Endpoints

```
POST   /api/v1/users
GET    /api/v1/users
GET    /api/v1/users/:id
PUT    /api/v1/users/:id
DELETE /api/v1/users/:id
POST   /api/v1/users/change-password
```

Full API documentation available in OpenAPI format at `.specify/openapi.yaml`

## Project Structure

```
backend/
├── src/
│   ├── config/          # Configuration files
│   ├── controllers/     # Request handlers
│   ├── middleware/      # Express middleware
│   ├── routes/          # API routes
│   ├── services/        # Business logic
│   ├── utils/           # Utility functions
│   └── index.ts         # Application entry point
├── prisma/
│   ├── schema.prisma    # Database schema
│   └── seed.ts          # Database seeding
├── tests/               # Test files
├── logs/                # Log files
└── dist/                # Compiled output
```

## Testing

Run all tests:

```bash
npm test
```

Run tests with coverage:

```bash
npm run test:coverage
```

Coverage requirements:
- Lines: 80%
- Functions: 80%
- Branches: 80%
- Statements: 80%

## Technology Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Language**: TypeScript
- **ORM**: Prisma
- **Database**: PostgreSQL 14+
- **Authentication**: JWT + bcrypt
- **Testing**: Vitest
- **Logging**: Winston
- **Code Quality**: ESLint + Prettier

## Security

- JWT tokens with 15-minute access token expiry
- Bcrypt password hashing with 10 rounds
- Role-based access control (RBAC)
- Rate limiting enabled
- Helmet security headers
- CORS configured

## License

MIT
