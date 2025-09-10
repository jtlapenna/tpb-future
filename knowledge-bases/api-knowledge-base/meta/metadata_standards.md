# Metadata Standards for The Peak Beyond Knowledge Base

This document outlines the metadata standards and conventions used in The Peak Beyond's knowledge base.

## Front Matter Format

All Markdown files in the knowledge base should include YAML front matter at the beginning of the file. The front matter provides metadata about the document and is enclosed between triple-dashed lines:

```yaml
---
title: "Document Title"
description: "Brief description of the document"
last_updated: "YYYY-MM-DD"
contributors: ["Contributor1", "Contributor2"]
related_files: ["path/to/related1.md", "path/to/related2.md"]
tags: ["tag1", "tag2", "tag3"]
ai_agent_relevance: ["AgentType1", "AgentType2"]
---
```

### Required Fields

The following fields are required in all front matter:

- **title**: The title of the document
- **description**: A brief description of the document's content
- **last_updated**: The date when the document was last updated (format: YYYY-MM-DD)
- **tags**: A list of tags that categorize the document

### Optional Fields

The following fields are optional but recommended:

- **contributors**: A list of people who have contributed to the document
- **related_files**: A list of related files in the knowledge base
- **ai_agent_relevance**: A list of AI agent types that would find this document relevant

## Tagging Conventions

Tags should be used consistently across the knowledge base to facilitate searching and filtering. The following tag categories are defined:

### Content Type Tags

- **system**: High-level system documentation
- **architecture**: Architectural documentation
- **functional**: Functional area documentation
- **technical**: Technical implementation documentation
- **api**: API documentation
- **reference**: Reference material

### Domain Tags

- **multi-tenant**: Related to multi-tenant architecture
- **pos-integration**: Related to POS integration
- **data-model**: Related to data models and relationships
- **authentication**: Related to authentication and authorization
- **synchronization**: Related to data synchronization
- **order-processing**: Related to order processing

### Component Tags

- **models**: Related to data models
- **controllers**: Related to controllers
- **jobs**: Related to background jobs
- **serializers**: Related to serializers
- **lib**: Related to library code
- **api-endpoints**: Related to API endpoints

## AI Agent Relevance

The `ai_agent_relevance` field should list the AI agent types that would find the document relevant. The following agent types are defined:

- **SystemArchitectAgent**: Interested in high-level system architecture
- **POSIntegrationSpecialistAgent**: Interested in POS integration and data synchronization
- **DatabaseOptimizationAgent**: Interested in database performance and structure
- **APIEnhancementAgent**: Interested in API design and performance
- **MultiTenantSpecialistAgent**: Interested in multi-tenant architecture and data isolation
- **OrderProcessingAgent**: Interested in order flow optimization
- **KioskManagementAgent**: Interested in kiosk configuration and management

## File Naming Conventions

Files should be named using lowercase letters, numbers, and underscores. The file extension should be `.md` for Markdown files and `.json` for JSON files.

Examples:
- `system_architecture.md`
- `api_endpoints.md`
- `multi_tenant_architecture.md`
- `kb_version.json`

## Directory Structure

The knowledge base follows a hierarchical directory structure:

```
knowledge-base/
├── meta/                  # Metadata about the knowledge base
├── system/                # System-level understanding
│   ├── overview/          # High-level system architecture
│   ├── cross_repository/  # Interactions with other repositories
│   └── domain_model/      # Business domain model
├── functional/            # Functional area documentation
│   ├── data_management/   # Data models and relationships
│   ├── api_endpoints/     # API documentation
│   ├── integrations/      # External system integrations
│   ├── background_processing/ # Background jobs and processing
│   └── validation/        # Data validation and business rules
├── technical/             # Technical implementation details
│   ├── code_organization/ # Code structure and organization
│   ├── implementation_details/ # Component-specific details
│   ├── performance/       # Performance considerations
│   └── technical_debt/    # Known issues and improvement opportunities
└── reference/             # Reference materials
```

## Cross-References

Cross-references between documents should use relative paths:

```markdown
See [System Architecture](../../system/overview/system_architecture.md) for more information.
```

## Versioning

The knowledge base follows semantic versioning (MAJOR.MINOR.PATCH):

- MAJOR: Significant restructuring or content changes
- MINOR: Addition of new content or substantial updates to existing content
- PATCH: Minor updates, corrections, or clarifications

The current version is maintained in the `kb_version.json` file.

## Maintenance

Documents should be reviewed and updated regularly to ensure they remain accurate and up-to-date. The `last_updated` field in the front matter should be updated whenever a document is modified.

The maintenance schedule is defined in the `update_history.json` file. 