# Tasks: Thematic Naming Guide

**Input**: Design documents from `/specs/002-thematic-naming/`  
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md  

**Tests**: The feature specification does NOT explicitly request TDD or test-first approach. Test tasks are included as optional items based on constitution requirements (70% coverage minimum).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story?] Description`

- **Checkbox**: Always `- [ ]` (markdown checkbox)
- **[ID]**: Sequential task number (T001, T002, etc.)
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3) - only for user story phases
- Include exact file paths in descriptions

## Path Conventions

Web application structure with backend/frontend separation as defined in plan.md:
- Backend: `src/backend/src/`
- Frontend: `src/frontend/src/`
- Tests: `src/backend/tests/` (unit/integration), `tests/` (E2E Playwright)
- Database: `src/backend/prisma/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Database schema and project structure initialization

- [ ] T001 Extend Prisma schema with ElementType enum in src/backend/prisma/schema.prisma
- [ ] T002 Extend Prisma schema with ThematicGuide model in src/backend/prisma/schema.prisma
- [ ] T003 [P] Extend Prisma schema with ThemeElement model in src/backend/prisma/schema.prisma
- [ ] T004 [P] Extend Prisma schema with ThemeLibraryItem model in src/backend/prisma/schema.prisma
- [ ] T005 [P] Extend Prisma schema with ThemeUsageRecord model in src/backend/prisma/schema.prisma
- [ ] T006 Create Prisma migration for thematic naming tables in src/backend/prisma/migrations/
- [ ] T007 Create seed data for 10 pre-built themes with 400+ elements in src/backend/prisma/seed.ts

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T008 Create RBAC middleware for Admin-only route protection in src/backend/src/middleware/rbac.ts
- [ ] T009 Create naming utility functions (snake_case, identifier truncation, sanitization) in src/backend/src/utils/namingUtils.ts
- [ ] T010 Create validation schemas for theme operations using Joi in src/backend/src/validators/themeValidators.ts
- [ ] T011 Create API error response envelope with structured errors in src/backend/src/utils/errorResponse.ts
- [ ] T012 Create audit logging service for theme operations in src/backend/src/services/auditLogService.ts
- [ ] T013 Run Prisma migration and seed built-in themes via npm scripts
- [ ] T014 Create Express router structure for thematic guides in src/backend/src/routes/thematicGuides.ts

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Create Custom Thematic Naming Guide (Priority: P1) 🎯 MVP

**Goal**: Enable Admins to create custom thematic naming guides with theme name, description, and themed elements (minimum 3).

**Independent Test**: 
1. Admin creates new thematic guide with theme name and 5 elements
2. System persists guide to database with unique ID
3. System generates preview naming suggestions for tables/columns
4. Verify guide appears in theme list

### Implementation for User Story 1

- [ ] T015 [P] [US1] Create ThematicGuideService with CRUD operations in src/backend/src/services/thematicGuideService.ts
- [ ] T016 [P] [US1] Create ThemeElementService for element management in src/backend/src/services/themeElementService.ts
- [ ] T017 [US1] Implement POST /api/themes/guides endpoint for guide creation in src/backend/src/routes/thematicGuides.ts
- [ ] T018 [US1] Implement validation for minimum 3 elements in src/backend/src/validators/themeValidators.ts
- [ ] T019 [US1] Implement audit logging for guide creation in thematicGuideService.ts
- [ ] T020 [US1] Create ThemeCreationWizard React component in src/frontend/src/components/themes/ThemeCreationWizard.tsx
- [ ] T021 [US1] Create API client methods for guide creation in src/frontend/src/services/thematicGuideAPI.ts
- [ ] T022 [US1] Implement form validation and error display in ThemeCreationWizard component
- [ ] T023 [US1] Add preview naming feature to wizard in ThemeCreationWizard.tsx

**Checkpoint**: At this point, Admins can create custom thematic guides with elements and see preview suggestions

---

## Phase 4: User Story 2 - Create Guide from Built-in Theme (Priority: P1)

**Goal**: Enable users to quickly create themed guides by selecting from 10 pre-built themes without manual data entry.

**Independent Test**:
1. User selects "Harry Potter" from built-in theme dropdown
2. System loads 50+ Harry Potter elements
3. User clicks "Create Guide"
4. System creates guide with theme name, description, and all elements
5. Verify naming suggestions use Harry Potter names

### Implementation for User Story 2

- [ ] T024 [P] [US2] Create ThemeLibraryService for built-in theme management in src/backend/src/services/themeLibraryService.ts
- [ ] T025 [P] [US2] Implement GET /api/themes/library endpoint for built-in themes in src/backend/src/routes/thematicGuides.ts
- [ ] T026 [US2] Implement POST /api/themes/guides/from-library endpoint in src/backend/src/routes/thematicGuides.ts
- [ ] T027 [US2] Create theme library browser component in src/frontend/src/components/themes/ThemeLibraryBrowser.tsx
- [ ] T028 [US2] Create useThemeLibrary React hook in src/frontend/src/hooks/useThemeLibrary.ts
- [ ] T029 [US2] Implement theme selection and guide creation flow in ThemeCreationWizard.tsx
- [ ] T030 [US2] Add theme icons and descriptions to library display in ThemeLibraryBrowser.tsx

**Checkpoint**: At this point, users can create guides from any of 10 built-in themes with one click

---

## Phase 5: User Story 3 - Apply Thematic Guide to Generate Naming Suggestions (Priority: P1)

**Goal**: Enable users to apply a thematic guide to receive themed naming suggestions for schema elements (tables, columns, etc.).

**Independent Test**:
1. User selects a table to name
2. User chooses a thematic guide (e.g., Harry Potter)
3. System generates 5-10 themed name suggestions
4. User selects "tbl_dumbledore"
5. System applies name and records usage

### Implementation for User Story 3

- [ ] T031 [P] [US3] Create NamingSuggestionService with LRU cycling algorithm in src/backend/src/services/namingSuggestionService.ts
- [ ] T032 [P] [US3] Implement three-stage suggestion pipeline (Filter → Rank → Format) in namingSuggestionService.ts
- [ ] T033 [US3] Implement POST /api/themes/suggestions endpoint in src/backend/src/routes/thematicGuides.ts
- [ ] T034 [US3] Implement POST /api/themes/apply endpoint to record usage in src/backend/src/routes/thematicGuides.ts
- [ ] T035 [US3] Create NamingSuggestionPanel React component in src/frontend/src/components/themes/NamingSuggestionPanel.tsx
- [ ] T036 [US3] Create useNamingSuggestions React hook in src/frontend/src/hooks/useNamingSuggestions.ts
- [ ] T037 [US3] Implement suggestion scoring logic (type match, freshness, recency, suffix penalty) in namingSuggestionService.ts
- [ ] T038 [US3] Implement collision avoidance and identifier truncation in namingSuggestionService.ts
- [ ] T039 [US3] Add usage tracking and denormalized counter updates in src/backend/src/services/themeUsageService.ts
- [ ] T040 [US3] Implement element cycling with numeric suffixes (_2, _3, etc.) in namingSuggestionService.ts

**Checkpoint**: At this point, the core MVP is complete - users can create guides and generate themed naming suggestions

---

## Phase 6: User Story 4 - Browse Available Themes (Priority: P2)

**Goal**: Enable users to discover available themed guides, understand theme characteristics, and preview naming examples.

**Independent Test**:
1. User navigates to Theme Library
2. System displays all themes with name, icon, description, element count
3. User clicks on "Star Wars" theme
4. System shows theme details with 10-15 example element names
5. User can search/filter themes

### Implementation for User Story 4

- [ ] T041 [P] [US4] Implement GET /api/themes/guides endpoint with pagination in src/backend/src/routes/thematicGuides.ts
- [ ] T042 [P] [US4] Implement GET /api/themes/guides/:id endpoint for theme details in src/backend/src/routes/thematicGuides.ts
- [ ] T043 [US4] Implement theme search and filter logic in ThemeLibraryService
- [ ] T044 [US4] Create ThematicGuidesPage main page component in src/frontend/src/pages/ThematicGuidesPage.tsx
- [ ] T045 [US4] Implement theme gallery view in ThemeLibraryBrowser.tsx
- [ ] T046 [US4] Implement theme detail panel with examples in ThemeLibraryBrowser.tsx
- [ ] T047 [US4] Add theme search and filter UI in ThemeLibraryBrowser.tsx
- [ ] T048 [US4] Implement theme popularity tracking in ThemeLibraryService

**Checkpoint**: At this point, users can discover and explore all available themes before creating guides

---

## Phase 7: User Story 5 - Customize Pre-built Theme (Priority: P2)

**Goal**: Enable users to customize pre-built themes by adding, removing, or replacing theme elements.

**Independent Test**:
1. User opens "Harry Potter" theme for editing
2. User adds custom element "dobby"
3. User removes element "voldemort"
4. User saves as new guide "(Modified)"
5. Verify naming suggestions use updated elements

### Implementation for User Story 5

- [ ] T049 [P] [US5] Implement PUT /api/themes/guides/:id endpoint for guide updates in src/backend/src/routes/thematicGuides.ts
- [ ] T050 [P] [US5] Implement POST /api/themes/guides/:id/clone endpoint in src/backend/src/routes/thematicGuides.ts
- [ ] T051 [US5] Create ThemeCustomizer React component in src/frontend/src/components/themes/ThemeCustomizer.tsx
- [ ] T052 [US5] Implement add/remove element functionality in ThemeCustomizer.tsx
- [ ] T053 [US5] Implement "Save as New Guide" with "(Modified)" label logic in thematicGuideService.ts
- [ ] T054 [US5] Add element list editor with drag-and-drop reordering in ThemeCustomizer.tsx
- [ ] T055 [US5] Implement preview updates when elements change in ThemeCustomizer.tsx

**Checkpoint**: At this point, users can customize any theme to match their specific needs

---

## Phase 8: User Story 6 - Export and Share Thematic Guide (Priority: P3)

**Goal**: Enable teams to export thematic guides to JSON for sharing with other projects or backup.

**Independent Test**:
1. User selects a thematic guide
2. User clicks "Export"
3. System downloads JSON file with guide data
4. Another user imports JSON file
5. System creates guide in database with all elements preserved

### Implementation for User Story 6

- [ ] T056 [P] [US6] Create ThemeExportService with JSON schema validation in src/backend/src/services/themeExportService.ts
- [ ] T057 [P] [US6] Implement GET /api/themes/guides/:id/export endpoint in src/backend/src/routes/thematicGuides.ts
- [ ] T058 [P] [US6] Implement POST /api/themes/guides/import endpoint with validation in src/backend/src/routes/thematicGuides.ts
- [ ] T059 [US6] Implement JSON Schema validation with ajv in themeExportService.ts
- [ ] T060 [US6] Implement version migration logic for schema versioning in themeExportService.ts
- [ ] T061 [US6] Implement SHA-256 checksum generation and verification in themeExportService.ts
- [ ] T062 [US6] Create ThemeExportDialog React component in src/frontend/src/components/themes/ThemeExportDialog.tsx
- [ ] T063 [US6] Implement export download functionality in ThemeExportDialog.tsx
- [ ] T064 [US6] Implement import file upload and validation in ThemeExportDialog.tsx
- [ ] T065 [US6] Add structured error display for import validation failures in ThemeExportDialog.tsx

**Checkpoint**: At this point, all 6 user stories are complete and independently functional

---

## Phase 9: Testing & Quality Assurance

**Purpose**: Comprehensive testing to achieve 70% coverage minimum per constitution

- [ ] T066 [P] Create unit tests for namingSuggestionService in src/backend/tests/unit/namingSuggestionService.test.ts
- [ ] T067 [P] Create unit tests for thematicGuideService in src/backend/tests/unit/thematicGuideService.test.ts
- [ ] T068 [P] Create unit tests for themeLibraryService in src/backend/tests/unit/themeLibraryService.test.ts
- [ ] T069 [P] Create unit tests for themeExportService in src/backend/tests/unit/themeExportService.test.ts
- [ ] T070 [P] Create unit tests for naming utility functions in src/backend/tests/unit/namingUtils.test.ts
- [ ] T071 [P] Create integration tests for theme API endpoints in src/backend/tests/integration/thematicGuidesAPI.test.ts
- [ ] T072 [P] Create E2E test for theme creation workflow in tests/thematic-naming/theme-creation.spec.ts
- [ ] T073 [P] Create E2E test for naming suggestions workflow in tests/thematic-naming/naming-suggestions.spec.ts
- [ ] T074 [P] Create E2E test for theme browser in tests/thematic-naming/theme-browser.spec.ts
- [ ] T075 [P] Create E2E test for theme customization in tests/thematic-naming/theme-customization.spec.ts
- [ ] T076 [P] Create E2E test for theme export/import in tests/thematic-naming/theme-export.spec.ts
- [ ] T077 Run test coverage analysis and verify 70% minimum coverage
- [ ] T078 Test edge cases: theme with <5 elements, 1000+ suggestions, element cycling behavior

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements, documentation, and production readiness

- [ ] T079 [P] Add API documentation for theme endpoints to OpenAPI spec in docs/api/
- [ ] T080 [P] Create user documentation for thematic naming feature in docs/features/thematic-naming.md
- [ ] T081 [P] Add Winston logging for all theme operations in services
- [ ] T082 [P] Add Application Insights telemetry for theme usage tracking
- [ ] T083 [P] Implement performance monitoring for suggestion generation (<500ms target)
- [ ] T084 Optimize database indexes for theme queries per research.md recommendations
- [ ] T085 [P] Add WCAG 2.1 AA accessibility compliance checks for theme UI components
- [ ] T086 [P] Run OWASP ZAP security scan on theme API endpoints
- [ ] T087 [P] Add input sanitization tests for XSS prevention in theme names/elements
- [ ] T088 Verify all constitution requirements are met (RBAC, audit trail, soft deletes, etc.)
- [ ] T089 Conduct performance testing with 100 concurrent users
- [ ] T090 Create runbook for theme seeding and maintenance in docs/operations/

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phases 3-8)**: All depend on Foundational phase completion
  - US1, US2, US3 (P1 stories) form the MVP - should be completed first
  - US4, US5 (P2 stories) can proceed after P1 stories
  - US6 (P3 story) can proceed after P2 stories or in parallel
- **Testing (Phase 9)**: Can proceed in parallel with implementation phases
- **Polish (Phase 10)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - May share components with US1 but independently testable
- **User Story 3 (P1)**: Depends on US1 or US2 (needs guides to generate suggestions from) - Can test with seeded themes
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Independently testable with seeded themes
- **User Story 5 (P2)**: Depends on US1 or US2 (needs guides to customize) - Can test with seeded themes
- **User Story 6 (P3)**: Depends on US1 (needs guides to export) - Can test with seeded themes

### Within Each User Story

- Backend services before API endpoints
- API endpoints before frontend components
- React hooks before components that use them
- Core functionality before UI polish
- Story complete before moving to next priority

### Parallel Opportunities

- **Phase 1 (Setup)**: Tasks T002-T005 can run in parallel (different models)
- **Phase 2 (Foundational)**: Tasks T009-T012 can run in parallel (different utilities)
- **User Story 1**: Tasks T015-T016 (services) can run in parallel
- **User Story 2**: Tasks T024-T025 (service + endpoint) can run in parallel
- **User Story 3**: Tasks T031-T032 (service development) can run in parallel
- **User Story 4**: Tasks T041-T042 (API endpoints) can run in parallel
- **User Story 5**: Tasks T049-T050 (update + clone endpoints) can run in parallel
- **User Story 6**: Tasks T056-T058 (export service + endpoints) can run in parallel
- **Phase 9 (Testing)**: All test tasks T066-T078 can run in parallel
- **Phase 10 (Polish)**: Most tasks can run in parallel (different concerns)

---

## Parallel Example: User Story 3 (Naming Suggestions)

```bash
# Launch service development in parallel:
Task T031: "Create NamingSuggestionService with LRU cycling algorithm"
Task T032: "Implement three-stage suggestion pipeline (Filter → Rank → Format)"

# Then launch API and usage tracking in parallel:
Task T033: "Implement POST /api/themes/suggestions endpoint"
Task T039: "Add usage tracking and denormalized counter updates"

# Then launch frontend components in parallel:
Task T035: "Create NamingSuggestionPanel React component"
Task T036: "Create useNamingSuggestions React hook"
```

---

## Implementation Strategy

### MVP First (User Stories 1, 2, 3 Only - All P1)

This delivers a complete, valuable feature that teams can immediately use:

1. ✅ Complete Phase 1: Setup (database schema)
2. ✅ Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. ✅ Complete Phase 3: User Story 1 (Create Custom Guides)
4. ✅ Complete Phase 4: User Story 2 (Create from Built-in Themes)
5. ✅ Complete Phase 5: User Story 3 (Generate Naming Suggestions)
6. **STOP and VALIDATE**: Test all three stories independently and together
7. Deploy/demo MVP

**MVP Delivers**:
- 10 pre-built themes with 400+ elements ready to use
- Custom guide creation for team-specific themes
- Themed naming suggestion generation with LRU cycling
- Complete core workflow: create → suggest → apply

### Incremental Delivery

After MVP deployment, add features incrementally:

1. **MVP Release** (US1 + US2 + US3): Core themed naming functionality
2. **Discovery Release** (US4): Add theme browsing and search
3. **Customization Release** (US5): Add theme editing capabilities
4. **Sharing Release** (US6): Add export/import for team collaboration

Each release adds value without breaking previous functionality.

### Parallel Team Strategy

With multiple developers after Foundational phase completes:

**Team A (Backend)**:
- US1 backend (T015-T019)
- US2 backend (T024-T026)
- US3 backend (T031-T034, T037-T040)

**Team B (Frontend)**:
- US1 frontend (T020-T023)
- US2 frontend (T027-T030)
- US3 frontend (T035-T036)

**Team C (Testing)**:
- Unit tests (T066-T070)
- Integration tests (T071)
- E2E tests (T072-T076)

---

## Task Summary

**Total Tasks**: 90

### By Phase:
- Phase 1 (Setup): 7 tasks
- Phase 2 (Foundational): 7 tasks (BLOCKING)
- Phase 3 (US1 - P1): 9 tasks
- Phase 4 (US2 - P1): 7 tasks
- Phase 5 (US3 - P1): 10 tasks
- Phase 6 (US4 - P2): 8 tasks
- Phase 7 (US5 - P2): 7 tasks
- Phase 8 (US6 - P3): 10 tasks
- Phase 9 (Testing): 13 tasks
- Phase 10 (Polish): 12 tasks

### By User Story:
- User Story 1 (Create Custom Guide): 9 tasks
- User Story 2 (Built-in Themes): 7 tasks
- User Story 3 (Generate Suggestions): 10 tasks
- User Story 4 (Browse Themes): 8 tasks
- User Story 5 (Customize Theme): 7 tasks
- User Story 6 (Export/Import): 10 tasks

### Parallel Opportunities: 45 tasks marked [P] can run in parallel within their phase

### MVP Scope:
- **Phases 1, 2, 3, 4, 5** = **40 tasks** for complete MVP
- Delivers all P1 user stories with seeded themes

---

## Format Validation

✅ **ALL tasks follow checklist format**: `- [ ] [ID] [P?] [Story?] Description with file path`
✅ **All tasks have unique sequential IDs**: T001-T090
✅ **All user story tasks have [Story] labels**: [US1], [US2], [US3], [US4], [US5], [US6]
✅ **All parallelizable tasks marked [P]**: 45 tasks can run in parallel
✅ **All tasks include file paths**: Exact file locations specified
✅ **Setup/Foundational tasks have no [Story] label**: Correctly formatted
✅ **Polish tasks have no [Story] label**: Correctly formatted

---

## Independent Test Criteria

Each user story can be tested independently:

- **US1**: Create guide → Verify in database → Generate preview → Verify suggestions
- **US2**: Select built-in theme → Create guide → Verify 50+ elements loaded → Test suggestions
- **US3**: Select guide → Request suggestions → Verify 5-10 themed names → Apply → Verify usage recorded
- **US4**: Open theme browser → View all themes → Search/filter → View details → Verify examples
- **US5**: Open guide → Add element → Remove element → Save as new → Verify modified guide works
- **US6**: Export guide → Download JSON → Validate format → Import → Verify data integrity

---

## Success Metrics (from spec.md)

- **SC-001**: Guide creation in <2 minutes ✅ (US1)
- **SC-002**: Theme gallery loads in <1s ✅ (US4)
- **SC-003**: Naming suggestions in <500ms ✅ (US3)
- **SC-004**: Built-in theme selection in <3s ✅ (US2)
- **SC-005**: Element cycling for 1000+ suggestions ✅ (US3)
- **SC-006**: Export/import without data loss ✅ (US6)
- **SC-007**: 85%+ suggestion success rate ✅ (US3)
- **SC-008**: Complete audit trail ✅ (Foundational + all stories)
- **SC-009**: Theme search in <1s ✅ (US4)
- **SC-010**: Admin-only operations enforced ✅ (Foundational + all stories)
- **SC-011**: 10 pre-built themes with 400+ elements ✅ (Setup)
- **SC-012**: Search across all themes in <1s ✅ (US4)

---

## Notes

- ✅ All tasks follow strict checklist format with checkboxes, IDs, and file paths
- ✅ Tasks organized by user story for independent implementation and testing
- ✅ Clear dependencies with Foundational phase blocking all user stories
- ✅ MVP scope clearly identified (Phases 1-5 = US1 + US2 + US3)
- ✅ Parallel opportunities identified for efficient team execution
- ✅ Independent test criteria for each user story
- ✅ All success criteria mapped to specific tasks
- ✅ Constitution requirements verified (RBAC, audit trail, security)
- ⚠️ Tests are optional but included for 70% coverage target
- 📝 Stop at any checkpoint to validate story independently before proceeding
