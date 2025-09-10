---
title: CMS Order Cancellation Flow
description: Documentation of the order cancellation process in the CMS application
last_updated: 2023-08-02
contributors: [AI Assistant]
---

# CMS Order Cancellation Flow

## Overview

The Order Cancellation Flow enables dispensary staff to cancel customer orders through The Peak Beyond's CMS application. This flow is essential for handling situations where orders cannot be fulfilled, customers request cancellations, or other business circumstances require order termination. The cancellation process includes verification, authorization, inventory management, customer notification, and record-keeping.

## User Roles

| Role | Permissions |
|------|-------------|
| Admin | Can cancel any order at any stage |
| Store Manager | Can cancel orders for their assigned store |
| Order Fulfillment Staff | Can initiate cancellation requests, but may require approval for certain order stages |
| Customer Service | Can cancel orders based on customer requests |

## Preconditions

1. User is authenticated in the CMS
2. User has appropriate permissions to cancel orders
3. Order exists in the system in a status that allows cancellation
4. User has navigated to either the order list view or order detail view

## Flow Steps

### From Order Detail View

1. **Review Order Details**
   - **Components**: OrderDetailComponent, OrderSummaryComponent
   - **State**: Order details loaded
   - **API Call**: None (data already loaded)
   - **User Interaction**: User reviews order information to confirm cancellation is appropriate
   - **System Response**: System displays complete order information

2. **Initiate Cancellation**
   - **Components**: OrderActionsComponent, ButtonComponent
   - **State**: Order details displayed
   - **API Call**: None (action initiation only)
   - **User Interaction**: User clicks "Cancel Order" button
   - **System Response**: System displays cancellation confirmation dialog

3. **Provide Cancellation Reason**
   - **Components**: CancellationDialogComponent, DropdownComponent, TextAreaComponent
   - **State**: Cancellation dialog displayed
   - **API Call**: None (form interaction only)
   - **User Interaction**: User selects cancellation reason from dropdown and adds optional notes
   - **System Response**: System validates input

4. **Confirm Cancellation**
   - **Components**: CancellationDialogComponent, ButtonComponent
   - **State**: Cancellation reason provided
   - **API Call**: None (confirmation only)
   - **User Interaction**: User clicks "Confirm Cancellation" button
   - **System Response**: System may display additional confirmation for orders in advanced stages

5. **Process Cancellation**
   - **Components**: LoadingIndicatorComponent
   - **State**: Cancellation confirmed
   - **API Call**: `PUT /api/v1/orders/:id/status` with status="cancelled" and reason data
   - **User Interaction**: None (waiting)
   - **System Response**: System processes cancellation, including:
     - Updating order status in database
     - Recording cancellation reason and user information
     - Returning inventory items to stock
     - Triggering customer notification if applicable
     - Processing refund if applicable

6. **Display Cancellation Confirmation**
   - **Components**: AlertComponent, OrderDetailComponent
   - **State**: Cancellation processed
   - **API Call**: None (update already processed)
   - **User Interaction**: None (automatic)
   - **System Response**: System displays success message and updates order details with cancelled status

7. **Return to Orders List (Optional)**
   - **Components**: NavigationComponent, ButtonComponent
   - **State**: Order cancelled
   - **API Call**: None (navigation only)
   - **User Interaction**: User clicks "Back to Orders" button
   - **System Response**: System navigates back to orders list view

### From Order List View

1. **Locate Order to Cancel**
   - **Components**: OrderListComponent, SearchFilterComponent
   - **State**: Orders list loaded
   - **API Call**: None (data already loaded)
   - **User Interaction**: User locates order using search or filters
   - **System Response**: System displays filtered list of orders

2. **Initiate Quick Cancellation**
   - **Components**: OrderRowComponent, ActionMenuComponent
   - **State**: Orders list displayed
   - **API Call**: None (action initiation only)
   - **User Interaction**: User clicks action menu and selects "Cancel Order"
   - **System Response**: System displays cancellation confirmation dialog

3. **Provide Cancellation Reason**
   - **Components**: CancellationDialogComponent, DropdownComponent, TextAreaComponent
   - **State**: Cancellation dialog displayed
   - **API Call**: None (form interaction only)
   - **User Interaction**: User selects cancellation reason and adds optional notes
   - **System Response**: System validates input

4. **Confirm Cancellation**
   - **Components**: CancellationDialogComponent, ButtonComponent
   - **State**: Cancellation reason provided
   - **API Call**: `PUT /api/v1/orders/:id/status` with status="cancelled" and reason data
   - **User Interaction**: User clicks "Confirm Cancellation" button
   - **System Response**: System processes cancellation (same as in detail view)

5. **Display Cancellation Confirmation**
   - **Components**: AlertComponent, OrderListComponent
   - **State**: Cancellation processed
   - **API Call**: None (update already processed)
   - **User Interaction**: None (automatic)
   - **System Response**: System displays success message and updates order row with cancelled status

## Alternative Paths

### A1. Bulk Order Cancellation

If multiple orders need to be cancelled simultaneously:

1. From orders list, user selects multiple orders using checkboxes
2. User clicks "Bulk Actions" dropdown and selects "Cancel Orders"
3. System displays cancellation dialog with count of selected orders
4. User selects common cancellation reason and adds notes
5. User confirms cancellation
6. System processes cancellation for all selected orders
7. System displays progress and results

### A2. Cancellation Requiring Approval

If the user doesn't have full cancellation authority:

1. User initiates cancellation process
2. System identifies that approval is required
3. System displays approval request form
4. User completes form with justification
5. User submits cancellation request
6. System notifies authorized approvers
7. Approver reviews and approves/rejects request
8. System completes cancellation if approved

### A3. Partial Order Cancellation

If only specific items in an order need to be cancelled:

1. User navigates to order detail view
2. User selects "Modify Order" option
3. User selects items to remove from order
4. User provides reason for partial cancellation
5. User confirms partial cancellation
6. System updates order with removed items and adjusts totals
7. System returns cancelled items to inventory
8. System notifies customer of partial cancellation

### A4. Customer-Requested Cancellation

If cancellation is initiated based on customer request:

1. User selects "Customer Requested" as cancellation reason
2. System displays additional fields for customer contact information
3. User enters customer contact details and request timestamp
4. User confirms cancellation
5. System processes cancellation with customer request details
6. System generates customer communication confirming cancellation

## Cancellation Reason Categories

| Category | Description | Examples |
|----------|-------------|----------|
| Customer Requested | Cancellation requested by customer | Changed mind, found better price, no longer needed |
| Inventory Issues | Items not available in stock | Out of stock, inventory discrepancy, quality issues |
| Payment Problems | Issues with payment processing | Payment declined, payment method invalid, fraud suspected |
| Regulatory Compliance | Cancellation due to compliance issues | Purchase limits exceeded, restricted product, age verification failed |
| Operational Issues | Internal operational problems | Staff shortage, system issues, delivery unavailable |
| Duplicate Order | Order is a duplicate of another order | Customer submitted twice, system error created duplicate |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Cancellation after fulfillment started | Require higher-level approval, handle partially prepared items |
| Cancellation after payment processed | Initiate refund process, generate refund documentation |
| Cancellation with loyalty points/rewards | Restore customer loyalty points, document restoration |
| Cancellation of recurring order | Option to cancel just this instance or all future orders |
| Cancellation during system maintenance | Queue cancellation request for processing after maintenance |
| Cancellation with missing inventory data | Flag for inventory reconciliation, proceed with cancellation |

## Error States

| Error | Handling |
|-------|----------|
| API failure during cancellation | Display error message with retry option |
| Inventory return failure | Complete cancellation, flag inventory for manual reconciliation |
| Notification failure | Complete cancellation, flag for manual customer communication |
| Refund processing failure | Complete cancellation, flag for manual refund processing |
| Concurrent modification | Warn about changes made by another user and offer refresh |
| Required approver unavailable | Offer escalation path or queue for later approval |

## Performance Considerations

1. **Asynchronous Processing**: Process inventory returns and notifications asynchronously
2. **Batch Processing**: Optimize bulk cancellations to minimize database operations
3. **Optimistic UI Updates**: Update UI immediately while processing backend changes
4. **Background Refund Processing**: Handle payment refunds in background jobs
5. **Notification Batching**: Batch customer notifications for bulk cancellations
6. **Cancellation Analytics**: Track cancellation metrics without impacting performance

## Related Flows

- [Order List View Flow](order_list_view_flow.md)
- [Order Detail View Flow](order_detail_view_flow.md)
- [Order Status Update Flow](order_status_update_flow.md)
- [Order Fulfillment Flow](order_fulfillment_flow.md)
- [Refund Processing Flow](refund_processing_flow.md)

## Components Used

- OrderDetailComponent
- OrderSummaryComponent
- OrderActionsComponent
- CancellationDialogComponent
- DropdownComponent
- TextAreaComponent
- ButtonComponent
- LoadingIndicatorComponent
- AlertComponent
- OrderListComponent
- SearchFilterComponent
- OrderRowComponent
- ActionMenuComponent
- BulkActionComponent
- NavigationComponent

## API Endpoints Used

- `PUT /api/v1/orders/:id/status` - Update order status to cancelled
- `POST /api/v1/orders/bulk_update` - Update multiple orders' status
- `POST /api/v1/orders/:id/refund` - Process refund for cancelled order
- `PUT /api/v1/inventory/return` - Return items to inventory
- `POST /api/v1/notifications/customer` - Send cancellation notification to customer
- `POST /api/v1/orders/:id/approval_request` - Request approval for cancellation

## Diagrams

### Sequence Diagram

```
User                    CMS UI                  Order Service           Inventory Service        Payment Service
 |                        |                           |                        |                      |
 |--Review Order--------->|                           |                        |                      |
 |                        |                           |                        |                      |
 |--Initiate Cancellation>|                           |                        |                      |
 |                        |                           |                        |                      |
 |<--Display Dialog-------|                           |                        |                      |
 |                        |                           |                        |                      |
 |--Provide Reason------->|                           |                        |                      |
 |                        |                           |                        |                      |
 |--Confirm Cancellation->|                           |                        |                      |
 |                        |                           |                        |                      |
 |                        |---Cancel Order----------->|                        |                      |
 |                        |                           |                        |                      |
 |                        |                           |---Return Inventory---->|                      |
 |                        |                           |                        |                      |
 |                        |                           |<--Inventory Updated----|                      |
 |                        |                           |                        |                      |
 |                        |                           |---Process Refund-------|--------------------->|
 |                        |                           |                        |                      |
 |                        |                           |<--Refund Confirmed-----|----------------------|
 |                        |                           |                        |                      |
 |                        |<--Cancellation Complete---|                        |                      |
 |                        |                           |                        |                      |
 |<--Display Confirmation-|                           |                        |                      |
 |                        |                           |                        |                      |
```

### State Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Active Order   │────>│  Cancellation   │────>│  Reason         │
│  State          │     │  Initiated      │     │  Provided       │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        │
                                                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Cancelled      │<────│  Processing     │<────│  Cancellation   │
│  State          │     │  Cancellation   │     │  Confirmed      │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Security Considerations

1. **Permission Checks**: Enforce role-based access control for cancellation actions
2. **Approval Workflows**: Implement approval requirements for high-value or late-stage cancellations
3. **Audit Logging**: Log all cancellation activities with user, timestamp, and reason details
4. **Refund Authorization**: Ensure proper authorization for refund processing
5. **Customer Data Protection**: Limit exposure of customer personal information
6. **Cancellation Limits**: Monitor for unusual cancellation patterns that might indicate abuse
7. **Notification Security**: Ensure customer notifications don't expose sensitive order details

## Testing

### Test Cases

1. **Standard Cancellation Flow**
   - Verify complete cancellation process works end-to-end
   - Ensure inventory is correctly returned to stock
   - Confirm order status changes appropriately
   - Verify cancellation reason is recorded

2. **Cancellation with Refund**
   - Test cancellation of paid orders
   - Verify refund is processed correctly
   - Ensure refund documentation is generated

3. **Bulk Cancellation**
   - Test cancelling multiple orders simultaneously
   - Verify all orders are processed correctly
   - Ensure proper error handling for partial failures

4. **Cancellation Requiring Approval**
   - Test approval workflow for restricted cancellations
   - Verify notification to approvers
   - Test approval and rejection paths

5. **Partial Order Cancellation**
   - Test cancelling specific items in an order
   - Verify order totals are recalculated correctly
   - Ensure only specified items are returned to inventory

6. **Security Testing**
   - Verify permission enforcement for different user roles
   - Test audit logging accuracy and completeness
   - Ensure customer data is appropriately protected

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-02 | AI Assistant | Initial creation of order cancellation flow documentation | 