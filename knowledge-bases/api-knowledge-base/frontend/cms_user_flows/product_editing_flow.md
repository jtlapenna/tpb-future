---
title: CMS Product Editing Flow
description: Documentation of the product editing flow in The Peak Beyond's CMS application
last_updated: 2023-08-02
contributors: [AI Assistant]
---

# CMS Product Editing Flow

## Overview

The Product Editing Flow allows dispensary staff to modify existing products in their inventory through The Peak Beyond's Content Management System (CMS). This flow enables users to update product information, pricing, images, and attributes to ensure the product catalog remains accurate and up-to-date. The flow includes safeguards to prevent data loss and tracks changes for audit purposes.

## User Roles

- **Admin**: Can edit products for any store
- **Store Manager**: Can edit products for their assigned store(s)
- **Inventory Manager**: Can edit products for their assigned store(s)
- **Content Manager**: Limited to editing product descriptions and images

## Preconditions

- User is authenticated in the CMS
- User has appropriate permissions to edit products
- Product exists in the system
- User has access to updated product information

## Flow Steps

1. **Navigate to Products Section**
   - Components: SidebarComponent, NavigationComponent
   - State: Initial products list state
   - API Calls: GET `/api/v1/store_products` (to load existing products)
   - User Interaction: User clicks on "Products" in the sidebar navigation
   - System Response: System displays the products list page

2. **Locate Product to Edit**
   - Components: ProductListComponent, SearchComponent, FilterComponent
   - State: Products list displayed
   - API Calls: GET `/api/v1/store_products` (with search/filter parameters if used)
   - User Interaction: User searches/filters products and/or browses the list
   - System Response: System displays filtered products list

3. **Select Product for Editing**
   - Components: ProductListComponent, ProductRowComponent, ActionButtonComponent
   - State: Product identified in list
   - API Calls: None
   - User Interaction: User clicks "Edit" button on the product row
   - System Response: System navigates to product edit page

4. **Load Product Details**
   - Components: ProductFormComponent, LoadingIndicatorComponent
   - State: Loading state
   - API Calls: GET `/api/v1/store_products/:id` (to load product details)
   - User Interaction: None (waiting)
   - System Response: System displays product form pre-filled with product data

5. **Edit Basic Product Information**
   - Components: ProductFormComponent, TextInputComponent, TextAreaComponent, DropdownComponent
   - State: Product form with existing data
   - API Calls: GET `/api/v1/categories` (to load available categories if not cached)
   - User Interaction: User modifies product name, description, and/or category
   - System Response: System validates input in real-time

6. **Edit Product Pricing**
   - Components: PricingFormComponent, NumberInputComponent, CheckboxComponent
   - State: Product form with updated basic info
   - API Calls: None
   - User Interaction: User modifies price, cost, discount information
   - System Response: System calculates margins and displays pricing preview

7. **Manage Product Images**
   - Components: ImageManagerComponent, ImagePreviewComponent, DragDropComponent
   - State: Product form with updated pricing
   - API Calls: 
     - GET `/api/v1/assets?product_id=:id` (to load existing images)
     - POST `/api/v1/assets` (to upload new images)
     - DELETE `/api/v1/assets/:id` (to remove images)
     - PUT `/api/v1/assets/:id/reorder` (to reorder images)
   - User Interaction: User adds, removes, reorders images
   - System Response: System updates image gallery, processes uploads/deletions

8. **Edit Product Attributes**
   - Components: AttributesFormComponent, TagSelectorComponent, CheckboxGroupComponent
   - State: Product form with updated images
   - API Calls: GET `/api/v1/attributes` (to load available attributes if not cached)
   - User Interaction: User modifies product attributes
   - System Response: System updates form with selected attributes

9. **Edit Inventory Levels**
   - Components: InventoryFormComponent, NumberInputComponent, ToggleComponent
   - State: Product form with updated attributes
   - API Calls: None
   - User Interaction: User modifies inventory quantity, low stock threshold
   - System Response: System validates inventory information

10. **Edit Display Options**
    - Components: DisplayOptionsComponent, ToggleComponent, RadioGroupComponent
    - State: Product form with updated inventory
    - API Calls: None
    - User Interaction: User modifies visibility, featured status, display order
    - System Response: System updates form with display options

11. **Preview Updated Product**
    - Components: ProductPreviewComponent, ProductCardComponent
    - State: Updated product form
    - API Calls: None
    - User Interaction: User clicks "Preview" button
    - System Response: System displays preview of how updated product will appear in kiosk

12. **Submit Product Updates**
    - Components: ProductFormComponent, ButtonComponent, LoadingIndicatorComponent
    - State: Updated product form, ready for submission
    - API Calls: PUT `/api/v1/store_products/:id` (to update the product)
    - User Interaction: User clicks "Save" or "Update" button
    - System Response: System shows loading indicator, processes submission

13. **Handle Submission Result**
    - Components: AlertComponent, RedirectComponent
    - State: Submission processing
    - API Calls: None (waiting for response from previous call)
    - User Interaction: None (waiting)
    - System Response: System displays success message or error details

14. **Return to Products List**
    - Components: ProductListComponent
    - State: Updated products list
    - API Calls: GET `/api/v1/store_products` (to refresh product list)
    - User Interaction: User clicks "Back to Products" or is automatically redirected
    - System Response: System displays updated products list with the modified product

## Alternative Paths

### A1. Cancel Editing

If the user wants to cancel editing:

1. At any point during editing, user clicks "Cancel" button
2. System prompts for confirmation if changes have been made
3. If confirmed, system discards changes and returns to products list
4. If not confirmed, system returns to editing

### A2. Save as Draft

If the user wants to save progress without publishing changes:

1. During editing, user clicks "Save as Draft" button
2. System saves current product information with "draft" status
3. User can continue editing or return to the form later

### A3. View Change History

If the user wants to see previous versions of the product:

1. User clicks "View History" button
2. System displays list of previous versions with timestamps and editors
3. User can select a version to view
4. User can optionally restore a previous version

### A4. Bulk Edit Mode

If the user wants to edit multiple products at once:

1. From products list, user selects multiple products
2. User clicks "Bulk Edit" button
3. System displays simplified form with fields common to all selected products
4. User makes changes to apply to all selected products
5. User submits changes
6. System updates all selected products

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Concurrent editing | Lock editing or implement conflict resolution if another user is editing |
| Product deleted while editing | Display notification and redirect to products list |
| Required fields cleared | Form validation prevents submission, highlights missing fields |
| Reverting to original values | "Reset" button available to revert changes to original values |
| Large number of images | Pagination for image gallery, optimized loading |
| POS sync during edit | Warn user about potential conflicts with POS data |
| Inventory changes during edit | Show real-time inventory updates if changed externally |

## Error States

| Error | Handling |
|-------|----------|
| Image upload failure | Display error with retry option, allow continuing without new images |
| Form submission failure | Preserve form data, display specific error, allow retry |
| Validation errors | Highlight fields with errors, provide guidance on fixing |
| Product not found | Display error message, redirect to products list |
| Permission denied | Display message about insufficient permissions |
| Network disconnection | Autosave data locally, restore when connection returns |

## Performance Considerations

1. **Optimistic Updates**: UI updates immediately while changes are saved in background
2. **Incremental Loading**: Load product sections incrementally for faster initial display
3. **Change Tracking**: Only modified fields are sent in update requests
4. **Image Caching**: Previously loaded images are cached to reduce bandwidth
5. **Form State Management**: Efficient state management to prevent unnecessary re-renders

## Related Flows

- [Product Creation Flow](product_creation_flow.md)
- [Product Deletion Flow](product_deletion_flow.md)
- [Inventory Management Flow](inventory_management_flow.md)
- [Product Version History Flow](product_version_history_flow.md)
- [Bulk Product Editing Flow](bulk_product_editing_flow.md)

## Components Used

| Component | Role | Description |
|-----------|------|-------------|
| ProductFormComponent | Container | Main container for the product editing form |
| TextInputComponent | UI | Reusable text input field with validation |
| TextAreaComponent | UI | Reusable text area for longer text content |
| DropdownComponent | UI | Reusable dropdown selector for categories |
| PricingFormComponent | Form | Handles product pricing information |
| ImageManagerComponent | Feature | Handles image management (add, remove, reorder) |
| AttributesFormComponent | Form | Handles product attributes selection |
| InventoryFormComponent | Form | Handles inventory level configuration |
| DisplayOptionsComponent | Form | Handles product display configuration |
| ProductPreviewComponent | Feature | Shows preview of product as it will appear in kiosk |
| ButtonComponent | UI | Reusable button with various states |
| AlertComponent | UI | Displays success and error messages |
| VersionHistoryComponent | Feature | Displays product version history |

## API Endpoints Used

| Endpoint | Method | Purpose | Request Data | Response Data |
|----------|--------|---------|--------------|---------------|
| `/api/v1/store_products` | GET | Load product list | Pagination, filters | Product list |
| `/api/v1/store_products/:id` | GET | Load product details | Product ID | Product details |
| `/api/v1/store_products/:id` | PUT | Update product | Updated product data | Updated product |
| `/api/v1/categories` | GET | Load categories | None | Categories list |
| `/api/v1/attributes` | GET | Load attributes | None | Attributes list |
| `/api/v1/assets` | GET | Load product images | Product ID | Asset list |
| `/api/v1/assets` | POST | Upload new images | Image file | Asset object |
| `/api/v1/assets/:id` | DELETE | Remove image | Asset ID | Success status |
| `/api/v1/assets/:id/reorder` | PUT | Reorder images | Order data | Success status |
| `/api/v1/store_products/:id/versions` | GET | Load version history | Product ID | Version list |

## Diagrams

### Sequence Diagram

```
User                    ProductFormComponent         ProductService            API
 |                              |                          |                     |
 |---(1) Navigate to Products-->|                          |                     |
 |                              |                          |                     |
 |                              |---(2) Load Products----->|                     |
 |                              |                          |                     |
 |                              |                          |---(3) GET /products>|
 |                              |                          |                     |
 |                              |                          |<---(4) Products-----|
 |                              |                          |                     |
 |                              |<---(5) Products----------|                     |
 |                              |                          |                     |
 |<---(6) Display Products------|                          |                     |
 |                              |                          |                     |
 |---(7) Click Edit------------>|                          |                     |
 |                              |                          |                     |
 |                              |---(8) Load Product------>|                     |
 |                              |                          |                     |
 |                              |                          |---(9) GET /product>-|
 |                              |                          |                     |
 |                              |                          |<---(10) Product-----|
 |                              |                          |                     |
 |                              |<---(11) Product----------|                     |
 |                              |                          |                     |
 |<---(12) Display Form---------|                          |                     |
 |                              |                          |                     |
 |---(13) Edit Product Data---->|                          |                     |
 |                              |                          |                     |
 |---(14) Submit Updates------->|                          |                     |
 |                              |                          |                     |
 |                              |---(15) Update Product--->|                     |
 |                              |                          |                     |
 |                              |                          |---(16) PUT /product>|
 |                              |                          |                     |
 |                              |                          |<---(17) Updated-----|
 |                              |                          |                     |
 |                              |<---(18) Success----------|                     |
 |                              |                          |                     |
 |<---(19) Success Message------|                          |                     |
 |                              |                          |                     |
```

### State Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Products List  │────>│  Loading Product│────>│  Editing Form   │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        │
        ┌───────────────────────────────────────────────┘
        │
        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Preview        │<────│  Modified Form  │<────│  Editing Fields │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │
        │
        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Submitting     │────>│  Success        │────>│  Products List  │
│                 │     │                 │     │  (Updated)      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │
        │
        ▼
┌─────────────────┐
│                 │
│  Error          │
│                 │
└─────────────────┘
```

## Security Considerations

1. **Permission Checks**: System verifies user has permission to edit the specific product
2. **Change Tracking**: All changes are logged with user information for audit purposes
3. **Input Sanitization**: All user inputs are sanitized to prevent XSS attacks
4. **CSRF Protection**: Form submissions include CSRF tokens
5. **Image Validation**: Uploaded images are validated for type, size, and content
6. **Concurrent Edit Protection**: Locking mechanism or conflict resolution for concurrent edits

## Testing

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| Basic Edit | Edit product name and description | Product updated successfully |
| Price Change | Modify product pricing | Price updated, margins recalculated |
| Image Management | Add, remove, reorder images | Images updated correctly |
| Attribute Changes | Modify product attributes | Attributes updated correctly |
| Validation Errors | Submit with invalid data | Form shows validation errors |
| Cancel Editing | Make changes and cancel | Changes discarded, return to list |
| Version History | View and restore previous version | Previous version restored |

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-02 | AI Assistant | Initial documentation of product editing flow | 