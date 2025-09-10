---
title: CMS Product Deletion Flow
description: Documentation of the product deletion flow in The Peak Beyond's CMS application
last_updated: 2023-08-02
contributors: [AI Assistant]
---

# CMS Product Deletion Flow

## Overview

The Product Deletion Flow allows dispensary staff to remove products from their inventory through The Peak Beyond's Content Management System (CMS). This flow enables users to safely delete products that are no longer offered, while maintaining data integrity and providing safeguards against accidental deletion. The flow includes options for soft deletion (archiving) and permanent deletion, with appropriate confirmation steps.

## User Roles

- **Admin**: Can delete products for any store
- **Store Manager**: Can delete products for their assigned store(s)
- **Inventory Manager**: Can delete products for their assigned store(s)
- **Content Manager**: Cannot delete products (view-only access)

## Preconditions

- User is authenticated in the CMS
- User has appropriate permissions to delete products
- Product exists in the system
- Product is not currently in active orders

## Flow Steps

1. **Navigate to Products Section**
   - Components: SidebarComponent, NavigationComponent
   - State: Initial products list state
   - API Calls: GET `/api/v1/store_products` (to load existing products)
   - User Interaction: User clicks on "Products" in the sidebar navigation
   - System Response: System displays the products list page

2. **Locate Product to Delete**
   - Components: ProductListComponent, SearchComponent, FilterComponent
   - State: Products list displayed
   - API Calls: GET `/api/v1/store_products` (with search/filter parameters if used)
   - User Interaction: User searches/filters products and/or browses the list
   - System Response: System displays filtered products list

3. **Initiate Product Deletion**
   - Components: ProductListComponent, ProductRowComponent, ActionButtonComponent
   - State: Product identified in list
   - API Calls: None
   - User Interaction: User clicks "Delete" button on the product row
   - System Response: System displays deletion confirmation modal

4. **Confirm Deletion**
   - Components: ConfirmationModalComponent, RadioButtonComponent, TextInputComponent
   - State: Confirmation modal displayed
   - API Calls: GET `/api/v1/store_products/:id/usage` (to check if product is in use)
   - User Interaction: User confirms deletion intent, optionally selects deletion type (archive/permanent)
   - System Response: System validates confirmation, checks for dependencies

5. **Process Deletion**
   - Components: ConfirmationModalComponent, LoadingIndicatorComponent
   - State: Deletion in progress
   - API Calls: 
     - For archiving: PUT `/api/v1/store_products/:id` (with `archived: true`)
     - For permanent deletion: DELETE `/api/v1/store_products/:id`
   - User Interaction: None (waiting)
   - System Response: System shows loading indicator, processes deletion

6. **Handle Deletion Result**
   - Components: AlertComponent
   - State: Deletion processing
   - API Calls: None (waiting for response from previous call)
   - User Interaction: None (waiting)
   - System Response: System displays success message or error details

7. **Update Products List**
   - Components: ProductListComponent
   - State: Updated products list
   - API Calls: None (list already updated via state management)
   - User Interaction: None (automatic)
   - System Response: System removes deleted product from list or marks it as archived

## Alternative Paths

### A1. Bulk Deletion

If the user wants to delete multiple products at once:

1. From products list, user selects multiple products using checkboxes
2. User clicks "Bulk Actions" dropdown and selects "Delete"
3. System displays confirmation modal with count of selected products
4. User confirms deletion intent, optionally selects deletion type
5. System processes deletion for all selected products
6. System displays progress and results

### A2. Deletion with Dependencies

If the product has dependencies (e.g., in orders, featured in layouts):

1. System displays warning about dependencies in confirmation modal
2. User must acknowledge dependencies by checking a confirmation box
3. System may suggest archiving instead of permanent deletion
4. User decides whether to proceed or cancel
5. If proceeding, system handles dependencies according to business rules

### A3. Restore Archived Product

If the user wants to restore a previously archived product:

1. User navigates to "Archived Products" view
2. User locates the archived product
3. User clicks "Restore" button
4. System displays confirmation modal
5. User confirms restoration
6. System restores product to active status

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Product in active orders | Prevent deletion, suggest archiving instead |
| Product featured in layouts | Warn user, allow proceeding with confirmation |
| Product with inventory | Warn user about inventory loss, require confirmation |
| Product synced from POS | Warn about sync implications, may require special handling |
| Recently modified product | Additional confirmation to prevent accidental deletion of new changes |
| Product with unique ID/SKU | Warn about potential issues with reusing ID/SKU in future |
| Last product in category | Warn that category may become empty |

## Error States

| Error | Handling |
|-------|----------|
| Permission denied | Display message about insufficient permissions |
| Deletion API failure | Display specific error, allow retry |
| Concurrent modification | Warn user that product was modified by another user, refresh data |
| Network disconnection | Retry mechanism, clear confirmation state on reconnection |
| Partial bulk deletion failure | Display which products were successfully deleted and which failed |
| Database constraint violation | Display user-friendly message explaining the constraint |

## Performance Considerations

1. **Optimistic UI Updates**: Remove product from list immediately while deletion processes
2. **Batch Processing**: Process bulk deletions in batches to avoid timeout
3. **Background Processing**: Handle complex deletion dependencies in background jobs
4. **Caching Updates**: Ensure cache invalidation for deleted products
5. **Minimal API Calls**: Combine checks and deletion in minimal API calls

## Related Flows

- [Product Creation Flow](product_creation_flow.md)
- [Product Editing Flow](product_editing_flow.md)
- [Bulk Product Management Flow](bulk_product_management_flow.md)
- [Archived Products Management Flow](archived_products_management_flow.md)
- [Product Restoration Flow](product_restoration_flow.md)

## Components Used

| Component | Role | Description |
|-----------|------|-------------|
| ProductListComponent | Container | Displays list of products with actions |
| ProductRowComponent | UI | Displays individual product in list with actions |
| ActionButtonComponent | UI | Button for triggering product actions |
| ConfirmationModalComponent | Feature | Modal dialog for confirming deletion |
| RadioButtonComponent | UI | Selection for deletion type (archive/permanent) |
| TextInputComponent | UI | Input for confirmation text (if required) |
| LoadingIndicatorComponent | UI | Shows loading state during deletion |
| AlertComponent | UI | Displays success or error messages |
| BulkActionsComponent | Feature | Handles bulk selection and actions |

## API Endpoints Used

| Endpoint | Method | Purpose | Request Data | Response Data |
|----------|--------|---------|--------------|---------------|
| `/api/v1/store_products` | GET | Load product list | Pagination, filters | Product list |
| `/api/v1/store_products/:id/usage` | GET | Check product dependencies | Product ID | Usage information |
| `/api/v1/store_products/:id` | PUT | Archive product | `{ archived: true }` | Updated product |
| `/api/v1/store_products/:id` | DELETE | Permanently delete product | Product ID | Success status |
| `/api/v1/store_products/bulk_delete` | POST | Delete multiple products | Product IDs, deletion type | Results summary |

## Diagrams

### Sequence Diagram

```
User                    ProductListComponent      ConfirmationModal         API
 |                              |                        |                   |
 |---(1) Navigate to Products-->|                        |                   |
 |                              |                        |                   |
 |                              |---(2) Load Products--->|                   |
 |                              |                        |                   |
 |                              |                        |                   |
 |                              |                        |                   |
 |<---(3) Display Products------|                        |                   |
 |                              |                        |                   |
 |---(4) Click Delete---------->|                        |                   |
 |                              |                        |                   |
 |                              |---(5) Open Modal------>|                   |
 |                              |                        |                   |
 |                              |                        |---(6) Check Usage>|
 |                              |                        |                   |
 |                              |                        |<---(7) Usage Info-|
 |                              |                        |                   |
 |<---(8) Display Modal---------|<---(9) Show Modal-----|                   |
 |                              |                        |                   |
 |---(10) Confirm Deletion----->|                        |                   |
 |                              |                        |                   |
 |                              |<---(11) Confirmed------|                   |
 |                              |                        |                   |
 |                              |---(12) Delete Product->|                   |
 |                              |                        |                   |
 |                              |                        |---(13) DELETE---->|
 |                              |                        |                   |
 |                              |                        |<---(14) Success---|
 |                              |                        |                   |
 |                              |<---(15) Success--------|                   |
 |                              |                        |                   |
 |<---(16) Success Message------|                        |                   |
 |                              |                        |                   |
 |<---(17) Update Product List--|                        |                   |
 |                              |                        |                   |
```

### State Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Products List  │────>│  Confirmation   │────>│  Deleting       │
│                 │     │  Modal          │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                │                        │
                                │                        │
                                ▼                        │
                        ┌─────────────────┐             │
                        │                 │             │
                        │  Cancelled      │             │
                        │                 │             │
                        └─────────────────┘             │
                                                        │
                                                        │
                                                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Products List  │<────│  Success        │<────│  Deleted        │
│  (Updated)      │     │  Message        │     │                 │
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

1. **Permission Checks**: System verifies user has permission to delete the specific product
2. **Audit Logging**: All deletion actions are logged with user information for audit purposes
3. **Confirmation Requirements**: Multi-step confirmation for destructive actions
4. **CSRF Protection**: Deletion requests include CSRF tokens
5. **Rate Limiting**: Prevent abuse through rate limiting of deletion actions
6. **Soft Deletion**: Preference for archiving over permanent deletion to prevent data loss

## Testing

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| Basic Deletion | Delete product with no dependencies | Product successfully deleted |
| Archive Product | Archive product instead of deleting | Product marked as archived, not visible in main list |
| Delete with Dependencies | Attempt to delete product with dependencies | Warning displayed, require additional confirmation |
| Bulk Deletion | Delete multiple products at once | All selected products deleted successfully |
| Permission Test | Attempt deletion without permission | Permission denied message displayed |
| Restore Archived | Restore previously archived product | Product restored to active status |
| Network Failure | Simulate network failure during deletion | Appropriate error handling, system recovers |

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-02 | AI Assistant | Initial documentation of product deletion flow | 