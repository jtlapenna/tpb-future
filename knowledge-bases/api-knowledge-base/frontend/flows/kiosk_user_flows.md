---
title: Kiosk UI User Flows
description: Documentation of key user flows in The Peak Beyond's kiosk UI
last_updated: 2023-08-01
contributors: [AI Assistant]
---

# Kiosk UI User Flows

## Overview

This document outlines the key user flows in The Peak Beyond's kiosk UI, which is the customer-facing touchscreen interface used in cannabis dispensaries. These flows represent the primary ways customers interact with the kiosk to browse products, learn about them, and place orders.

*Note: This document is based on system documentation and will be refined once we have access to the frontend codebase.*

## Primary User Flows

### 1. Product Browsing Flow

The product browsing flow allows customers to explore the dispensary's product catalog.

#### Steps

1. **Start at Home Screen**
   - Components: HomeComponent, WelcomeComponent
   - State: Initial application state
   - API Calls: None (data preloaded)

2. **Navigate to Category**
   - Components: CategoryNavigationComponent, CategoryListComponent
   - State: Selected category updated
   - API Calls: `/api/v1/:catalog_id/store_categories`

3. **View Product List**
   - Components: ProductListComponent, ProductCardComponent
   - State: Product list loaded
   - API Calls: `/api/v1/:catalog_id/store_products?category_id=:category_id`

4. **Filter Products**
   - Components: FilterComponent, ProductListComponent
   - State: Filter criteria updated, filtered product list
   - API Calls: `/api/v1/:catalog_id/store_products?filters=:filters`

5. **Sort Products**
   - Components: SortComponent, ProductListComponent
   - State: Sort criteria updated, sorted product list
   - API Calls: None (client-side sorting)

#### Edge Cases

| Edge Case | Handling |
|-----------|----------|
| No products in category | Display "No products found" message with recommendations |
| Slow network connection | Show loading skeleton, load data progressively |
| Filter returns no results | Show "No matching products" with option to clear filters |

#### Error States

| Error | Handling |
|-------|----------|
| API error | Show error message with retry option |
| Session timeout | Redirect to welcome screen |

### 2. Product Detail Flow

The product detail flow allows customers to view detailed information about a specific product.

#### Steps

1. **Select Product from List**
   - Components: ProductCardComponent, ProductListComponent
   - State: Selected product updated
   - API Calls: None (navigation)

2. **View Product Details**
   - Components: ProductDetailComponent, ProductGalleryComponent, ProductAttributesComponent
   - State: Product details loaded
   - API Calls: `/api/v1/:catalog_id/store_products/:id`

3. **View Related Products**
   - Components: RelatedProductsComponent, ProductCardComponent
   - State: Related products loaded
   - API Calls: `/api/v1/:catalog_id/store_products/:id/related`

4. **Add to Cart**
   - Components: ProductDetailComponent, AddToCartComponent
   - State: Cart updated
   - API Calls: None (client-side cart management)

#### Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Product out of stock | Disable "Add to Cart" button, show "Out of Stock" message |
| Product requires age verification | Show age verification modal before displaying details |
| Product has variants | Show variant selector with price differences |

#### Error States

| Error | Handling |
|-------|----------|
| Product not found | Show error message with return to catalog option |
| Failed to load details | Show partial information with retry option |

### 3. NFC/RFID Interaction Flow

The NFC/RFID interaction flow allows customers to interact with physical products using NFC or RFID technology.

#### Steps

1. **Place Product on Kiosk**
   - Components: NfcReaderComponent, RfidReaderComponent
   - State: Reading NFC/RFID
   - API Calls: None (hardware interaction)

2. **Identify Product**
   - Components: NfcReaderComponent, LoadingComponent
   - State: Product ID detected
   - API Calls: `/api/v1/:catalog_id/rfid_products/:rfid`

3. **Display Product Details**
   - Components: ProductDetailComponent, ProductAnimationComponent
   - State: Product details loaded, animation playing
   - API Calls: `/api/v1/:catalog_id/store_products/:id`

4. **Add to Cart**
   - Components: ProductDetailComponent, AddToCartComponent
   - State: Cart updated
   - API Calls: None (client-side cart management)

#### Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Unrecognized NFC/RFID | Show "Product not recognized" message |
| Multiple NFC/RFID detected | Show disambiguation screen to select product |
| NFC/RFID read error | Show "Please try again" message |

#### Error States

| Error | Handling |
|-------|----------|
| Hardware error | Show "NFC/RFID reader not available" message |
| Product not in system | Show "Product information not available" message |

### 4. Cart and Checkout Flow

The cart and checkout flow allows customers to review their selections and place an order.

#### Steps

1. **View Cart**
   - Components: CartComponent, CartItemComponent
   - State: Cart items displayed
   - API Calls: None (client-side cart management)

2. **Update Quantities**
   - Components: CartItemComponent, QuantitySelectorComponent
   - State: Cart quantities updated
   - API Calls: None (client-side cart management)

3. **Remove Items**
   - Components: CartItemComponent, RemoveItemComponent
   - State: Cart items updated
   - API Calls: None (client-side cart management)

4. **Proceed to Checkout**
   - Components: CartComponent, CheckoutButtonComponent
   - State: Navigating to checkout
   - API Calls: None (navigation)

5. **Enter Customer Information**
   - Components: CheckoutComponent, CustomerFormComponent
   - State: Customer information entered
   - API Calls: None (form handling)

6. **Submit Order**
   - Components: CheckoutComponent, OrderSummaryComponent
   - State: Order submitted, confirmation displayed
   - API Calls: `/api/v1/:catalog_id/orders`

#### Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Empty cart | Disable checkout button, show "Your cart is empty" message |
| Item becomes unavailable | Show warning, allow removal or continuation |
| Order exceeds limits | Show warning with option to adjust quantities |

#### Error States

| Error | Handling |
|-------|----------|
| Order submission failure | Show error with retry option |
| Validation errors | Highlight fields with errors, show guidance |
| Payment processing error | Show error with alternative payment options |

### 5. Search Flow

The search flow allows customers to find specific products quickly.

#### Steps

1. **Open Search**
   - Components: HeaderComponent, SearchButtonComponent
   - State: Search modal opened
   - API Calls: None (UI interaction)

2. **Enter Search Query**
   - Components: SearchComponent, SearchInputComponent
   - State: Search query entered
   - API Calls: None (input handling)

3. **View Search Results**
   - Components: SearchResultsComponent, ProductCardComponent
   - State: Search results loaded
   - API Calls: `/api/v1/:catalog_id/store_products/search?q=:query`

4. **Select Product**
   - Components: SearchResultsComponent, ProductCardComponent
   - State: Selected product updated
   - API Calls: None (navigation)

#### Edge Cases

| Edge Case | Handling |
|-----------|----------|
| No search results | Show "No products found" with suggestions |
| Minimum search length | Require minimum 3 characters before searching |
| Too many results | Paginate results or suggest refining search |

#### Error States

| Error | Handling |
|-------|----------|
| Search API error | Show error with retry option |
| Timeout | Show partial results with option to continue waiting |

## Secondary User Flows

### 1. Educational Content Flow

The educational content flow allows customers to learn about cannabis products and their effects.

#### Steps

1. **Navigate to Education Section**
   - Components: NavigationComponent, EducationComponent
   - State: Education section loaded
   - API Calls: `/api/v1/:catalog_id/store_articles`

2. **Select Article**
   - Components: ArticleListComponent, ArticleCardComponent
   - State: Selected article updated
   - API Calls: None (navigation)

3. **View Article**
   - Components: ArticleDetailComponent, RelatedProductsComponent
   - State: Article content loaded
   - API Calls: `/api/v1/:catalog_id/store_articles/:id`

### 2. Promotions Flow

The promotions flow allows customers to view current deals and promotions.

#### Steps

1. **Navigate to Promotions**
   - Components: NavigationComponent, PromotionsComponent
   - State: Promotions section loaded
   - API Calls: `/api/v1/:catalog_id/promotions`

2. **View Promotion Details**
   - Components: PromotionDetailComponent, PromotionProductsComponent
   - State: Promotion details loaded
   - API Calls: `/api/v1/:catalog_id/promotions/:id`

3. **Add Promotional Product to Cart**
   - Components: PromotionProductsComponent, AddToCartComponent
   - State: Cart updated with promotional pricing
   - API Calls: None (client-side cart management)

## Real-Time Update Flows

### 1. Inventory Update Flow

The inventory update flow handles real-time updates to product inventory.

#### Steps

1. **Subscribe to Updates**
   - Components: AppComponent, PusherService
   - State: Subscribed to Pusher channel
   - API Calls: None (Pusher connection)

2. **Receive Inventory Update**
   - Components: PusherService, ProductService
   - State: Inventory data updated
   - API Calls: None (Pusher event)

3. **Update UI**
   - Components: ProductCardComponent, ProductDetailComponent
   - State: UI reflects updated inventory
   - API Calls: None (state update)

### 2. Product Update Flow

The product update flow handles real-time updates to product information.

#### Steps

1. **Receive Product Update**
   - Components: PusherService, ProductService
   - State: Product data updated
   - API Calls: None (Pusher event)

2. **Update UI**
   - Components: ProductCardComponent, ProductDetailComponent
   - State: UI reflects updated product information
   - API Calls: None (state update)

## Performance Considerations

1. **Lazy Loading**: User flows should implement lazy loading to minimize initial load time
2. **Caching**: Frequently accessed data should be cached to reduce API calls
3. **Optimistic Updates**: UI should update optimistically for better user experience
4. **Debouncing**: Input events should be debounced to reduce API calls
5. **Progressive Loading**: Images and heavy content should load progressively

## Next Steps

To complete the user flow documentation, we need to:

1. **Obtain Frontend Codebase Access**: To verify the actual implementation of these flows
2. **Create Flow Diagrams**: Visual representations of each user flow
3. **Document Component Interactions**: Detailed documentation of how components interact
4. **Analyze Performance**: Measure and document performance characteristics

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-01 | AI Assistant | Initial user flow documentation based on system overview | 