---
title: CMS Product Creation Flow
description: Documentation of the product creation flow in The Peak Beyond's CMS application
last_updated: 2023-08-02
contributors: [AI Assistant]
---

# CMS Product Creation Flow

## Overview

The Product Creation Flow allows dispensary staff to add new products to their inventory through The Peak Beyond's Content Management System (CMS). This flow is critical for maintaining an up-to-date product catalog that accurately reflects the dispensary's offerings. The flow includes steps for entering product details, setting pricing, uploading images, and configuring product attributes.

## User Roles

- **Admin**: Can create products for any store
- **Store Manager**: Can create products for their assigned store(s)
- **Inventory Manager**: Can create products for their assigned store(s)
- **Content Manager**: Limited to editing product descriptions and images

## Preconditions

- User is authenticated in the CMS
- User has appropriate permissions to create products
- User has access to product information (name, description, pricing, etc.)
- User has product images available (if applicable)

## Flow Steps

1. **Navigate to Products Section**
   - Components: SidebarComponent, NavigationComponent
   - State: Initial products list state
   - API Calls: GET `/api/v1/store_products` (to load existing products)
   - User Interaction: User clicks on "Products" in the sidebar navigation
   - System Response: System displays the products list page

2. **Initiate Product Creation**
   - Components: ProductListComponent, ActionButtonComponent
   - State: Product list displayed
   - API Calls: None
   - User Interaction: User clicks "Add New Product" button
   - System Response: System displays the product creation form

3. **Enter Basic Product Information**
   - Components: ProductFormComponent, TextInputComponent, TextAreaComponent, DropdownComponent
   - State: Empty product form
   - API Calls: GET `/api/v1/categories` (to load available categories)
   - User Interaction: User enters product name, description, and selects category
   - System Response: System validates input in real-time

4. **Set Product Pricing**
   - Components: PricingFormComponent, NumberInputComponent, CheckboxComponent
   - State: Product form with basic info
   - API Calls: None
   - User Interaction: User enters price, cost, discount information
   - System Response: System calculates margins and displays pricing preview

5. **Upload Product Images**
   - Components: ImageUploaderComponent, ImagePreviewComponent, DragDropComponent
   - State: Product form with pricing info
   - API Calls: POST `/api/v1/assets` (to upload images)
   - User Interaction: User uploads product images or drags and drops files
   - System Response: System uploads images, displays previews, allows reordering

6. **Configure Product Attributes**
   - Components: AttributesFormComponent, TagSelectorComponent, CheckboxGroupComponent
   - State: Product form with images
   - API Calls: GET `/api/v1/attributes` (to load available attributes)
   - User Interaction: User selects product attributes (strain, potency, effects, etc.)
   - System Response: System updates form with selected attributes

7. **Set Inventory Levels**
   - Components: InventoryFormComponent, NumberInputComponent, ToggleComponent
   - State: Product form with attributes
   - API Calls: None
   - User Interaction: User enters inventory quantity, sets low stock threshold
   - System Response: System validates inventory information

8. **Configure Display Options**
   - Components: DisplayOptionsComponent, ToggleComponent, RadioGroupComponent
   - State: Product form with inventory info
   - API Calls: None
   - User Interaction: User configures visibility, featured status, display order
   - System Response: System updates form with display options

9. **Preview Product**
   - Components: ProductPreviewComponent, ProductCardComponent
   - State: Complete product form
   - API Calls: None
   - User Interaction: User clicks "Preview" button
   - System Response: System displays preview of how product will appear in kiosk

10. **Submit Product**
    - Components: ProductFormComponent, ButtonComponent, LoadingIndicatorComponent
    - State: Complete product form, ready for submission
    - API Calls: POST `/api/v1/store_products` (to create the product)
    - User Interaction: User clicks "Save" or "Publish" button
    - System Response: System shows loading indicator, processes submission

11. **Handle Submission Result**
    - Components: AlertComponent, RedirectComponent
    - State: Submission processing
    - API Calls: None (waiting for response from previous call)
    - User Interaction: None (waiting)
    - System Response: System displays success message or error details

12. **Return to Products List**
    - Components: ProductListComponent
    - State: Updated products list with new product
    - API Calls: GET `/api/v1/store_products` (to refresh product list)
    - User Interaction: User clicks "Back to Products" or is automatically redirected
    - System Response: System displays updated products list with the new product

## Alternative Paths

### A1. Save as Draft

If the user wants to save progress without publishing:

1. After any step, user clicks "Save as Draft" button
2. System saves current product information with "draft" status
3. User can continue editing or return to the form later

### A2. Duplicate Existing Product

If the user wants to create a product similar to an existing one:

1. From the products list, user selects "Duplicate" on an existing product
2. System pre-fills the product form with information from the selected product
3. User modifies information as needed and continues with the normal flow

### A3. Import Product from POS

If the user wants to import a product from the POS system:

1. User clicks "Import from POS" button
2. System displays list of products from POS not yet in the CMS
3. User selects products to import
4. System pre-fills the product form with information from the POS
5. User reviews and modifies information as needed
6. User continues with the normal flow from step 5 (Upload Product Images)

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Required fields missing | Form validation prevents submission, highlights missing fields |
| Invalid pricing information | System validates pricing logic, prevents negative prices |
| Duplicate product name | System warns about duplicate name, allows override or change |
| Large image uploads | System processes images in background, shows progress indicator |
| Slow network connection | Form autosaves periodically, allows resuming after connection issues |
| POS integration unavailable | System allows manual creation, flags for sync later |
| Category doesn't exist | User can create new category inline during product creation |

## Error States

| Error | Handling |
|-------|----------|
| Image upload failure | Display error with retry option, allow skipping images |
| Form submission failure | Preserve form data, display specific error, allow retry |
| Validation errors | Highlight fields with errors, provide guidance on fixing |
| POS sync error | Allow manual entry, log error for resolution |
| Server error | Display friendly message, log details, offer support contact |
| Concurrent edit conflict | Notify user of conflict, offer merge or override options |

## Performance Considerations

1. **Image Optimization**: Images are optimized before upload to reduce size
2. **Lazy Loading**: Form sections are loaded progressively as needed
3. **Autosave**: Form state is periodically saved to prevent data loss
4. **Debounced Validation**: Input validation is debounced to reduce API calls
5. **Cached Lookups**: Category and attribute lists are cached for quick access

## Related Flows

- [Product Editing Flow](product_editing_flow.md)
- [Product Deletion Flow](product_deletion_flow.md)
- [Inventory Management Flow](inventory_management_flow.md)
- [Category Management Flow](category_management_flow.md)
- [Bulk Product Import Flow](bulk_product_import_flow.md)

## Components Used

| Component | Role | Description |
|-----------|------|-------------|
| ProductFormComponent | Container | Main container for the product creation form |
| TextInputComponent | UI | Reusable text input field with validation |
| TextAreaComponent | UI | Reusable text area for longer text content |
| DropdownComponent | UI | Reusable dropdown selector for categories |
| PricingFormComponent | Form | Handles product pricing information |
| ImageUploaderComponent | Feature | Handles image upload and management |
| AttributesFormComponent | Form | Handles product attributes selection |
| InventoryFormComponent | Form | Handles inventory level configuration |
| DisplayOptionsComponent | Form | Handles product display configuration |
| ProductPreviewComponent | Feature | Shows preview of product as it will appear in kiosk |
| ButtonComponent | UI | Reusable button with various states |
| AlertComponent | UI | Displays success and error messages |

## API Endpoints Used

| Endpoint | Method | Purpose | Request Data | Response Data |
|----------|--------|---------|--------------|---------------|
| `/api/v1/store_products` | GET | Load product list | Pagination, filters | Product list |
| `/api/v1/store_products` | POST | Create new product | Product data | Created product |
| `/api/v1/categories` | GET | Load categories | None | Categories list |
| `/api/v1/attributes` | GET | Load attributes | None | Attributes list |
| `/api/v1/assets` | POST | Upload images | Image file | Asset object |
| `/api/v1/pos/products` | GET | Load POS products | Filters | POS products list |

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
 |---(7) Click Add New--------->|                          |                     |
 |                              |                          |                     |
 |<---(8) Show Form-------------|                          |                     |
 |                              |                          |                     |
 |---(9) Enter Product Data---->|                          |                     |
 |                              |                          |                     |
 |---(10) Upload Images-------->|                          |                     |
 |                              |                          |                     |
 |                              |---(11) Upload Images---->|                     |
 |                              |                          |                     |
 |                              |                          |---(12) POST /assets>|
 |                              |                          |                     |
 |                              |                          |<---(13) Asset IDs---|
 |                              |                          |                     |
 |                              |<---(14) Asset IDs--------|                     |
 |                              |                          |                     |
 |---(15) Submit Form---------->|                          |                     |
 |                              |                          |                     |
 |                              |---(16) Create Product--->|                     |
 |                              |                          |                     |
 |                              |                          |---(17) POST /products>|
 |                              |                          |                     |
 |                              |                          |<---(18) Product-----|
 |                              |                          |                     |
 |                              |<---(19) Success----------|                     |
 |                              |                          |                     |
 |<---(20) Success Message------|                          |                     |
 |                              |                          |                     |
```

### State Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Products List  │────>│  Empty Form     │────>│  Basic Info     │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        │
                                                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Display Options│<────│  Attributes     │<────│  Pricing        │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                                                │
        │                                                │
        ▼                                                ▼
┌─────────────────┐                             ┌─────────────────┐
│                 │                             │                 │
│  Preview        │                             │  Images         │
│                 │                             │                 │
└─────────────────┘                             └─────────────────┘
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

1. **Permission Checks**: System verifies user has permission to create products
2. **Input Sanitization**: All user inputs are sanitized to prevent XSS attacks
3. **CSRF Protection**: Form submissions include CSRF tokens
4. **Image Validation**: Uploaded images are validated for type, size, and content
5. **Audit Logging**: All product creation actions are logged for audit purposes
6. **Data Validation**: Server-side validation ensures data integrity

## Testing

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| Create Basic Product | Create product with minimal required fields | Product created successfully |
| Create Complete Product | Create product with all fields populated | Product created with all details |
| Validation Errors | Submit form with missing required fields | Form shows validation errors |
| Image Upload | Upload various image types and sizes | Images processed and attached to product |
| Draft Saving | Save product as draft | Product saved with draft status |
| Duplicate Product | Create product with same name as existing | Warning shown, allow override |
| POS Import | Import product from POS | Product created with POS data |

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-02 | AI Assistant | Initial documentation of product creation flow | 