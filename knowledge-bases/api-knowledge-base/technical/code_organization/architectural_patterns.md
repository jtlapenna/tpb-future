---
title: "Architectural Patterns"
description: "Overview of the architectural patterns used in The Peak Beyond's backend system"
last_updated: "2023-07-11"
contributors: ["AI Analysis Team"]
related_files: [
  "technical/code_organization/directory_structure.md",
  "system/overview/system_architecture.md",
  "functional/api_endpoints/api_overview.md"
]
tags: ["technical", "architecture", "patterns", "design"]
ai_agent_relevance: [
  "SystemArchitectAgent", 
  "APISpecialistAgent"
]
---

# Architectural Patterns

## Overview

The Peak Beyond's backend system employs a variety of architectural patterns to ensure maintainability, scalability, and separation of concerns. This document outlines the key architectural patterns used throughout the codebase, providing developers with an understanding of the system's design principles and implementation approaches.

## Key Concepts

- **Layered Architecture**: The system is organized into distinct layers with clear responsibilities.
- **RESTful API Design**: APIs follow REST principles for resource-oriented interactions.
- **Service Objects**: Complex business logic is encapsulated in dedicated service objects.
- **Multi-tenant Architecture**: The system supports multiple tenants (stores) with data isolation.
- **Policy-based Authorization**: Access control is implemented using policy objects.
- **Serializer Pattern**: Data transformation for API responses is handled by serializers.

## Layered Architecture

The system follows a layered architecture that separates concerns and promotes maintainability:

```
┌─────────────────────────────────────────────────────────────┐
│                      Client Applications                     │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                         API Gateway                          │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      Controller Layer                        │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                       Service Layer                          │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                        Model Layer                           │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      Database Layer                          │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

1. **Controller Layer**: Handles HTTP requests, performs authentication and authorization, and delegates to the service layer.
2. **Service Layer**: Implements business logic, orchestrates operations, and interacts with the model layer.
3. **Model Layer**: Represents business entities, implements data validation, and defines relationships.
4. **Database Layer**: Manages data persistence and retrieval.

### Implementation

Each layer is implemented using specific components:

- **Controller Layer**: Rails controllers in `app/controllers/`
- **Service Layer**: Service objects in `app/operations/` and `app/lib/`
- **Model Layer**: ActiveRecord models in `app/models/`
- **Database Layer**: PostgreSQL database with migrations in `db/migrate/`

## RESTful API Design

The API follows RESTful design principles, organizing endpoints around resources and using standard HTTP methods for operations.

### Resource-Oriented Endpoints

```
/stores                 # Collection of stores
/stores/:id             # Specific store
/stores/:id/products    # Collection of products for a store
/stores/:id/products/:id # Specific product for a store
```

### HTTP Methods

- **GET**: Retrieve resources
- **POST**: Create resources
- **PUT/PATCH**: Update resources
- **DELETE**: Remove resources

### Status Codes

- **2xx**: Success (200 OK, 201 Created, 204 No Content)
- **4xx**: Client errors (400 Bad Request, 401 Unauthorized, 404 Not Found)
- **5xx**: Server errors (500 Internal Server Error, 503 Service Unavailable)

### Implementation

```ruby
# Example of a RESTful controller
class ProductsController < ApplicationController
  def index
    @products = policy_scope(Product).page(params[:page]).per(params[:per_page])
    render json: @products
  end
  
  def show
    authorize @product
    render json: @product
  end
  
  def create
    @product = Product.new(product_params)
    authorize @product
    
    if @product.save
      render json: @product, status: :created
    else
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  end
  
  def update
    authorize @product
    
    if @product.update(product_params)
      render json: @product
    else
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  end
  
  def destroy
    authorize @product
    @product.destroy
    head :no_content
  end
end
```

## Service Object Pattern

Complex business logic is encapsulated in service objects, following the single responsibility principle.

### Implementation

Service objects are implemented in the `app/operations/` directory and follow a consistent pattern:

```ruby
# Example of a service object
class CreateOrder
  include Dry::Monads[:result]
  
  def call(params)
    order = Order.new(params)
    
    if order.save
      # Additional business logic
      notify_pos_system(order)
      send_confirmation_email(order)
      Success(order)
    else
      Failure(order.errors)
    end
  end
  
  private
  
  def notify_pos_system(order)
    # Implementation
  end
  
  def send_confirmation_email(order)
    # Implementation
  end
end
```

### Usage in Controllers

Service objects are used in controllers to handle complex operations:

```ruby
# Example of using a service object in a controller
def create
  result = CreateOrder.new.call(order_params)
  
  if result.success?
    render json: result.value!, status: :created
  else
    render json: { errors: result.failure }, status: :unprocessable_entity
  end
end
```

## Multi-tenant Architecture

The system implements a multi-tenant architecture where each store (dispensary) has its own isolated data.

### Tenant Isolation

Tenant isolation is implemented through store-based scoping in models:

```ruby
# Example of tenant isolation in a model
class StoreProduct < ApplicationRecord
  belongs_to :store
  belongs_to :product
  
  # Ensure queries are scoped to the current store
  default_scope { where(store_id: Store.current_id) if Store.current_id }
  
  # Validation to ensure products stay within their tenant
  validates :store_id, presence: true
end
```

### Tenant Context

The tenant context is maintained throughout the request lifecycle:

```ruby
# Example of setting tenant context in a controller
class ApplicationController < ActionController::Base
  before_action :set_store
  
  private
  
  def set_store
    store_id = params[:store_id] || request.headers['X-Store-ID']
    Store.current_id = store_id if store_id.present?
  end
end
```

## Policy-based Authorization

Authorization is implemented using Pundit policies, defining who can perform which actions on which resources.

### Policy Implementation

```ruby
# Example of a Pundit policy
class StorePolicy < ApplicationPolicy
  def index?
    user.admin? || user.store_manager?
  end
  
  def show?
    user.admin? || user.store_manager? || record.users.include?(user)
  end
  
  def create?
    user.admin?
  end
  
  def update?
    user.admin? || (user.store_manager? && record.users.include?(user))
  end
  
  def destroy?
    user.admin?
  end
end
```

### Usage in Controllers

Policies are used in controllers to authorize actions:

```ruby
# Example of using policies in a controller
def show
  @store = Store.find(params[:id])
  authorize @store
  render json: @store
end
```

## Serializer Pattern

Data transformation for API responses is handled by serializers, ensuring consistent response formats.

### Serializer Implementation

```ruby
# Example of a serializer
class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :created_at, :updated_at
  
  belongs_to :brand
  has_many :variants
  
  attribute :image_url do
    object.image.url if object.image.present?
  end
  
  attribute :in_stock do
    object.inventory > 0
  end
end
```

### Response Format

Serializers produce consistent JSON responses:

```json
{
  "data": {
    "id": 1,
    "type": "product",
    "attributes": {
      "name": "Example Product",
      "description": "This is an example product",
      "price": 19.99,
      "created_at": "2023-01-01T00:00:00Z",
      "updated_at": "2023-01-02T00:00:00Z",
      "image_url": "https://example.com/images/product.jpg",
      "in_stock": true
    },
    "relationships": {
      "brand": {
        "data": {
          "id": 2,
          "type": "brand"
        }
      },
      "variants": {
        "data": [
          {
            "id": 3,
            "type": "variant"
          }
        ]
      }
    }
  }
}
```

## API Versioning

The API uses URL-based versioning to ensure backward compatibility:

```
/api/v1/products        # Version 1 of the products API
```

This approach allows for introducing breaking changes in new versions while maintaining support for existing clients.

## Authentication Patterns

The system implements multiple authentication patterns for different client types:

### JWT Authentication

Used for administrative API access:

```ruby
# Example of JWT authentication
class AdminController < ApplicationController
  before_action :authenticate_user
  
  private
  
  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    payload = JWT.decode(token, Rails.application.secrets.secret_key_base)
    @current_user = User.find(payload['sub'])
  rescue JWT::DecodeError
    render json: { error: 'Invalid token' }, status: :unauthorized
  end
end
```

### API Token Authentication

Used for public API access:

```ruby
# Example of API token authentication
class ApiController < ApplicationController
  before_action :authenticate_store
  
  private
  
  def authenticate_store
    token = request.headers['Authorization']&.split('token=')&.last
    @current_store = Store.find_by(api_token: token)
    
    unless @current_store
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
end
```

## Background Processing Pattern

Asynchronous tasks are handled using background jobs with Sidekiq:

```ruby
# Example of a background job
class SyncProductsJob < ApplicationJob
  queue_as :default
  
  def perform(store_id)
    store = Store.find(store_id)
    # Synchronization logic
  end
end
```

## Common Patterns and Best Practices

### Controller Concerns

Shared controller logic is extracted into concerns:

```ruby
# Example of a controller concern
module Paginatable
  extend ActiveSupport::Concern
  
  included do
    def paginate(collection)
      collection.page(params[:page] || 1).per(params[:per_page] || 20)
    end
  end
end
```

### Model Concerns

Shared model logic is extracted into concerns:

```ruby
# Example of a model concern
module Tenantable
  extend ActiveSupport::Concern
  
  included do
    belongs_to :store
    validates :store_id, presence: true
    default_scope { where(store_id: Store.current_id) if Store.current_id }
  end
end
```

### Error Handling

Consistent error handling is implemented across the application:

```ruby
# Example of error handling
rescue_from ActiveRecord::RecordNotFound do |e|
  render json: { error: 'Resource not found' }, status: :not_found
end

rescue_from Pundit::NotAuthorizedError do |e|
  render json: { error: 'Not authorized' }, status: :forbidden
end
```

## Known Issues and Limitations

- Some older parts of the codebase may not follow the current architectural patterns
- The service object pattern is not consistently applied across all business logic
- Background job error handling could be improved

## Technical Debt

- Refactor controllers to consistently use service objects
- Improve error handling in background jobs
- Standardize API response formats across all endpoints

## AI Agent Notes

- **SystemArchitectAgent**: When designing new features, follow the established architectural patterns, particularly the layered architecture and service object pattern. Consider the multi-tenant architecture when implementing data access.
- **APISpecialistAgent**: When working with APIs, follow the RESTful design principles and use serializers for consistent response formats. Be aware of the versioning strategy when making changes to existing endpoints.
- **Next documents**: Consider reviewing [system/overview/system_architecture.md] for a high-level overview of the system architecture, and [functional/api_endpoints/api_overview.md] for details on the API endpoints.

## References

- [Ruby on Rails Architecture](https://guides.rubyonrails.org/getting_started.html)
- [RESTful API Design](https://restfulapi.net/)
- [Service Objects in Rails](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)
- [Pundit Authorization](https://github.com/varvet/pundit)
- [Active Model Serializers](https://github.com/rails-api/active_model_serializers) 