# Code Analysis Rules

#[section:code-analysis]
#[type:ai-rules]
#[complexity:high]
#[confidence:0.95]

## Overview
This document defines the rules and patterns for analyzing style-related code during the migration process. These rules help AI agents identify, analyze, and transform style patterns effectively.

## Static Analysis Rules

This document outlines the rules for static analysis of style patterns.

## Rule Categories

### Syntax Rules
- Valid CSS syntax
- Property validation
- Value validation

### Pattern Rules
- Component patterns
- Layout patterns
- Theme patterns

### Dependency Rules
- Import validation
- Theme dependencies
- Component dependencies

## Rule Implementation

### Syntax Validation
1. Parse CSS/SCSS
2. Check properties
3. Validate values

### Pattern Detection
1. Match patterns
2. Extract components
3. Analyze relationships

### Dependency Analysis
1. Track imports
2. Map dependencies
3. Validate references

```yaml
static_analysis:
  scss_patterns:
    - rule: "variable_detection"
      pattern: "\\$[a-zA-Z][a-zA-Z0-9_-]*"
      priority: "high"
      
    - rule: "mixin_detection"
      pattern: "@include [a-zA-Z][a-zA-Z0-9_-]*"
      priority: "high"
      
    - rule: "nested_selectors"
      pattern: "&[:\\.]?[a-zA-Z-]+"
      priority: "medium"

  angular_patterns:
    - rule: "component_styles"
      pattern: "styleUrls:|styles:"
      priority: "high"
      
    - rule: "view_encapsulation"
      pattern: "ViewEncapsulation\\."
      priority: "high"
      
    - rule: "host_binding"
      pattern: "@HostBinding\\('class'\\)"
      priority: "medium"
```

## Dependency Analysis

```yaml
dependency_analysis:
  style_dependencies:
    - type: "theme"
      files:
        - "src/styles/theme/**/*.scss"
        - "src/styles/variables/**/*.scss"
      priority: "high"
      
    - type: "components"
      files:
        - "src/app/components/**/*.scss"
        - "src/app/components/**/*.css"
      priority: "medium"
      
    - type: "utilities"
      files:
        - "src/styles/utilities/**/*.scss"
      priority: "low"

  import_analysis:
    - pattern: "@import '[^']*'"
      action: "map_dependencies"
      priority: "high"
      
    - pattern: "@use '[^']*'"
      action: "map_dependencies"
      priority: "high"
```

## Transformation Rules

```typescript
interface TransformationRule {
  selector: string;
  pattern: RegExp;
  transform: (match: string) => string;
  priority: 'high' | 'medium' | 'low';
}

const transformationRules: TransformationRule[] = [
  {
    selector: 'scss-variable',
    pattern: /\$([a-zA-Z][a-zA-Z0-9_-]*)/g,
    transform: (match) => `props.theme.${match.slice(1)}`,
    priority: 'high'
  },
  {
    selector: 'mixin',
    pattern: /@include ([a-zA-Z][a-zA-Z0-9_-]*)/g,
    transform: (match) => `${match.slice(9)}Styles`,
    priority: 'high'
  }
];
```

## Code Quality Metrics

```yaml
quality_metrics:
  complexity:
    - measure: "selector_depth"
      max_depth: 3
      severity: "warning"
      
    - measure: "specificity"
      max_value: 20
      severity: "warning"
      
  maintainability:
    - measure: "duplicate_styles"
      threshold: 0.1
      severity: "error"
      
    - measure: "theme_consistency"
      threshold: 0.95
      severity: "error"
```

## Performance Analysis

```yaml
performance_rules:
  bundle_size:
    - rule: "css_bundle_size"
      threshold: "50kb"
      severity: "warning"
      
    - rule: "unused_styles"
      threshold: 0.1
      severity: "error"
      
  runtime:
    - rule: "style_calculation"
      threshold: "16ms"
      severity: "warning"
      
    - rule: "reflow_triggers"
      threshold: 0
      severity: "error"
```

## Migration Validation

```yaml
validation_rules:
  style_integrity:
    - check: "visual_regression"
      threshold: 0.98
      tool: "percy"
      
    - check: "theme_variables"
      match_rate: 1.0
      severity: "error"
      
  accessibility:
    - check: "contrast_ratio"
      minimum: 4.5
      severity: "error"
      
    - check: "font_sizes"
      scale: "modular"
      severity: "warning"
```

## AI Agent Instructions

1. **Analysis Process**
   ```yaml
   process:
     - step: "Scan for style patterns"
       tools: ["static_analysis", "dependency_analysis"]
       output: "pattern_map"
       
     - step: "Evaluate dependencies"
       tools: ["dependency_analysis"]
       output: "dependency_graph"
       
     - step: "Transform patterns"
       tools: ["transformation_rules"]
       output: "transformed_code"
       
     - step: "Validate changes"
       tools: ["validation_rules"]
       output: "validation_report"
   ```

2. **Error Handling**
   ```yaml
   error_handling:
     pattern_mismatch:
       action: "log_and_skip"
       severity: "warning"
       
     dependency_conflict:
       action: "resolve_manually"
       severity: "error"
       
     validation_failure:
       action: "rollback_and_retry"
       severity: "error"
   ```

3. **Reporting**
   ```yaml
   reporting:
     metrics:
       - "pattern_coverage"
       - "transformation_success_rate"
       - "validation_results"
       
     format:
       - type: "json"
         path: "reports/analysis/"
       - type: "html"
         path: "reports/dashboard/"
   ``` 