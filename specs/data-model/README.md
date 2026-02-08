# Data Model Specifications

Database schema design, entity relationships, and data dictionary.

## Entity Relationship Diagram

```
User (1) ──────── (N) Server
  │                   │
  │                   └─── (1) ──────── (N) Database
  │                                         │
  │                                         └─── (1) ──────── (N) Table
  │                                                               │
  │                                                               └─── (1) ──────── (N) Element
  │
  └─── (1) ──────── (N) Abbreviation
```

## Core Entities

### User
System user with role-based access.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| username | String | Unique username |
| email | Email | User email |
| fullName | String | User's full name |
| role | Enum | ADMIN, EDITOR, VIEWER |
| isActive | Boolean | Account active status |
| lastLoginAt | DateTime | Last login timestamp |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

### Server
Database server connection.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| name | String | Server name |
| description | String | Server description |
| host | String | Hostname/IP address |
| port | Integer | Port number |
| rdbmsType | Enum | POSTGRESQL, MYSQL, ORACLE, DB2, INFORMIX, SQLSERVER |
| location | String | Physical/logical location |
| status | Enum | ACTIVE, INACTIVE, ARCHIVED |
| createdById | UUID | Creator user ID |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

### Database
Logical database within a server.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| serverId | UUID | Parent server FK |
| name | String | Database name |
| description | String | Database description |
| purpose | String | Business purpose |
| status | Enum | ACTIVE, INACTIVE, ARCHIVED |
| createdById | UUID | Creator user ID |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

### Table
Table/View within a database.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| databaseId | UUID | Parent database FK |
| name | String | Table name |
| description | String | Table description |
| tableType | Enum | TABLE, VIEW, MATERIALIZED_VIEW |
| rowCountEstimate | Integer | Estimated row count |
| status | Enum | ACTIVE, INACTIVE, ARCHIVED |
| createdById | UUID | Creator user ID |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

### Element
Column/Field within a table.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| tableId | UUID | Parent table FK |
| name | String | Column name |
| description | String | Column description |
| dataType | String | SQL data type |
| length | Integer | Column length/size |
| precision | Integer | Numeric precision |
| scale | Integer | Numeric scale |
| isNullable | Boolean | Nullable flag |
| isPrimaryKey | Boolean | Primary key flag |
| isForeignKey | Boolean | Foreign key flag |
| defaultValue | String | Default value |
| position | Integer | Column order position |
| createdById | UUID | Creator user ID |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

### Abbreviation
Business term abbreviation.

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| source | String | Source term |
| abbreviation | String | Abbreviated term |
| definition | String | Definition/meaning |
| isPrimeClass | Boolean | Prime class flag |
| category | String | Category classification |
| createdById | UUID | Creator user ID |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

## Key Constraints

- Foreign Keys: Enforce referential integrity
- Unique Constraints: server(name), database(serverId, name), table(databaseId, name)
- Check Constraints: Valid RDBMS types, status values, table types
- Not Null: All required fields enforced

## Indexes

- Servers: (status), (createdById)
- Databases: (serverId), (status), (createdById)
- Tables: (databaseId), (status), (createdById)
- Elements: (tableId), (position), (createdById)
- Abbreviations: (source), (abbreviation), (category), (createdById)

## Data Dictionary

### RDBMS Types
- POSTGRESQL - PostgreSQL
- MYSQL - MySQL
- ORACLE - Oracle Database
- DB2 - IBM DB2
- INFORMIX - IBM Informix
- SQLSERVER - Microsoft SQL Server

### Entity Status
- ACTIVE - Currently active and in use
- INACTIVE - Inactive but retained
- ARCHIVED - Archived for historical reference

### Table Types
- TABLE - Regular database table
- VIEW - Database view
- MATERIALIZED_VIEW - Materialized/snapshot view

### User Roles
- ADMIN - Full system access
- EDITOR - Can create/edit schemas
- VIEWER - Read-only access
