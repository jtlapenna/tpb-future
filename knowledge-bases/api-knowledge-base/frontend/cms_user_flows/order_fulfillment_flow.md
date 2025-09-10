---
title: CMS Order Fulfillment Flow
description: Documentation of the order fulfillment process in the CMS application
last_updated: 2023-08-02
contributors: [AI Assistant]
---

# CMS Order Fulfillment Flow

## Overview

The Order Fulfillment Flow enables dispensary staff to process and fulfill customer orders through The Peak Beyond's CMS application. This flow is critical for ensuring timely and accurate order processing, inventory management, and customer satisfaction. The fulfillment process includes verifying order details, preparing products, marking items as prepared, and completing the fulfillment process.

## User Roles

| Role | Permissions |
|------|-------------|
| Admin | Full access to fulfill any order |
| Store Manager | Can fulfill orders for their assigned store |
| Fulfillment Specialist | Can fulfill orders but cannot modify order details |
| Cashier | Can mark orders as paid and complete fulfillment |

## Preconditions

1. User is authenticated in the CMS
2. User has appropriate permissions to fulfill orders
3. Order exists in the system with a status that allows fulfillment (typically "Confirmed" or "Processing")
4. Inventory is available to fulfill the order

## Flow Steps

### 1. Navigate to Orders Section

- **Components**: Navigation Menu, Orders Dashboard
- **State**: Initial state, loading orders list
- **API Call**: `GET /api/v1/orders` with appropriate filters
- **User Interaction**: User clicks on "Orders" in the main navigation menu
- **System Response**: System displays the orders list view with filtering options

### 2. Locate Order to Fulfill

- **Components**: Orders List, Search/Filter Controls
- **State**: Orders list loaded, waiting for user selection
- **API Call**: None (using already loaded data)
- **User Interaction**: User filters orders by status "Confirmed" or uses search to find specific order
- **System Response**: System displays filtered list of orders eligible for fulfillment

### 3. Select Order for Fulfillment

- **Components**: Order List Item, Action Menu
- **State**: Order selected for fulfillment
- **API Call**: `GET /api/v1/orders/:id` to load detailed order information
- **User Interaction**: User clicks "Fulfill" button on the order or selects "Fulfill" from action menu
- **System Response**: System navigates to the order fulfillment view

### 4. Review Order Details

- **Components**: Order Detail View, Fulfillment Panel
- **State**: Order details loaded, fulfillment process initiated
- **API Call**: None (using already loaded data)
- **User Interaction**: User reviews order information including customer details, products, quantities, and special instructions
- **System Response**: System displays complete order information with fulfillment options

### 5. Verify Inventory Availability

- **Components**: Inventory Check Panel, Product List
- **State**: Inventory verification in progress
- **API Call**: `GET /api/v1/inventory/check` with order items
- **User Interaction**: User initiates inventory check or system does this automatically
- **System Response**: System displays inventory status for each product in the order, highlighting any discrepancies

### 6. Begin Fulfillment Process

- **Components**: Fulfillment Workflow, Progress Indicator
- **State**: Fulfillment in progress
- **API Call**: `PUT /api/v1/orders/:id/status` with status="fulfilling"
- **User Interaction**: User clicks "Begin Fulfillment" button
- **System Response**: System updates order status and displays the fulfillment workflow

### 7. Prepare Products

- **Components**: Product Checklist, Barcode Scanner Integration
- **State**: Product preparation in progress
- **API Call**: None (local state only)
- **User Interaction**: User collects each product and checks it off the list, optionally scanning barcodes to verify
- **System Response**: System updates the UI to show progress as items are checked off

### 8. Mark Items as Prepared

- **Components**: Product Checklist, Item Status Indicators
- **State**: Items being marked as prepared
- **API Call**: `PUT /api/v1/orders/:id/items/:itemId/status` with status="prepared"
- **User Interaction**: User marks each item as prepared after collecting and verifying it
- **System Response**: System updates item status and progress indicators

### 9. Record Package Information (if applicable)

- **Components**: Packaging Form, Label Printer Integration
- **State**: Package information being recorded
- **API Call**: `PUT /api/v1/orders/:id/package` with package details
- **User Interaction**: User enters package information (weight, dimensions, tracking number)
- **System Response**: System saves package information and may generate shipping labels

### 10. Verify Fulfillment Completion

- **Components**: Fulfillment Verification Panel, Checklist Summary
- **State**: Verification in progress
- **API Call**: None (using local state)
- **User Interaction**: User reviews the fulfillment checklist to ensure all items are prepared
- **System Response**: System displays summary of prepared items and remaining steps

### 11. Mark Order as Fulfilled

- **Components**: Fulfillment Action Button, Status Update Modal
- **State**: Fulfillment completion in progress
- **API Call**: `PUT /api/v1/orders/:id/status` with status="fulfilled"
- **User Interaction**: User clicks "Complete Fulfillment" button
- **System Response**: System updates order status, records fulfillment timestamp, and user information

### 12. Process Payment (if applicable)

- **Components**: Payment Processing Panel, Payment Method Selector
- **State**: Payment processing
- **API Call**: `POST /api/v1/orders/:id/payments` with payment details
- **User Interaction**: User processes payment or marks as paid based on payment method
- **System Response**: System records payment information and updates order status

### 13. Generate Receipt/Packing Slip

- **Components**: Receipt Generator, Print Dialog
- **State**: Document generation
- **API Call**: `GET /api/v1/orders/:id/documents/receipt`
- **User Interaction**: User clicks "Generate Receipt" or "Print Packing Slip"
- **System Response**: System generates the document and displays print options

### 14. Complete Order

- **Components**: Order Completion Button, Confirmation Dialog
- **State**: Order completion
- **API Call**: `PUT /api/v1/orders/:id/status` with status="completed"
- **User Interaction**: User clicks "Complete Order" button
- **System Response**: System finalizes the order, updates inventory, and displays confirmation

### 15. Return to Orders List

- **Components**: Navigation Button, Orders List View
- **State**: Navigation back to orders list
- **API Call**: `GET /api/v1/orders` to refresh orders list
- **User Interaction**: User clicks "Back to Orders" or similar navigation option
- **System Response**: System navigates back to the orders list view, showing updated order statuses

## Alternative Paths

### A. Partial Fulfillment

If only some items can be fulfilled due to inventory constraints:

1. User marks available items as prepared
2. User selects "Partial Fulfillment" option
3. System prompts for reason and handling of unfulfilled items
4. User selects whether to backorder, substitute, or refund unfulfilled items
5. System updates order with partial fulfillment status and creates follow-up actions for unfulfilled items

### B. Fulfillment with Substitutions

If substitutions are needed or requested:

1. User identifies item needing substitution
2. User clicks "Substitute Item" option
3. System displays available substitutes based on category and attributes
4. User selects appropriate substitute and quantity
5. System updates order with substitution information
6. Fulfillment continues with substituted item

### C. Batch Fulfillment

For fulfilling multiple orders simultaneously:

1. User selects multiple orders from orders list
2. User selects "Batch Fulfill" option
3. System groups items by product across all selected orders
4. User prepares products in batches and assigns to respective orders
5. System updates all orders simultaneously as fulfillment progresses

### D. Curbside/Delivery Handoff

For orders requiring handoff to customer or delivery service:

1. User completes standard fulfillment steps
2. User selects "Prepare for Handoff" option
3. System prompts for handoff method (curbside, delivery service, etc.)
4. User enters relevant handoff details (parking spot, delivery service, etc.)
5. System generates handoff instructions and notifications
6. Order remains in "Awaiting Handoff" status until confirmed delivered

## Edge Cases and Error States

### Inventory Discrepancies

- **Scenario**: Actual inventory doesn't match system inventory during fulfillment
- **Handling**: System allows manual override with manager approval, logs discrepancy, and triggers inventory audit

### Customer Cancellation During Fulfillment

- **Scenario**: Customer cancels order while fulfillment is in progress
- **Handling**: System alerts fulfillment staff, provides option to continue or abort fulfillment, and guides through return-to-inventory process

### Payment Processing Failures

- **Scenario**: Payment cannot be processed at fulfillment completion
- **Handling**: System allows order to be placed on hold, provides payment retry options, and allows fulfillment to continue with manager override

### Regulatory Compliance Issues

- **Scenario**: System detects potential regulatory issue (purchase limits, restricted products)
- **Handling**: System blocks fulfillment completion, alerts manager, and provides compliance information

## Performance Considerations

1. **Batch Processing**: Optimize for batch operations when fulfilling multiple orders
2. **Offline Capabilities**: Allow basic fulfillment operations to continue during temporary connectivity issues
3. **Barcode Scanning**: Ensure fast and accurate barcode scanning for efficient product verification
4. **Print Queue Management**: Optimize receipt and label printing to prevent bottlenecks
5. **Real-time Inventory Updates**: Balance immediate inventory updates with system performance

## Related Flows

- [Order List View Flow](./order_list_view_flow.md)
- [Order Detail View Flow](./order_detail_view_flow.md)
- [Order Status Update Flow](./order_status_update_flow.md)
- [Order Cancellation Flow](./order_cancellation_flow.md)
- [Inventory Management Flow](./inventory_management_flow.md)

## Components Used

- OrdersList
- OrderDetailView
- FulfillmentWorkflow
- ProductChecklist
- InventoryVerification
- PaymentProcessor
- ReceiptGenerator
- StatusUpdateModal
- BarcodeScanner
- PackagingForm
- PrintManager

## API Endpoints Used

- `GET /api/v1/orders` - Load orders list
- `GET /api/v1/orders/:id` - Load specific order details
- `PUT /api/v1/orders/:id/status` - Update order status
- `GET /api/v1/inventory/check` - Verify inventory availability
- `PUT /api/v1/orders/:id/items/:itemId/status` - Update status of specific order items
- `PUT /api/v1/orders/:id/package` - Update package information
- `POST /api/v1/orders/:id/payments` - Process or record payment
- `GET /api/v1/orders/:id/documents/receipt` - Generate receipt or packing slip

## Diagrams

### Sequence Diagram

```
User                    CMS UI                  Order Service           Inventory Service        Payment Service
 |                        |                           |                        |                      |
 |--Navigate to Orders--->|                           |                        |                      |
 |                        |---Get Orders List-------->|                        |                      |
 |                        |<--Return Orders List------|                        |                      |
 |--Select Order--------->|                           |                        |                      |
 |                        |---Get Order Details------>|                        |                      |
 |                        |<--Return Order Details----|                        |                      |
 |--Begin Fulfillment---->|                           |                        |                      |
 |                        |---Update Order Status---->|                        |                      |
 |                        |<--Status Updated----------|                        |                      |
 |                        |---Check Inventory---------|----------------------->|                      |
 |                        |<--Inventory Status--------|------------------------|                      |
 |--Mark Items Prepared-->|                           |                        |                      |
 |                        |---Update Item Status----->|                        |                      |
 |                        |<--Items Updated-----------|                        |                      |
 |--Complete Fulfillment->|                           |                        |                      |
 |                        |---Update Order Status---->|                        |                      |
 |                        |<--Status Updated----------|                        |                      |
 |--Process Payment------>|                           |                        |                      |
 |                        |---Process Payment---------|------------------------|--------------------->|
 |                        |<--Payment Confirmed-------|------------------------|----------------------|
 |--Complete Order------->|                           |                        |                      |
 |                        |---Update Order Status---->|                        |                      |
 |                        |---Update Inventory--------|----------------------->|                      |
 |                        |<--Order Completed---------|------------------------|                      |
```

### State Diagram

```
[Order Created] ---> [Order Confirmed] ---> [Fulfillment Started] ---> [Items Prepared]
                                                                            |
                                                                            v
[Order Completed] <--- [Payment Processed] <--- [Order Fulfilled] <--- [Package Prepared]
```

## Security Considerations

1. **Permission Checks**: Enforce role-based access control for all fulfillment actions
2. **Audit Logging**: Log all fulfillment activities with user, timestamp, and action details
3. **Payment Information Security**: Ensure payment processing follows PCI compliance standards
4. **Customer Data Protection**: Limit exposure of customer personal information to necessary staff
5. **Inventory Adjustment Authorization**: Require appropriate authorization for inventory adjustments
6. **Receipt/Label Printing Security**: Ensure sensitive information is appropriately handled on printed materials

## Testing

### Test Cases

1. **Standard Fulfillment Flow**
   - Verify complete fulfillment process works end-to-end
   - Ensure inventory is correctly updated
   - Confirm order status changes appropriately

2. **Partial Fulfillment**
   - Test partial fulfillment with various reasons
   - Verify handling of unfulfilled items
   - Ensure appropriate notifications are generated

3. **Error Handling**
   - Test behavior when inventory is insufficient
   - Verify system response to payment processing failures
   - Test network connectivity issues during fulfillment

4. **Performance Testing**
   - Measure fulfillment completion time for various order sizes
   - Test system performance during batch fulfillment
   - Verify printing performance for receipts and labels

5. **Security Testing**
   - Verify permission enforcement for different user roles
   - Test audit logging accuracy and completeness
   - Ensure customer data is appropriately protected

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-02 | AI Assistant | Initial creation of order fulfillment flow documentation | 