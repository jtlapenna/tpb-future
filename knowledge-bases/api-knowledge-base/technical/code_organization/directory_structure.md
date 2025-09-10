---
title: "Repository Directory Structure"
description: "Overview of The Peak Beyond's backend repository structure and organization"
last_updated: "2023-07-11"
contributors: ["AI Analysis Team"]
related_files: [
  "technical/code_organization/architectural_patterns.md",
  "system/overview/system_architecture.md",
  "technical/implementation_details/models/overview.md"
]
tags: ["technical", "code-organization", "directory-structure", "repository"]
ai_agent_relevance: [
  "SystemArchitectAgent", 
  "DocumentationAgent"
]
---

# Repository Directory Structure

## Overview

The Peak Beyond's backend repository follows a standard Ruby on Rails application structure with some custom directories for specialized functionality. This document provides a comprehensive overview of the repository organization, helping developers navigate the codebase efficiently and understand where different components are located.

## Key Concepts

- **Standard Rails Structure**: The repository follows the conventional Ruby on Rails directory structure with app/, config/, db/, etc.
- **Custom Directories**: Additional directories have been added for specialized functionality like operations/, contracts/, and parsers/.
- **Multi-tier Architecture**: The codebase is organized into layers (database, model, service, API, integration, background processing).
- **Component Separation**: Different components are separated into their own directories to maintain a clean separation of concerns.

## Directory Structure

```
thepeakbeyond-aim-tpb-be/
├── app/                      # Core application code
│   ├── channels/             # ActionCable channels for real-time features
│   ├── contracts/            # Business logic contracts/validations
│   ├── controllers/          # Request handlers
│   │   ├── api/              # API-specific controllers
│   │   │   └── v1/           # Version 1 API endpoints
│   │   └── webhooks/         # Webhook endpoints for POS integrations
│   ├── jobs/                 # Background job definitions
│   ├── lib/                  # Application-specific libraries
│   │   ├── blaze/            # Blaze POS integration
│   │   ├── covasoft/         # COVA POS integration
│   │   ├── ez_texting/       # EZ Texting integration
│   │   ├── flowhub/          # Flowhub POS integration
│   │   ├── headset/          # Headset integration
│   │   ├── leaflogix/        # Leaflogix POS integration
│   │   ├── shopify/          # Shopify integration
│   │   └── treez/            # Treez POS integration
│   ├── mailers/              # Email templates and logic
│   ├── models/               # Data models and business logic
│   │   └── concerns/         # Shared model behaviors
│   ├── operations/           # Service objects for complex operations
│   ├── parsers/              # Data parsers for external systems
│   │   └── webhooks/         # Webhook data parsers
│   ├── policies/             # Authorization policies
│   ├── serializers/          # JSON serializers for API responses
│   │   └── api/v1/           # API v1 serializers
│   └── views/                # View templates
│       ├── api_sync_mailer/  # Email templates for API sync
│       ├── layouts/          # Layout templates
│       └── orders_mailer/    # Email templates for orders
├── bin/                      # Executable scripts
├── config/                   # Application configuration
│   ├── environments/         # Environment-specific settings
│   └── initializers/         # Rails initializers
├── db/                       # Database configuration and migrations
│   └── migrate/              # Database migration files
├── docs/                     # Documentation
│   └── api/                  # API documentation
├── lib/                      # Shared libraries and tasks
│   └── tasks/                # Rake tasks
├── public/                   # Publicly accessible files
├── redis/                    # Redis-related configurations
├── spec/                     # Test files
│   ├── acceptance/           # Acceptance tests
│   ├── controllers/          # Controller tests
│   ├── factories/            # Test factories
│   ├── jobs/                 # Job tests
│   ├── mailers/              # Mailer tests
│   ├── models/               # Model tests
│   ├── operations/           # Operation tests
│   ├── parsers/              # Parser tests
│   ├── policies/             # Policy tests
│   ├── requests/             # Request tests
│   ├── routing/              # Routing tests
│   └── support/              # Test support files
└── tmp/                      # Temporary files
```

## Directory Descriptions

### app/

The `app/` directory contains the main application code, organized into subdirectories based on component type.

#### app/channels/

Contains Action Cable channels for real-time features, enabling WebSocket communication between the server and clients.

#### app/contracts/

Houses business logic contracts that define validation rules and constraints for data operations, using the dry-validation gem.

#### app/controllers/

Contains controllers that handle incoming HTTP requests and generate responses. Organized into subdirectories:

- **api/v1/**: Controllers for version 1 of the API
- **concerns/**: Shared controller logic implemented as modules
- **webhooks/**: Controllers that handle incoming webhook requests from POS systems

#### app/jobs/

Contains background job classes that handle asynchronous processing using Sidekiq. These jobs handle tasks like data synchronization, email sending, and cleanup operations.

#### app/lib/

Contains application-specific libraries and modules, particularly integrations with external systems:

- **blaze/**: Integration with Blaze POS
- **covasoft/**: Integration with COVA POS
- **ez_texting/**: Integration with EZ Texting SMS service
- **flowhub/**: Integration with Flowhub POS
- **headset/**: Integration with Headset analytics
- **leaflogix/**: Integration with Leaflogix POS
- **shopify/**: Integration with Shopify e-commerce
- **treez/**: Integration with Treez POS

#### app/mailers/

Contains mailer classes for sending emails, including order confirmations and system notifications.

#### app/models/

Contains ActiveRecord models that represent database tables and encapsulate business logic:

- **concerns/**: Shared model behaviors implemented as modules

#### app/operations/

Contains service objects that encapsulate complex business operations, following the single responsibility principle.

#### app/parsers/

Contains classes for parsing data from various sources, particularly webhook payloads from POS systems.

#### app/policies/

Contains authorization policies using the Pundit gem, defining who can perform which actions on which resources.

#### app/serializers/

Contains serializers that format data for API responses, using the active_model_serializers gem.

#### app/views/

Contains view templates for rendering HTML responses, primarily for emails since this is an API-focused application.

### bin/

Contains executable scripts for running the application, including setup, server start, and console access.

### config/

Contains configuration files for the application, including routes, database settings, and environment-specific configurations.

### db/

Contains database-related files, including migrations, seeds, and schema definitions.

### docs/

Contains documentation files, particularly API documentation.

### lib/

Contains shared libraries and tasks that are not specific to the application domain.

### public/

Contains static files that are served directly by the web server.

### redis/

Contains Redis-related configurations and scripts.

### spec/

Contains test files organized by component type, using RSpec as the testing framework.

## Relationships with Other Components

The directory structure reflects the multi-tier architecture of the application:

1. **Database Layer**: Represented by `db/` directory
2. **Model Layer**: Represented by `app/models/` directory
3. **Service Layer**: Represented by `app/operations/` and `app/lib/` directories
4. **API Layer**: Represented by `app/controllers/` and `app/serializers/` directories
5. **Integration Layer**: Represented by `app/lib/` subdirectories for POS integrations
6. **Background Processing Layer**: Represented by `app/jobs/` directory

## Common Patterns and Best Practices

### Directory Organization

- **Component-based Organization**: Code is organized by component type (controllers, models, jobs, etc.)
- **Versioned APIs**: API controllers and serializers are versioned (v1) to support API evolution
- **Concerns for Shared Logic**: Shared logic is extracted into concerns modules
- **Service Objects**: Complex operations are encapsulated in service objects

### File Naming Conventions

- **Singular Model Names**: Model files use singular names (e.g., `product.rb` for the `Product` model)
- **Plural Controller Names**: Controller files use plural names (e.g., `products_controller.rb`)
- **Descriptive Job Names**: Job files include a descriptive action and the `_job` suffix (e.g., `sync_products_job.rb`)
- **Consistent Serializer Names**: Serializer files include the model name and `_serializer` suffix (e.g., `product_serializer.rb`)

## Known Issues and Limitations

- Some older parts of the codebase may not follow the current directory structure conventions
- The `app/lib/` directory contains both application-specific code and external integrations, which could be better separated
- Some business logic may be spread across models, operations, and controllers, making it harder to follow

## Technical Debt

- Consider moving POS integrations to a dedicated `integrations/` directory
- Refactor shared code in `app/lib/` to follow a more consistent pattern
- Ensure all new components follow the established directory structure

## AI Agent Notes

- **SystemArchitectAgent**: When designing new features, follow the established directory structure and place components in the appropriate directories. Consider the multi-tier architecture when deciding where to place new code.
- **DocumentationAgent**: When documenting code, reference the directory structure to help developers locate the components being described.
- **Next documents**: Consider reviewing [technical/code_organization/architectural_patterns.md] for information on the architectural patterns used in the codebase, and [technical/implementation_details/models/overview.md] for details on the model layer.

## References

- [Ruby on Rails Directory Structure](https://guides.rubyonrails.org/getting_started.html#creating-the-blog-application)
- [Service Objects in Rails](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)
- [Pundit Authorization](https://github.com/varvet/pundit) 