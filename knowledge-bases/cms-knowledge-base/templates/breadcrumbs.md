# Breadcrumb Navigation

<!-- This template provides breadcrumb navigation for documentation pages -->
<!-- Usage: Copy and modify for each documentation page -->

<!-- Breadcrumb Navigation Template -->

<!-- Usage: Include this at the top of each documentation page -->
<!-- Format: [Parent Category](../parent/index.md) > [Current Category](./index.md) > Current Page -->

<!-- Examples for different page types -->

<!-- Architecture pages -->
[Home](../README.md) > [Architecture](../architecture/overview.md) > [System Design](../architecture/system-design.md)

<!-- Guide pages -->
[Home](../README.md) > [Guides](../guides/quickstart.md) > [Migration Guide](../guides/migration-guide.md)

<!-- Pattern pages -->
[Home](../README.md) > [Patterns](../patterns/detection/rules.md) > [Detection](../patterns/detection/rules.md) > Rules

<!-- Validation pages -->
[Home](../README.md) > [Validation](../validation/rules/style-integrity.md) > [Rules](../validation/rules/style-integrity.md) > Style Integrity

<!-- Implementation Notes:
1. Each documentation page should include the appropriate breadcrumb path at the top
2. Use relative paths (../) for links to ensure proper navigation
3. Current page should be plain text (not a link)
4. Parent categories should link to their index pages
-->

```markdown
[Home](/) > [Category] > [Current Page]
```

## Examples

### Architecture Pages
```markdown
[Home](/) > [Architecture](../architecture) > [Overview](overview.md)
[Home](/) > [Architecture](../architecture) > [System Design](system-design.md)
```

### Guide Pages
```markdown
[Home](/) > [Guides](../guides) > [Migration Guide](migration-guide.md)
[Home](/) > [Guides](../guides) > [Quickstart](quickstart.md)
```

### Pattern Pages
```markdown
[Home](/) > [Patterns](../patterns) > [Detection](detection) > [Rules](rules.md)
[Home](/) > [Patterns](../patterns) > [Analysis](analysis) > [Static Rules](static-rules.md)
```

### Validation Pages
```markdown
[Home](/) > [Validation](../validation) > [Rules](rules) > [Style Integrity](style-integrity.md)
[Home](/) > [Validation](../validation) > [Metrics](metrics) > [Core Metrics](core-metrics.md)
```

## Implementation Notes

1. Each page should include the appropriate breadcrumb path at the top
2. Links should use relative paths from the current document
3. The current page should be plain text (not a link)
4. Parent categories should link to their index pages 