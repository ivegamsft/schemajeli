# Feature Specification: Industry-Specific Naming Templates

**Feature Branch**: `003-industry-naming`  
**Created**: February 8, 2026  
**Status**: Draft  
**Input**: User description: "Allow import of standard industry-specific names so users can specify industry and use case and system presents standard starter set of names as theme"

## Overview

Enable users to quickly bootstrap database schemas with domain-standard naming conventions by selecting an industry (Retail, Finance, Healthcare, SaaS, etc.) and business context (e.g., Bookstore, Fashion E-commerce, CRM). The system provides curated, industry-standard entity and attribute names that reflect best practices and common patterns in that domain, imported as a naming theme.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Select Industry and Use Case to Import Names (Priority: P1)

Users need to quickly populate schema with relevant, industry-standard naming without manual identification of entities. By selecting an industry and specific use case, the system provides a vetted set of domain-appropriate names.

**Why this priority**: This is the core feature delivering immediate value. Users can instantly get domain-expert naming patterns applicable to their specific business context, saving time and ensuring schema alignment with industry practices.

**Independent Test**: Can be fully tested by: 1) Navigating to industry templates, 2) Selecting industry + use case (e.g., Retail > Bookstore), 3) Viewing generated naming suggestions, 4) Creating a theme from the suggestions.

**Acceptance Scenarios**:

1. **Given** user navigates to "Industry Templates", **When** user sees industry selector, **Then** system displays list of industries (Retail, Finance, Healthcare, SaaS, Education, Hospitality, Manufacturing, Entertainment, Media, Publishing)
2. **Given** user selects "Retail" industry, **When** user clicks "Next", **Then** system displays contextual use cases (Bookstore, Fashion, Grocery, Electronics, General Merchandise, Multi-vendor Marketplace)
3. **Given** user selects "Retail > Bookstore", **When** page loads, **Then** system displays: industry description, recommended entities (Book, Author, Publisher, Order, Customer, Inventory), and domain-specific attributes (ISBN, StockQuantity, ServiceType, ShippingAddress)
4. **Given** templates displayed, **When** user clicks "Preview Names", **Then** system shows sample table/column names following bookstore conventions (tbl_book, col_isbn, tbl_author, col_publisheddate)

---

### User Story 2 - Browse Available Industries and Use Cases (Priority: P1)

Users need to explore what industries and business contexts are available before committing to import. A browsable catalog helps users find relevant templates and understand what naming patterns are available.

**Why this priority**: Discovery drives adoption. Users need clear visibility into industry options and what naming conventions come with each choice. This is critical to first-time user experience.

**Independent Test**: Can be fully tested by: 1) Opening industry template browser, 2) Viewing all industries with icons/descriptions, 3) Expanding use cases within each industry, 4) Previewing sample entities for each context.

**Acceptance Scenarios**:

1. **Given** user accesses industry templates catalog, **When** page loads, **Then** system displays 10+ industries with icons, count of available use cases, and brief description
2. **Given** user sees industry list, **When** user clicks on an industry, **Then** system expands to show 4-8 use cases specific to that industry with descriptions
3. **Given** use case is displayed, **When** user hovers/clicks on use case, **Then** system shows: typical entities (3-5 examples), count of total entities, count of total attributes
4. **Given** users exploring templates, **When** user uses search box, **Then** system filters industries/use cases by keyword (e.g., "retail" finds all retail-related contexts)

---

### User Story 3 - Import Industry Template as Named Theme (Priority: P1)

When users select an industry/use case, the system imports that template as a theme they can immediately use for naming suggestions and apply to their schema.

**Why this priority**: Completing the flow from discovery to application is critical. Users need to quickly convert industry template selection into an actionable naming theme in one click.

**Independent Test**: Can be fully tested by: 1) Selecting industry template, 2) Clicking "Import as Theme", 3) Verifying theme is created and available for naming suggestions.

**Acceptance Scenarios**:

1. **Given** user has selected an industry template, **When** user clicks "Import as Theme", **Then** system creates a new theme with template name (e.g., "Retail - Bookstore"), imports all entities/attributes, and confirms creation
2. **Given** theme imported, **When** user navigates to "Thematic Guides", **Then** system displays newly imported theme with "Industry Template" label, element count, and source industry
3. **Given** imported theme created, **When** user selects this theme for naming suggestions, **Then** system provides domain-appropriate names for tables/columns (e.g., "tbl_book", "col_authorid")
4. **Given** user wants to customize imported theme, **When** user edits the theme, **Then** previous entries remain linked to source template with modification history visible

---

### User Story 4 - Customize Industry Template Before Import (Priority: P2)

Users may want to adapt an industry template to their specific needs (remove unnecessary entities, add custom attributes) before importing as a theme.

**Why this priority**: Customization increases applicability of templates. Users can tailor industry patterns to their exact schema requirements, but this is secondary to the core import workflow.

**Independent Test**: Can be fully tested by: 1) Selecting industry template, 2) Removing/adding entities, 3) Confirming customization and importing.

**Acceptance Scenarios**:

1. **Given** user reviewing industry template, **When** user clicks "Edit Before Import", **Then** editor opens showing all template entities and attributes with add/remove buttons
2. **Given** editor open, **When** user clicks X next to an entity, **Then** entity and related attributes are marked for removal with strikethrough
3. **Given** user wants to add entity, **When** user clicks "Add Custom Entity", **Then** text input appears to add new entity name with optional description
4. **Given** user completes customization, **When** user clicks "Import", **Then** system creates theme with original entities minus removed items plus custom additions, preserving audit trail of modifications

---

### User Story 5 - Request New Industry Template to Catalog (Priority: P3)

Users may encounter business contexts not yet covered in the industry template catalog. They should be able to request new industry templates to expand the system's coverage.

**Why this priority**: Community feedback drives evolution of template catalog. Requests help prioritize new templates, but this is less critical than core functionality. Can be implemented as Phase 2 feature.

**Independent Test**: Can be fully tested by: 1) Accessingtemplate request form, 2) Submitting industry/use case request, 3) Confirming request is logged.

**Acceptance Scenarios**:

1. **Given** user cannot find their specific industry, **When** user clicks "Request New Template", **Then** form appears asking for industry name, use case, and description of typical entities
2. **Given** form completed, **When** user clicks "Submit Request", **Then** system confirms request and shows "Request submitted - we'll review and prioritize"
3. **Given** request submitted, **When** Admin reviews requests, **Then** system shows request queue with voting/priority indicators

---

### Edge Cases

- What happens when an industry has overlapping use cases? System MUST clearly distinguish each use case with specific description and show sample entities to clarify differences
- How does system handle user importing same industry template twice? System MUST detect duplicate imports and ask user to rename (append number or custom suffix) to prevent confusion
- What if industry template references entities not commonly used in user's schema? System MUST show template preview with entity descriptions BEFORE import, allowing users to understand what they're getting
- What happens when user edits an imported industry template and later a new version of the template is released? System MUST allow users to merge updates or keep current version with clear versioning markers

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST maintain catalog of 30+ industry templates covering major business domains (Retail, Finance, Healthcare, SaaS, Education, Hospitality, Manufacturing, Entertainment, Media, Publishing)
- **FR-002**: System MUST support tiered use case counts: major industries (Retail, Finance, Healthcare, SaaS) MUST have 5-8 use cases; emerging industries (Hospitality, Manufacturing) MAY have 3-5 use cases; minimum 3 use cases per industry
- **FR-003**: System MUST display industry templates with industry name, icon, description, use case count, and total entity count
- **FR-004**: System MUST allow users to search industry templates by industry name, use case name, or keyword (e.g., "bookstore")
- **FR-005**: System MUST show template preview including: industry/use case description, typical entities (3-5 with brief descriptions), total entity count, total attribute count, schema complexity indicator
- **FR-006**: System MUST import industry template as new theme with template name, element list, and "Industry Template" source marker
- **FR-007**: System MUST prevent duplicate imports of same template, warning user if they attempt to import already-imported template and offering rename option
- **FR-008**: System MUST allow users to customize industry template before import (add/remove entities, add custom attributes, edit descriptions)
- **FR-009**: System MUST persist customization audit trail showing which entities/attributes were added/removed and why
- **FR-010**: System MUST generate naming suggestions from imported industry template using entity/attribute naming patterns from domain
- **FR-011**: System MUST support template versioning allowing users to accept updates or keep current version when new template versions released
- **FR-012**: System MUST display template version history and changelog showing what changed between versions
- **FR-013**: System MUST enforce Admin-only access to create/manage/update industry templates in catalog
- **FR-014**: System MUST support user requests for new industry templates with tracking and prioritization
- **FR-015**: System MUST export industry templates in standard format (JSON) to allow backup and sharing

### Key Entities *(include if feature involves data)*

- **IndustryTemplate**: Pre-curated domain naming standard. Contains: industry_name, use_case_name, description, icon_url, entity_list (with descriptions), attribute_list (with type/constraints), version, created_at, last_updated_at, popularity_score

- **TemplateEntity**: Named business concept in industry template (e.g., "Book", "Customer", "Order"). Contains: entity_name, description, entity_type (core/optional), related_attributes array, data_classification

- **TemplateAttribute**: Named property/column in domain entity (e.g., "ISBN", "PublishedDate"). Contains: attribute_name, data_type_hint, description, is_required, business_purpose

- **ImportedIndustryTheme**: Instance of industry template imported into user's theme library. Contains: template_id (reference), theme_name (derived or custom), customizations (entities/attributes added/removed), import_date, imported_by, customization_audit

- **TemplateRequest**: User request for new industry template. Contains: industry_name, use_case_name, description, requested_by, requested_date, status (pending/approved/completed), votes (upvoted count)

- **AuditLog**: Records all template operations. Contains: template_id, action_type (imported/customized/updated), timestamp, user_id, change_summary

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can browse industry templates and select import option in under 2 minutes
- **SC-002**: Industry template catalog loads with 30+ industries and use cases in under 1 second
- **SC-003**: Importing industry template as theme completes in under 3 seconds
- **SC-004**: Naming suggestions generated from industry templates match domain conventions 90%+ of the time
- **SC-005**: Search across industry templates and use cases returns relevant results in under 500ms
- **SC-006**: Users successfully customize and import industry templates without errors 95%+ of the time
- **SC-007**: Duplicate import detection prevents accidental duplicates 100% of accuracy
- **SC-008**: Template preview shows accurate entity/attribute counts with no discrepancies
- **SC-009**: All template operations include complete audit trail (user, timestamp, action)
- **SC-010**: 100% of industry template management (CRUD) operations restricted to Admin role
- **SC-011**: Industry templates reduce schema design time by 40% compared to manual naming (measured in pilot)
- **SC-012**: 75%+ of new users adopt at least one industry template in first month of feature availability

## Pre-populated Industry Templates (30+ at Launch)

Industry templates are curated by domain experts and updated quarterly. Coverage includes:

### Retail (5 use cases)
- Bookstore (65+ entities: Book, Author, Publisher, Order, Inventory, Review, Customer)
- Fashion E-commerce (70+ entities: Product, Garment Size, Color, Style, Collection, Cart, Order)
- Grocery Store (55+ entities: Product, SKU, Supplier, Store Location, Inventory, POS Transaction)
- Electronics Store (60+ entities: Product, Specification, Warranty, Supplier, DOA)
- Multi-vendor Marketplace (75+ entities: Vendor, Product Listing, Order, Fulfillment, Review, Rating)

### Financial Services (6 use cases)
- Banking Core (80+ entities: Account, Customer, Transaction, Card, Loan, Balance)
- Payroll System (50+ entities: Employee, Compensation, Tax, Deduction, Paycheck)
- Investment Portfolio (70+ entities: Security, Holding, Transaction, Fund, Performance)
- Insurance Claims (65+ entities: Policy, Claim, Damage, Adjuster, Settlement)
- Cryptocurrency/Blockchain (60+ entities: Wallet, Transaction, Block, Smart Contract)
- Lending Platform (55+ entities: Borrower, Loan, Repayment, Interest, Risk Assessment)

### Healthcare (5 use cases)
- Clinic/Hospital (75+ entities: Patient, Provider, Appointment, Prescription, Diagnosis, Room)
- Electronic Health Records (80+ entities: MedicalHistory, Vital, Lab Result, Imaging Report)
- Pharmacy Management (60+ entities: Drug Inventory, Prescription, Filling, Insurance Claim)
- Insurance Eligibility (55+ entities: Plan, Coverage, Deductible, Claim Processing)
- Mental Health Platform (50+ entities: Patient, Session, Therapist, Medication, Progress Note)

### SaaS/Software (7 use cases)
- CRM System (85+ entities: Account, Contact, Opportunity, Deal, Activity, Pipeline)
- Project Management (70+ entities: Project, Task, Milestone, Assignee, Comment, TimeLog)
- Email Marketing Platform (65+ entities: Campaign, Subscriber, Audience, Template, Sending, Analytics)
- Document Management (55+ entities: Document, Version, Permission, Workflow, Comment)
- HR Management System (75+ entities: Employee, Department, Position, Benefit, Payroll)
- Analytics Platform (60+ entities: Event, Metric, Dimension, Dashboard, User, Segment)
- Learning Management System (65+ entities: Course, Student, Enrollment, Lesson, Quiz, Grade)

### Education (3 use cases)
- University (80+ entities: Student, Faculty, Course, Enrollment, Grade, Department)
- Online Learning Platform (70+ entities: Learner, Course, Module, Lesson, AssignmentLet me split that last one.

## Dependencies

- **Thematic Naming Guides**: Industry templates are imported as themes; requires thematic naming feature to be fully functional
- **Database Schema**: Industry templates provide naming reference for schema design phase
- **RBAC System**: Only Admins can manage templates; all users can browse/import
- **Audit System**: Track all template operations for governance and analytics

## Assumptions

1. Industry templates are curated by domain experts and updated by Admin team quarterly
2. Each industry has 5-8 relevant use cases; edge case industries may have fewer options
3. Templates provide naming guidance, not schema validation rules (no constraints enforcement)
4. Users can customize templates before import but cannot edit templates after import (version-locked)
5. Duplicate import detection uses template ID not name (allows reimport with renamed theme)
6. Template request feature is secondary; initial launch provides 30+ popular templates covering 80% of use cases

---

**Estimated Effort:** 8 story points (2-week sprint for database + API + UI)  
**Team:** Backend (template management/API) + Frontend (template browser/preview) + Content (curate templates)  
**Dependencies**: Thematic Naming feature (feature 002) must be deployed first
