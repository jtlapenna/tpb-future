# Create Order

## Overview

The Create Order endpoint allows users to create a new order in the system. This endpoint integrates with various Point of Sale (POS) systems based on the store's configuration. It supports creating new orders as well as resuming in-progress orders.

## Endpoint Details

- **URL**: `POST /api/v1/orders`
- **HTTP Method**: POST
- **Authentication**: Required (JWT token)
- **Authorization**: Any authenticated user can access this endpoint
- **API Version**: v1

## Request Headers

| Header Name | Required | Description |
|-------------|----------|-------------|
| Content-Type | Yes | Must be `application/json` |
| Authorization | Yes | Format: "Bearer {token}" |

## Request Parameters

### Request Body

```json
{
  "order": {
    "customer_id": "string",
    "order_number": "string",
    "notes": "string",
    "cart_id": "string",
    "customer_name": "string",
    "customer_email": "string",
    "order_source": "string",
    "type": "string",
    "items": [
      {
        "product_id": "integer",
        "quantity": "integer",
        "product_value_id": "integer"
      }
    ]
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| customer_id | string | Yes | The unique identifier of the customer placing the order |
| order_number | string | No | A unique identifier for the order |
| notes | string | No | Additional notes for the order |
| cart_id | string | No | The identifier of the cart associated with the order |
| customer_name | string | No | The name of the customer (used for notifications) |
| customer_email | string | No | The email of the customer (used for notifications) |
| order_source | string | No | The source of the order (default: "IN_STORE") |
| type | string | No | The type of order (default: "POS") |
| items | array | Yes | The items included in the order |
| items[].product_id | integer | Yes | The unique identifier of the product |
| items[].quantity | integer | Yes | The quantity of the product |
| items[].product_value_id | integer | No | The identifier of the specific product variant or value |

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
    "items": [
      {
        "id": "string",
        "product_id": "integer",
        "quantity": "integer",
        "product_value_id": "integer"
      }
    ],
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

#### 405 Method Not Allowed

```json
{
  "status": 405,
  "message": "method not allowed"
}
```

#### 422 Unprocessable Entity

```json
{
  "errors": {
    "customer_id": ["can't be blank"],
    "items": ["can't be blank"]
  }
}
```

## Implementation Details

### Controller

- **File**: `app/controllers/api/v1/orders_controller.rb`
- **Method**: `create`
- **Logic**:
  1. Validate the request parameters
  2. Check if there's an existing in-progress order for the customer
  3. If an in-progress order exists, update it with the new items
  4. If no in-progress order exists, create a new order
  5. Store the order data in the CustomerOrder model
  6. Send email notifications if enabled
  7. Return the created or updated order

### Models

- **Primary Model**: `CustomerOrder`
  - Stores order information including customer ID, order ID, and order data
  - Belongs to a store
  - Validates presence of customer_id and order_id

- **Related Model**: `Order`
  - Virtual model for handling order data
  - Includes validation for items

### External Integrations

The endpoint integrates with various POS systems based on the store's configuration:
- Treez
- Flowhub
- Leaflogix
- Shopify
- Covasoft
- Blaze

Each integration has its own client implementation for creating orders.

### Database Queries

- Primary query: `INSERT INTO customer_orders (customer_id, order_id, store_id, data) VALUES (?, ?, ?, ?)`
- If updating an existing order: `UPDATE customer_orders SET data = ? WHERE id = ?`

## Examples

### Example 1: Create a New Order

#### Request

```
POST /api/v1/orders
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

{
  "order": {
    "customer_id": "12345",
    "order_number": "ORD-2023-001",
    "notes": "First-time customer",
    "items": [
      {
        "product_id": 123,
        "quantity": 2
      },
      {
        "product_id": 456,
        "quantity": 1,
        "product_value_id": 789
      }
    ]
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
    "items": [
      {
        "id": "item-1",
        "product_id": 123,
        "quantity": 2
      },
      {
        "id": "item-2",
        "product_id": 456,
        "quantity": 1,
        "product_value_id": 789
      }
    ],
    "data": {
      "order_number": "ORD-2023-001",
      "notes": "First-time customer",
      "created_at": "2023-07-24T10:00:00Z"
    }
  }
}
```

### Example 2: Resume an In-Progress Order

#### Request

```
POST /api/v1/orders
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

{
  "order": {
    "customer_id": "12345",
    "items": [
      {
        "product_id": 789,
        "quantity": 1
      }
    ]
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
    "items": [
      {
        "id": "item-1",
        "product_id": 123,
        "quantity": 2
      },
      {
        "id": "item-2",
        "product_id": 456,
        "quantity": 1,
        "product_value_id": 789
      },
      {
        "id": "item-3",
        "product_id": 789,
        "quantity": 1
      }
    ],
    "data": {
      "order_number": "ORD-2023-001",
      "notes": "First-time customer",
      "created_at": "2023-07-24T10:00:00Z",
      "updated_at": "2023-07-24T10:15:00Z"
    }
  }
}
```

## Common Use Cases

1. **E-commerce Integration**: Create orders from online purchases
2. **In-store Kiosk Orders**: Process orders initiated from in-store kiosks
3. **Order Management**: Create and manage customer orders
4. **Inventory Management**: Track product sales and inventory changes
5. **Customer Relationship Management**: Associate orders with customer profiles

## Related Endpoints

- [Update Order](update_order_endpoint.md): Update an existing order
- [Get Order Status](status_order_endpoint.md): Check the status of an order
- [Preview Order](preview_order_endpoint.md): Preview an order before creation

## Notes for AI Agents

### Documentation Agent
- Ensure this documentation is kept in sync with any changes to the OrdersController#create method
- Cross-reference with related endpoints to maintain consistency

### Order Management Agent
- Use this endpoint to create new orders in the system
- Be aware that the implementation varies based on the store's POS integration
- Handle the case where an in-progress order already exists for the customer

### Integration Agent
- This endpoint integrates with various POS systems
- The response format may vary slightly depending on the POS system
- Email notifications can be sent if enabled in the store settings

### Customer Management Agent
- Orders are associated with customers via the customer_id
- Customer information (name, email) can be included for notification purposes
- Existing in-progress orders for a customer will be updated rather than creating a new order

## Technical Debt and Known Issues

1. **POS-Specific Implementation**: The endpoint behavior varies based on the POS system, making it harder to maintain
2. **Limited Validation**: Some validation is delegated to the POS system, which may lead to inconsistent error handling
3. **No Bulk Creation**: Cannot create multiple orders in a single request
4. **Limited Error Details**: Error responses from POS systems may not provide detailed information
5. **Email Notification Dependency**: Email notifications are sent synchronously, which could impact performance

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-24 | AI Assistant | Initial documentation | 