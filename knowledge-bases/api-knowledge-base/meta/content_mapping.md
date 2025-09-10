# Content Mapping Document

## Overview
This document tracks the content audit findings and maps current content to the new directory structure.

## Output Directory Content

| File | Content Type | New Location | Status | Notes |
|------|--------------|--------------|--------|-------|
| 1_system_overview_and_architecture.md | Architecture | docs/architecture/overview/ | To Migrate | Current, comprehensive overview |
| 2_key_models_and_relationships.md | Architecture | docs/architecture/components/ | To Migrate | Current model documentation |
| 3_pos_integration_points.md | Integration | docs/api/integration/ | To Migrate | Current integration documentation |
| 4_api_endpoints.md | API | docs/api/public/ | To Migrate | Current API documentation |
| 5_database_schema.md | Database | docs/implementation/database/ | To Migrate | Current schema documentation |
| 6_entity_relationship_diagram.md | Database | docs/implementation/database/ | To Migrate | Current ERD |
| 7_data_validation_and_business_rules.md | Implementation | docs/implementation/services/ | To Migrate | Current validation rules |
| 8_database_performance.md | Database | docs/implementation/database/ | To Migrate | Current performance docs |
| 9_api_architecture_and_design.md | Architecture | docs/architecture/overview/ | To Migrate | Current API architecture |
| 10_integration_patterns_and_strategies.md | Integration | docs/api/integration/ | To Migrate | Current integration patterns |
| index.md | Navigation | docs/ | To Migrate | Update for new structure |

## Web Interface Directory Content

| File | Content Type | New Location | Status | Notes |
|------|--------------|--------------|--------|-------|
| *.html files | Implementation | archive/web-interface/ | To Archive | Old web viewer |
| *.sh scripts | Implementation | archive/web-interface/ | To Archive | Old setup scripts |
| js/, css/, images/ | Implementation | archive/web-interface/ | To Archive | Old assets |
| README.md | Documentation | archive/web-interface/ | To Archive | Old viewer docs |

## API Prepared Reference Files

| File | Content Type | New Location | Status | Notes |
|------|--------------|--------------|--------|-------|
| api_analysis_summary.md | Analysis | docs/meta/analysis/ | To Migrate | Current analysis |
| integration_patterns.md | Integration | docs/api/integration/ | Review | Compare with output version |
| api_reference_index.md | API | docs/api/ | To Migrate | Update for new structure |
| error_handling.md | Implementation | docs/implementation/services/ | To Migrate | Current error handling |
| authentication_authorization.md | Security | docs/api/security/ | To Migrate | Current auth docs |
| request_response_formats.md | API | docs/api/ | To Migrate | Current formats |
| *_template.md files | Templates | docs/meta/templates/ | To Migrate | Current templates |

## Analysis Files

| File | Content Type | New Location | Status | Notes |
|------|--------------|--------------|--------|-------|
| audit_summary.md | Analysis | docs/meta/analysis/ | To Migrate | Current audit |
| gap_analysis_report.md | Analysis | docs/meta/analysis/ | To Migrate | Current analysis |
| project_audit.md | Analysis | docs/meta/analysis/ | To Migrate | Current audit |
| progress_tracking.md | Progress | docs/meta/progress/ | To Archive | Superseded |
| steps.md | Progress | docs/meta/progress/ | To Archive | Superseded |
| task_list.md | Progress | docs/meta/progress/ | To Archive | Superseded |

## Documentation Roadmap

| File | Content Type | New Location | Status | Notes |
|------|--------------|--------------|--------|-------|
| documentation_roadmap.md | Planning | docs/meta/roadmap/ | To Migrate | Current roadmap |

## Docs Directory Content

| Directory/File | Content Type | New Location | Status | Notes |
|----------------|--------------|--------------|--------|-------|
| architecture/overview.md | Architecture | docs/architecture/overview/ | To Review | Compare with output files |
| architecture/components.md | Architecture | docs/architecture/components/ | To Review | Compare with output files |
| architecture/integrations.md | Integration | docs/api/integration/ | To Review | Compare with output files |
| implementation/authentication/ | Security | docs/api/security/ | To Review | Compare with knowledge-base |
| implementation/api/ | API | docs/api/ | To Review | Compare with output files |
| implementation/database/ | Database | docs/implementation/database/ | To Review | Compare with output files |
| implementation/testing/ | Testing | docs/implementation/testing/ | To Migrate | Current testing docs |
| operations/configuration/ | Operations | docs/guides/setup/ | To Migrate | Current config guides |
| operations/deployment/ | Operations | docs/guides/deployment/ | To Migrate | Current deployment guides |
| operations/maintenance/ | Operations | docs/guides/maintenance/ | To Migrate | Current maintenance guides |
| analysis/audits/ | Analysis | docs/meta/analysis/ | To Review | Compare with analysis_files |
| analysis/gaps/ | Analysis | docs/meta/analysis/ | To Review | Compare with analysis_files |
| analysis/progress/ | Progress | docs/meta/progress/ | To Review | Compare with analysis_files |
| meta/organization/ | Meta | docs/meta/ | To Migrate | Current meta docs |
| meta/standards/ | Meta | docs/meta/ | To Migrate | Current standards |
| meta/templates/ | Meta | docs/meta/templates/ | To Review | Compare with other templates |
| README.md | Navigation | docs/ | To Update | Update for new structure |

## Knowledge Base Directory Content

| Directory/File | Content Type | New Location | Status | Notes |
|----------------|--------------|--------------|--------|-------|
| meta/ | Meta | docs/meta/ | To Review | Compare with docs meta |
| testing/ | Testing | docs/implementation/testing/ | To Review | Compare with docs testing |
| integrations/ | Integration | docs/api/integration/ | To Review | Compare with other integration docs |
| api/ | API | docs/api/ | To Review | Compare with other API docs |
| database/ | Database | docs/implementation/database/ | To Review | Compare with other database docs |
| configuration/ | Configuration | docs/guides/setup/ | To Review | Compare with operations docs |
| authentication/ | Security | docs/api/security/ | To Review | Compare with implementation docs |
| functional/ | Implementation | docs/implementation/ | To Review | Review subdirectories |
| system/ | Architecture | docs/architecture/ | To Review | Compare with architecture docs |
| inventory_management_documentation/ | Implementation | docs/implementation/ | To Review | Specific feature docs |
| current_and_next_steps.md | Progress | docs/meta/progress/ | To Archive | Superseded |
| documentation_plan.md | Planning | docs/meta/roadmap/ | To Review | Compare with roadmap |
| progress_summary.md | Progress | docs/meta/progress/ | To Archive | Superseded |
| frontend/ | Frontend | docs/implementation/frontend/ | To Migrate | Frontend documentation |
| task_tracking.md | Progress | docs/meta/progress/ | To Archive | Superseded |
| next_steps_and_recommendations.md | Planning | docs/meta/roadmap/ | To Review | Compare with roadmap |
| templates/ | Templates | docs/meta/templates/ | To Review | Compare with other templates |
| next_steps.md | Progress | docs/meta/progress/ | To Archive | Superseded |
| technical/ | Implementation | docs/implementation/ | To Review | Compare with implementation docs |
| reference/ | Reference | docs/meta/reference/ | To Migrate | Reference documentation |
| README.md | Navigation | docs/ | To Review | Use for new structure |

## Consolidation Strategy

### Architecture Documentation
1. Compare and merge:
   - output/1_system_overview_and_architecture.md
   - output/2_key_models_and_relationships.md
   - docs/architecture/overview.md
   - docs/architecture/components.md
   - knowledge-base/system/overview/

### API Documentation
1. Compare and merge:
   - output/4_api_endpoints.md
   - docs/implementation/api/
   - knowledge-base/api/
   - api-prepared-reference-files/api_endpoints.md

### Integration Documentation
1. Compare and merge:
   - output/3_pos_integration_points.md
   - output/10_integration_patterns_and_strategies.md
   - docs/architecture/integrations.md
   - knowledge-base/integrations/
   - api-prepared-reference-files/integration_patterns.md

### Database Documentation
1. Compare and merge:
   - output/5_database_schema.md
   - output/6_entity_relationship_diagram.md
   - output/8_database_performance.md
   - docs/implementation/database/
   - knowledge-base/database/

### Implementation Documentation
1. Compare and merge:
   - output/7_data_validation_and_business_rules.md
   - docs/implementation/
   - knowledge-base/functional/
   - knowledge-base/technical/

### Meta Documentation
1. Compare and merge:
   - docs/meta/
   - knowledge-base/meta/
   - templates from all locations

## Next Steps
1. Begin content migration with architecture documentation
2. Create new index files for each major section
3. Update cross-references
4. Archive outdated content
5. Validate new structure

## Notes
- Focus on preserving the most current and comprehensive content
- Maintain AI-friendly structure from knowledge-base
- Ensure clear navigation and cross-referencing
- Keep specialized documentation (e.g., inventory management) organized within implementation
- Consider creating new templates based on best examples
- Update all index files to reflect new structure
- Create comprehensive README files for each major section

Last Updated: Current timestamp 