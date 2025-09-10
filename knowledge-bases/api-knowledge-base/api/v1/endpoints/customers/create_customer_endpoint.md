# Create Customer

## Overview

The Create Customer endpoint allows users to create a new customer in the system. This endpoint integrates with various Point of Sale (POS) systems based on the store's configuration. It supports creating customers with basic information such as name, contact details, and identification.

## Endpoint Details

- **URL**: `POST /api/v1/:catalog_id/customers`
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

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| catalog_id | string | Yes | The ID of the catalog (kiosk) to create the customer in |

### Request Body

```json
{
  "customer": {
    "first_name": "string",
    "last_name": "string",
    "gender": "string",
    "birthday": "string",
    "email": "string",
    "phone": "string",
    "drivers_license": "string",
    "notes": "string"
  }
}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| first_name | string | Yes | The customer's first name |
| last_name | string | Yes | The customer's last name |
| gender | string | No | The customer's gender |
| birthday | string | No | The customer's birthday (format varies by POS system) |
| email | string | No | The customer's email address |
| phone | string | No | The customer's phone number |
| drivers_license | string | No | The customer's driver's license number |
| notes | string | No | Additional notes about the customer |

## Response Formats

### Success Response

- **Status Code**: 201 Created
- **Content Type**: application/json

```json
{
  "customer": {
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
    "first_name": ["can't be blank"],
    "last_name": ["can't be blank"]
  }
}
```

## Implementation Details

### Controller

- **File**: `app/controllers/api/v1/customers_controller.rb`
- **Method**: `create`
- **Logic**:
  1. Find the customer client for the kiosk's store
  2. Require that a customer client exists
  3. Check if the client supports customer creation
  4. Call the `create!` method on the customer client with the permitted parameters
  5. Return the created customer

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

Each integration has its own customer client implementation for creating customers. Note that not all POS systems support customer creation through the API.

## Examples

### Example 1: Create a Basic Customer

#### Request

```
POST /api/v1/123/customers
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

{
  "customer": {
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "phone": "555-123-4567"
  }
}
```

#### Response

```json
{
  "customer": {
    "status": "ACTIVE",
    "customer_id": "12345",
    "first_name": "John",
    "last_name": "Doe",
    "gender": null,
    "birthday": null,
    "email": "john.doe@example.com",
    "phone": "555-123-4567",
    "drivers_license": null,
    "notes": null
  }
}
```

### Example 2: Create a Detailed Customer

#### Request

```
POST /api/v1/123/customers
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

{
  "customer": {
    "first_name": "Jane",
    "last_name": "Smith",
    "gender": "Female",
    "birthday": "1990-10-20",
    "email": "jane.smith@example.com",
    "phone": "555-987-6543",
    "drivers_license": "DL87654321",
    "notes": "New customer"
  }
}
```

#### Response

```json
{
  "customer": {
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
}
```

## Common Use Cases

1. **Customer Registration**: Register new customers in the system
2. **Customer Onboarding**: Onboard customers during their first visit
3. **Customer Data Management**: Create and maintain customer records
4. **Order Processing**: Create customers for order processing
5. **Customer Relationship Management**: Build a customer database for marketing and relationship management

## Related Endpoints

- [List Customers](list_customers_endpoint.md): Retrieve a list of customers
- [Create Order](create_order_endpoint.md): Create a new order for a customer

## Notes for AI Agents

### Documentation Agent
- Ensure this documentation is kept in sync with any changes to the CustomersController#create method
- Cross-reference with related endpoints to maintain consistency

### Customer Management Agent
- Use this endpoint to create new customers in the system
- Be aware that the implementation varies based on the store's POS integration
- Not all POS systems support customer creation through the API

### Integration Agent
- This endpoint integrates with various POS systems
- The required fields may vary by POS system
- Some POS systems may have additional validation rules

### Order Management Agent
- Create customers before creating orders for them
- Use the customer_id returned from this endpoint in the Create Order endpoint

## Technical Debt and Known Issues

1. **POS-Specific Implementation**: The endpoint behavior varies based on the POS system, making it harder to maintain
2. **Limited Validation**: Some validation is delegated to the POS system, which may lead to inconsistent error handling
3. **No Bulk Creation**: Cannot create multiple customers in a single request
4. **Limited Error Details**: Error responses from POS systems may not provide detailed information
5. **Inconsistent Support**: Not all POS systems support customer creation through the API

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-27 | AI Assistant | Initial documentation | 