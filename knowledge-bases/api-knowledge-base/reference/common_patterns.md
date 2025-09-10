# Common Patterns and Best Practices

## Overview
This document outlines the common patterns and best practices used throughout The Peak Beyond's backend system. These patterns ensure consistency, maintainability, and reliability across the codebase.

## Architectural Patterns

### Layered Architecture
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
│                      Database Layer                          │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities
1. **Controller Layer**: HTTP request handling, authentication, authorization
2. **Service Layer**: Business logic, operation orchestration
3. **Model Layer**: Business entities, data validation, relationships
4. **Database Layer**: Data persistence and retrieval

## Design Patterns

### Adapter Pattern
Used for integrating with different POS systems:

```ruby
module PosAdapter
  def fetch_products(options = {})
    raise NotImplementedError
  end
  
  def fetch_inventory(options = {})
    raise NotImplementedError
  end
  
  def submit_order(order, options = {})
    raise NotImplementedError
  end
  
  def fetch_order_status(order_id, options = {})
    raise NotImplementedError
  end
end
```

### Service Object Pattern
For encapsulating complex business logic:

```ruby
class CreateOrder
  include Dry::Monads[:result]
  
  def call(params)
    order = Order.new(params)
    
    if order.save
      notify_pos_system(order)
      send_confirmation_email(order)
      Success(order)
    else
      Failure(order.errors)
    end
  end
end
```

### Circuit Breaker Pattern
For handling external service failures:

```typescript
class CircuitBreaker {
  private failureThreshold: number;
  private resetTimeout: number;
  private state: CircuitState;

  async execute<T>(command: () => Promise<T>): Promise<T> {
    if (this.isOpen()) {
      throw new CircuitOpenError();
    }
    try {
      const result = await command();
      this.recordSuccess();
      return result;
    } catch (error) {
      this.recordFailure();
      throw error;
    }
  }
}
```

## Integration Patterns

### Synchronization Patterns

#### Full Sync
For complete data synchronization:
- Initial data population
- After major system changes
- Weekly reconciliation

#### Incremental Sync
For efficient updates:
- Regular scheduled updates
- Real-time inventory updates
- High-frequency synchronization

#### Event-Based Sync
For real-time updates:
- Webhook-based updates
- Real-time inventory changes
- Order status updates

### Error Handling Pattern
Consistent error response format:

```json
{
  "errors": [
    {
      "status": "422",
      "code": "validation_error",
      "title": "Validation Error",
      "detail": "Name can't be blank",
      "source": {
        "pointer": "/data/attributes/name"
      }
    }
  ]
}
```

## Testing Patterns

### Factory Pattern
For test data creation:

```ruby
FactoryBot.define do
  factory :store do
    name { "Test Store" }
    api_key { "test_key" }
    
    trait :with_products do
      after(:create) do |store|
        create_list(:store_product, 3, store: store)
      end
    end
  end
end
```

### Mock Pattern
For external service testing:

```ruby
let(:api_mock) { double(:treez_api_client) }
before do
  allow(Treez::ApiClient).to receive(:new)
    .with(store.treez_api_config)
    .and_return(api_mock)
end
```

## Security Patterns

### Multi-tenant Pattern
For data isolation:

```ruby
module Tenantable
  extend ActiveSupport::Concern
  
  included do
    belongs_to :store
    validates :store_id, presence: true
    default_scope { where(store_id: Store.current_id) if Store.current_id }
  end
end
```

### Authentication Pattern
For API security:

```ruby
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

## Best Practices

### API Design
1. Use resource-based URLs
2. Use standard HTTP methods
3. Return appropriate status codes
4. Provide consistent response formats
5. Version your APIs

### Code Organization
1. Keep models focused on single responsibilities
2. Extract shared behavior into concerns
3. Use service objects for complex operations
4. Implement consistent error handling
5. Follow naming conventions

### Testing
1. Write comprehensive unit tests
2. Include integration tests for critical paths
3. Test error scenarios
4. Mock external dependencies
5. Use factories for test data

### Security
1. Use HTTPS for all endpoints
2. Implement proper authentication
3. Validate all input
4. Implement rate limiting
5. Follow security best practices

## Known Issues and Limitations
- Some older code may not follow current patterns
- Inconsistent use of service objects
- Room for improvement in error handling
- Technical debt in background job processing

## Version History
- Initial creation: [Current Date]
- Added integration patterns section
- Added security patterns section
- Added best practices section 