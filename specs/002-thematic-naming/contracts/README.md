# Thematic Naming API Contracts

> **Feature**: 002-thematic-naming  
> **Format**: OpenAPI 3.0.3  
> **Base Path**: `/api/v1`  
> **Auth**: Azure Entra ID JWT (Bearer token)

---

## Contract Files

| File | Description | User Stories |
|------|-------------|--------------|
| [thematic-guides-api.yaml](./thematic-guides-api.yaml) | CRUD operations for thematic naming guides | US-1, US-2, US-5 |
| [theme-library-api.yaml](./theme-library-api.yaml) | Browse and search built-in theme templates | US-2, US-4 |
| [naming-suggestions-api.yaml](./naming-suggestions-api.yaml) | Generate and apply naming suggestions | US-3 |
| [theme-export-api.yaml](./theme-export-api.yaml) | Export/import guides as JSON | US-6 |

---

## Endpoint Summary

### Thematic Guides (`thematic-guides-api.yaml`)

| Method | Path | Description | RBAC | US |
|--------|------|-------------|------|----|
| `GET` | `/thematic-guides` | List guides (paginated, filterable) | Viewer+ | US-1, US-2 |
| `POST` | `/thematic-guides` | Create guide (custom or from built-in) | Admin | US-1, US-2 |
| `GET` | `/thematic-guides/:id` | Get guide details with elements | Viewer+ | US-1, US-2 |
| `PUT` | `/thematic-guides/:id` | Update/customize guide (add/remove elements) | Admin | US-5 |
| `DELETE` | `/thematic-guides/:id` | Soft-delete guide | Admin | — |
| `POST` | `/thematic-guides/:id/preview` | Preview naming suggestions (read-only) | Viewer+ | FR-008 |

### Theme Library (`theme-library-api.yaml`)

| Method | Path | Description | RBAC | US |
|--------|------|-------------|------|----|
| `GET` | `/theme-library` | List built-in themes (sorted by popularity) | Viewer+ | US-2, US-4 |
| `GET` | `/theme-library/search` | Search themes by name/keyword | Viewer+ | US-4, FR-010 |
| `GET` | `/theme-library/:id` | Theme details with grouped elements & stats | Viewer+ | US-4 |

### Naming Suggestions (`naming-suggestions-api.yaml`)

| Method | Path | Description | RBAC | US |
|--------|------|-------------|------|----|
| `POST` | `/naming-suggestions` | Generate 5-10 themed suggestions | Viewer+ | US-3, FR-003 |
| `POST` | `/naming-suggestions/apply` | Apply suggestion to schema entity | Maintainer+ | US-3 |
| `GET` | `/naming-suggestions/usage` | View usage history / audit trail | Viewer+ | FR-015 |

### Theme Export/Import (`theme-export-api.yaml`)

| Method | Path | Description | RBAC | US |
|--------|------|-------------|------|----|
| `GET` | `/thematic-guides/:id/export` | Export guide as JSON file | Viewer+ | US-6, FR-012 |
| `POST` | `/thematic-guides/import` | Import guide from JSON file | Admin | US-6, FR-013 |
| `POST` | `/thematic-guides/import/validate` | Validate import file (dry-run) | Viewer+ | FR-013 |

---

## Requirements Traceability

| Requirement | Endpoint(s) | Notes |
|-------------|-------------|-------|
| FR-001 | `POST /thematic-guides` | Min 3 elements enforced in request validation |
| FR-002 | `GET /theme-library` | 10 pre-populated themes via seed data |
| FR-003 | `POST /naming-suggestions` | Three-stage pipeline: Filter → Rank → Format |
| FR-008 | `POST /thematic-guides/:id/preview` | Preview without persisting usage records |
| FR-010 | `GET /theme-library/search` | Search by name, keyword, category |
| FR-011 | All mutation endpoints | `x-rbac-roles: [Admin]` on POST/PUT/DELETE |
| FR-012 | `GET /thematic-guides/:id/export` | Self-describing JSON with SHA-256 checksum |
| FR-013 | `POST /thematic-guides/import` | 6-stage validation pipeline with error details |
| FR-015 | `GET /naming-suggestions/usage` | Full audit trail of naming decisions |
| SC-003 | `POST /naming-suggestions` | Documented: <500ms target (expected ~3ms) |
| SC-009 | `GET /theme-library/search` | Documented: <1s target |

---

## Common Patterns

### Authentication

All endpoints require a valid Azure Entra ID JWT in the `Authorization` header:

```
Authorization: Bearer <jwt-token>
```

### RBAC Roles

| Role | Permissions |
|------|-------------|
| **Viewer** | Read guides, browse library, generate suggestions, export |
| **Maintainer** | Viewer + apply suggestions to schema entities |
| **Admin** | Maintainer + create/edit/delete guides, import guides |

### Pagination

List endpoints accept `page` (1-based) and `perPage` (1-100, default 20) query parameters. Responses include a `meta` object:

```json
{
  "data": [...],
  "meta": {
    "total": 42,
    "page": 1,
    "perPage": 20,
    "totalPages": 3
  }
}
```

### Error Format

All errors follow the standard envelope:

```json
{
  "error": "BAD_REQUEST",
  "message": "Human-readable error message",
  "details": [...]
}
```

### Rate Limiting

- **100 requests/minute** per authenticated user
- Rate limit headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `Retry-After`

---

## Data Model Reference

See [../data-model.md](../data-model.md) for complete entity definitions, Prisma schema, and index strategy. Key entities:

- **ThematicGuide** — Guide container with metadata and soft deletes
- **ThemeElement** — Individual themed names with LRU usage tracking
- **ThemeLibraryItem** — Read-only built-in theme catalog entries
- **ThemeUsageRecord** — Audit trail of naming decisions
