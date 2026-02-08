# Feature Specification: Style Guide Management

**Feature Branch**: `001-style-guides`  
**Created**: February 8, 2026  
**Status**: Draft  
**Input**: User description: "Create style guide management for defining, importing, and modifying naming conventions and standards"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create Custom Style Guide (Priority: P1)

Administrators need to define organization-specific naming conventions for databases, tables, columns, and other schema elements. They should be able to create a reusable style guide that enforces consistent naming patterns across multiple deployments.

**Why this priority**: Creating style guides is the foundation of the feature. Without this, nothing else can be applied or imported. This delivers immediate value by allowing teams to document their naming standards.

**Independent Test**: Can be fully tested by: 1) Creating a new style guide with name, description, and naming rules, 2) Verifying the guide appears in the style guide list, 3) Confirming the guide can be applied to a database.

**Acceptance Scenarios**:

1. **Given** user is an Administrator, **When** user navigates to "Style Guides" and clicks "Create New", **Then** user sees a form with fields for name, description, and naming rule builder
2. **Given** user has filled in guide name and at least one naming rule, **When** user clicks "Save", **Then** system persists the guide to database and shows confirmation message
3. **Given** style guide has been created, **When** administrator views the style guide list, **Then** the new guide appears in the list with creation date and version "1.0"
4. **Given** user is creating a style guide, **When** user leaves the name field empty, **Then** system shows validation error "Name is required"

---

### User Story 2 - Import Style Guide from File (Priority: P2)

Teams need to import standardized style guides from shared sources (GitHub, team repositories). This allows reuse of proven naming conventions without manual recreation.

**Why this priority**: Importing allows organizations to adopt industry standards or shared team conventions. This is critical for onboarding new teams and standardizing across departments, but secondary to the ability to create custom guides.

**Independent Test**: Can be fully tested by: 1) Uploading a valid JSON style guide file, 2) Verifying the file is parsed correctly, 3) Confirming the imported guide appears in the list with source metadata.

**Acceptance Scenarios**:

1. **Given** user clicks "Import Style Guide", **When** user selects a valid JSON file with naming rules, **Then** system displays preview of rules before import
2. **Given** preview is displayed, **When** user confirms import, **Then** system creates the guide with "Imported" source label and records the import timestamp
3. **Given** user attempts to import a malformed JSON file, **When** user selects the file, **Then** system shows validation error with specific issue (e.g., "Invalid JSON syntax at line 5")
4. **Given** a style guide with the same name already exists, **When** user imports a guide with that name, **Then** system prevents duplicate and suggests renaming

---

### User Story 3 - Modify Existing Style Guide (Priority: P2)

Administrators need to update style guides as naming conventions evolve. They should be able to edit rules, add new conventions, and maintain version history of changes.

**Why this priority**: Modification keeps style guides current and maintainable. Without versioning and history, teams can't track when conventions changed, but this is secondary to being able to create and import guides.

**Independent Test**: Can be fully tested by: 1) Opening an existing style guide for edit, 2) Changing a naming rule pattern, 3) Saving changes and verifying version increments.

**Acceptance Scenarios**:

1. **Given** user opens an existing style guide, **When** user clicks "Edit", **Then** user sees all current rules in editable form
2. **Given** user has modified a naming rule pattern, **When** user clicks "Save", **Then** system creates new version (e.g., increments from 1.0 to 1.1) and persists change
3. **Given** a style guide has been modified, **When** user views guide details, **Then** system shows version history with previous versions and option to view
4. **Given** a style guide is being edited, **When** user clicks "Show Usage", **Then** system displays "Used in X databases/schemas" with option to see impact analysis

---

### User Story 4 - Validate Schema Against Style Guide (Priority: P3)

Teams should be able to validate their existing schema elements against a style guide to identify naming violations and receive correction suggestions.

**Why this priority**: Validation enables style guide enforcement but is not critical for the core functionality. It's a supporting feature that demonstrates value after guides are created and applied.

**Independent Test**: Can be fully tested by: 1) Applying a style guide to a database, 2) Running validation, 3) Viewing violation report with suggestions.

**Acceptance Scenarios**:

1. **Given** user selects a database and a style guide, **When** user clicks "Validate", **Then** system analyzes all schema elements and generates report
2. **Given** validation has completed, **When** user views results, **Then** system displays violation count, list of violations, and suggested corrections
3. **Given** violations are displayed, **When** user selects individual violations, **Then** system shows "before/after" comparison of naming changes
4. **Given** user reviews violations, **When** user clicks "Audit Trail", **Then** system records which guide was applied by which user and when

---

### User Story 5 - Export Style Guide (Priority: P3)

Teams need to export style guides to share with external teams or version control systems. Export ensures guides can be backed up and distributed in standard formats.

**Why this priority**: Export is valuable for sharing and documentation but not critical to the core feature. It can be added after create/import/modify are fully functional.

**Independent Test**: Can be fully tested by: 1) Selecting a style guide, 2) Exporting to JSON, 3) Verifying exported file is valid and re-importable.

**Acceptance Scenarios**:

1. **Given** user selects a style guide, **When** user clicks "Export" and chooses "JSON", **Then** system downloads valid JSON file containing all rules
2. **Given** file has been exported, **When** user re-imports the exported file, **Then** system parses it successfully without data loss
3. **Given** user exports a style guide, **When** user opens the exported file, **Then** file includes guide name, version, creation date, and all naming rules

---

### Edge Cases

- What happens when a style guide has no naming rules defined? System MUST reject save and show error "At least one naming rule is required"
- How does system handle large style guides with 1000+ naming rules? System MUST load in under 5 seconds and paginate the rules list
- What if user modifies a style guide while it's being applied to multiple databases? System MUST show warning "This guide is currently in use by 3 databases. Changes will affect those resources."

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow Administrators to create new style guides with name, description, and naming rules
- **FR-002**: System MUST validate style guide name is unique and non-empty
- **FR-003**: System MUST support importing style guides from JSON and YAML file formats
- **FR-004**: System MUST validate imported file structure matches style guide schema before import
- **FR-005**: System MUST maintain version history of all style guide changes
- **FR-006**: System MUST allow Administrators to edit existing style guides and increment version number
- **FR-007**: System MUST prevent deletion of style guides that are currently applied to resources, showing "In Use" status
- **FR-008**: System MUST allow querying the list of style guides with search, filter, and pagination
- **FR-009**: System MUST record audit trail of style guide creation, modification, and application (user, timestamp, action)
- **FR-010**: System MUST validate database schema elements against applied style guide and report violations
- **FR-011**: System MUST export style guides in JSON and YAML formats with all metadata preserved
- **FR-012**: System MUST enforce Admin role for all style guide management operations (create, import, modify, delete)
- **FR-013**: System MUST support naming rules with regex patterns, case conventions, and description fields
- **FR-014**: System MUST allow style guide application to database/schema entities via UI
- **FR-015**: System MUST persist style guides with unique IDs and maintain referential integrity with usage records

### Key Entities *(include if feature involves data)*

- **StyleGuide**: Represents a reusable set of naming conventions with version control. Contains: name (unique), description, version, creation metadata, active status, source (manual/imported)

- **NamingRule**: Represents a single naming convention pattern within a style guide. Contains: entity type (table/column/index/constraint), regex pattern, case convention (PascalCase/camelCase/UPPER_SNAKE/lower_snake), description, required flag

- **ValidationRule**: Optional regex-based rule for deeper validation. Contains: name, pattern, error message to display on violation

- **StyleGuideUsage**: Tracks application of style guide to schemas/databases. Contains: style guide ID, resource type and ID, applied timestamp, applied by user ID, violation count

- **AuditLog**: Records all changes to style guides. Contains: style guide ID, action type (created/modified/applied), timestamp, user ID, change summary

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Administrators can create a style guide with 5+ naming rules in under 3 minutes
- **SC-002**: System can import a style guide from valid JSON/YAML file in under 2 seconds
- **SC-003**: Validation of a 1000-table schema against style guide completes in under 5 seconds
- **SC-004**: Style guide list view loads with pagination of 50 guides in under 1 second
- **SC-005**: All style guide operations (CRUD) include complete audit trail with user, timestamp, and action
- **SC-006**: System prevents accidental deletion of in-use style guides with clear warning message
- **SC-007**: Exported style guides are valid and can be re-imported without data loss
- **SC-008**: 100% of style guide management operations are restricted to Admin role
- **SC-009**: Style guide versioning correctly increments major.minor on modifications
- **SC-010**: Violation report displays before/after comparisons for all suggested corrections
