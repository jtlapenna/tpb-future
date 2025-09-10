---
title: AI Agent Documentation Rules
description: Guidelines for creating documentation that is optimized for AI agent consumption and processing
last_updated: 2023-07-10
contributors: [Documentation Team]
related_files: 
  - knowledge-base/meta/metadata_standards.md
  - knowledge-base/meta/contributor_guidelines.md
tags: [meta, guidelines, ai-agents]
ai_agent_relevance:
  - DocumentationAgent
  - SystemArchitectAgent
  - POSIntegrationSpecialistAgent
  - APISpecialistAgent
---

# AI Agent Documentation Rules

This document outlines the rules and best practices for creating documentation that is optimized for AI agent consumption and processing. Following these guidelines will ensure that AI agents can effectively understand, navigate, and utilize the knowledge base.

## Core Principles

1. **Consistency**: Use consistent terminology, formatting, and structure across all documents
2. **Explicitness**: Make relationships and dependencies explicit rather than implicit
3. **Atomicity**: Each document should focus on a single concept or component
4. **Completeness**: Include all relevant information within a document or provide clear references
5. **Metadata-richness**: Include comprehensive metadata to aid in document discovery and relevance assessment

## Document Structure

### Front Matter Requirements

All documents must include YAML front matter with the following fields:

```yaml
---
title: Document Title
description: Brief description of the document's content
last_updated: YYYY-MM-DD
contributors: [Contributor1, Contributor2]
related_files: 
  - path/to/related/file1.md
  - path/to/related/file2.md
tags: [tag1, tag2, tag3]
ai_agent_relevance:
  - AgentType1
  - AgentType2
---
```

The `ai_agent_relevance` field is particularly important as it explicitly indicates which types of AI agents would find the document relevant.

### Section Headers

Use a consistent hierarchy of section headers:

1. Document title (H1): Only one per document
2. Major sections (H2): Primary divisions of the document
3. Subsections (H3): Divisions within major sections
4. Minor subsections (H4): Further divisions as needed

### Required Sections

Each document should include the following sections where applicable:

1. **Overview**: Brief introduction to the topic
2. **Key Concepts**: Definitions of important terms and concepts
3. **Implementation Details**: Technical details of the implementation
4. **Relationships**: How this component relates to other components
5. **Examples**: Code examples or usage examples
6. **Common Patterns**: Recurring patterns or best practices
7. **Known Issues**: Known limitations or issues
8. **AI Agent Notes**: Special considerations for AI agents

## Terminology and Language

### Consistent Terminology

- Maintain a glossary of terms in `knowledge-base/meta/glossary.md`
- Use terms consistently across all documents
- Define terms on first use within a document

### Clear and Precise Language

- Use simple, direct language
- Avoid ambiguity and vagueness
- Use active voice rather than passive voice
- Keep sentences concise and focused

### Code References

- Use consistent formatting for code references:
  - Inline code: `code`
  - Code blocks: ```language\ncode\n```
- Always specify the language for syntax highlighting
- Include comments in code examples to explain key points

## Cross-References and Relationships

### Explicit References

- Use relative paths for links to other documents
- Include the `related_files` field in front matter
- Explain the nature of relationships between documents

### Dependency Graphs

- For complex systems, include a dependency graph
- Use mermaid.js syntax for diagrams
- Explain the significance of each relationship

## AI Agent-Specific Considerations

### Agent Types

Reference the following agent types in the `ai_agent_relevance` field:

- `DocumentationAgent`: For general documentation tasks
- `SystemArchitectAgent`: For high-level system architecture
- `POSIntegrationSpecialistAgent`: For POS integration details
- `APISpecialistAgent`: For API-related documentation
- `DatabaseSpecialistAgent`: For database-related documentation
- `SecuritySpecialistAgent`: For security-related documentation
- `PerformanceOptimizationAgent`: For performance-related documentation

### Agent Notes Section

Include an "AI Agent Notes" section in each document with:

- Specific guidance for different agent types
- Key insights that might not be obvious from the content
- Suggested next documents to consult for related information

Example:

```markdown
## AI Agent Notes

- **SystemArchitectAgent**: This component is central to the multi-tenant architecture and should be considered when evaluating system-wide changes.
- **APISpecialistAgent**: Note the authentication requirements for these endpoints differ from the standard pattern.
- **Next documents**: Consider reviewing `system/security/authentication.md` and `functional/api_endpoints/rate_limiting.md` for related information.
```

## Diagrams and Visual Aids

### Diagram Format

- Use mermaid.js syntax for diagrams
- Include a text description of the diagram for accessibility
- Keep diagrams focused on a single concept

### Required Diagrams

Include the following types of diagrams where applicable:

- Component diagrams for system architecture
- Entity-relationship diagrams for data models
- Sequence diagrams for processes and workflows
- State diagrams for state machines

## Examples

### Good Example

```markdown
---
title: Authentication Service
description: Overview of the authentication service and its integration points
last_updated: 2023-07-05
contributors: [Auth Team]
related_files: 
  - system/security/authorization.md
  - functional/api_endpoints/authentication.md
tags: [security, authentication, service]
ai_agent_relevance:
  - SecuritySpecialistAgent
  - APISpecialistAgent
---

# Authentication Service

## Overview

The Authentication Service manages user authentication across the platform, supporting multiple authentication methods and integration with third-party identity providers.

## Key Concepts

- **JWT Tokens**: JSON Web Tokens used for stateless authentication
- **Refresh Tokens**: Long-lived tokens used to obtain new access tokens
- **Identity Providers**: External services that authenticate users

## Implementation Details

The service is implemented as a standalone microservice with the following components:

```ruby
class AuthenticationService
  def authenticate(credentials)
    # Authentication logic
  end
end
```

## AI Agent Notes

- **SecuritySpecialistAgent**: This service implements OWASP best practices for token management.
- **APISpecialistAgent**: All API endpoints except /health and /login require a valid JWT token.
- **Next documents**: Review `system/security/jwt_configuration.md` for token configuration details.
```

## Maintenance and Updates

- Review documentation regularly for accuracy
- Update the `last_updated` field when changes are made
- Add new contributors to the `contributors` field
- Ensure all links and references remain valid

## Conclusion

Following these rules will ensure that the documentation is optimized for AI agent consumption, making it easier for agents to provide accurate and helpful assistance based on the knowledge base content. 