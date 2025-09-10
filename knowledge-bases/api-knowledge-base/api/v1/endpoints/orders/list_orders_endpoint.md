# List Orders

## Overview

The List Orders endpoint allows users to retrieve a paginated list of customer orders in the system. This endpoint supports filtering by order UUID, pagination, and sorting.

## Endpoint Details

- **URL**: `GET /api/v1/:catalog_id/customer_order`
- **HTTP Method**: GET
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
| catalog_id | string | Yes | The ID of the catalog to retrieve orders from |

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| q | string | No | Filter orders by UUID (partial match) |
| page | integer | No | Page number for pagination (default: 1) |
| page_size | integer | No | Number of items per page (default: 25) |
| sort_by | string | No | Field to sort by |
| sort_direction | string | No | Sort direction (`asc` or `desc`) |

## Response Formats

### Success Response

- **Status Code**: 200 OK
- **Content Type**: application/json

```json
{
  "order_customers": [
    {
      "id": "integer",
      "uuid": "string",
      "first_name": "string",
      "last_name": "string",
      "amount": "decimal",
      "payed": "boolean",
      "date": "datetime",
      "client_id": "integer",
      "kiosks_id": "integer",
      "created_at": "datetime",
      "updated_at": "datetime"
    }
  ],
  "meta": {
    "current_page": "integer",
    "next_page": "integer",
    "prev_page": "integer",
    "total_pages": "integer",
    "total_count": "integer"
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

## Implementation Details

### Controller

- **File**: `app/controllers/api/v1/customer_order_controller.rb`
- **Method**: `index`
- **Logic**:
  1. Retrieve all OrderCustomer records
  2. Filter by UUID if a query parameter is provided
  3. Apply pagination and sorting
  4. Return the paginated list with metadata

### Models

- **Primary Model**: `OrderCustomer`
  - Stores order information including customer name, amount, and payment status
  - Validates presence of kiosks_id, first_name, last_name, and amount

### Database Queries

- Primary query: `SELECT * FROM order_customers WHERE uuid LIKE ? ORDER BY ? LIMIT ? OFFSET ?`

## Examples

### Example 1: List All Orders

#### Request

```
GET /api/v1/123/customer_order
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
{
  "order_customers": [
    {
      "id": 1,
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "first_name": "John",
      "last_name": "Doe",
      "amount": 150.00,
      "payed": false,
      "date": "2023-07-26T10:00:00Z",
      "client_id": 123,
      "kiosks_id": 456,
      "created_at": "2023-07-26T10:00:00Z",
      "updated_at": "2023-07-26T10:00:00Z"
    },
    {
      "id": 2,
      "uuid": "550e8400-e29b-41d4-a716-446655440001",
      "first_name": "Jane",
      "last_name": "Smith",
      "amount": 200.00,
      "payed": true,
      "date": "2023-07-25T15:30:00Z",
      "client_id": 123,
      "kiosks_id": 456,
      "created_at": "2023-07-25T15:30:00Z",
      "updated_at": "2023-07-25T15:30:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 5,
    "total_count": 125
  }
}
```

### Example 2: Filter Orders by UUID

#### Request

```
GET /api/v1/123/customer_order?q=550e8400
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
{
  "order_customers": [
    {
      "id": 1,
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "first_name": "John",
      "last_name": "Doe",
      "amount": 150.00,
      "payed": false,
      "date": "2023-07-26T10:00:00Z",
      "client_id": 123,
      "kiosks_id": 456,
      "created_at": "2023-07-26T10:00:00Z",
      "updated_at": "2023-07-26T10:00:00Z"
    },
    {
      "id": 2,
      "uuid": "550e8400-e29b-41d4-a716-446655440001",
      "first_name": "Jane",
      "last_name": "Smith",
      "amount": 200.00,
      "payed": true,
      "date": "2023-07-25T15:30:00Z",
      "client_id": 123,
      "kiosks_id": 456,
      "created_at": "2023-07-25T15:30:00Z",
      "updated_at": "2023-07-25T15:30:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": null,
    "prev_page": null,
    "total_pages": 1,
    "total_count": 2
  }
}
```

## Common Use Cases

1. **Order Management**: View and manage all customer orders
2. **Order Tracking**: Track the status of orders
3. **Sales Reporting**: Generate reports on sales and order history
4. **Customer Service**: Look up orders for customer service inquiries
5. **Inventory Management**: Track product sales through orders

## Related Endpoints

- [Create Order](create_order_endpoint.md): Create a new order
- [Update Order](update_order_endpoint.md): Update an existing order
- [Get Order](get_order_endpoint.md): Retrieve details of a specific order

## Notes for AI Agents

### Documentation Agent
- Ensure this documentation is kept in sync with any changes to the CustomerOrderController#index method
- Cross-reference with related endpoints to maintain consistency

### Order Management Agent
- Use this endpoint to retrieve a list of orders
- Note that this endpoint returns OrderCustomer records, which are different from the CustomerOrder records used in the Create/Update Order endpoints
- The response includes pagination metadata that can be used for navigating through large result sets

### Integration Agent
- This endpoint provides a way to list orders created through the system
- The response format is consistent with other paginated endpoints in the API
- UUID filtering can be used to find specific orders

### Reporting Agent
- This endpoint can be used to gather data for sales reports
- The pagination features allow for processing large datasets in manageable chunks
- Consider using server-side filtering to reduce the amount of data transferred

## Technical Debt and Known Issues

1. **Inconsistent Order Models**: The system uses both OrderCustomer and CustomerOrder models for different order-related endpoints
2. **Limited Filtering Options**: The endpoint only supports filtering by UUID, not by other attributes like date or payment status
3. **No Detailed Order Information**: The response does not include detailed information about order items
4. **No Sorting Options Documentation**: While the endpoint supports sorting, there's no documentation on which fields can be sorted
5. **No Authorization Checks**: The endpoint does not appear to have specific authorization checks for accessing orders

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-26 | AI Assistant | Initial documentation | 