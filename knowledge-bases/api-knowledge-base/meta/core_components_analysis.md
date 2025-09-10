# Core Components Analysis

## API Controllers (V1)

### Primary Resource Controllers

1. **Products Controller** (`products_controller.rb`)
   - Largest controller (311 lines)
   - Core product management functionality
   - Product listing and details
   - Product search and filtering
   - Product variants and attributes

2. **Orders Controller** (`orders_controller.rb`)
   - Order management (191 lines)
   - Order creation and processing
   - Order status updates
   - Order history and details

3. **Carts Controller** (`carts_controller.rb`)
   - Shopping cart functionality (258 lines)
   - Cart item management
   - Cart validation
   - Cart checkout process

4. **Catalogs Controller** (`catalogs_controller.rb`)
   - Product catalog management (122 lines)
   - Catalog organization
   - Category management
   - Product grouping

### Customer Management

1. **Customers Controller** (`customers_controller.rb`)
   - Customer profile management
   - Customer lookup
   - Customer preferences

2. **Customer Order Controller** (`customer_order_controller.rb`)
   - Customer-specific order handling
   - Order history by customer
   - Customer order preferences

### Content Management

1. **Ad Banners Controller** (`ad_banners_controller.rb`)
   - Advertisement management
   - Banner placement
   - Banner content

2. **Ad Banner Locations Controller** (`ad_banner_locations_controller.rb`)
   - Banner location management
   - Position configuration
   - Display rules

3. **Catalog Articles Controller** (`catalog_articles_controller.rb`)
   - Article management
   - Content organization
   - Article categorization

### Organization Controllers

1. **Stores Controller** (`stores_controller.rb`)
   - Store management
   - Store configuration
   - Store settings

2. **Brands Controller** (`brands_controller.rb`)
   - Brand management
   - Brand associations
   - Brand metadata

3. **Categories Controller** (`categories_controller.rb`)
   - Category organization
   - Category hierarchy
   - Product categorization

### Base Components

1. **Application Controller** (`application_controller.rb`)
   - Base controller functionality
   - Authentication handling
   - Error handling
   - Common utilities

## Controller Patterns

### Authentication and Authorization
- JWT-based authentication
- Role-based access control
- Store-specific authorization

### Response Formatting
- JSON API compliance
- Consistent error formats
- Pagination support

### Data Validation
- Strong parameters
- Input sanitization
- Business rule validation

### Error Handling
- Standardized error responses
- Exception handling
- Error logging

## Integration Points

### POS Systems
- Order submission
- Inventory sync
- Customer lookup

### External Services
- Payment processing
- Notification delivery
- Data synchronization

## Background Processing

### Order Processing
- Async order submission
- Status updates
- Notification dispatch

### Data Synchronization
- Product updates
- Inventory levels
- Price changes

## Next Steps for Analysis

1. **Service Integrations**
   - Document POS system integrations
   - Map external service connections
   - Analyze authentication flows

2. **Background Jobs**
   - Map job structure
   - Document job scheduling
   - Analyze job dependencies

3. **Serializers**
   - Document response formats
   - Map object relationships
   - Analyze data transformation

*Last Updated: March 20, 2024* 