# Pattern Detection Rules

This document outlines the rules and patterns used to identify Angular styles for migration.

## Style Pattern Categories

1. Theme Variables
2. Global Styles
3. Component-Specific Styles
4. Layout Patterns
5. Utility Classes

## Detection Rules

### Theme Variables
- Identify global theme variables
- Map color schemes
- Extract typography settings

### Global Styles
- Detect global style declarations
- Identify reset styles
- Map shared utilities

### Component Styles
- Analyze component-level styles
- Map ViewEncapsulation settings
- Extract dynamic styles

### Layout Patterns
- Identify flexbox usage
- Map grid systems
- Extract positioning patterns

### Utility Classes
- Map common utility classes
- Extract shared mixins
- Identify helper functions

## Pattern Definitions

### 1. Component Styles
```yaml
pattern_detection:
  type: "component_styles"
  identifiers:
    - ":host"
    - "::ng-deep"
    - ".component-class"
  confidence_threshold: 0.9
  migration_priority: "high"
  examples:
    - pattern: ":host { ... }"
      transform_to: "styled.div`...`"
    - pattern: "::ng-deep .child"
      transform_to: "css`...`"
  validation:
    - check: "no-host-selector"
    - check: "styled-components-syntax"
```

### 2. Form Controls
```yaml
pattern_detection:
  type: "form_control"
  identifiers:
    - "form-control"
    - "ng-invalid"
    - "ng-touched"
    - "ng-dirty"
  confidence_threshold: 0.8
  migration_priority: "high"
  examples:
    - pattern: ".form-control.ng-invalid"
      transform_to: "${props => props.invalid && css`...`}"
  validation:
    - check: "react-form-state"
    - check: "styled-components-props"
```

### 3. Layout Patterns
```yaml
pattern_detection:
  type: "layout"
  identifiers:
    - "d-flex"
    - "container"
    - "row"
    - "col-"
  confidence_threshold: 0.85
  migration_priority: "medium"
  examples:
    - pattern: ".d-flex"
      transform_to: "styled.div`display: flex;`"
    - pattern: ".container"
      transform_to: "Container"
  validation:
    - check: "flex-properties"
    - check: "grid-system"
```

### 4. Theme Variables
```yaml
pattern_detection:
  type: "theme_variables"
  identifiers:
    - "$"
    - "@include"
    - "@mixin"
  confidence_threshold: 0.95
  migration_priority: "high"
  examples:
    - pattern: "$primary"
      transform_to: "${props => props.theme.colors.primary}"
    - pattern: "@include theme-colors"
      transform_to: "ThemeProvider"
  validation:
    - check: "theme-context"
    - check: "color-variables"
```

### 5. Utility Classes
```yaml
pattern_detection:
  type: "utilities"
  identifiers:
    - "mt-"
    - "mb-"
    - "p-"
    - "text-"
  confidence_threshold: 0.75
  migration_priority: "medium"
  examples:
    - pattern: ".mt-3"
      transform_to: "styled.div`margin-top: 1rem;`"
    - pattern: ".text-primary"
      transform_to: "styled.span`color: ${props => props.theme.colors.primary};`"
  validation:
    - check: "spacing-utilities"
    - check: "text-utilities"
```

## Detection Algorithm

```typescript
interface PatternMatch {
  type: string;
  confidence: number;
  pattern: string;
  transformation: string;
  validation: string[];
}

function detectPattern(code: string): PatternMatch[] {
  // Algorithm outline for AI agents
  1. Analyze code structure
  2. Match against pattern identifiers
  3. Calculate confidence score
  4. Determine transformation approach
  5. Return matches with validation rules
}
```

## Validation Rules

```yaml
validation_rules:
  global:
    - rule: "theme_context_exists"
      severity: "error"
    - rule: "styled_components_syntax"
      severity: "error"
    
  component_specific:
    - rule: "props_typing"
      severity: "warning"
    - rule: "css_in_js_patterns"
      severity: "warning"
```

## Usage Metrics

```yaml
pattern_usage:
  component_styles:
    detected: 234
    success_rate: 0.95
    common_issues:
      - "theme context missing"
      - "prop types undefined"
  
  form_controls:
    detected: 156
    success_rate: 0.92
    common_issues:
      - "validation state mapping"
      - "form context missing"
``` 