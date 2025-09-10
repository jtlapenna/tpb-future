---
title: "Multi-Tenant Architecture"
description: "Overview of The Peak Beyond's multi-tenant architecture for cannabis dispensaries"
last_updated: "2023-07-15"
contributors: ["AI Analysis Team"]
related_files: [
  "system/domain_model/business_entities.md",
  "functional/data_management/core_models.md",
  "functional/data_management/database_schema.md"
]
tags: ["system", "architecture", "multi-tenant", "data-isolation", "store"]
ai_agent_relevance: [
  "SystemArchitectAgent", 
  "DatabaseOptimizationAgent", 
  "MultiTenantSpecialistAgent"
]
---

# Multi-Tenant Architecture

## Overview

The Peak Beyond's system implements a **multi-tenant architecture** where each cannabis dispensary (Store) has its own isolated data while sharing common master data. This architecture is fundamental to the system's design, allowing multiple dispensaries to use the same platform while maintaining data separation and customization.

## Key Concepts

### Tenant Isolation

Each store (dispensary) in the system operates as a separate tenant with isolated data. This ensures that one dispensary's data (products, inventory, orders, customers) does not mix with another's, providing security and privacy.

### Shared Master Data

While tenant data is isolated, the system maintains shared master data (such as common products, brands, and categories) that can be referenced across tenants. This reduces duplication and ensures consistency.

### Tenant-Specific Customization

Each tenant can customize shared master data to fit their specific needs. For example, a dispensary can set its own prices, inventory levels, and product descriptions while referencing the same master product.

### Cross-Tenant Operations

Some operations, such as reporting and analytics, can span across tenants when performed by system administrators. These operations respect tenant boundaries while providing aggregated insights.

## Implementation Details

### Structure

The multi-tenant architecture is implemented through a combination of database design and application logic:

1. **Tenant Identifier**: Each tenant-specific table includes a `store_id` column that identifies the tenant.
2. **Tenant-Specific Tables**: Tables like `store_products`, `store_categories`, and `orders` are tenant-specific.
3. **Shared Tables**: Tables like `products`, `brands`, and `categories` are shared across tenants.
4. **Tenant Context**: Application logic maintains a tenant context for each request.

### Data Flow

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│                 │      │                 │      │                 │
│  Master Data    │─────►│  Tenant Data    │─────►│  User Interface │
│  (Shared)       │      │  (Store-specific)│      │  (Kiosk/CMS)    │
│                 │      │                 │      │                 │
└─────────────────┘      └─────────────────┘      └─────────────────┘
```

1. Master data (products, categories, brands) is created and maintained centrally
2. Each tenant (store) references this master data and adds store-specific attributes
3. The user interface (kiosk or CMS) displays the combined data to users

## Relationships with Other Components

### Depends On
- **Store Model**: The central entity representing a tenant
- **Database Schema**: Designed to support multi-tenancy
- **Authentication System**: Ensures users only access their tenant's data

### Used By
- **API Layer**: Enforces tenant isolation in all requests
- **Query System**: Automatically scopes queries to the current tenant
- **Reporting System**: Respects tenant boundaries for data aggregation

## Examples

### Tenant Scoping in Models

```ruby
# Example of tenant scoping in a model
class StoreProduct < ApplicationRecord
  belongs_to :store
  belongs_to :product
  belongs_to :product_variant, optional: true
  
  # Tenant scoping - only return products for the current store
  scope :for_store, ->(store_id) { where(store_id: store_id) }
  
  # Validation to ensure products stay within their tenant
  validates :store_id, presence: true
end
```

### Tenant Context in Controllers

```ruby
# Example of tenant context in a controller
class Api::V1::ProductsController < ApplicationController
  before_action :set_store
  
  def index
    @products = @store.store_products.includes(:product, :product_variant)
    # ...
  end
  
  private
  
  def set_store
    @store = Store.find(params[:store_id])
  end
end
```

## Common Patterns and Best Practices

### Tenant Identification Pattern
Always identify the tenant early in the request lifecycle and maintain that context throughout the request processing.

### Shared vs. Tenant-Specific Data Pattern
Clearly separate data that should be shared across tenants from data that should be tenant-specific.

### Best Practice: Explicit Tenant Scoping
Always explicitly scope queries to a tenant, even when the current tenant seems obvious from context.

### Best Practice: Tenant Validation
Validate that data belongs to the correct tenant before performing operations on it.

## Known Issues and Limitations

### Cross-Tenant Queries
Complex reporting queries that span multiple tenants can be performance-intensive.

### Workaround
Implement a data warehouse or reporting database that denormalizes data for efficient cross-tenant reporting.

## Technical Debt

### Inconsistent Tenant Scoping
Some older parts of the codebase may not consistently apply tenant scoping.

### Improvement Opportunities
- Implement a global tenant scoping mechanism at the database connection level
- Add automated tests specifically for tenant isolation
- Refactor older code to consistently use tenant scoping patterns

## AI Agent Notes

### For System Architect Agent
When designing new features, always consider the multi-tenant architecture. Any new tables that contain tenant-specific data should include a `store_id` column and appropriate foreign key constraints.

### For Database Optimization Agent
When optimizing queries, be aware that most queries should be scoped to a specific tenant. Look for opportunities to add composite indexes that include the tenant identifier.

### For Multi-Tenant Specialist Agent
Monitor for any potential data leakage between tenants. Regularly audit the system to ensure tenant isolation is maintained, especially after major changes.

## Cross-Repository Considerations

### Frontend Considerations
The frontend (Kiosk UI) must maintain tenant context in all API requests, typically by including the store ID in API endpoints.

### CMS Considerations
The CMS must enforce tenant isolation in its user interface, ensuring that users only see and modify data for tenants they have access to.

## External Resources

For more information on multi-tenant architectures, refer to:

- [Microsoft Learn - Multi-tenant Data Architecture](https://learn.microsoft.com/en-us/azure/architecture/guide/multitenant/approaches/data-isolation)
- [Shopify Engineering - Multi-tenant Rails Applications](https://shopify.engineering/building-resilient-multi-tenant-architecture)

## References

- [Multi-Tenant Data Architecture](https://docs.microsoft.com/en-us/azure/architecture/guide/multitenant/considerations/data-considerations)
- [Rails Multi-Tenancy Patterns](https://engineering.shopify.com/blogs/engineering/building-a-multitenant-application-in-rails) 