---
title: "Models Implementation Overview"
description: "Overview of The Peak Beyond's backend models implementation and organization"
last_updated: "2023-07-11"
contributors: ["AI Analysis Team"]
related_files: [
  "technical/code_organization/directory_structure.md",
  "functional/data_management/core_models.md",
  "functional/data_management/entity_relationships.md"
]
tags: ["technical", "implementation", "models", "data-management"]
ai_agent_relevance: [
  "DatabaseSpecialistAgent", 
  "SystemArchitectAgent"
]
---

# Models Implementation Overview

## Overview

The `app/models` directory is a crucial part of The Peak Beyond's backend application, housing the model classes that represent the core business entities and encapsulate the business logic. These models form the foundation of the application's data layer, providing an object-oriented interface to the database and implementing business rules and validations.

## Key Concepts

- **ActiveRecord Models**: Models inherit from ApplicationRecord (which inherits from ActiveRecord::Base), providing ORM functionality.
- **Business Logic Encapsulation**: Models encapsulate business logic related to their respective entities.
- **Data Validation**: Models implement validation rules to ensure data integrity.
- **Associations**: Models define relationships with other models using ActiveRecord associations.
- **Multi-tenant Architecture**: Models implement tenant isolation through store-based scoping.

## Model Structure

The models directory contains numerous model classes, each representing a specific business entity in the application. Key models include:

### Core Business Entities

- **Store**: Represents a cannabis dispensary, the primary tenant in the multi-tenant architecture.
- **Product**: Represents a master product that can be sold across multiple stores.
- **StoreProduct**: Represents a store-specific instance of a product with store-specific attributes.
- **Order**: Represents a customer order within a specific store.
- **Customer**: Represents a customer who can place orders.
- **Kiosk**: Represents a physical kiosk device installed in a store.

### Supporting Entities

- **Image**: Represents image assets used throughout the application.
- **LayoutNavigation**: Defines the navigation structure for the application layout.
- **PaymentGateway**: Interfaces with payment processing services.
- **Cart**: Represents the shopping cart, managing items added by customers.
- **Category**: Represents product categories for organization.
- **Brand**: Represents product brands.
- **Tag**: Represents tags that can be applied to products.

## Implementation Details

### Model File Structure

Each model file typically follows this structure:

```ruby
class ModelName < ApplicationRecord
  # Associations
  belongs_to :parent_model
  has_many :child_models
  
  # Validations
  validates :required_field, presence: true
  
  # Scopes
  scope :active, -> { where(active: true) }
  
  # Callbacks
  before_save :normalize_data
  
  # Instance methods
  def some_business_logic
    # Implementation
  end
  
  private
  
  # Private methods
  def normalize_data
    # Implementation
  end
end
```

### Common Patterns

#### Multi-tenant Scoping

Models that belong to a specific store implement tenant isolation through scoping:

```ruby
class StoreProduct < ApplicationRecord
  belongs_to :store
  belongs_to :product
  
  # Ensure queries are scoped to the current store
  default_scope { where(store_id: Store.current_id) if Store.current_id }
  
  # Validation to ensure products stay within their tenant
  validates :store_id, presence: true
end
```

#### Soft Deletion

Many models implement soft deletion to preserve data integrity while allowing "deletion" from the user perspective:

```ruby
class Product < ApplicationRecord
  # Add a deleted_at timestamp
  scope :active, -> { where(deleted_at: nil) }
  
  def soft_delete
    update(deleted_at: Time.current)
  end
  
  def restore
    update(deleted_at: nil)
  end
end
```

#### Versioning

Important models use the paper_trail gem for versioning and audit trails:

```ruby
class Order < ApplicationRecord
  has_paper_trail
  
  # Rest of the model
end
```

#### Serialization

Models that need to store complex data in a single column use serialization:

```ruby
class StoreSettings < ApplicationRecord
  serialize :preferences, JSON
  
  # Rest of the model
end
```

## Relationships with Other Components

### Controllers

Controllers interact with models to fetch and manipulate data:

```ruby
class ProductsController < ApplicationController
  def index
    @products = Product.active.includes(:category, :brand)
    # ...
  end
end
```

### Serializers

Serializers format model data for API responses:

```ruby
class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price
  
  belongs_to :category
  belongs_to :brand
end
```

### Operations

Service objects use models to implement complex business operations:

```ruby
class CreateOrder
  def call(params)
    order = Order.new(params)
    # Complex business logic
    order.save
    order
  end
end
```

## Common Patterns and Best Practices

### Model Organization

- **Keep Models Focused**: Each model should represent a single business entity.
- **Extract Concerns**: Shared behavior should be extracted into concerns.
- **Use Scopes for Common Queries**: Define scopes for frequently used queries.
- **Validate at the Model Level**: Implement validations within models to enforce data integrity.

### Naming Conventions

- **Singular Model Names**: Model classes and files use singular names (e.g., `Product`, not `Products`).
- **Descriptive Association Names**: Association names should clearly describe the relationship.
- **Consistent Method Naming**: Use consistent naming for similar methods across models.

## Known Issues and Limitations

- Some models may have too many responsibilities, violating the single responsibility principle.
- Business logic may be spread across models, controllers, and operations, making it harder to follow.
- Some older models may not follow current best practices for multi-tenant scoping.

## Technical Debt

- Refactor large models to extract functionality into concerns or service objects.
- Ensure consistent multi-tenant scoping across all models.
- Improve test coverage for model methods and validations.
- Document complex business logic within models.

## Examples

### Store Model

```ruby
class Store < ApplicationRecord
  # Associations
  has_many :store_products, dependent: :destroy
  has_many :products, through: :store_products
  has_many :orders
  has_many :customers
  has_many :kiosks
  
  # Validations
  validates :name, presence: true
  validates :timezone, presence: true
  
  # Scopes
  scope :active, -> { where(active: true) }
  
  # Class methods
  def self.current_id
    RequestStore.store[:current_store_id]
  end
  
  def self.current
    find_by(id: current_id) if current_id
  end
  
  # Instance methods
  def sync_with_pos
    # Implementation
  end
end
```

### Product Model

```ruby
class Product < ApplicationRecord
  # Associations
  has_many :store_products, dependent: :destroy
  has_many :stores, through: :store_products
  belongs_to :category, optional: true
  belongs_to :brand, optional: true
  
  # Validations
  validates :name, presence: true
  
  # Scopes
  scope :active, -> { where(deleted_at: nil) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  
  # Instance methods
  def available_in_store?(store_id)
    store_products.where(store_id: store_id).exists?
  end
end
```

## AI Agent Notes

- **DatabaseSpecialistAgent**: When optimizing database queries, pay attention to the associations and scopes defined in models. Consider adding indexes for frequently queried columns and using eager loading to avoid N+1 query problems.
- **SystemArchitectAgent**: When designing new features, consider how they fit into the existing model structure and follow the established patterns for multi-tenant scoping and soft deletion.
- **Next documents**: Consider reviewing [functional/data_management/core_models.md] for information on the core business entities and their relationships, and [functional/data_management/entity_relationships.md] for a visual representation of the entity relationships.

## References

- [ActiveRecord Basics](https://guides.rubyonrails.org/active_record_basics.html)
- [ActiveRecord Associations](https://guides.rubyonrails.org/association_basics.html)
- [ActiveRecord Validations](https://guides.rubyonrails.org/active_record_validations.html)
- [Multi-tenant Strategies in Rails](https://engineering.shopify.com/blogs/engineering/building-a-multitenant-application-in-rails) 