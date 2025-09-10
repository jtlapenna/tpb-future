# Contributor Guidelines for The Peak Beyond Knowledge Base

This document provides guidelines for contributing to The Peak Beyond's knowledge base.

## Getting Started

1. Familiarize yourself with the [knowledge base structure](../README.md) and [metadata standards](metadata_standards.md).
2. Identify the appropriate location for your contribution based on the content type.
3. Use the appropriate template from the `templates` directory.
4. Follow the writing style and formatting guidelines outlined below.

## Types of Contributions

### New Documentation

To create new documentation:

1. Identify the appropriate directory for your content.
2. Copy the relevant template from the `templates` directory.
3. Fill in the template with your content.
4. Add appropriate metadata in the front matter.
5. Add cross-references to related documentation.
6. Update the `update_history.json` file.

### Updates to Existing Documentation

To update existing documentation:

1. Update the content as needed.
2. Update the `last_updated` field in the front matter.
3. Add yourself to the `contributors` list if you're not already there.
4. Update any cross-references that may be affected.
5. Update the `update_history.json` file.

### Reviews and Feedback

To review existing documentation:

1. Check for accuracy and completeness.
2. Verify that cross-references are correct.
3. Ensure that metadata is complete and follows standards.
4. Provide feedback through the appropriate channels.

## Writing Style Guidelines

### General Principles

- **Be clear and concise**: Use simple language and avoid jargon.
- **Be consistent**: Use consistent terminology and formatting.
- **Be comprehensive**: Cover all relevant aspects of the topic.
- **Be accurate**: Ensure that all information is correct and up-to-date.
- **Be helpful**: Focus on what would be most helpful to the reader.

### Formatting Guidelines

- Use Markdown for all documentation.
- Use headings to organize content (# for title, ## for sections, ### for subsections).
- Use code blocks for code examples (```language).
- Use tables for structured data.
- Use lists for sequential steps or related items.
- Use blockquotes for important notes or warnings.

### Code Examples

- Include code examples where appropriate.
- Use syntax highlighting by specifying the language (```ruby).
- Keep code examples concise and focused.
- Explain what the code does and why it's relevant.

## Review Process

All contributions to the knowledge base should go through a review process:

1. **Self-review**: Review your own contribution for accuracy, completeness, and adherence to guidelines.
2. **Peer review**: Have at least one other person review your contribution.
3. **Final review**: A designated reviewer will perform a final review before acceptance.

## Maintenance Responsibilities

Contributors are responsible for:

1. Keeping their contributions up-to-date.
2. Responding to feedback and questions about their contributions.
3. Participating in regular reviews of the knowledge base.

## AI Agent Considerations

When creating or updating documentation, consider how it will be used by AI agents:

1. Include specific guidance for relevant AI agent types in the "AI Agent Notes" section.
2. Use clear and consistent terminology that can be easily understood by AI agents.
3. Provide explicit cross-references to related documentation.
4. Include examples and patterns that AI agents can follow.

## Templates

Use the following templates for different types of documentation:

- [System-Level Template](../templates/system_level_template.md): For system-level documentation
- [Functional Area Template](../templates/functional_area_template.md): For functional area documentation
- [Technical Implementation Template](../templates/technical_implementation_template.md): For technical implementation documentation
- [API Endpoint Template](../templates/api_endpoint_template.md): For API endpoint documentation

## Questions and Support

If you have questions or need support with your contribution, please contact the knowledge base maintainers. 