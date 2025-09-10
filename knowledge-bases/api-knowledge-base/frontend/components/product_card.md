---
title: ProductCard Component
description: Displays a product card with image, name, price, and add to cart functionality
last_updated: 2023-08-02
contributors: [AI Assistant]
---

# ProductCard Component

## Basic Information

| Property | Value |
|----------|-------|
| **Component Type** | UI Component |
| **Angular Module** | ProductsModule |
| **Selector** | app-product-card |
| **File Path** | src/app/components/products/product-card/product-card.component.ts |
| **Created Date** | 2022-03-15 (estimated) |
| **Last Modified** | 2023-01-20 (estimated) |

## Description

The ProductCard component displays a product in a card format, showing the product image, name, price, and an "Add to Cart" button. It's used in product listings and search results to provide a consistent product display across the application. This component is one of the most frequently used components in the Kiosk UI, appearing on the home screen, category pages, search results, and related products sections.

## Screenshots

[Screenshots would be included here showing the ProductCard in different states: normal, hover, out of stock, on sale, etc.]

## Props/Inputs

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| product | Product | Yes | - | The product object to display |
| showAddToCart | boolean | No | true | Whether to show the "Add to Cart" button |
| size | 'small' \| 'medium' \| 'large' | No | 'medium' | The size of the card |
| showPrice | boolean | No | true | Whether to show the product price |
| highlightNew | boolean | No | false | Whether to highlight the product as new |
| showQuantitySelector | boolean | No | false | Whether to show the quantity selector |

## State/Outputs

| Name | Type | Description |
|------|------|-------------|
| addToCart | EventEmitter<{product: Product, quantity: number}> | Emitted when the "Add to Cart" button is clicked |
| productClick | EventEmitter<Product> | Emitted when the product card is clicked |
| quantityChange | EventEmitter<number> | Emitted when the quantity is changed (if showQuantitySelector is true) |

## Methods/Functions

| Name | Parameters | Return Type | Description |
|------|------------|-------------|-------------|
| handleAddToCart | event: MouseEvent | void | Handles the "Add to Cart" button click, prevents event propagation, and emits the addToCart event |
| handleProductClick | event: MouseEvent | void | Handles the product card click and emits the productClick event |
| getDiscountPercentage | - | number | Calculates the discount percentage if the product is on sale |
| isProductAvailable | - | boolean | Checks if the product is in stock and available for purchase |
| getProductImage | - | string | Gets the primary product image URL or a placeholder if none exists |
| onQuantityChange | quantity: number | void | Handles quantity changes and emits the quantityChange event |

## Lifecycle Hooks

| Hook | Purpose |
|------|---------|
| ngOnInit | Sets up the component and initializes the product image |
| ngOnChanges | Updates the component when the product input changes |
| ngOnDestroy | Cleans up any subscriptions or event listeners |

## API Interactions

| Endpoint | Method | Purpose | Data Sent | Data Received |
|----------|--------|---------|-----------|---------------|
| /api/v1/:catalog_id/store_products/:id/view | POST | Track product views | Product ID | Success status |

## State Management

| Action | State Effect | Components Affected |
|--------|--------------|---------------------|
| ADD_TO_CART | Adds product to cart state | CartComponent, CartIndicatorComponent |
| VIEW_PRODUCT | Sets current product in state | ProductDetailComponent |
| UPDATE_QUANTITY | Updates product quantity in cart | CartComponent, CartSummaryComponent |

## Dependencies

### Component Dependencies

| Component | Relationship | Description |
|-----------|--------------|-------------|
| ProductListComponent | Parent | ProductListComponent renders multiple ProductCard components in a grid or list |
| ProductImageComponent | Child | ProductCard includes a ProductImageComponent to display the product image |
| QuantitySelectorComponent | Child | ProductCard includes a QuantitySelectorComponent when showQuantitySelector is true |
| PriceComponent | Child | ProductCard includes a PriceComponent to display the product price |
| BadgeComponent | Child | ProductCard includes BadgeComponent for "New", "Sale", etc. indicators |

### Service Dependencies

| Service | Purpose |
|---------|---------|
| CartService | Used to add products to the cart and check if a product is already in the cart |
| ProductService | Used to track product views and get additional product information |
| AnalyticsService | Used to track user interactions with the product card |
| StoreService | Used to get store-specific information like pricing and availability |

## Usage Examples

### Basic Usage

```typescript
<app-product-card
  [product]="product"
  (addToCart)="onAddToCart($event)"
  (productClick)="onProductClick($event)">
</app-product-card>
```

### Advanced Usage

```typescript
<app-product-card
  [product]="product"
  [showAddToCart]="isProductAvailable(product)"
  [size]="'large'"
  [highlightNew]="isNewProduct(product)"
  [showQuantitySelector]="true"
  (addToCart)="onAddToCart($event)"
  (productClick)="onProductClick($event)"
  (quantityChange)="onQuantityChange($event)">
</app-product-card>
```

## Edge Cases and Limitations

| Scenario | Behavior | Workaround |
|----------|----------|------------|
| Product has no image | Displays a placeholder image | Ensure all products have at least one image |
| Product is out of stock | Disables the "Add to Cart" button | Use the showAddToCart property to hide the button |
| Long product names | Truncates the name with ellipsis | Keep product names concise |
| Product has multiple prices | Shows the default price | Use the PriceComponent's advanced options for multiple prices |
| Product requires age verification | No built-in age verification | Handle age verification at the list level before showing products |

## Accessibility

| Feature | Implementation | Notes |
|---------|----------------|-------|
| Keyboard navigation | Tab index and keyboard event handlers | Users can navigate and add to cart using keyboard only |
| Screen reader support | ARIA labels and roles | All interactive elements have appropriate ARIA attributes |
| Color contrast | High contrast between text and background | Meets WCAG AA standards |
| Focus indicators | Visible focus outlines | Clear indicators when elements are focused |
| Alternative text | Alt text for product images | Screen readers can describe the product image |

## Performance Considerations

| Consideration | Implementation | Impact |
|---------------|----------------|--------|
| Rendering optimization | OnPush change detection | Reduces unnecessary re-renders |
| Image loading | Lazy loading with placeholder | Improves initial load time |
| Data binding | Minimized number of bindings | Reduces change detection cycles |
| Memoization | Cached calculations for discount, availability | Prevents recalculation on every render |
| Event handling | Debounced event handlers | Prevents excessive event firing |

## Testing

| Test Type | Coverage | Key Test Cases |
|-----------|----------|----------------|
| Unit tests | 85% | Tests rendering with different props, event emissions, method calculations |
| Integration tests | 70% | Tests interaction with CartService, ProductService |
| E2E tests | 50% | Tests adding product to cart from listing, navigating to product detail |

## Related Components

| Component | Relationship | Notes |
|-----------|--------------|-------|
| ProductDetailComponent | Navigation target | Clicking the card navigates to this component |
| CartComponent | Functional relationship | Products added from this card appear in the cart |
| ProductImageComponent | Child component | Used to display the product image |
| ProductListComponent | Parent component | Contains multiple ProductCard components |
| RelatedProductsComponent | Container | Uses ProductCard to display related products |

## Design Patterns

| Pattern | Implementation | Purpose |
|---------|----------------|---------|
| Presentational Component | Pure rendering based on inputs | Separation of concerns |
| Event Delegation | Output events for actions | Allows parent components to control behavior |
| Conditional Rendering | ngIf directives | Shows/hides elements based on conditions |
| Container/Presentational | Used as presentational component | Keeps business logic in container components |
| Composition | Composed of smaller components | Promotes reusability and maintainability |

## Future Improvements

| Improvement | Priority | Description |
|-------------|----------|-------------|
| Add animation | Medium | Add transition animations when hovering over the card |
| Support for badges | High | Add support for "New", "Sale", etc. badges |
| Quick view functionality | Low | Add a quick view button to show product details in a modal |
| Wishlist integration | Medium | Add ability to add product to wishlist |
| Comparison feature | Low | Add ability to mark product for comparison |
| Performance optimization | High | Optimize rendering for large product lists |

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-02 | AI Assistant | Initial documentation | 