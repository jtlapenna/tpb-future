# List Customers

## Overview

The List Customers endpoint allows users to retrieve a list of customers from the system. This endpoint integrates with various Point of Sale (POS) systems based on the store's configuration and supports filtering by customer attributes such as name, email, phone, and birthday.

## Endpoint Details

- **URL**: `GET /api/v1/:catalog_id/customers`
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
| catalog_id | string | Yes | The ID of the catalog (kiosk) to retrieve customers from |

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| first_name | string | No | Filter customers by first name |
| last_name | string | No | Filter customers by last name |
| phone | string | No | Filter customers by phone number |
| email | string | No | Filter customers by email address |
| driver_license | string | No | Filter customers by driver's license number |
| birthday | string | No | Filter customers by birthday (format varies by POS system) |

## Response Formats

### Success Response

- **Status Code**: 200 OK
- **Content Type**: application/json

```json
{
  "customers": [
    {
      "status": "string",
      "customer_id": "string",
      "first_name": "string",
      "last_name": "string",
      "gender": "string",
      "birthday": "string",
      "email": "string",
      "phone": "string",
      "drivers_license": "string",
      "notes": "string"
    }
  ]
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

## Implementation Details

### Controller

- **File**: `app/controllers/api/v1/customers_controller.rb`
- **Method**: `index`
- **Logic**:
  1. Find the customer client for the kiosk's store
  2. Require that a customer client exists
  3. Call the `all` method on the customer client with the filtered parameters
  4. Return the list of customers

### Models

- **Primary Model**: `Customer`
  - Stores customer information including name, contact details, and identification
  - Belongs to a store
  - Validates presence of customer_id

### External Integrations

The endpoint integrates with various POS systems based on the store's configuration:
- Treez
- Flowhub
- Leaflogix
- Blaze
- Covasoft

Each integration has its own customer client implementation for retrieving customers.

## Examples

### Example 1: List All Customers

#### Request

```
GET /api/v1/123/customers
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
{
  "customers": [
    {
      "status": "ACTIVE",
      "customer_id": "12345",
      "first_name": "John",
      "last_name": "Doe",
      "gender": "Male",
      "birthday": "1985-05-15",
      "email": "john.doe@example.com",
      "phone": "555-123-4567",
      "drivers_license": "DL12345678",
      "notes": "Preferred customer"
    },
    {
      "status": "ACTIVE",
      "customer_id": "67890",
      "first_name": "Jane",
      "last_name": "Smith",
      "gender": "Female",
      "birthday": "1990-10-20",
      "email": "jane.smith@example.com",
      "phone": "555-987-6543",
      "drivers_license": "DL87654321",
      "notes": "New customer"
    }
  ]
}
```

### Example 2: Filter Customers by Name

#### Request

```
GET /api/v1/123/customers?first_name=John&last_name=Doe
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```json
{
  "customers": [
    {
      "status": "ACTIVE",
      "customer_id": "12345",
      "first_name": "John",
      "last_name": "Doe",
      "gender": "Male",
      "birthday": "1985-05-15",
      "email": "john.doe@example.com",
      "phone": "555-123-4567",
      "drivers_license": "DL12345678",
      "notes": "Preferred customer"
    }
  ]
}
```

## Common Use Cases

1. **Customer Management**: View and manage customer information
2. **Customer Lookup**: Find customers by name, email, or phone number
3. **Order Processing**: Retrieve customer information for order creation
4. **Customer Verification**: Verify customer identity using driver's license
5. **Marketing**: Retrieve customer information for marketing campaigns

## Related Endpoints

- [Create Customer](create_customer_endpoint.md): Create a new customer
- [Create Order](create_order_endpoint.md): Create a new order for a customer

## Notes for AI Agents

### Documentation Agent
- Ensure this documentation is kept in sync with any changes to the CustomersController#index method
- Cross-reference with related endpoints to maintain consistency

### Customer Management Agent
- Use this endpoint to retrieve customer information
- Be aware that the implementation varies based on the store's POS integration
- The response format may vary slightly depending on the POS system

### Integration Agent
- This endpoint integrates with various POS systems
- The filtering capabilities may vary by POS system
- Some POS systems may have limitations on the number of customers returned

### Order Management Agent
- Use this endpoint to retrieve customer information for order creation
- Customer IDs from this endpoint can be used in the Create Order endpoint

## Technical Debt and Known Issues

1. **POS-Specific Implementation**: The endpoint behavior varies based on the POS system, making it harder to maintain
2. **Limited Pagination**: The endpoint does not appear to support pagination, which could be problematic for stores with many customers
3. **Inconsistent Response Format**: The response format may vary slightly depending on the POS system
4. **No Sorting Options**: The endpoint does not support sorting the results
5. **Limited Error Handling**: Error responses from POS systems may not provide detailed information

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-27 | AI Assistant | Initial documentation | 