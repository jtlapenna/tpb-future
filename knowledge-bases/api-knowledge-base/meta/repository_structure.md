# Repository Structure Analysis

## Core Directories

### 1. App Directory (`app/`)
- **Controllers** (`app/controllers/`)
  - API V1 controllers (`api/v1/`)
  - Webhook controllers (`webhooks/`)
  - Concerns for shared logic
- **Models** (`app/models/`)
  - Core business models
  - Model concerns
- **Serializers** (`app/serializers/`)
  - API V1 serializers
  - Base serializers
- **Jobs** (`app/jobs/`)
  - Background processing tasks
  - Scheduled jobs
- **Operations** (`app/operations/`)
  - Business logic operations
  - Service objects
- **Policies** (`app/policies/`)
  - Authorization policies
  - Access control rules
- **Lib** (`app/lib/`)
  - POS integrations:
    - Blaze
    - Covasoft
    - Flowhub
    - Headset
    - Leaflogix
    - Shopify
    - Treez
  - Utility modules
- **Mailers** (`app/mailers/`)
  - Email templates
  - Notification logic

### 2. Config Directory (`config/`)
- **Environments**
  - Development
  - Production
  - Test
- **Initializers**
  - Framework configurations
  - Third-party integrations

### 3. Database Directory (`db/`)
- **Migrations**
  - Schema changes
  - Data migrations
- **Schema**
  - Current database structure
- **Seeds**
  - Initial data setup

### 4. Test Directory (`spec/`)
- **Models**
  - Model unit tests
- **Controllers**
  - Controller tests
- **Requests**
  - API endpoint tests
- **Policies**
  - Authorization tests
- **Factories**
  - Test data factories
- **Support**
  - Test helpers

### 5. Infrastructure
- **Redis** (`redis/`)
  - Cache configuration
  - Queue setup
- **Docker**
  - Main Dockerfile
  - Sidekiq Dockerfile
  - Docker Compose config

## Key Entry Points

1. **API Endpoints**
   - `app/controllers/api/v1/`
   - RESTful resource endpoints
   - Webhook receivers

2. **Background Processing**
   - `app/jobs/`
   - Sidekiq workers
   - Scheduled tasks

3. **Data Models**
   - `app/models/`
   - Core business logic
   - Data relationships

4. **Integration Points**
   - `app/lib/` POS clients
   - Webhook handlers
   - External service adapters

## Configuration Files

1. **Application Settings**
   - `config/application.rb`
   - `config/environments/*.rb`
   - `config/initializers/*.rb`

2. **Database Configuration**
   - `config/database.yml`
   - `db/schema.rb`

3. **Infrastructure**
   - `docker-compose.yml`
   - `Dockerfile`
   - `Dockerfile_Sidekiq`

4. **Development**
   - `.ruby-version`
   - `.ruby-gemset`
   - `Gemfile`
   - `Gemfile.lock`

## Best Practices

1. **Code Organization**
   - Follow directory structure conventions
   - Keep related files together
   - Use appropriate namespacing

2. **Testing**
   - Maintain test coverage
   - Use factories for test data
   - Follow RSpec conventions

3. **Documentation**
   - Keep README updated
   - Document complex logic
   - Maintain API documentation

*Last Updated: March 20, 2024* 