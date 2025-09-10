# Update Order

## Overview

The Update Order endpoint allows users to update specific attributes of an existing order in the system. This endpoint is primarily used to update printing-related information for orders, such as the printed date and printed ID.

## Endpoint Details

- **URL**: `PUT /api/v1/orders/:id`
- **HTTP Method**: PUT
- **Authentication**: Required (JWT token)
- **Authorization**: Any authenticated user can access this endpoint
- **API Version**: v1

## Request Headers

| Header Name | Required | Description |
|-------------|----------|-------------|
| Content-Type | Yes | Must be `application/json` |
| Authorization | Yes | Format: "Bearer {token}" |

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | The unique identifier of the order to update |

### Request Body

```json
{
  "order": {
    "printed_date": "datetime",
    "printed_id": "string"
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| printed_date | datetime | No | The date and time when the order was printed |
| printed_id | string | No | The identifier associated with the printed order |

## Response Formats

### Success Response

- **Status Code**: 200 OK
- **Content Type**: application/json

```json
{
  "order": {
    "id": "string",
    "customer_id": "string",
    "status": "string",
    "printed_date": "datetime",
    "printed_id": "string",
    "data": {
      "additional_data": "varies by POS system"
    }
  }
}
```

### Error Responses

#### 401 Unauthorized

```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

#### 404 Not Found

```json
{
  "error": "Order not found"
}
```

#### 422 Unprocessable Entity

```json
{
  "errors": {
    "printed_date": ["is not a valid datetime"],
    "printed_id": ["is too long (maximum is 255 characters)"]
  }
}
```

## Implementation Details

### Controller

- **File**: `app/controllers/api/v1/orders_controller.rb`
- **Method**: `update`
- **Logic**:
  1. Find the order using the `find_order` before_action
  2. Update the order with the permitted parameters
  3. Return the updated order

### Models

- **Primary Model**: `CustomerOrder`
  - Stores order information including customer ID, order ID, and order data
  - Belongs to a store
  - Validates presence of customer_id and order_id

### Database Queries

- Primary query: `UPDATE customer_orders SET printed_date = ?, printed_id = ? WHERE order_id = ? AND store_id = ?`

## Examples

### Example 1: Update Order Printing Information

#### Request

```
PUT /api/v1/orders/ORD-2023-001
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

{
  "order": {
    "printed_date": "2023-07-25T14:30:00Z",
    "printed_id": "PRINT-12345"
  }
}
```

#### Response

```json
{
  "order": {
    "id": "ORD-2023-001",
    "customer_id": "12345",
    "status": "AWAITING_PROCESSING",
    "printed_date": "2023-07-25T14:30:00Z",
    "printed_id": "PRINT-12345",
    "data": {
      "order_number": "ORD-2023-001",
      "notes": "First-time customer",
      "created_at": "2023-07-24T10:00:00Z"
    }
  }
}
```

## Common Use Cases

1. **Order Fulfillment Tracking**: Update order printing information for fulfillment tracking
2. **Receipt Management**: Associate printed receipts with digital orders
3. **Audit Trail**: Maintain a record of when orders were printed for audit purposes
4. **Order Processing Workflow**: Track the progress of orders through the printing stage

## Related Endpoints

- [Create Order](create_order_endpoint.md): Create a new order
- [Get Order Status](status_order_endpoint.md): Check the status of an order
- [Preview Order](preview_order_endpoint.md): Preview an order before creation

## Notes for AI Agents

### Documentation Agent
- Ensure this documentation is kept in sync with any changes to the OrdersController#update method
- Cross-reference with related endpoints to maintain consistency

### Order Management Agent
- Use this endpoint to update printing information for orders
- Note that this endpoint only updates specific attributes (printed_date, printed_id)
- For updating order status, use the status endpoint instead

### Integration Agent
- This endpoint updates the CustomerOrder record directly
- It does not interact with external POS systems
- The response includes the updated order data

### Printing System Agent
- Use this endpoint to record when an order has been printed
- Include both the printed_date (when it was printed) and printed_id (identifier for the printed receipt)
- This information can be used for tracking and auditing purposes

## Technical Debt and Known Issues

1. **Limited Update Capabilities**: The endpoint only allows updating printing-related information, not other order attributes
2. **No Validation for printed_id Format**: There's no specific format validation for the printed_id field
3. **No Audit Trail**: Changes to the order are not logged in an audit trail
4. **No Notification**: Updates to orders do not trigger notifications to relevant parties

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-25 | AI Assistant | Initial documentation | 