# Feature Specification: Extended Naming Support

**Feature Branch**: `004-extended-naming`  
**Created**: February 8, 2026  
**Status**: Draft  
**Input**: User description: "Support naming beyond schemas: databases, servers, infrastructure as code, and MVP products with code names"

## Overview

Expand the naming system beyond database schema elements (tables, columns) to support naming other critical infrastructure and project artifacts: databases, servers, Kubernetes resources, Terraform modules, Docker containers, cloud resources, and MVP product code names. Users can apply thematic guides and industry templates to any artifact type, creating consistent naming conventions across the entire technology stack.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Apply Naming Guides to Databases and Servers (Priority: P1)

Database and server administrators need consistent, memorable naming conventions for infrastructure. They should be able to apply the same thematic guides used for schemas to name databases, server instances, and cloud VMs.

**Why this priority**: Database/server naming is foundational infrastructure decision. Applying consistent naming patterns here cascades to all downstream systems. This delivers immediate value to infrastructure teams.

**Independent Test**: Can be fully tested by: 1) Selecting a thematic guide (e.g., Harry Potter), 2) Applying to database naming context, 3) Receiving themed suggestions (e.g., "dumbledore_prod", "hermione_staging", "potter_backup"), 4) Creating naming convention for database instances.

**Acceptance Scenarios**:

1. **Given** user navigates to "Database Naming" and selects a thematic guide, **When** user chooses context (Production, Staging, Development, Backup), **Then** system generates suggestions with context-aware suffixes (e.g., "dumbledore_prod", "hermione_stage")
2. **Given** user is naming server instances (physical or cloud VMs), **When** user applies thematic guide with server context, **Then** system generates short names suitable for hostnames (e.g., "dumbledore-01", "hermione-02") with numeric suffixes for multi-instance scenarios
3. **Given** multiple environments exist, **When** user applies naming convention, **Then** system automatically applies environment-specific suffixes (prod, stage, dev, test) based on context
4. **Given** user reviews naming suggestions, **When** user finds naming pattern suitable, **Then** system creates reusable naming convention that can be applied to all databases in organization

---

### User Story 2 - Support Infrastructure-as-Code Artifact Naming (Priority: P1)

DevOps and platform teams need naming guidance for Terraform modules, Docker images, Kubernetes resources, and cloud infrastructure. They should be able to apply naming guides to IaC artifacts and cloud resources to ensure consistency.

**Why this priority**: IaC is central to modern deployment. Consistent naming of Terraform modules, container images, and K8s resources prevents confusion and enables better automation. This is critical for DevOps teams.

**Independent Test**: Can be fully tested by: 1) Creating naming convention for Terraform modules, 2) Applying to naming context (compute, storage, networking, database), 3) Receiving themed suggestions for module names, 4) Applying same convention to container and K8s resources.

**Acceptance Scenarios**:

1. **Given** DevOps engineer selects thematic guide for Terraform, **When** user chooses resource type (compute, storage, networking, database, security), **Then** system generates thematic names (e.g., "terraform-module-dumbledore-compute", "tf-hermione-network") with scoped prefixes
2. **Given** user is naming Docker images, **When** user applies naming guide with container context, **Then** system generates tagged image names (e.g., "registry.example.com/dumbledore-api:v1", "registry.example.com/hermione-worker:latest")
3. **Given** user is naming Kubernetes resources (deployments, services, configmaps), **When** user applies naming convention, **Then** system generates K8s-compatible resource names (e.g., "dumbledore-deployment", "hermione-svc") following DNS/RFC standards
4. **Given** organization has multiple cloud providers (AWS, Azure, GCP), **When** user applies naming guide, **Then** system adapts names to cloud-specific constraints and naming conventions (e.g., AWS S3 bucket name restrictions)

---

### User Story 3 - Generate MVP/Product Code Names (Priority: P2)

Product and engineering teams need catchy, memorable code names for internal projects, MVPs, and releases. Thematic naming guides can generate product code names that align with team culture and project themes.

**Why this priority**: Product naming is valuable for team cohesion and marketing, but secondary to infrastructure naming. However, it's a distinct use case that drives team engagement with naming system.

**Independent Test**: Can be fully tested by: 1) Selecting thematic guide, 2) Applying to product naming context, 3) Generating code names for MVP release cycle, 4) Documenting naming scheme for team.

**Acceptance Scenarios**:

1. **Given** product team is planning MVP release cycle, **When** user selects thematic guide for product code names, **Then** system generates sequence of project code names (e.g., "Project Dumbledore" Phase 1, "Project Hermione" Phase 2, "Project Potter" Phase 3)
2. **Given** user is naming major features or releases, **When** user applies naming guide with product context, **Then** system generates memorable, brandable names for internal use and potential public release
3. **Given** multiple teams are using same thematic guide, **When** each team applies guide to products, **Then** system prevents code name collisions and suggests alternatives (e.g., "Scarlet" vs. "Scarlet-Platform-Team")
4. **Given** product team documents naming scheme, **When** user exports code name list, **Then** system generates document with code names, definitions, project descriptions, and usage guidelines

---

### User Story 4 - Create Artifact Type Naming Profiles (Priority: P2)

Users need to customize how naming guides apply to different artifact types. A naming profile specifies naming patterns, constraints, and transforms for each artifact type (database, server, module, container, product).

**Why this priority**: Different artifact types have different naming constraints (length, allowed characters, case conventions). Profiles enable flexible adaptation of thematic guides to diverse artifact types, but this is secondary to core functionality.

**Independent Test**: Can be fully tested by: 1) Creating naming profile for Kubernetes resources, 2) Specifying naming constraints (lowercase, DNS-compliant), 3) Applying profile to guide, 4) Generating K8s-safe names.

**Acceptance Scenarios**:

1. **Given** user navigates to "Naming Profiles", **When** user creates new profile for Kubernetes, **Then** system displays profile settings: name format, case convention (lowercase), separator (dash), prefix/suffix patterns, max length (63 chars for DNS)
2. **Given** profile configured, **When** user applies thematic guide with this profile, **Then** system transforms themed names to match profile constraints (e.g., "Harry Potter" → "harry-potter-01", respecting DNS rules)
3. **Given** organization has multiple naming contexts, **When** user manages profiles, **Then** system displays all profiles with artifact types, constraints, and application count
4. **Given** user applies same guide across different profiles, **When** same themed element is used, **Then** system maintains element identity while adapting format to each profile's constraints

---

### User Story 5 - Document and Export Naming Conventions (Priority: P3)

Teams need to document naming conventions they've created across all artifact types. Export should generate compliance documentation, naming schemas, and team guidelines.

**Why this priority**: Documentation enables governance and onboarding, but is less critical than core naming functionality. Can be Phase 2 feature.

**Independent Test**: Can be fully tested by: 1) Creating naming conventions for multiple artifact types, 2) Exporting as documentation, 3) Verifying document includes all conventions and examples.

**Acceptance Scenarios**:

1. **Given** organization has defined naming conventions for all artifact types, **When** user clicks "Export Conventions", **Then** system generates markdown/PDF with: convention name, artifact types covered, naming examples, constraints, and team approval signatures
2. **Given** documentation exported, **When** user shares with team, **Then** document includes: naming patterns (regex), apply-by date, exceptions, and approval authority
3. **Given** conventions documented, **When** new team member joins, **Then** export serves as onboarding guide for naming standards across organization

---

### Edge Cases

- What happens when artifact naming constraints conflict with thematic guide? (e.g., Kubernetes max 63 chars, but themed name is longer) System MUST truncate intelligently with collision detection while preserving uniqueness
- How does system handle reserved names in different contexts? (e.g., "master" in Kubernetes, reserved keywords in cloud providers) System MUST maintain blocklist per artifact type and suggest alternatives
- What if user tries to apply product code name pattern to infrastructure? System MUST show clear warning about context mismatch and allow override with confirmation
- How are naming conventions enforced across teams? System MUST provide lint/validation APIs for CI/CD pipelines to check new resources against conventions (external tool integration point)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support naming artifact types: Database, Server, Terraform Module, Docker Container, Kubernetes Resource, Cloud Resource, MVP/Product
- **FR-002**: System MUST apply thematic guides and industry templates to any supported artifact type
- **FR-003**: System MUST generate context-aware naming suggestions for each artifact type (environment suffixes, scoped prefixes, provider-specific formats)
- **FR-004**: System MUST respect artifact type constraints: max length, allowed characters, case conventions, reserved names, DNS compliance
- **FR-005**: System MUST create reusable naming profiles that define format, constraints, and transforms for each artifact type
- **FR-006**: System MUST support environment contexts (Production, Staging, Development, Test, Backup) with automatic suffixes or prefixes
- **FR-007**: System MUST detect naming collisions across artifact types and suggest alternatives to prevent conflicts
- **FR-008**: System MUST maintain blocklist of reserved names per artifact type (Kubernetes reserved terms, AWS naming restrictions, etc.)
- **FR-009**: System MUST adapt same thematic guide to multiple artifact types without losing themed element identity
- **FR-010**: System MUST support cloud provider-specific naming adaptations (AWS S3 bucket restrictions, Azure naming conventions, GCP patterns)
- **FR-011**: System MUST track naming convention versioning and provide migration path for renamed artifacts
- **FR-012**: System MUST provide export functionality for naming conventions as documentation and lint rules
- **FR-013**: System MUST generate CI/CD-compatible output (JSON, YAML, Terraform rules) for convention enforcement in pipelines
- **FR-014**: System MUST record audit trail of all naming decisions with context and approver information
- **FR-015**: System MUST support team-specific naming governance with approval workflows for convention changes

## Key Entities *(include if feature involves data)*

- **ArtifactType**: Defines supported naming context. Contains: type_name (Database, Server, TerraformModule, DockerContainer, K8sResource, CloudResource, Product), constraints (max_length, allowed_chars, reserved_names), naming_examples array

- **NamingProfile**: Reusable format specification for artifact types. Contains: profile_name, artifact_type, name_format (template with variables), case_convention, separator_char, prefix/suffix patterns, max_length, created_by, version

- **NamingConvention**: Organization-wide standard for naming specific artifact type. Contains: convention_name, artifact_types array, thematic_guide_id, industry_template_id, profiles applied, environment suffixes, created_by, approval_status, effective_date

- **ArtifactNamingRecord**: Instance of artifact that was named. Contains: artifact_id, artifact_type, assigned_name, naming_convention_id, thematic_element_used, profile_applied, created_at, created_by, context (environment, team), version

- **CollisionDetectionRecord**: Tracks naming collisions and resolutions. Contains: artifact1_id, artifact2_id, artifact_types, collision_detected_at, resolution (renamed, approved, etc.), resolved_by

- **AuditLog**: Records all naming operations. Contains: artifact_id, action_type (created/renamed/approved/versioned), timestamp, user_id, old_name, new_name, context_info

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can generate naming suggestions for any of 7 supported artifact types in under 500ms
- **SC-002**: Naming profile creation and application takes under 2 minutes per artifact type
- **SC-003**: System detects 100% of naming collisions across artifact types within same namespace
- **SC-004**: Reserved name blocklist prevents 100% of constraint violations
- **SC-005**: Context-aware naming (environment suffixes, scoped prefixes) generates correct formats 98%+ of the time
- **SC-006**: Cloud provider-specific naming adaptations succeed 95%+ of the time without manual override
- **SC-007**: Thematic element identity is preserved when applying same guide across 5+ artifact types
- **SC-008**: Naming convention export generates valid JSON/YAML CI/CD lint rules 100% of the time
- **SC-009**: Team collision prevention (code name conflicts) is enforced across all teams
- **SC-010**: All naming operations include complete audit trail with approver signatures
- **SC-011**: Organizations report 50%+ reduction in naming-related infrastructure issues post-implementation
- **SC-012**: 80%+ of teams adopt artifact type naming conventions within first quarter

## Dependencies

- **Thematic Naming Guides** (Feature 002): Required for naming suggestions
- **Industry Templates** (Feature 003): Optional but enhances domain-specific naming
- **Style Guides** (Feature 001): Can be combined for enforcement rules (Phase 2)
- **Database Schema**: Persist naming conventions and audit trail
- **RBAC System**: Enforce approval workflows for convention changes
- **Audit System**: Track all naming decisions

## Assumptions

1. Different artifact types have fundamentally different naming constraints and contexts
2. Organizations need governance around naming consistency across entire technology stack
3. Environment contexts (prod, stage, dev) are universally applicable across artifact types
4. Cloud providers have specific naming restrictions that must be respected automatically
5. Reserved names blocklists are maintained by system admins and updated periodically
6. Naming profiles are organizational assets; multiple teams can reuse same profiles
7. Product code naming is optional use case; teams may not participate
8. Collision detection operates within namespace boundaries (prod naming separate from dev)

---

**Estimated Effort:** 13 story points (3-week sprint for multi-artifact support)  
**Team:** Backend (artifact naming API) + Frontend (profile builder UI) + DevOps (constraint validation)  
**Dependencies**: Thematic Naming feature (002) recommended before starting this feature
