# Feature: Style Guide Management

**Status:** Specification  
**Created:** February 8, 2026  
**Priority:** Medium  

## Overview

Enable administrators to define, import, and manage schema naming conventions and formatting standards through reusable style guides. This allows teams to enforce consistent naming patterns across multiple databases and deployments.

## User Scenarios

### 1. Create a New Style Guide
**Actor:** Administrator  
**Scenario:** Create a custom style guide with naming conventions for tables, columns, and abbreviations.

**Steps:**
1. User navigates to "Style Guides" section
2. Clicks "Create New Style Guide"
3. Enters guide name (e.g., "Enterprise Naming Standards")
4. Defines naming rules:
   - Table naming pattern (e.g., `tbl_[Function]_[Entity]`)
   - Column naming pattern (e.g., `col_[DataType]_[Name]`)
   - Abbreviation rules
   - Case conventions (CamelCase, snake_case, UPPER_SNAKE_CASE)
5. Sets validation rules (regex patterns)
6. Saves the guide
7. System confirms creation with guide ID and version

**Acceptance:**
- Style guide is saved to database with unique ID
- Admin can immediately apply the guide to databases
- Guide is versioned for change tracking

### 2. Import Style Guide from File
**Actor:** Administrator  
**Scenario:** Import a predefined style guide from a JSON/YAML file (e.g., from GitHub or team repository).

**Steps:**
1. User navigates to "Style Guides"
2. Clicks "Import Style Guide"
3. Selects file upload or URL source
4. Provides:
   - Style guide file (JSON/YAML format)
   - Optional: Name override
   - Optional: Target environment (dev/staging/prod)
5. System validates file structure
6. Previews rules before import
7. Confirms import
8. System creates style guide in database

**Acceptance:**
- File is parsed and validated against schema
- All naming rules are extracted correctly
- Guide appears in style guide list with "Imported" label
- Timestamp and source URL are recorded

### 3. Modify Existing Style Guide
**Actor:** Administrator  
**Scenario:** Update naming conventions in an existing style guide (add new rules, edit patterns, remove deprecated rules).

**Steps:**
1. User navigates to "Style Guides"
2. Selects a style guide from the list
3. Clicks "Edit"
4. Modifies:
   - Naming patterns
   - Case conventions
   - Validation regex
   - Description
5. Reviews changes summary
6. Saves changes
7. System optionally shows:
   - Number of resources using this guide
   - Option to apply changes retroactively?

**Acceptance:**
- Changes are saved as new version
- Previous version is accessible via version history
- Modification timestamp is recorded with user who made the change
- Option to prevent retroactive application or warn about impact

### 4. Apply Style Guide to Database/Schema
**Actor:** Administrator  
**Scenario:** Apply a saved style guide to validate and potentially rename schema elements.

**Steps:**
1. User navigates to database/schema edit page
2. In "Settings," selects "Apply Style Guide"
3. Chooses a style guide from dropdown
4. System analyzes current schema against guide rules
5. Shows violations and recommendations
6. Optionally applies auto-corrections (if enabled)
7. Saves changes

**Acceptance:**
- Violations are highlighted clearly
- User can accept/reject individual corrections
- Audit trail shows which guide was applied

### 5. Export Style Guide
**Actor:** Administrator  
**Scenario:** Export a style guide to share with team or version control.

**Steps:**
1. User selects a style guide
2. Clicks "Export"
3. Chooses format (JSON, YAML, CSV)
4. Optional: Anonymize sensitive metadata
5. Downloads file

**Acceptance:**
- Exported file is valid and can be imported again
- File format is standards-compliant
- All rules are complete in export

## Functional Requirements

### Core Features
1. **Create Style Guide**
   - Name, description, version fields
   - Define naming patterns with regex/templates
   - Support for multiple naming conventions (tables, columns, constraints, indexes)
   - Set case conventions (Pascal, camelCase, UPPER_SNAKE, lower_snake)
   - Define abbreviation handling rules
   - Validation rule definitions

2. **Import Style Guide**
   - Support JSON and YAML formats
   - Validate file structure before import
   - Parse naming patterns and rules
   - Detect and prevent duplicate imports
   - Show preview before confirmation
   - Record import source and timestamp

3. **Modify Style Guide**
   - Edit all guide properties
   - Add/remove naming rules
   - Manage rule versions
   - Version history with rollback option
   - Show impact analysis (e.g., "Used in 3 databases")
   - Change audit trail (who changed what when)

4. **View and Search**
   - List all style guides with metadata
   - Search by name or description
   - Filter by environment (dev/staging/prod)
   - Show usage count and last modified date
   - Display guide version

5. **Apply and Validate**
   - Analyze schema against guide rules
   - Generate violation report
   - Suggest corrections based on patterns
   - Option for auto-correction with approval workflow
   - Show before/after comparison

6. **Export Style Guide**
   - Export to JSON/YAML
   - Export to CSV for spreadsheet review
   - Include metadata and version info
   - Option to include usage statistics

### Data Structure
```
StyleGuide {
  id: UUID
  name: string (required)
  description: string
  version: string (semantic)
  created_at: timestamp
  created_by: UUID (User)
  updated_at: timestamp
  updated_by: UUID (User)
  environment: enum (dev, staging, prod)
  source: enum (manual, imported, templated)
  source_url: string (nullable)
  naming_rules: [
    {
      entity_type: enum (table, column, index, constraint, abbreviation)
      pattern: string (regex or template)
      case_convention: enum (PascalCase, camelCase, UPPER_SNAKE, lower_snake)
      description: string
      is_required: boolean
    }
  ]
  validation_rules: [
    {
      name: string
      pattern: string (regex)
      error_message: string
    }
  ]
  is_active: boolean
  is_template: boolean (for built-in templates)
}

StyleGuideUsage {
  guide_id: UUID
  resource_type: enum (Database, Schema, Server)
  resource_id: UUID
  applied_at: timestamp
  applied_by: UUID (User)
  violations_count: integer
}
```

## Success Criteria

### Functional
- ✅ Users can create style guides with multiple naming rules
- ✅ Users can import valid JSON/YAML style guides without data loss
- ✅ Users can modify existing guides and see version history
- ✅ System validates schema against applied style guides
- ✅ Violations are clearly identified with correction suggestions
- ✅ Users can export guides in multiple formats

### Performance
- ✅ Style guide creation: < 2 seconds
- ✅ Import large guide (500+ rules): < 5 seconds
- ✅ Validation of 1000-table schema: < 3 seconds
- ✅ List style guides: < 1 second (with pagination)

### Usability
- ✅ Style guide creation wizard is 3 steps maximum
- ✅ Import process shows clear validation errors
- ✅ Violations report is sortable and filterable
- ✅ Export formats are standards-compliant

### Data Quality
- ✅ All style guides are versioned
- ✅ Change audit trail is complete
- ✅ Imports preserve all metadata
- ✅ No data loss on modification

## Dependencies

- **Abbreviation Management**: Leverage existing abbreviation system for guide rules
- **Database Schema**: Extend current schema metadata to track guide application
- **RBAC System**: Only Admins can create/modify guides
- **Audit System**: Track all guide creation, modification, and application events

## Assumptions

1. Style guides are organization-level (not server/database specific)
2. Multiple guides can coexist; only one is applied per resource at a time
3. Applying a guide does NOT automatically rename schema elements (only suggests)
4. Teams will share guides via export/import or through version control
5. Built-in templates will be provided (e.g., "Microsoft SQL Server Standard")

## Out of Scope

- Automatic schema renaming (recommendation only)
- Machine learning to auto-detect naming patterns
- Enforcement via database triggers
- Integration with external style guide repositories (initial phase)

## Related Features

- [Abbreviation Management](abbreviations.md) - Coordinate with naming rules
- [Database Schema Validation](schema-validation.md) - Use guides for validation
- [Audit Trail System](audit-trail.md) - Track guide application and changes

---

**Priority for Implementation:** Phase 2  
**Estimated Effort:** 13 story points (3-week sprint)  
**Team:** Backend (database model) + Frontend (UI) + DevOps (testing)
