---
title: CMS Order Status Update Flow
description: Documentation of the order status update flow in The Peak Beyond's CMS application
last_updated: 2023-08-02
contributors: [AI Assistant]
---

# CMS Order Status Update Flow

## Overview

The Order Status Update Flow allows dispensary staff to change the status of customer orders through The Peak Beyond's Content Management System (CMS). This flow is critical for tracking order progress from initial submission through processing, fulfillment, and completion. Status updates trigger notifications to customers, update inventory, and maintain an audit trail of order history. The flow can be initiated from both the order list view and the order detail view.

## User Roles

- **Admin**: Can update status for any order across all stores
- **Store Manager**: Can update status for orders in their assigned store(s)
- **Order Fulfillment Staff**: Can update status for orders in their assigned store(s), limited to certain status transitions
- **Reporting User**: Cannot update order status (view-only access)

## Preconditions

- User is authenticated in the CMS
- User has appropriate permissions to update order status
- Order exists in the system
- User has navigated to either the order list view or order detail view

## Flow Steps

### From Order Detail View

1. **View Current Order Status**
   - Components: OrderDetailComponent, StatusBadgeComponent
   - State: Order details loaded
   - API Calls: None (data already loaded)
   - User Interaction: None (automatic)
   - System Response: System displays current order status with visual indicator

2. **Initiate Status Update**
   - Components: StatusUpdateComponent, ButtonComponent
   - State: Order details loaded
   - API Calls: None (action initiation only)
   - User Interaction: User clicks "Update Status" button
   - System Response: System displays status update form with available status options

3. **Select New Status**
   - Components: StatusUpdateComponent, DropdownComponent
   - State: Status update form displayed
   - API Calls: None (form interaction only)
   - User Interaction: User selects new status from dropdown
   - System Response: System may display additional fields based on selected status

4. **Add Status Notes**
   - Components: StatusUpdateComponent, TextAreaComponent
   - State: Status update form with status selected
   - API Calls: None (form interaction only)
   - User Interaction: User optionally enters notes about the status change
   - System Response: System validates input

5. **Submit Status Update**
   - Components: StatusUpdateComponent, ButtonComponent, LoadingIndicatorComponent
   - State: Status update form completed
   - API Calls: PUT `/api/v1/orders/:id` with status data
   - User Interaction: User clicks "Save" or "Update" button
   - System Response: System shows loading indicator while processing update

6. **Process Status Update**
   - Components: LoadingIndicatorComponent
   - State: Processing update
   - API Calls: None (waiting for response from previous call)
   - User Interaction: None (waiting)
   - System Response: System processes status update, including:
     - Updating order status in database
     - Recording status change in order history
     - Triggering notifications if applicable
     - Updating inventory if applicable

7. **Display Update Confirmation**
   - Components: AlertComponent, OrderDetailComponent
   - State: Update completed
   - API Calls: None (update already processed)
   - User Interaction: None (automatic)
   - System Response: System displays success message and refreshes order details with new status

### From Order List View

1. **View Orders List**
   - Components: OrderListComponent, OrderRowComponent
   - State: Orders list loaded
   - API Calls: None (data already loaded)
   - User Interaction: None (automatic)
   - System Response: System displays list of orders with current status

2. **Initiate Quick Status Update**
   - Components: OrderRowComponent, StatusDropdownComponent
   - State: Orders list displayed
   - API Calls: None (action initiation only)
   - User Interaction: User clicks on status dropdown in order row
   - System Response: System displays available status options

3. **Select New Status**
   - Components: StatusDropdownComponent
   - State: Status dropdown expanded
   - API Calls: None (selection only)
   - User Interaction: User selects new status from dropdown
   - System Response: System may display confirmation dialog for certain status changes

4. **Confirm Status Update**
   - Components: ConfirmationModalComponent, TextAreaComponent
   - State: Confirmation dialog displayed
   - API Calls: None (confirmation only)
   - User Interaction: User confirms status change, optionally adding notes
   - System Response: System validates input

5. **Submit Status Update**
   - Components: ConfirmationModalComponent, LoadingIndicatorComponent
   - State: Confirmation provided
   - API Calls: PUT `/api/v1/orders/:id` with status data
   - User Interaction: User clicks "Confirm" button
   - System Response: System shows loading indicator while processing update

6. **Process Status Update**
   - Components: LoadingIndicatorComponent
   - State: Processing update
   - API Calls: None (waiting for response from previous call)
   - User Interaction: None (waiting)
   - System Response: System processes status update (same as in detail view)

7. **Display Update Confirmation**
   - Components: AlertComponent, OrderRowComponent
   - State: Update completed
   - API Calls: None (update already processed)
   - User Interaction: None (automatic)
   - System Response: System displays success message and updates order row with new status

## Alternative Paths

### A1. Bulk Status Update

If the user wants to update status for multiple orders at once:

1. From orders list, user selects multiple orders using checkboxes
2. User clicks "Bulk Actions" dropdown and selects "Update Status"
3. System displays status update dialog with count of selected orders
4. User selects new status and optionally adds notes
5. User confirms update
6. System processes status update for all selected orders
7. System displays progress and results

### A2. Status Update with Required Fields

If the selected status requires additional information:

1. User selects a status that requires additional information (e.g., "Rejected")
2. System displays additional required fields (e.g., rejection reason)
3. User completes required fields
4. User submits status update
5. System validates all required fields before processing

### A3. Automated Status Updates

If status updates are triggered by external events:

1. External system (e.g., POS) sends status update notification
2. System automatically updates order status
3. System records status change in order history
4. System displays updated status to any users viewing the order

## Status Transition Rules

| Current Status | Allowed Next Status | Notes |
|----------------|---------------------|-------|
| New | Processing, Cancelled | Initial status when order is created |
| Processing | Ready for Pickup, Completed, Cancelled | Order is being prepared |
| Ready for Pickup | Completed, Cancelled | Order is ready for customer pickup |
| Completed | - | Terminal status, no further transitions allowed |
| Cancelled | - | Terminal status, no further transitions allowed |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Invalid status transition | Prevent transition and display explanation |
| Status update without permission | Display permission error and log attempt |
| Concurrent status updates | Implement optimistic locking and conflict resolution |
| Status update for completed order | Prevent update and display explanation |
| Status update for cancelled order | Prevent update and display explanation |
| Status update with inventory implications | Validate inventory before allowing update |
| Status update with payment implications | Validate payment status before allowing update |

## Error States

| Error | Handling |
|-------|----------|
| API failure during update | Display error message with retry option |
| Validation failure | Display specific validation errors and highlight fields |
| Inventory constraint violation | Display inventory issue and suggest resolution |
| Payment constraint violation | Display payment issue and suggest resolution |
| Concurrent modification | Warn about changes made by another user and offer refresh |
| Network disconnection during update | Preserve form state and retry when connection restored |

## Performance Considerations

1. **Optimistic Updates**: Update UI immediately while processing backend changes
2. **Debounced Submissions**: Prevent multiple rapid submissions of the same form
3. **Efficient Validation**: Validate input on the client side before sending to server
4. **Background Processing**: Process complex status change implications in background jobs
5. **Notification Batching**: Batch notifications for bulk status updates
6. **Caching**: Cache order status for quick access during the session

## Related Flows

- [Order List View Flow](order_list_view_flow.md)
- [Order Detail View Flow](order_detail_view_flow.md)
- [Order Fulfillment Flow](order_fulfillment_flow.md)
- [Order Cancellation Flow](order_cancellation_flow.md)

## Components Used

| Component | Role | Description |
|-----------|------|-------------|
| OrderDetailComponent | Container | Main component for displaying order details |
| StatusBadgeComponent | UI | Visual indicator of order status |
| StatusUpdateComponent | Feature | Form for updating order status |
| DropdownComponent | UI | Dropdown for selecting status |
| TextAreaComponent | UI | Input for status notes |
| ButtonComponent | UI | Action buttons for form submission |
| LoadingIndicatorComponent | UI | Indicates loading state |
| AlertComponent | UI | Displays success or error messages |
| OrderListComponent | Container | Displays list of orders |
| OrderRowComponent | UI | Displays individual order in list |
| StatusDropdownComponent | UI | Quick status update dropdown in list view |
| ConfirmationModalComponent | UI | Confirms status update |
| BulkActionComponent | Feature | Handles bulk status updates |

## API Endpoints Used

| Endpoint | Method | Purpose | Request Data | Response Data |
|----------|--------|---------|--------------|---------------|
| `/api/v1/orders/:id` | PUT | Update order status | Order ID, status, notes | Updated order |
| `/api/v1/orders/bulk_update` | POST | Update multiple orders | Order IDs, status, notes | Success status, results |
| `/api/v1/orders/:id/history` | GET | Fetch order history | Order ID | Status history timeline |
| `/api/v1/orders/:id/allowed_statuses` | GET | Fetch allowed status transitions | Order ID | List of allowed statuses |

## Diagrams

### Sequence Diagram (Detail View)

```
User                    StatusUpdateComponent      API
 |                              |                   |
 |---(1) Click Update Status--->|                   |
 |                              |                   |
 |<---(2) Display Form----------|                   |
 |                              |                   |
 |---(3) Select Status--------->|                   |
 |                              |                   |
 |---(4) Add Notes------------->|                   |
 |                              |                   |
 |---(5) Submit Update--------->|                   |
 |                              |                   |
 |                              |---(6) Update Order-->|
 |                              |                   |
 |                              |<---(7) Confirmation--|
 |                              |                   |
 |<---(8) Display Success-------|                   |
 |                              |                   |
```

### State Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Initial State  │────>│  Update Form    │────>│  Status Selected│
│  (Current       │     │  Displayed      │     │                 │
│   Status)       │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        │
                                                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Success State  │<────│  Processing     │<────│  Form Submitted │
│  (New Status)   │     │  Update         │     │                 │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │
        │
        ▼
┌─────────────────┐
│                 │
│  Error State    │
│  (If update     │
│   fails)        │
└─────────────────┘
```

## Security Considerations

1. **Permission Checks**: Ensure users can only update status for orders they have permission to modify
2. **Role-Based Restrictions**: Limit available status options based on user role
3. **Audit Logging**: Log all status changes with user information for audit purposes
4. **CSRF Protection**: Implement CSRF tokens for all form submissions
5. **Input Validation**: Validate all input data before processing updates
6. **Rate Limiting**: Implement rate limiting to prevent abuse
7. **Action Authorization**: Verify user has permission for specific status transitions

## Testing

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| Valid Status Update | Update order to valid next status | Status updated successfully |
| Invalid Status Transition | Attempt invalid status transition | Error message displayed, status unchanged |
| Required Fields | Update to status requiring additional fields | Additional fields displayed and validated |
| Bulk Status Update | Update multiple orders at once | All orders updated successfully |
| Concurrent Updates | Two users update same order simultaneously | Conflict detected and handled appropriately |
| Permission Test | User without permission attempts update | Permission denied message displayed |
| Network Failure | Network fails during update | Error handled gracefully with retry option |
| Status with Notifications | Update to status that triggers notifications | Notifications sent successfully |
| Status with Inventory Impact | Update to status that affects inventory | Inventory updated correctly |

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-02 | AI Assistant | Initial documentation of order status update flow | 