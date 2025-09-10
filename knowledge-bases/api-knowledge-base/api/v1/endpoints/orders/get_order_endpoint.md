# Get Order

## Overview

Based on the analysis of the codebase, there doesn't appear to be a dedicated endpoint for retrieving a single order by its ID. Instead, the system provides the following alternatives:

1. The [List Orders](list_orders_endpoint.md) endpoint can be used with filtering to find a specific order
2. The [Status Order](status_order_endpoint.md) endpoint can be used to check the status of a specific order
3. Order information is returned as part of the response when creating or updating an order

This documentation outlines the available methods for retrieving order information and provides guidance on how to work with the existing endpoints.

## Alternative Approaches

### Using the List Orders Endpoint

The List Orders endpoint (`GET /api/v1/:catalog_id/customer_order`) can be used with filtering to find a specific order:

```
GET /api/v1/:catalog_id/customer_order?q=ORDER_UUID
```

This will return a list of orders matching the UUID filter, which should typically be a single order if the UUID is unique.

### Using the Status Order Endpoint

The Status Order endpoint (`PUT /api/v1/orders/status`) can be used to check the status of a specific order:

```
PUT /api/v1/orders/status
Content-Type: application/json
Authorization: Bearer {token}

{
  "order": {
    "customer_id": "string",
    "ticket_id": "string",
    "order_status": "string"
  }
}
```

This endpoint is primarily designed to update the status of an order, but it also returns the current order information in the response.

### Order Information in Create/Update Responses

When creating or updating an order, the response includes the complete order information:

- Create Order: `POST /api/v1/orders`
- Update Order: `PUT /api/v1/orders/:id`

Both of these endpoints return the order information in their responses, which can be used to retrieve order details after creation or update.

## Implementation Details

### Controller

- **File**: `app/controllers/api/v1/orders_controller.rb`
- **Methods**:
  - `status`: Updates and returns order status
  - `create`: Creates and returns a new order
  - `update`: Updates and returns an existing order

### Models

- **Primary Models**:
  - `CustomerOrder`: Stores order information for orders created through the API
  - `OrderCustomer`: Stores order information for orders created through the customer order system

## Common Use Cases

1. **Order Tracking**: Track the status and details of an order
2. **Order Fulfillment**: Retrieve order details for fulfillment
3. **Customer Service**: Look up order information for customer inquiries
4. **Order History**: View historical order information

## Related Endpoints

- [Create Order](create_order_endpoint.md): Create a new order
- [Update Order](update_order_endpoint.md): Update an existing order
- [List Orders](list_orders_endpoint.md): Retrieve a list of orders
- [Status Order](status_order_endpoint.md): Check or update the status of an order

## Notes for AI Agents

### Documentation Agent
- Note that there is no dedicated endpoint for retrieving a single order
- Cross-reference with related endpoints to maintain consistency

### Order Management Agent
- Use the List Orders endpoint with filtering to find a specific order
- Use the Status Order endpoint to check the status of a specific order
- Store order information returned from Create/Update endpoints for later reference

### Integration Agent
- Be aware that retrieving a single order requires using alternative approaches
- Consider implementing a caching mechanism for order information
- Use the appropriate approach based on the specific use case

## Technical Debt and Known Issues

1. **No Dedicated Get Order Endpoint**: The system lacks a dedicated endpoint for retrieving a single order by ID
2. **Inconsistent Order Models**: The system uses both OrderCustomer and CustomerOrder models for different order-related endpoints
3. **Limited Filtering Options**: The List Orders endpoint only supports filtering by UUID, not by other attributes
4. **Status Endpoint Requires Update**: The Status endpoint requires an update operation to retrieve order information

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-26 | AI Assistant | Initial documentation 