---
document_type: technical_documentation
category: style_migration
version: 1.0
last_updated: 2024-03-13
status: active
priority: high
dependencies:
  frameworks:
    - angular: 8.x
    - react: 18.x
  styling:
    - bootstrap: 4.x
    - styled-components: 5.x
    - scss: latest
file_relationships:
  - path: src/app/scss/_variables.scss
    type: source
    usage_count: 156
  - path: src/app/scss/application.scss
    type: entry_point
    usage_count: 1
code_coverage:
  style_files: 47
  components_with_styles: 89
  utility_classes: 234
  theme_variables: 156
migration_complexity: high
ai_tools:
  - pattern_recognition
  - code_transformation
  - dependency_analysis
---

# Migration Guide

This guide provides step-by-step instructions for migrating styles from Angular to React.

## Prerequisites

- Node.js and npm installed
- Access to both Angular and React codebases
- Development environment setup
- Required dependencies installed

## Migration Steps

1. Theme Migration
   - Extract theme variables
   - Convert to styled-components theme
   - Update global styles

2. Component Migration
   - Identify component styles
   - Convert to styled-components
   - Update component references

3. Layout Migration
   - Convert flexbox layouts
   - Update grid systems
   - Migrate positioning rules

4. Testing and Validation
   - Visual regression testing
   - Performance testing
   - Accessibility validation

## Related Documentation

- [Component Library Reference](../reference/component_library.md)
- [Development Guide](development_guide.md)
- [Accessibility Guide](accessibility_guide.md)

# Style Migration Guide

#[section:overview]
#[type:introduction]
#[complexity:medium]
## Overview
This guide documents the current styling architecture and provides a comprehensive plan for migrating styles from the Angular application to the new React-based system. The current application uses a combination of SCSS, Bootstrap, and custom styling patterns that need to be carefully migrated to maintain consistency and functionality.

#[section:current-architecture]
#[type:system-documentation]
#[complexity:high]
#[migration-priority:1]
## Current Architecture

#[pattern:style-structure]
#[usage:global]
#[files:47]
### 1. Core Style Structure
```scss
// Main style entry point (application.scss)
@import "variables";
@import "mixins";
@import "bootstrap/scss/bootstrap";
@import "font-awesome/scss/font-awesome";
@import "bootstrap-override";
@import "libs-override";
@import "general";
@import "global-transitions";
@import "utils";
```

#[pattern:theme-system]
#[type:design-tokens]
#[complexity:medium]
### 2. Theme System

#[pattern:color-system]
#[usage:127]
#[files:45]
#[components:["Button", "Alert", "Card", "Badge"]]
#### Color Palette
```scss
// Primary Colors
$primary: #00C796;
$secondary: $gray-lighter;
$success: #419641;
$info: #5dc4bf;
$warning: #EE991B;
$danger: #dd5826;

// Text Colors
$text-color: $gray;
$headings-font-color: #351B64;
$link-color: #7168DF;
```

#[pattern:typography-scale]
#[usage:89]
#[files:38]
#[components:["Text", "Heading", "Label"]]
#### Typography
```scss
// Font Families
$font-face: 'Roboto';
$font-family: $font-face, sans-serif;
$font-family-secondary: 'ProximaNova';
$font-family-secondary-semibold: 'ProximaNovaSemiBold';

// Font Sizes
$font-size-root: 14px;
$font-size-base: 1rem;
$font-size-larger: 15px;
$font-size-mini: 13px;
```

#[pattern:component-patterns]
#[type:component-documentation]
#[complexity:high]
### 3. Component Patterns

#[pattern:layout-components]
#[usage:67]
#[files:29]
#### Layout Components
- Navbar: Fixed top navigation
  - Usage: 1 global instance
  - Dependencies: Bootstrap navbar
- Sidebar: Collapsible side menu
  - Usage: 1 global instance
  - Dependencies: Custom implementation
- Content area: Responsive padding system
  - Usage: Multiple components
  - Dependencies: Grid system

#[pattern:form-components]
#[usage:156]
#[files:42]
#### Form Components
- Custom input styles
  - Usage: 89 instances
  - Validation integration
- Validation states
  - Success, Error, Warning states
  - ARIA attributes
- Select components
  - Custom styling
  - Accessibility support
- Form groups
  - Layout patterns
  - Spacing system

#[pattern:common-patterns]
#[usage:234]
#[files:47]
#### Common Patterns
```scss
// Global Transitions
a {
  @include transition(
    background-color .15s ease-in-out,
    border-color .15s ease-in-out,
    color .15s ease-in-out
  );
}

// Utility Classes
.no-margin { margin: 0; }
.no-padding { padding: 0; }
.display-block { display: block; }
```

#[section:migration-strategy]
#[type:implementation-guide]
#[complexity:high]
## Migration Strategy

#[pattern:css-in-js]
#[type:setup-guide]
#[complexity:medium]
### 1. CSS-in-JS Setup

/**
 * @component-context
 * @name: ThemeProvider
 * @usage-frequency: high
 * @modified: 2024-03-13
 * @dependencies: ["styled-components"]
 * @migration-priority: high
 */
#### Styled Components Setup
```typescript
// theme.ts
export const theme = {
  colors: {
    primary: '#00C796',
    secondary: '#eee',
    success: '#419641',
    info: '#5dc4bf',
    warning: '#EE991B',
    danger: '#dd5826',
    text: '#555',
    headings: '#351B64',
    link: '#7168DF'
  },
  typography: {
    fontFamily: {
      primary: 'Roboto, sans-serif',
      secondary: 'ProximaNova, sans-serif',
      semibold: 'ProximaNovaSemiBold, sans-serif'
    },
    fontSize: {
      root: '14px',
      base: '1rem',
      larger: '15px',
      mini: '13px'
    }
  }
};
```

#[section:migration-steps]
#[type:process-guide]
#[complexity:high]
### 2. Component Migration Steps

#[decision-tree:migration-approach]
1. **Global Styles**
   - Create global style component
     - If Bootstrap dependent → Use React-Bootstrap
     - If Custom styles → Use styled-components
   - Migrate reset and base styles
     - High priority → Custom implementation
     - Low priority → Use existing library
   - Set up theme provider
     - Complex theme → Custom provider
     - Simple theme → Default provider

2. **Utility Classes**
   - Convert SCSS utility classes to styled-components
   - Create reusable styled components for common patterns
   - Migration priority based on usage frequency

3. **Component-Specific Styles**
   - Migrate component styles to styled-components
   - Maintain component-specific theme variables
   - Follow dependency order

#[pattern:bootstrap-migration]
#[type:implementation-guide]
#[complexity:high]
### 3. Bootstrap Migration

#[migration-example:react-bootstrap]
#### Approach 1: React-Bootstrap
```typescript
/**
 * @migration-map
 * Angular Pattern -> React Pattern
 * @source: src/app/shared/button/button.component.ts
 * @target: src/components/Button/Button.tsx
 */
import { Button, Form } from 'react-bootstrap';
import styled from 'styled-components';

const StyledButton = styled(Button)`
  background-color: ${props => props.theme.colors.primary};
  &:hover {
    background-color: ${props => props.theme.colors.primaryDark};
  }
`;
```

#[migration-example:custom-components]
#### Approach 2: Custom Components
```typescript
/**
 * @component-context
 * @name: Button
 * @usage-frequency: high
 * @dependencies: ["Theme", "Typography"]
 */
const Button = styled.button`
  padding: 0.375rem 0.75rem;
  border-radius: 0.25rem;
  font-family: ${props => props.theme.typography.fontFamily.primary};
  background-color: ${props => props.theme.colors.primary};
  color: white;
  
  &:hover {
    opacity: 0.9;
  }
`;
```

#[pattern:responsive-design]
#[type:implementation-guide]
#[complexity:medium]
### 4. Responsive Design

```typescript
/**
 * @pattern:breakpoints
 * @usage:global
 * @migration-priority:high
 */
export const breakpoints = {
  xs: '0',
  sm: '576px',
  md: '768px',
  lg: '992px',
  xl: '1200px'
};

export const media = {
  up: (breakpoint: keyof typeof breakpoints) => `
    @media (min-width: ${breakpoints[breakpoint]})
  `,
  down: (breakpoint: keyof typeof breakpoints) => `
    @media (max-width: ${breakpoints[breakpoint]})
  `
};
```

#[section:best-practices]
#[type:guidelines]
#[complexity:medium]
## Best Practices

#[pattern:theme-consistency]
### 1. Theme Consistency
- Use theme variables for all styles
- Maintain a single source of truth for design tokens
- Document any deviations from the theme system

#[pattern:component-organization]
### 2. Component Organization
- Keep styled components close to their React components
- Use composition for complex styling needs
- Maintain clear naming conventions

#[pattern:performance]
### 3. Performance Considerations
- Use dynamic styles sparingly
- Implement code splitting for large style bundles
- Optimize critical CSS rendering

#[section:migration-checklist]
#[type:task-list]
#[complexity:medium]
## Migration Checklist

1. [ ] Set up CSS-in-JS tooling
2. [ ] Create theme configuration
3. [ ] Migrate global styles
4. [ ] Convert utility classes
5. [ ] Migrate component styles
6. [ ] Update responsive layouts
7. [ ] Test cross-browser compatibility
8. [ ] Optimize performance
9. [ ] Document new styling patterns

#[section:related-documentation]
#[type:cross-references]
## Related Documentation
- [Component Library](../reference/component_library.md)
  - Usage: 234 imports
  - Shared Styles: 45
- [Development Guide](development_guide.md)
  - Referenced Patterns: 67
  - Migration Examples: 23
- [Accessibility Guide](accessibility_guide.md)
  - ARIA Patterns: 34
  - Color Contrast Rules: 12 