# Update Customer

## Overview

Based on the analysis of the codebase, there doesn't appear to be a dedicated endpoint for updating an existing customer by its ID. The API only supports creating new customers and retrieving existing ones. This documentation outlines the current limitations and provides guidance on alternative approaches.

## Current Limitations

The API routes for customers are limited to:
- `GET /api/v1/:catalog_id/customers` (List Customers)
- `POST /api/v1/:catalog_id/customers` (Create Customer)

There is no `PUT` or `PATCH` endpoint for updating customer information.

## Alternative Approaches

### Using the Create Customer Endpoint

In some cases, depending on the POS system integration, creating a customer with the same identifier (such as email or phone number) might update the existing customer record instead of creating a new one. However, this behavior is not guaranteed and depends on the specific POS system implementation.

```
POST /api/v1/:catalog_id/customers
Content-Type: application/json
Authorization: Bearer {token}

{
  "customer": {
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "phone": "555-123-4567",
    "drivers_license": "DL12345678",
    "notes": "Updated information"
  }
}
```

### Direct POS System Integration

For applications requiring customer updates, it may be necessary to integrate directly with the POS system's API rather than using this backend as an intermediary. Each POS system has its own API for customer management, which may include update functionality.

## Implementation Details

### Controller

- **File**: `app/controllers/api/v1/customers_controller.rb`
- **Methods**: Only `index` and `create` are implemented; there is no `update` method.

### Models

- **Primary Model**: `Customer`
  - Stores customer information including name, contact details, and identification
  - Belongs to a store
  - Validates presence of customer_id

## Common Use Cases and Workarounds

1. **Customer Information Updates**: To update customer information, consider:
   - Using the Create Customer endpoint with the same identifier (if the POS system supports upsert)
   - Integrating directly with the POS system's API
   - Implementing a custom update endpoint in your application

2. **Customer Preferences**: For storing customer preferences that don't need to be synchronized with the POS system, consider:
   - Storing this information in a separate system
   - Extending the Customer model with additional fields that are managed separately from the POS system

3. **Customer Status Changes**: For changing customer status (e.g., active to inactive), consider:
   - Using the POS system's native interface
   - Implementing a custom status management system

## Related Endpoints

- [List Customers](list_customers_endpoint.md): Retrieve a list of customers
- [Create Customer](create_customer_endpoint.md): Create a new customer

## Notes for AI Agents

### Documentation Agent
- Note that there is no dedicated endpoint for updating customers
- Cross-reference with related endpoints to maintain consistency

### Customer Management Agent
- Be aware that customer updates are not directly supported through this API
- Consider alternative approaches for updating customer information
- Understand the limitations of the current implementation

### Integration Agent
- Direct integration with the POS system may be necessary for customer updates
- The behavior of the Create Customer endpoint with existing customers varies by POS system
- Consider implementing a custom update mechanism if customer updates are essential

## Technical Debt and Known Issues

1. **Missing Update Functionality**: The API lacks a dedicated endpoint for updating customer information
2. **Inconsistent POS System Behavior**: Different POS systems may handle customer creation with existing identifiers differently
3. **Limited Customer Management**: The API provides limited customer management capabilities
4. **Potential Data Inconsistency**: Without proper update functionality, there's a risk of data inconsistency between systems

## Changelog

| Date | Author | Changes |
|------|--------|---------|
| 2023-07-27 | AI Assistant | Initial documentation 