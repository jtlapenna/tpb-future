# Testing Implementation Documentation

## Overview
The Peak Beyond's backend system implements comprehensive testing across multiple layers, including unit tests, integration tests, and policy tests. This document details the testing implementation and patterns.

## Test Structure

### Unit Tests
Located in `spec/models/`, `spec/lib/`, and `spec/parsers/`

1. Model Tests
   - Validation rules
   - Callbacks
   - Scopes
   - Relationships
   - Business logic

2. Library Tests
   - API client implementations
   - Service integrations
   - Error handling
   - Data transformations

3. Parser Tests
   - Data parsing logic
   - Format validation
   - Error handling
   - Edge cases

### Integration Tests
Located in `spec/controllers/` and `spec/requests/`

1. Controller Tests
   - Request handling
   - Response formatting
   - Error scenarios
   - Authorization checks

2. API Integration Tests
   - POS system integration
   - External service communication
   - Webhook handling
   - Real-time updates

### Policy Tests
Located in `spec/policies/`

1. Authorization Rules
   - Permission checks
   - Role-based access
   - Resource ownership
   - Scope restrictions

## Test Patterns

### Factory Patterns
```ruby
# Example factory definitions
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

### Mock Patterns
```ruby
# Example API client mocking
let(:api_mock) { double(:treez_api_client) }
before do
  allow(Treez::ApiClient).to receive(:new)
    .with(store.treez_api_config)
    .and_return(api_mock)
end
```

### Shared Examples
```ruby
# Example shared behavior
RSpec.shared_examples "create order integration" do
  it "creates order successfully" do
    expect { post :create, params: params }
      .to change { CustomerOrder.count }.by(1)
  end
end
```

## Test Categories

### POS Integration Tests

1. Treez Integration
   - Order creation/updates
   - Customer management
   - Product synchronization
   - Error handling

2. Leaflogix Integration
   - Order processing
   - Customer data
   - Inventory sync
   - API communication

3. Flowhub Integration
   - Order management
   - Customer operations
   - Product data
   - Error scenarios

### API Endpoint Tests

1. Store Management
   - CRUD operations
   - Settings configuration
   - Category management
   - Tax handling

2. Product Management
   - Product creation/updates
   - Variant handling
   - Category association
   - Price management

3. Customer Management
   - Customer operations
   - Order processing
   - Profile management
   - Authentication

### Model Tests

1. Store Models
   - Validation rules
   - Relationship integrity
   - Callback behavior
   - Scope functionality

2. Product Models
   - Variant handling
   - Category association
   - Price calculations
   - Stock management

3. Order Models
   - Order creation
   - Item validation
   - Total calculations
   - Status transitions

## Test Coverage

### Core Components
- Models: ~95% coverage
- Controllers: ~90% coverage
- Services: ~85% coverage
- Policies: ~80% coverage

### Integration Points
- POS Systems: ~90% coverage
- External Services: ~85% coverage
- Webhooks: ~80% coverage
- Real-time Features: ~75% coverage

## Testing Tools

1. RSpec
   - Test framework
   - Behavior-driven development
   - Expectation syntax
   - Test organization

2. FactoryBot
   - Test data generation
   - Association handling
   - Trait definitions
   - Sequence management

3. WebMock
   - HTTP request stubbing
   - Response mocking
   - Request verification
   - Network isolation

4. VCR
   - HTTP interaction recording
   - Playback functionality
   - Cassette management
   - Real API testing

## Best Practices

1. Test Organization
   - Group related tests
   - Use descriptive contexts
   - Follow arrange-act-assert
   - Keep tests focused

2. Test Data
   - Use factories
   - Avoid database hits
   - Clean up after tests
   - Use realistic data

3. Mocking/Stubbing
   - Mock external services
   - Stub complex operations
   - Verify interactions
   - Handle edge cases

4. Performance
   - Use database cleaner
   - Minimize database hits
   - Use appropriate scope
   - Clean test data

## Common Patterns

### Request Specs
```ruby
RSpec.describe "API V1 Products", type: :request do
  describe "GET /api/v1/products" do
    it "returns list of products" do
      get "/api/v1/products"
      expect(response).to have_http_status(200)
      expect(json_response[:data]).to be_an(Array)
    end
  end
end
```

### Controller Specs
```ruby
RSpec.describe ProductsController, type: :controller do
  describe "POST #create" do
    it "creates a new product" do
      expect {
        post :create, params: valid_attributes
      }.to change(Product, :count).by(1)
    end
  end
end
```

### Model Specs
```ruby
RSpec.describe Product, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should belong_to(:store) }
    it { should have_many(:variants) }
  end
end
```

## Test Environment

### Configuration
```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include RequestSpecHelper, type: :request
end
```

### Database Cleaner
```ruby
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
end
```

## Continuous Integration

### CircleCI Configuration
```yaml
test:
  steps:
    - checkout
    - run: bundle exec rspec
    - store_test_results:
        path: /tmp/test-results
```

## Maintenance

1. Regular Tasks
   - Update test data
   - Review coverage
   - Clean up tests
   - Update mocks

2. Best Practices
   - Keep tests current
   - Remove obsolete tests
   - Update documentation
   - Monitor performance 