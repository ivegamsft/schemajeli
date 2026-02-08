# API Specifications

REST API specification and documentation for SchemaJeli.

## OpenAPI Reference

See [../openapi.yaml](../openapi.yaml) for the complete OpenAPI 3.0.3 specification.

### Core Endpoints

#### Authentication
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Refresh access token

#### Servers
- `GET /servers` - List all servers
- `POST /servers` - Create new server
- `GET /servers/{id}` - Get server details
- `PUT /servers/{id}` - Update server
- `DELETE /servers/{id}` - Delete server

#### Databases
- `GET /servers/{id}/databases` - List databases for server
- `POST /servers/{id}/databases` - Create database
- `GET /databases/{id}` - Get database details
- `PUT /databases/{id}` - Update database
- `DELETE /databases/{id}` - Delete database

#### Tables
- `GET /databases/{id}/tables` - List tables in database
- `POST /databases/{id}/tables` - Create table
- `GET /tables/{id}` - Get table details
- `PUT /tables/{id}` - Update table
- `DELETE /tables/{id}` - Delete table

#### Elements (Columns)
- `GET /tables/{id}/elements` - List columns in table
- `POST /tables/{id}/elements` - Create column
- `GET /elements/{id}` - Get column details
- `PUT /elements/{id}` - Update column
- `DELETE /elements/{id}` - Delete column

#### Abbreviations
- `GET /abbreviations` - List abbreviations
- `POST /abbreviations` - Create abbreviation
- `GET /abbreviations/{id}` - Get abbreviation
- `PUT /abbreviations/{id}` - Update abbreviation
- `DELETE /abbreviations/{id}` - Delete abbreviation

#### Search & Reports
- `GET /search` - Search across entities
- `GET /reports/ddl` - Generate DDL report

## Authentication

All endpoints require Bearer token authentication (JWT from Azure Entra ID).

```
Authorization: Bearer <access_token>
```

## Response Format

All responses follow a consistent JSON format:

```json
{
  "status": "success|error",
  "data": { },
  "pagination": {
    "page": 1,
    "pageSize": 25,
    "total": 100
  }
}
```

## Error Handling

Errors return appropriate HTTP status codes with error details:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Detailed error message",
  "details": { }
}
```

## Pagination

List endpoints support pagination via query parameters:
- `page` (default: 1) - Page number
- `pageSize` (default: 25, max: 200) - Items per page
