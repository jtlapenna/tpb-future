---
title: CMS Order Detail View Flow
description: Documentation of the order detail view flow in The Peak Beyond's CMS application
last_updated: 2023-08-02
contributors: [AI Assistant]
---

# CMS Order Detail View Flow

## Overview

The Order Detail View Flow allows dispensary staff to view comprehensive information about a specific customer order through The Peak Beyond's Content Management System (CMS). This flow provides a detailed view of order information, including customer details, product items, payment information, status history, and fulfillment details. The detail view serves as the central hub for order management actions such as updating status, processing fulfillment, and handling customer communications.

## User Roles

- **Admin**: Can view all order details across all stores and perform all actions
- **Store Manager**: Can view order details for their assigned store(s) and perform all actions
- **Order Fulfillment Staff**: Can view order details for their assigned store(s) and perform fulfillment actions
- **Reporting User**: Can view order details but cannot modify them

## Preconditions

- User is authenticated in the CMS
- User has appropriate permissions to view order details
- Order exists in the system
- User has navigated to the order detail view (typically from the orders list)

## Flow Steps

1. **Load Order Details**
   - Components: OrderDetailComponent, LoadingIndicatorComponent
   - State: Loading state
   - API Calls: GET `/api/v1/orders/:id`
   - User Interaction: None (automatic after navigation to order detail page)
   - System Response: System displays loading indicator while fetching order details

2. **Display Order Summary**
   - Components: OrderSummaryComponent, StatusBadgeComponent
   - State: Order details loaded
   - API Calls: None (data already loaded)
   - User Interaction: None (automatic)
   - System Response: System displays order summary information:
     - Order ID/Number
     - Order date/time
     - Current status with visual indicator
     - Total amount
     - Payment method
     - Customer name and contact information

3. **Display Order Items**
   - Components: OrderItemsComponent, OrderItemRowComponent
   - State: Order details loaded
   - API Calls: None (data already loaded)
   - User Interaction: None (automatic)
   - System Response: System displays list of ordered items with details:
     - Product name and image
     - Quantity
     - Price per unit
     - Subtotal
     - Product options/variants
     - Special instructions (if any)

4. **Display Payment Information**
   - Components: PaymentInfoComponent
   - State: Order details loaded
   - API Calls: None (data already loaded)
   - User Interaction: None (automatic)
   - System Response: System displays payment details:
     - Payment method
     - Transaction ID
     - Payment status
     - Subtotal, tax, discounts, and total
     - Receipt information

5. **Display Customer Information**
   - Components: CustomerInfoComponent
   - State: Order details loaded
   - API Calls: None (data already loaded)
   - User Interaction: None (automatic)
   - System Response: System displays customer details:
     - Name
     - Contact information (phone, email)
     - Customer ID/loyalty information
     - Order history link
     - Age verification status

6. **Display Order History**
   - Components: OrderHistoryComponent, TimelineComponent
   - State: Order details loaded
   - API Calls: GET `/api/v1/orders/:id/history`
   - User Interaction: None (automatic)
   - System Response: System displays order status history in a timeline:
     - Status changes with timestamps
     - User who made each change
     - Notes associated with each status change

7. **Update Order Status**
   - Components: StatusUpdateComponent, DropdownComponent, TextAreaComponent
   - State: Order details loaded
   - API Calls: PUT `/api/v1/orders/:id`
   - User Interaction: User selects new status from dropdown, optionally adds notes, and clicks "Update Status"
   - System Response: System updates order status, adds entry to history, and refreshes order details

8. **Process Order Fulfillment**
   - Components: FulfillmentComponent, ChecklistComponent, ButtonComponent
   - State: Order details loaded
   - API Calls: PUT `/api/v1/orders/:id/fulfill`
   - User Interaction: User marks items as prepared, confirms fulfillment details, and clicks "Process Fulfillment"
   - System Response: System processes fulfillment, updates order status, and refreshes order details

9. **Print Order Documents**
   - Components: PrintOptionsComponent, ButtonComponent
   - State: Order details loaded
   - API Calls: GET `/api/v1/orders/:id/print?type=receipt|label|invoice`
   - User Interaction: User selects document type and clicks "Print"
   - System Response: System generates and downloads or displays the requested document

10. **Cancel Order**
    - Components: CancelOrderComponent, ConfirmationModalComponent, TextAreaComponent
    - State: Order details loaded
    - API Calls: PUT `/api/v1/orders/:id/cancel`
    - User Interaction: User clicks "Cancel Order", provides reason, and confirms cancellation
    - System Response: System cancels the order, updates status, and refreshes order details

11. **Navigate Back to Orders List**
    - Components: NavigationComponent, ButtonComponent
    - State: Order details loaded
    - API Calls: None (navigation only)
    - User Interaction: User clicks "Back to Orders" or breadcrumb navigation
    - System Response: System navigates back to the orders list view

## Alternative Paths

### A1. Edit Order Items

If the order has not been processed and store policy allows editing:

1. User clicks "Edit Items" button
2. System displays editable item list
3. User modifies quantities, removes items, or adds new items
4. User confirms changes
5. System updates order and recalculates totals

### A2. Apply Discount

If store policy allows post-order discounts:

1. User clicks "Apply Discount" button
2. System displays discount options
3. User selects discount type and amount
4. User provides reason for discount
5. System applies discount, updates totals, and adds note to history

### A3. Customer Communication

If communication with the customer is needed:

1. User clicks "Contact Customer" button
2. System displays communication options (SMS, email)
3. User selects method and enters message
4. System sends communication and logs it in order history

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Order not found | Display error message with navigation back to orders list |
| Order in transitional state | Display warning about transitional state and refresh options |
| Order with refunded items | Clearly indicate refunded items and refund amounts |
| Order with price adjustments | Show original and adjusted prices with explanation |
| Order with special requirements | Highlight special requirements with visual indicators |
| Order with age verification issues | Display prominent warning and verification instructions |
| Order with inventory discrepancies | Show inventory warnings and resolution options |

## Error States

| Error | Handling |
|-------|----------|
| API failure when loading order | Display error message with retry option |
| Status update failure | Show specific error message and allow retry |
| Fulfillment processing error | Display detailed error information and troubleshooting steps |
| Print generation failure | Show error with alternative download options |
| Cancellation failure | Explain reason for failure and alternative actions |
| Concurrent modification | Warn about changes made by another user and offer refresh |

## Performance Considerations

1. **Lazy Loading**: Load order history and detailed information on demand
2. **Optimistic Updates**: Update UI immediately while processing backend changes
3. **Caching**: Cache order details for quick access during the session
4. **Background Refreshing**: Periodically check for order updates in the background
5. **Print Preparation**: Generate print documents in the background while user continues working
6. **Efficient API Calls**: Combine related data in single API calls to reduce requests

## Related Flows

- [Order List View Flow](order_list_view_flow.md)
- [Order Status Update Flow](order_status_update_flow.md)
- [Order Fulfillment Flow](order_fulfillment_flow.md)
- [Order Cancellation Flow](order_cancellation_flow.md)

## Components Used

| Component | Role | Description |
|-----------|------|-------------|
| OrderDetailComponent | Container | Main component for displaying order details |
| OrderSummaryComponent | Feature | Displays order summary information |
| StatusBadgeComponent | UI | Visual indicator of order status |
| OrderItemsComponent | Feature | Displays list of ordered items |
| OrderItemRowComponent | UI | Displays individual order item |
| PaymentInfoComponent | Feature | Displays payment details |
| CustomerInfoComponent | Feature | Displays customer information |
| OrderHistoryComponent | Feature | Displays order status history |
| TimelineComponent | UI | Displays chronological events |
| StatusUpdateComponent | Feature | Allows updating order status |
| DropdownComponent | UI | Provides selection options |
| TextAreaComponent | UI | Input for notes and comments |
| FulfillmentComponent | Feature | Manages order fulfillment process |
| ChecklistComponent | UI | Checklist for fulfillment steps |
| PrintOptionsComponent | Feature | Options for printing documents |
| CancelOrderComponent | Feature | Handles order cancellation |
| ConfirmationModalComponent | UI | Confirms destructive actions |
| NavigationComponent | UI | Provides navigation controls |
| ButtonComponent | UI | Action buttons |
| LoadingIndicatorComponent | UI | Indicates loading state |

## API Endpoints Used

| Endpoint | Method | Purpose | Request Data | Response Data |
|----------|--------|---------|--------------|---------------|
| `/api/v1/orders/:id` | GET | Fetch order details | Order ID | Complete order details |
| `/api/v1/orders/:id/history` | GET | Fetch order history | Order ID | Status history timeline |
| `/api/v1/orders/:id` | PUT | Update order status | Order ID, status, notes | Updated order |
| `/api/v1/orders/:id/fulfill` | PUT | Process fulfillment | Order ID, fulfillment details | Fulfillment confirmation |
| `/api/v1/orders/:id/print` | GET | Generate printable document | Order ID, document type | Document file |
| `/api/v1/orders/:id/cancel` | PUT | Cancel order | Order ID, reason | Cancellation confirmation |
| `/api/v1/orders/:id/items` | PUT | Update order items | Order ID, updated items | Updated order |
| `/api/v1/orders/:id/discount` | POST | Apply discount | Order ID, discount details | Updated order |
| `/api/v1/orders/:id/contact` | POST | Contact customer | Order ID, message, method | Communication confirmation |

## Diagrams

### Sequence Diagram

```
User                    OrderDetailComponent       API
 |                              |                   |
 |                              |                   |
 |                              |---(1) Fetch Order--->|
 |                              |                   |
 |                              |<---(2) Order Details-|
 |                              |                   |
 |<---(3) Display Order---------|                   |
 |                              |                   |
 |                              |---(4) Fetch History->|
 |                              |                   |
 |                              |<---(5) Order History-|
 |                              |                   |
 |<---(6) Display History-------|                   |
 |                              |                   |
 |---(7) Update Status--------->|                   |
 |                              |                   |
 |                              |---(8) Update Order-->|
 |                              |                   |
 |                              |<---(9) Confirmation--|
 |                              |                   |
 |<---(10) Refresh Display------|                   |
 |                              |                   |
```

### State Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Initial State  │────>│  Loading Order  │────>│  Order Loaded   │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        │
                                                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Order Updated  │<────│  Updating Order │<────│  Action Selected│
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │
        │
        ▼
┌─────────────────┐
│                 │
│  Navigation     │
│  Away           │
└─────────────────┘
```

## Security Considerations

1. **Permission Checks**: Ensure users can only view and modify orders they have permission to access
2. **Sensitive Data Handling**: Mask sensitive customer and payment information based on user role
3. **Audit Logging**: Log all order view and modification actions for audit purposes
4. **CSRF Protection**: Implement CSRF tokens for all form submissions
5. **Input Validation**: Validate all input data before processing updates
6. **Rate Limiting**: Implement rate limiting to prevent abuse
7. **Action Authorization**: Verify user has permission for specific actions (cancel, refund, etc.)

## Testing

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| Load Order | Load the order details | Order details displayed correctly |
| View Order History | View the order status history | Timeline of status changes displayed |
| Update Status | Change order status | Status updated and reflected in UI |
| Process Fulfillment | Process order fulfillment | Order marked as fulfilled with updated status |
| Print Receipt | Generate and print receipt | Receipt document generated and downloaded |
| Cancel Order | Cancel an order | Order status changed to cancelled |
| Edit Items | Modify order items | Order updated with new items and totals |
| Apply Discount | Apply discount to order | Discount applied and totals updated |
| Contact Customer | Send message to customer | Message sent and logged in history |
| Navigation | Navigate back to orders list | Return to orders list view |

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-02 | AI Assistant | Initial documentation of order detail view flow | 