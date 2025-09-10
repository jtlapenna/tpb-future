# System Architecture Overview

## Introduction

This document provides a high-level overview of the Style Migration System architecture, its components, and their interactions. The system is designed to facilitate the migration of styles from Angular to React while maintaining consistency and quality.

## System Components

### Pattern Detection System
![System Overview](diagrams/system-overview.mmd)

The pattern detection system identifies Angular style patterns in the source code. It consists of three main components:
- **Theme Variables**: Extracts and analyzes theme-related variables and tokens
- **Global Styles**: Identifies globally applied styles and their usage patterns
- **Component Styles**: Detects component-specific styling patterns and their relationships

### Data Flow Pipeline
![Data Flow](diagrams/data-flow.mmd)

The data flow pipeline processes style information from Angular to React through several stages:
1. **Style Extraction**: Parses Angular source files to extract style information
2. **Pattern Analysis**: Analyzes extracted styles for patterns and relationships
3. **Transformation**: Converts styles to React/styled-components format
4. **Validation**: Ensures the transformed styles meet quality criteria

### Validation System
![Validation Pipeline](diagrams/validation-flow.mmd)

The validation system ensures style migration accuracy through multiple testing layers:
- **Visual Tests**: Verify component appearance and layout consistency
- **Performance Tests**: Check bundle size, render time, and memory usage
- **Accessibility Tests**: Validate color contrast, screen reader compatibility, and keyboard navigation

### Migration Process
![Migration Process](diagrams/migration-flow.mmd)

The migration process handles the transformation of styles in a systematic way:
1. Theme Migration: Convert theme variables and global styles
2. Component Migration: Transform component-specific styles
3. Layout Migration: Migrate layout patterns and responsive designs
4. Utility Migration: Convert utility classes and mixins

## Decision Trees

### Pattern Detection
![Pattern Detection Decision Tree](diagrams/pattern-detection-decision.mmd)

The pattern detection decision tree guides the identification of style patterns by:
- Determining if styles are global or component-scoped
- Identifying theme variables and their usage
- Classifying utility classes and mixins
- Detecting dynamic styling patterns

### Style Transformation
![Style Transformation Decision Tree](diagrams/style-transformation-decision.mmd)

The style transformation decision tree guides the conversion process through:
- Pattern-specific transformation rules
- Theme variable mapping
- Component style conversion
- Layout pattern migration

## Related Documentation

- [Detection Rules](../patterns/detection/rules.md) - Detailed rules for pattern detection
- [Pattern Relationships](../patterns/relationships/dependencies.md) - How different style patterns interact
- [Style Integrity Rules](../validation/rules/style-integrity.md) - Rules for maintaining style consistency
- [Migration Guide](../guides/migration-guide.md) - Step-by-step migration instructions

## Implementation Notes

1. **Color Coding**:
   - Green: Primary system components
   - Purple: Processing/transformation steps
   - Orange: Output/validation results
   - Gray: Input/source components

2. **Flow Direction**:
   - Top to bottom: Process flow
   - Left to right: Data transformation
   - Dotted lines: Error recovery paths

3. **Component Relationships**:
   - Solid lines: Direct relationships
   - Subgraphs: Related component groups
   - Bidirectional arrows: Interactive processes 