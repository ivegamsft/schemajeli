# Feature Specification: Thematic Naming Guide

**Feature Branch**: `002-thematic-naming`  
**Created**: February 8, 2026  
**Status**: Draft  
**Input**: User description: "Create a naming guide that allows specification of naming standards inspired by different themes like Harry Potter, Star Wars, fruit, animals, etc."

## Overview

Enable teams to create and use themed naming guides that provide pre-defined, themed naming conventions for schema elements. Instead of manually defining naming rules, users can choose a theme (e.g., Harry Potter characters, Star Wars planets, fruit names, animal names) and automatically generate contextually-themed naming suggestions. This makes schema naming fun, memorable, and team-specific while maintaining consistency.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create Custom Thematic Naming Guide (Priority: P1)

Teams need the ability to create custom thematic naming guides based on a chosen theme. A guide provides themed naming suggestions that make schema elements more memorable and personality-driven while maintaining naming consistency.

**Why this priority**: Creating custom themed guides is the foundation. Teams need to be able to define their own themes to make the feature valuable for different organizational contexts. This delivers immediate personality and team identity to database schemas.

**Independent Test**: Can be fully tested by: 1) Creating a new thematic guide with a theme name, 2) Defining theme elements (e.g., Harry Potter spells, potions, characters), 3) Verifying suggestions are generated for table/column naming.

**Acceptance Scenarios**:

1. **Given** user is an Administrator, **When** user navigates to "Thematic Naming Guides" and clicks "Create New", **Then** user sees form with theme selection and element list builder
2. **Given** user selects "Custom" theme and adds theme elements (e.g., 5+ themed names), **When** user clicks "Save", **Then** system persists guide and generates naming suggestions for database elements
3. **Given** thematic guide has been created, **When** user clicks "Preview Naming", **Then** system shows sample element names using theme (e.g., "tbl_dumbledore", "col_hermione")
4. **Given** user is creating guide, **When** user provides fewer than 3 theme elements, **Then** system shows error "Minimum 3 theme elements required"

---

### User Story 2 - Create Guide from Built-in Theme (Priority: P1)

Teams should be able to quickly create themed guides by selecting from pre-built themes (Harry Potter, Star Wars, fruit, animals, planets, musical artists, famous artists, mythology, flowers, colors) without manual data entry, or Admins can create entirely new custom themes.

**Why this priority**: Pre-built themes provide immediate value and require zero data entry. Teams can instantly start using fun naming conventions, making the feature accessible to all users regardless of theme customization skill.

**Independent Test**: Can be fully tested by: 1) Selecting a built-in theme from dropdown, 2) Creating guide from theme, 3) Verifying naming suggestions are generated correctly.

**Acceptance Scenarios**:

1. **Given** user clicks "Create New Thematic Guide", **When** user selects "Harry Potter" theme, **Then** system loads 50+ Harry Potter character/spell/potion names
2. **Given** theme selected, **When** user clicks "Create Guide", **Then** system creates guide with theme name, description, and themed element list
3. **Given** guide created from built-in theme, **When** user views guide details, **Then** system shows theme category, element count, and list of example names
4. **Given** multiple built-in themes available (10 pre-populated themes), **When** user views theme list, **Then** system displays themes with icons and element count (e.g., "Star Wars - 60 planets", "Musical Artists - 75 musicians", "Mythology - 40 deities")

---

### User Story 3 - Apply Thematic Guide to Generate Naming Suggestions (Priority: P1)

When designing or naming schema elements, users need to apply a thematic guide to receive themed naming suggestions that align with the chosen theme while following the element type (table, column, etc.).

**Why this priority**: This is the core value delivery. Without the ability to use guides for naming suggestions, they're just data storage. Getting themed suggestions makes naming schema elements fun and memorable.

**Independent Test**: Can be fully tested by: 1) Selecting a table to name, 2) Applying thematic guide, 3) Viewing generated themed suggestions, 4) Selecting and confirming a suggestion.

**Acceptance Scenarios**:

1. **Given** user is naming a new table and selects a thematic guide, **When** user clicks "Generate Suggestions", **Then** system displays 5-10 themed name options (e.g., "tbl_harry", "tbl_hermione", "tbl_dumbledore")
2. **Given** suggestions are displayed, **When** user clicks on a suggestion, **Then** system shows why this name fits (e.g., "Harry Potter character - protagonist, well-known")
3. **Given** user is naming a column in a Harry Potter themed context, **When** user clicks "Suggest Names", **Then** system provides themed suggestions (e.g., "col_spell", "col_potion", "col_wand")
4. **Given** no suitable theme matches available, **When** system generates suggestions, **Then** system falls back to numbered conventions (e.g., "col_1", "col_2") with clear messaging

---

### User Story 4 - Browse Available Themes (Priority: P2)

Users need to discover what themed naming guides are available in the system, understand each theme's style and vocabulary, and preview naming examples before committing to use a theme.

**Why this priority**: Theme discovery drives adoption. Users need to see options and understand theme characteristics before deciding which theme suits their team's needs. Secondary to core functionality but important for usability.

**Independent Test**: Can be fully tested by: 1) Viewing theme browser/gallery, 2) Previewing theme names and descriptions, 3) Viewing sample naming suggestions.

**Acceptance Scenarios**:

1. **Given** user navigates to "Theme Library", **When** page loads, **Then** system displays all available themes with name, icon, description, and element count
2. **Given** user clicks on a theme, **When** detail panel opens, **Then** system shows theme description, 10-15 example element names, stats (element count, popularity), and "Create Guide" button
3. **Given** viewing theme details, **When** user scrolls through example names, **Then** system groups examples by element type (characters vs. places vs. objects) with labels
4. **Given** multiple themes available, **When** user uses search box, **Then** system filters themes by name or keyword (e.g., "space" finds "Star Wars", "Planets")

---

### User Story 5 - Customize Pre-built Theme (Priority: P2)

Users may want to customize a pre-built theme by adding, removing, or replacing theme elements to match their team's preferences or context.

**Why this priority**: Customization increases flexibility and team buy-in. Users can adapt built-in themes to their specific needs, but this is secondary to the core create/apply/browse workflow.

**Independent Test**: Can be fully tested by: 1) Loading a built-in theme, 2) Adding custom elements, 3) Removing unused elements, 4) Verifying updated naming suggestions reflect changes.

**Acceptance Scenarios**:

1. **Given** user opens a pre-built theme for editing, **When** user clicks "Add Elements", **Then** text input appears to add theme-specific names (e.g., "dobby" for Harry Potter)
2. **Given** user adds custom element, **When** user clicks "Generate Preview", **Then** system shows naming suggestions using the new element
3. **Given** user wants to remove an element, **When** user clicks delete icon, **Then** system removes element and recalculates suggestions
4. **Given** customization complete, **When** user clicks "Save as New Guide", **Then** system creates a derived guide linked to original theme with "(Modified)" label

---

### User Story 6 - Export and Share Thematic Guide (Priority: P3)

Teams need to export thematic guides to share with other projects or teams, including backup and version control compatibility.

**Why this priority**: Sharing enables organizational standardization but is less critical than core naming functionality. Can be implemented after core features are stable.

**Independent Test**: Can be fully tested by: 1) Exporting a guide to JSON, 2) Verifying valid format, 3) Re-importing to confirm data integrity.

**Acceptance Scenarios**:

1. **Given** user selects a thematic guide, **When** user clicks "Export", **Then** system downloads JSON file with theme name, elements, metadata
2. **Given** JSON file exported, **When** another user imports via "Import Guide", **Then** system successfully parses and creates guide in database
3. **Given** guide exported, **When** user opens file in text editor, **Then** file is human-readable JSON with clear structure and comments

---

### Edge Cases

- What happens when a theme has very few elements (< 5) available for a large schema with 1000+ tables/columns? System MUST cycle through elements with numeric suffixes (e.g., "tbl_harry_1", "tbl_harry_2") and show warning about theme capacity
- How does system handle naming collisions when multiple users are naming elements simultaneously with same theme? System MUST show already-used names in suggestions and allow selection anyway with uniqueness check
- What if a team creates a theme with offensive or inappropriate names? System MUST allow Admin to flag/report themes and implement content moderation review process
- What happens when user is not Administrator attempting to create a theme? System MUST enforce Admin role and show permission error

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow Administrators to create custom thematic naming guides with theme name, description, and list of themed element names (minimum 3 elements)
- **FR-002**: System MUST support theme creation by Admins and provide 10 pre-populated built-in themes: Harry Potter, Star Wars, Fruit, Animals, Planets, Musical Artists, Famous Artists, Mythology, Flowers, Colors
- **FR-003**: System MUST generate naming suggestions for schema elements based on selected thematic guide
- **FR-004**: System MUST support different naming patterns for different element types (table vs. column vs. index) from same theme
- **FR-004a**: System MUST support both built-in theme extension (create guides from built-in themes) and Admin-created custom themes
- **FR-005**: System MUST allow Admins to create entirely new themes with custom theme name, description, category, and element list
- **FR-005a**: System MUST allow users to customize pre-built themes by adding, removing, or replacing theme elements
- **FR-006**: System MUST persist thematic guides with unique IDs, version numbers, creation metadata, and audit trail
- **FR-007**: System MUST store element usage count and most-recently-used timestamp for each theme element
- **FR-008**: System MUST generate preview of naming suggestions before user commits to using a guide
- **FR-009**: System MUST display theme details including element count, description, and sample suggestions in theme browser
- **FR-010**: System MUST search and filter themes by name, keyword, or theme category
- **FR-011**: System MUST enforce Admin-only access to create/edit/delete thematic guides
- **FR-012**: System MUST export guides to JSON format with all metadata and elements preserved
- **FR-013**: System MUST import guides from JSON files with validation of structure and deduplication check
- **FR-014**: System MUST cycle through theme elements with sequential numbering when element pool is exhausted (e.g., "dumbledore_1", "dumbledore_2")
- **FR-015**: System MUST record audit trail of guide creation, modification, and usage (user, timestamp, action)

### Key Entities *(include if feature involves data)*

- **ThematicGuide**: Represents a named set of themed naming elements. Contains: name (required), description, theme category (built-in vs. custom), theme_elements array, created_at, created_by, version, is_active flag

- **ThemeElement**: Represents a single themed name available for use (e.g., "dumbledore", "hermione"). Contains: element_text (unique within guide), element_type (character/place/object), frequency_used (counter), last_used_at timestamp

- **ThemeLibraryItem**: Built-in theme template (Harry Potter, Star Wars, etc.). Contains: theme_id (UUID), name, category, description, icon_url, element_count, popularity_score, created_at

- **ThemeUsageRecord**: Tracks when theme elements are used for naming. Contains: theme_guide_id, element_id, entity_type (table/column), entity_id, selected_by (user), selected_at

- **AuditLog**: Records all theme guide operations. Contains: guide_id, action_type (created/modified/used/deleted), timestamp, user_id, change_summary

## Pre-populated Built-in Themes

The system launches with 10 comprehensive themed element libraries:

1. **Harry Potter** (50+ elements): Characters (Harry, Hermione, Dumbledore, Voldemort), spells (Expelliarmus, Expecto Patronum), potions (Polyjuice, Felix Felicis)
2. **Star Wars** (60+ elements): Planets (Tatooine, Coruscant, Endor), characters (Luke, Leia, Han, Yoda), ships (Millennium Falcon, X-Wing)
3. **Fruit** (30+ elements): Apple, Banana, Orange, Strawberry, Mango, Kiwi, Pineapple, Blueberry, Raspberry, Peach
4. **Animals** (50+ elements): Lion, Tiger, Elephant, Eagle, Dolphin, Penguin, Cheetah, Giraffe, Whale, Owl
5. **Planets** (40+ elements): Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto, Kepler442b
6. **Musical Artists** (75+ elements): Beatles, Mozart, Beethoven, Adele, Beyoncé, Drake, Taylor Swift, Radiohead, The Who, Led Zeppelin
7. **Famous Artists** (40+ elements): Picasso, Van Gogh, Da Vinci, Michelangelo, Monet, Warhol, Dali, Frida, Pollock, Rembrandt
8. **Mythology** (40+ elements): Zeus, Athena, Apollo, Aphrodite, Thor, Loki, Odin, Valkyrie, Phoenix, Minotaur
9. **Flowers** (35+ elements): Rose, Tulip, Daisy, Sunflower, Lavender, Lilac, Orchid, Peony, Iris, Carnation
10. **Colors** (40+ elements): Crimson, Sapphire, Emerald, Gold, Silver, Azure, Violet, Coral, Indigo, Chartreuse

Admins may create additional custom themes following the same structure.

## Dependencies

- **Abbreviation Management**: Consider leveraging existing abbreviation system for guide rules in Phase 2
- **Database Schema**: Extend current schema metadata to track guide application
- **RBAC System**: Only Admins can create/modify themes and guides
- **Audit System**: Track all theme and guide creation, modification, and application events

## Assumptions

1. Themed guides are meant to make naming fun and memorable, not enforce standards (different from Style Guides)
2. Theme elements are simple text strings allowing wide variety of theme types
3. Multiple themes can be active simultaneously; users choose which theme to use per naming session
4. Pre-populated themes are provided at launch; Admins can create org-specific themes afterward
5. Theme element cycling with numeric suffixes handles large schemas gracefully

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Administrators can create a custom thematic guide with 10+ elements in under 2 minutes
- **SC-002**: System loads theme gallery with 10+ built-in themes in under 1 second
- **SC-003**: Naming suggestions generate in under 500ms for any schema element
- **SC-004**: Pre-built theme selection creates a guide and generates first suggestions in under 3 seconds
- **SC-005**: Theme element cycling works correctly for 1000+ suggestions without performance degradation
- **SC-006**: Exported guides are valid JSON and re-import without data loss 100% of the time
- **SC-007**: Users successfully select themed names without requiring fallback to manual entry 85%+ of the time
- **SC-008**: All guide creation/modification operations include complete audit trail (user, timestamp, action)
- **SC-009**: Theme search/filter returns relevant results in topic relevance ranking in under 1 second
- **SC-010**: 100% of guide and theme management operations are restricted to Admin role with clear permission messages
- **SC-011**: System launches with 10 pre-populated themes containing 400+ total themed elements ready for use
- **SC-012**: Search across all 10 themes and user-created themes returns results in under 1 second
