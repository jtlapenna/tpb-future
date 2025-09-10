# Model Relationships

## Core Models

### Store
- **Has Many**:
  - `store_products`
  - `kiosks`
  - `customers`
  - `store_settings`
  - `store_taxes`
  - `store_categories`
  - `payment_gateways`
  - `store_articles`
  - `customer_orders`
  - `store_syncs`
- **Has One**:
  - `api_settings`
  - `notification_settings`
- **Belongs To**:
  - `client`

### Product
- **Has Many**:
  - `product_variants`
  - `product_values`
  - `reviews`
  - `images`
  - `store_products`
- **Has Many Through**:
  - `categories` through `product_categories`
  - `brands` through `product_brands`
- **Has One**:
  - `product_layout`

### Customer
- **Has Many**:
  - `customer_orders`
  - `favorites`
  - `reviews`
- **Belongs To**:
  - `store`
- **Has One**:
  - `customer_sync`

### Kiosk
- **Has Many**:
  - `kiosk_products`
  - `kiosk_assets`
  - `welcome_assets`
  - `ad_banners`
- **Belongs To**:
  - `store`
  - `kiosk_layout`

## Product-Related Models

### StoreProduct
- **Belongs To**:
  - `store`
  - `product`
  - `product_variant`
- **Has Many**:
  - `kiosk_products`
  - `store_product_promotions`
  - `customer_order_store_products`
  - `cart_items`

### ProductVariant
- **Belongs To**:
  - `product`
- **Has Many**:
  - `store_products`
  - `product_values`
  - `images`

### ProductLayout
- **Has Many**:
  - `product_layout_tabs`
  - `product_layout_elements`
  - `product_layout_values`
- **Belongs To**:
  - `product`

## Store Configuration Models

### StoreSetting
- **Belongs To**:
  - `store`
- **Has Many**:
  - `store_taxes`
  - `store_categories`

### StoreCategory
- **Belongs To**:
  - `store`
- **Has Many**:
  - `store_category_taxes`
  - `store_category_kiosk_layouts`
  - `store_products`

### PaymentGateway
- **Belongs To**:
  - `store`
  - `payment_gateway_provider`

## Layout and Display Models

### KioskLayout
- **Has Many**:
  - `kiosks`
  - `layout_positions`
  - `layout_navigations`
  - `store_category_kiosk_layouts`

### LayoutNavigation
- **Has Many**:
  - `layout_navigation_items`
- **Belongs To**:
  - `kiosk_layout`

### AdConfig
- **Has Many**:
  - `ad_banners`
  - `ad_banner_locations`
- **Belongs To**:
  - `store`

## Order Management Models

### CustomerOrder
- **Belongs To**:
  - `customer`
  - `store`
- **Has Many**:
  - `customer_order_store_products`
- **Has One**:
  - `order_customer`

### Cart
- **Has Many**:
  - `cart_items`
- **Belongs To**:
  - `customer`
  - `store`

## Content Models

### Article
- **Has Many**:
  - `store_articles`
  - `images`
- **Has Many Through**:
  - `products` through `article_products`

### Asset
- **Has Many**:
  - `asset_elements`
  - `kiosk_assets`
  - `welcome_assets`
- **Polymorphic**:
  - `assetable`

## Validation and Rules

### Common Validations
- Presence validations on required associations
- Uniqueness constraints where appropriate
- Scoped validations within store context
- Format validations for specific fields

### Key Callbacks
- Product indexing with Algolia
- Cache invalidation
- Synchronization triggers
- Status updates

### Important Scopes
- Active/inactive filtering
- Store-specific queries
- Date-based filtering
- Status-based queries

## Performance Considerations

### Indexes
- Foreign key indexes
- Composite indexes for common queries
- Full-text search indexes
- Unique constraints

### Eager Loading
- Product associations
- Store configurations
- Order details
- Layout components

### Caching Strategy
- Counter cache columns
- Association caching
- Query result caching
- Fragment caching

## Best Practices

1. Association Management
   - Use dependent destroy where appropriate
   - Implement soft deletes for important records
   - Maintain referential integrity
   - Use transaction blocks for complex operations

2. Query Optimization
   - Use eager loading to avoid N+1 queries
   - Implement counter caches for counts
   - Use scopes for common queries
   - Index frequently queried columns

3. Data Integrity
   - Implement model-level validations
   - Use database constraints
   - Maintain data consistency
   - Handle edge cases

4. Maintenance
   - Regular index optimization
   - Periodic cache clearing
   - Database cleanup tasks
   - Performance monitoring 