# Template Archive

This directory contains templates that were part of the original analysis but have been archived for the following reasons:
- Redundancy with other templates
- Not directly relevant to cross-repository analysis
- Better covered by more comprehensive templates
- Too specific for our current needs

## Archived Templates

### Platform-Specific
1. `mobile_analysis.txt`
   - Reason: Not relevant to current system architecture
   - Coverage: Mobile-specific concerns can be addressed in general architecture analysis

2. `cross_platform_analysis.txt`
   - Reason: Too specific for current needs
   - Coverage: Platform considerations covered in architecture template

### Specialized Analysis
3. `internationalization_analysis.txt`
   - Reason: Not a primary concern for current analysis
   - Coverage: Can be addressed as part of general architecture if needed

4. `accessibility_analysis.txt`
   - Reason: Not a primary focus for backend/integration analysis
   - Coverage: Can be addressed in frontend analysis if needed

### Redundant Templates
5. `code_review.txt`
   - Reason: Covered by architecture and pattern analysis
   - Coverage: Code quality aspects integrated into core templates

6. `pattern_analysis.txt`
   - Reason: Integrated into architecture and integration templates
   - Coverage: Patterns now analyzed as part of core analysis

7. `cloud_analysis.txt`
   - Reason: Infrastructure concerns covered in architecture template
   - Coverage: Cloud-specific aspects integrated into deployment sections

### Development Process
8. `devops_analysis.txt`
   - Reason: CI/CD aspects covered in integration template
   - Coverage: Deployment concerns in architecture template

9. `microservices_analysis.txt`
   - Reason: Service architecture covered in architecture template
   - Coverage: Microservices patterns in integration analysis

10. `compliance_analysis.txt`
    - Reason: Compliance aspects integrated into security template
    - Coverage: Industry-specific compliance in context integration

## Template Consolidation Map

Shows where the functionality from archived templates has been integrated:

```
mobile_analysis.txt        → architecture.md (Platform section)
cross_platform_analysis.txt → architecture.md (Compatibility section)
internationalization_analysis.txt → architecture.md (if needed)
accessibility_analysis.txt → architecture.md (if needed)
code_review.txt           → architecture.md + integration.md
pattern_analysis.txt      → architecture.md (Patterns section)
cloud_analysis.txt        → architecture.md (Infrastructure section)
devops_analysis.txt       → integration.md (Deployment section)
microservices_analysis.txt → integration.md + architecture.md
compliance_analysis.txt   → security.md (Compliance section)
```

## Notes
- Templates can be unarchived if future analysis needs change
- Core functionality from archived templates has been preserved in consolidated templates
- Industry-specific aspects are now handled through context integration rather than separate templates

## Version History
- 1.0 (2024-03-21): Initial archive creation and template consolidation 