# Data Storage Analysis

## Overview
This document provides a detailed analysis of data storage patterns across the three repositories, examining how data is persisted, cached, and shared between components.

**Sources Reviewed:**
- Backend: `config/database.yml`, `db/schema.rb`, `app/models/store_setting.rb`, `config/cable.yml`, Redis configuration files
- Frontend: `src/api/db.js`, `src/api/dbconfig.js`, `src/analytics/db.js`
- CMS: Component data handling patterns

## Key Findings

### Database Architecture Patterns

#### Backend (Rails) Data Persistence
- **PostgreSQL Database**: The Rails application uses PostgreSQL as its primary relational database:
  ```yaml
  # From database.yml
  default: &default
    adapter: postgresql
    encoding: unicode
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  ```
- **Redis for Caching and Job Queue**: Redis is used for caching and background job processing:
  ```yaml
  # From cable.yml for Action Cable
  production:
    adapter: redis
    url: redis://localhost:6379/1
    channel_prefix: peak_beyond_api_production
  ```
- **Complex Schema**: The database schema includes over 50 tables with relationships supporting the product catalog, user management, and order processing.

#### Frontend (Vue.js) Local Storage
- **IndexedDB**: The frontend implements multiple IndexedDB databases for offline capabilities:
  ```javascript
  // From api/dbconfig.js
  request.onupgradeneeded = e => {
    console.log('onupgradeneeded')
    let db = e.target.result
    db.createObjectStore('products', { autoIncrement: true, keyPath: 'id' })
    db.createObjectStore('brands', { autoIncrement: true, keyPath: 'id' })
    db.createObjectStore('articles', { autoIncrement: true, keyPath: 'id' })
    db.createObjectStore('rfids', { autoIncrement: true, keyPath: 'id' })
    db.createObjectStore('tags', { autoIncrement: true, keyPath: 'id' })
  }
  ```
- **Analytics Events Storage**: A separate IndexedDB database for storing analytics events:
  ```javascript
  // From analytics/db.js
  const DB_NAME = 'analitics_Events'
  // ...
  db.createObjectStore('events', { autoIncrement: !0, keyPath: 'id' })
  ```

### Data Storage Patterns

#### Backend Data Models
- **ActiveRecord Models**: Standard Rails ActiveRecord models with associations and validations.
- **Serialized JSON in Database**: Some models use serialized JSON for flexible schema storage:
  ```ruby
  # From store_setting.rb
  store :data, accessors: %i[
    admin_email printer_location pos_location main_color secondary_color
    featured_products_on_top_for_brands_page 
    # ... more fields
  ], coder: JSON
  ```
- **Schema Migration Patterns**: The application uses standard Rails migrations for schema evolution.

#### Frontend Repository Pattern
- **Local-Remote Repository Pattern**: The frontend implements a repository pattern with local and remote data sources:
  ```javascript
  // Conceptual pattern from the code
  class ProductsRepo extends Repo {
    async index(options) {
      try {
        // Get from remote
        const response = await this.remote.index(options)
        const products = response.data.products
        
        // Store locally if configured
        if (self.kioskConfig.STORE_LOCALLY === 1) {
          await Promise.all(
            products.map(async product => {
              await this.local.save(product)
            })
          )
        }
        return { products, meta: response.data.meta }
      } catch (e) {
        // Fall back to local or handle error
      }
    }
  }
  ```
- **Offline-First Architecture**: The data storage pattern supports offline-first operations with synchronization.

### Cross-Repository Data Flow

#### Data Flow Patterns
1. **Backend to Frontend**:
   - REST API responses are cached in IndexedDB for offline use
   - Data is structured according to API response schemas
   
2. **Frontend to Backend**:
   - Data is stored locally first, then synchronized with backend when connectivity is available
   - Analytics events follow batch synchronization pattern

3. **CMS to Backend**:
   - Direct database updates through API endpoints
   - No local storage, all changes immediately persisted to backend

### Data Evolution and Migration

#### Backend Database Migrations
- **Standard Rails Migrations**: The application uses ActiveRecord migrations for schema evolution:
  ```ruby
  # Example migration from db/migrate/20180626224949_create_store_settings.rb
  class CreateStoreSettings < ActiveRecord::Migration[5.1]
    def change
      create_table :store_settings do |t|
        t.integer :store_id
        t.text :data
        
        t.timestamps
      end
      
      add_index :store_settings, :store_id
      add_foreign_key :store_settings, :stores
    end
  end
  ```

#### Frontend Schema Versioning
- **IndexedDB Versioning**: The frontend manages schema changes with explicit versioning:
  ```javascript
  // From dbconfig.js
  const DB_VERSION = 1
  ```

## Integration Challenges and Patterns

### Challenges Identified
1. **Schema Synchronization**: Keeping client-side data schemas in sync with backend changes
2. **Offline Conflict Resolution**: Managing conflicts during synchronization after offline operations
3. **Data Integrity**: Ensuring data integrity across multiple storage mechanisms

### Effective Patterns
1. **Repository Abstraction**: Abstraction of data access behind repository interfaces
2. **Background Synchronization**: Batched and background data synchronization
3. **JSON Serialization**: Using JSON serialization for flexible schema evolution

## Questions & Gaps

### Open Questions
1. How are database schema changes coordinated across repositories?
2. What is the conflict resolution strategy when offline data conflicts with backend state?
3. How is data migration handled for IndexedDB schema changes?

### Areas Needing Investigation
- Detailed data synchronization mechanisms
- Error recovery procedures for failed synchronization
- Data backup and restoration procedures
- Role-based data access controls

### Potential Risks
- **Schema Drift**: Client and server schemas may drift over time, causing compatibility issues
- **Data Synchronization Failures**: Failed sync operations may lead to data loss or inconsistency
- **Storage Limitations**: Browser storage limitations could impact offline functionality

## Next Steps
1. Document data synchronization protocols
2. Analyze schema migration coordination
3. Investigate conflict resolution strategies
4. Establish best practices for cross-repository data integrity

## Cross-References
- Related to: [API Integration Analysis](./api-integration-findings.md)
- Related to: [Event Integration Analysis](./event-integration-findings.md)
- Supports: [Data Flow Patterns](../initial-understanding/data-flow-patterns-findings.md)

## Version History
- 1.0.0 (2024-03-21): Initial findings document created 