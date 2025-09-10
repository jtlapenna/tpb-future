---
title: API Overview
description: High-level overview of The Peak Beyond's API architecture
last_updated: 2023-07-10
contributors: [AI Assistant]
related_files:
  - knowledge-base/technical/code_organization/architectural_patterns.md
  - knowledge-base/api/administrative/sample_store_endpoint.md
  - knowledge-base/technical/api_analysis_approach.md
tags:
  - api
  - architecture
  - overview
ai_agent_relevance:
  - APIDocumentationAgent
  - SystemArchitectAgent
  - IntegrationSpecialistAgent
---

# API Overview

## Version Information
- Category: API Documentation
- Type: Overview
- Current Version: 1.0.0
- Status: Current
- Last Updated: 2024-03-20
- Last Reviewer: AI Assistant
- Next Review Due: 2024-04-20

## Version History
### Version 1.0.0 (2024-03-20)
- Author: AI Assistant
- Reviewer: AI Assistant
- Changes:
  - Initial version
  - Added required metadata sections
  - Structured according to documentation guidelines

## Dependencies
### Required By
- API Version 1 Documentation
- Authentication Documentation
- Integration Documentation

### Depends On
- System Architecture Overview
- Technical Implementation Details

## Review History
- Last Review: 2024-03-20
- Reviewer: AI Assistant
- Outcome: Approved
- Comments: Document follows guidelines and provides comprehensive overview

## Maintenance Schedule
- Review Frequency: Monthly
- Next Scheduled Review: 2024-04-20
- Update Window: First week of each month
- Quality Assurance: Format compliance, link validation, technical accuracy

## Introduction

The Peak Beyond's API is designed to provide a comprehensive interface for interacting with the cannabis retail platform. The API follows RESTful design principles and is organized into logical resource groups that reflect the core business entities of the system.

This document provides a high-level overview of the API architecture, including authentication mechanisms, versioning strategy, response formats, and error handling.

## API Architecture

### Design Principles

The API is designed with the following principles in mind:

1. **RESTful Design**: Resources are accessed via standard HTTP methods (GET, POST, PUT, DELETE) and follow REST conventions.
2. **JSON:API Compliance**: Responses follow the [JSON:API specification](https://jsonapi.org/) for consistent formatting.
3. **Versioning**: All endpoints are versioned to ensure backward compatibility.
4. **Authentication**: Secure access is enforced through token-based authentication.
5. **Authorization**: Fine-grained access control is implemented using policy-based authorization.
6. **Multi-tenancy**: All operations are scoped to a specific tenant.
7. **Rate Limiting**: Endpoints are rate-limited to prevent abuse.
8. **Comprehensive Documentation**: Each endpoint is thoroughly documented.

### API Groups

The API is organized into the following groups:

1. **Administrative API**: Endpoints for managing stores, products, kiosks, and users.
2. **Public API**: Endpoints for customer-facing operations like browsing products and placing orders.
3. **Webhook API**: Endpoints for receiving notifications from external systems.
4. **Integration API**: Endpoints for integrating with POS systems and other third-party services.

## Authentication and Authorization

### Authentication Methods

The API supports the following authentication methods:

1. **JWT Authentication**: Used for user authentication in both administrative and public APIs.
2. **API Token Authentication**: Used for service-to-service communication and integrations.

#### JWT Authentication

JWT (JSON Web Token) authentication is used for authenticating users. The authentication flow is as follows:

1. User provides credentials (email/password) to the login endpoint.
2. Server validates credentials and returns a JWT token.
3. Client includes the JWT token in the `Authorization` header of subsequent requests.
4. Server validates the token and identifies the user.

Example JWT header:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### API Token Authentication

API token authentication is used for service-to-service communication and integrations. The authentication flow is as follows:

1. Administrator generates an API token for a specific service.
2. Service includes the API token in the `X-API-Key` header of requests.
3. Server validates the token and identifies the service.

Example API token header:
```
X-API-Key: api_key_123456789
```

### Authorization

Authorization is implemented using the Pundit gem, which provides policy-based access control. Each resource has a corresponding policy class that defines the permissions for various actions.

For example, the `StorePolicy` class defines who can create, read, update, or delete store resources:

```ruby
class StorePolicy < ApplicationPolicy
  def index?
    user.admin? || user.store_manager?
  end

  def show?
    user.admin? || user.store_manager? || record.users.include?(user)
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || (user.store_manager? && record.users.include?(user))
  end

  def destroy?
    user.admin?
  end
end
```

## Multi-Tenant Architecture

The API is designed to support multiple tenants (cannabis retailers) on a single platform. Each tenant has its own isolated data, but shares common master data and code.

### Tenant Identification

Tenants are identified by a unique tenant ID, which is included in the `X-Tenant-ID` header of each request:

```
X-Tenant-ID: tenant_123
```

### Tenant Scoping

All database queries are automatically scoped to the current tenant using a tenant context mechanism. This ensures that data from one tenant is never exposed to another tenant.

## API Versioning

The API uses URL-based versioning to ensure backward compatibility. All endpoints are prefixed with the API version:

```
/api/v1/admin/stores
```

When a new version of the API is released, the version number is incremented:

```
/api/v2/admin/stores
```

This allows clients to continue using the older version of the API while transitioning to the newer version.

## Request and Response Formats

### Request Format

Requests to the API should include the following:

1. **HTTP Method**: GET, POST, PUT, DELETE, etc.
2. **URL**: The endpoint URL, including the API version.
3. **Headers**: Authentication, content type, and tenant ID headers.
4. **Query Parameters**: For filtering, sorting, and pagination.
5. **Request Body**: For POST and PUT requests, in JSON format.

Example request:
```
POST /api/v1/admin/stores
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-Tenant-ID: tenant_123

{
  "store": {
    "name": "Green Leaf Dispensary",
    "address": {
      "street": "123 Main St",
      "city": "San Francisco",
      "state": "CA",
      "zip": "94105"
    }
  }
}
```

### Response Format

Responses from the API follow the JSON:API specification and include the following:

1. **HTTP Status Code**: Indicates the result of the request.
2. **Response Body**: Contains the requested data or error information.

Example success response:
```json
{
  "data": {
    "id": "123",
    "type": "store",
    "attributes": {
      "name": "Green Leaf Dispensary",
      "address": {
        "street": "123 Main St",
        "city": "San Francisco",
        "state": "CA",
        "zip": "94105"
      },
      "created_at": "2023-07-10T15:30:45Z",
      "updated_at": "2023-07-10T15:30:45Z"
    },
    "relationships": {
      "kiosks": {
        "links": {
          "related": "/api/v1/admin/stores/123/kiosks"
        }
      }
    }
  }
}
```

## Error Handling

### Error Response Format

Error responses follow a consistent format:

```json
{
  "error": "Error type",
  "message": "Human-readable error message",
  "details": {
    "field1": ["Error details for field1"],
    "field2": ["Error details for field2"]
  }
}
```

### Common Error Types

| Status Code | Error Type | Description |
|-------------|------------|-------------|
| 400 | Bad Request | The request was malformed or missing required parameters. |
| 401 | Unauthorized | Authentication is required or the provided credentials are invalid. |
| 403 | Forbidden | The authenticated user does not have permission to perform the requested action. |
| 404 | Not Found | The requested resource does not exist. |
| 422 | Unprocessable Entity | The request was well-formed but contains semantic errors. |
| 429 | Too Many Requests | The client has sent too many requests in a given amount of time. |
| 500 | Internal Server Error | An unexpected error occurred on the server. |

## Pagination, Filtering, and Sorting

### Pagination

List endpoints support pagination using the `page` and `per_page` query parameters:

```
GET /api/v1/admin/stores?page=2&per_page=10
```

Pagination information is included in the response metadata:

```json
{
  "data": [...],
  "meta": {
    "pagination": {
      "current_page": 2,
      "per_page": 10,
      "total_pages": 5,
      "total_count": 47
    }
  }
}
```

### Filtering

List endpoints support filtering using query parameters:

```
GET /api/v1/admin/stores?filter[name]=Green
```

Multiple filters can be combined:

```
GET /api/v1/admin/stores?filter[name]=Green&filter[state]=CA
```

### Sorting

List endpoints support sorting using the `sort` query parameter:

```
GET /api/v1/admin/stores?sort=name
```

For descending order, prefix the field with a minus sign:

```
GET /api/v1/admin/stores?sort=-created_at
```

Multiple sort fields can be specified:

```
GET /api/v1/admin/stores?sort=state,-name
```

## Rate Limiting

To prevent abuse, the API implements rate limiting based on the client's IP address and API key. Rate limits are specified per endpoint and are included in the response headers:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1594383600
```

When a rate limit is exceeded, the API returns a 429 Too Many Requests response.

## Webhooks

The API includes webhook endpoints for receiving notifications from external systems, such as POS systems. Webhooks are authenticated using API tokens and follow a consistent format.

Example webhook payload:
```json
{
  "event_type": "product_updated",
  "timestamp": "2023-07-10T15:30:45Z",
  "data": {
    "product_id": "123",
    "name": "Blue Dream",
    "price": 45.99
  }
}
```

## API Client Libraries

The Peak Beyond provides client libraries for common programming languages to simplify integration with the API:

- **JavaScript/TypeScript**: [@peakbeyond/api-client](https://www.npmjs.com/package/@peakbeyond/api-client)
- **Ruby**: [peakbeyond-api-client](https://rubygems.org/gems/peakbeyond-api-client)
- **Python**: [peakbeyond-api-client](https://pypi.org/project/peakbeyond-api-client/)

## API Documentation

Comprehensive documentation for each API endpoint is available in the knowledge base:

- [Administrative API](../api/administrative/)
- [Public API](../api/public/)
- [Webhook API](../api/webhooks/)
- [Integration API](../api/integration/)

## Best Practices

When working with the API, follow these best practices:

1. **Use Appropriate HTTP Methods**: Use GET for retrieving data, POST for creating resources, PUT for updating resources, and DELETE for removing resources.
2. **Include Authentication Headers**: Always include the appropriate authentication headers in your requests.
3. **Handle Rate Limiting**: Implement exponential backoff when rate limits are encountered.
4. **Validate Input**: Validate input data before sending it to the API.
5. **Handle Errors**: Implement proper error handling for different HTTP status codes.
6. **Use Pagination**: For endpoints that return large collections, use pagination to improve performance.
7. **Minimize Request Frequency**: Cache responses when appropriate to reduce the number of API calls.

## Conclusion

The Peak Beyond's API provides a comprehensive interface for interacting with the cannabis retail platform. By following RESTful design principles and implementing features like versioning, authentication, and rate limiting, the API ensures a secure and reliable experience for developers and integrators.

For detailed information about specific endpoints, refer to the endpoint documentation in the knowledge base. 