# Quickstart Guide

Get started with the Style Migration System quickly with this guide.

## Installation

```bash
npm install @style-migration/core
npm install @style-migration/cli
```

## Basic Usage

1. Initialize the migration:
   ```bash
   style-migrate init
   ```

2. Configure your project:
   ```bash
   style-migrate config
   ```

3. Run the migration:
   ```bash
   style-migrate run
   ```

## Validation

Run the validation suite:
```bash
style-migrate validate
```

## Common Commands

- `style-migrate status` - Check migration status
- `style-migrate analyze` - Analyze style patterns
- `style-migrate test` - Run test suite
- `style-migrate report` - Generate reports

# Style Migration Quick Start Guide

#[section:quickstart]
#[type:developer-guide]
#[complexity:medium]
#[confidence:0.95]

## Getting Started

### Prerequisites
```yaml
required:
  - Node.js >= 14
  - npm >= 6
  - Git
tools:
  - styled-components
  - percy (for visual testing)
  - eslint-styled-components
  - typescript >= 4.0
```

### Installation

```bash
# Install required dependencies
npm install styled-components @types/styled-components
npm install --save-dev percy @percy/cli eslint-styled-components

# Install migration tools
npm install --save-dev @style-migration/tools
```

## Quick Start Steps

### 1. Initial Setup

```typescript
// setup.ts
import { initializeMigration } from '@style-migration/tools';

const config = {
  sourceDir: './src',
  angularPattern: '**/*.component.scss',
  themeFiles: './src/styles/theme/**/*.scss',
  outputDir: './src/migrated'
};

initializeMigration(config);
```

### 2. Theme Migration

```typescript
// Identify theme variables
const theme = {
  colors: {
    primary: '$primary-color',    // Will be transformed
    secondary: '$secondary-color' // Will be transformed
  },
  spacing: {
    unit: '$spacing-unit'        // Will be transformed
  }
};

// Create theme provider
import { ThemeProvider } from 'styled-components';

const AppThemeProvider: React.FC = ({ children }) => (
  <ThemeProvider theme={theme}>
    {children}
  </ThemeProvider>
);
```

### 3. Component Migration Example

Before (Angular):
```scss
// button.component.scss
:host {
  .button {
    background-color: $primary-color;
    padding: $spacing-unit;
    
    &:hover {
      background-color: darken($primary-color, 10%);
    }
    
    &.disabled {
      opacity: 0.5;
    }
  }
}
```

After (React):
```typescript
// Button.styles.ts
import styled from 'styled-components';

export const StyledButton = styled.button`
  background-color: ${props => props.theme.colors.primary};
  padding: ${props => props.theme.spacing.unit};
  
  &:hover {
    background-color: ${props => darken(0.1, props.theme.colors.primary)};
  }
  
  ${props => props.disabled && css`
    opacity: 0.5;
  `}
`;
```

### 4. Running Validation

```bash
# Run visual regression tests
npm run migration:validate-visual

# Check bundle size impact
npm run migration:analyze-bundle

# Validate accessibility
npm run migration:check-a11y
```

## Common Patterns & Solutions

### 1. ViewEncapsulation Migration
```typescript
// Before (Angular)
@Component({
  encapsulation: ViewEncapsulation.None
})

// After (React)
const GlobalStyle = createGlobalStyle`
  /* Your global styles here */
`;
```

### 2. NgClass to styled-components
```typescript
// Before (Angular)
<div [ngClass]="{'active': isActive}">

// After (React)
const StyledDiv = styled.div<{ isActive: boolean }>`
  ${props => props.isActive && css`
    /* active styles */
  `}
`;
```

### 3. Media Queries
```typescript
// Before (Angular)
@media (max-width: 768px) {
  .mobile-only { display: block; }
}

// After (React)
const ResponsiveComponent = styled.div`
  ${props => props.theme.media.mobile`
    display: block;
  `}
`;
```

## Troubleshooting Guide

### Common Issues

1. **Theme Variable Not Found**
```yaml
error: "$primary-color not found in theme"
solution:
  - Check theme.ts for variable mapping
  - Verify variable exists in original SCSS
  - Add to theme if missing
```

2. **Style Bleeding**
```yaml
issue: "Styles affecting other components"
solution:
  - Use styled-components composition
  - Avoid global styles
  - Check component isolation
```

3. **Performance Issues**
```yaml
problem: "Bundle size increased"
solutions:
  - Use dynamic imports
  - Split theme into modules
  - Optimize styled-components usage
```

## Validation Checklist

```yaml
pre_commit:
  - [ ] Styles properly scoped
  - [ ] Theme variables used
  - [ ] No CSS-in-JS anti-patterns
  - [ ] Props properly typed

visual_testing:
  - [ ] Component matches original
  - [ ] Responsive behavior preserved
  - [ ] Hover/focus states working
  - [ ] Animations smooth

accessibility:
  - [ ] Color contrast maintained
  - [ ] Focus indicators visible
  - [ ] Semantic HTML preserved
```

## Quick Commands

```bash
# Start new component migration
npm run migrate:component src/app/components/example

# Validate current migration
npm run migrate:validate

# Generate migration report
npm run migrate:report

# Revert problematic migration
npm run migrate:revert last
```

## Best Practices Summary

1. **Always**
   - Use theme variables
   - Type your styled components
   - Test responsive behavior
   - Validate accessibility

2. **Never**
   - Use direct color values
   - Skip visual validation
   - Mix global and component styles
   - Ignore TypeScript errors

3. **Consider**
   - Component composition
   - Performance impact
   - Browser compatibility
   - Maintainability

## Getting Help

```yaml
resources:
  documentation:
    - style_migration_summary.md
    - patterns/detection_rules.md
    - validation/rules.md
    
  support:
    slack: "#style-migration-help"
    docs:../../../migration"
    wiki: "/wiki/style-guide"
```

## Next Steps

1. **Start Small**
   - Begin with simple components
   - Validate each step
   - Document patterns found

2. **Scale Up**
   - Migrate shared components
   - Update theme system
   - Automate testing

3. **Optimize**
   - Review performance
   - Refine patterns
   - Share learnings 