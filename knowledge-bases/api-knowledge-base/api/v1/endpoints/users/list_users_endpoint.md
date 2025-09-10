---
title: List Users
description: API endpoint for retrieving a paginated list of users
last_updated: 2023-07-28
contributors: [AI Assistant]
---

# List Users

## Overview

The List Users endpoint retrieves a paginated list of all users in the system. This endpoint is typically used by administrators to manage user accounts and permissions.

## Endpoint Details

- **URL**: `GET /users`
- **Method**: `GET`
- **Authentication**: Required (JWT token)
- **Authorization**: Only admin users can access this endpoint

## Request Headers

| Header | Value | Required | Description |
|--------|-------|----------|-------------|
| Content-Type | application/json | Yes | Specifies the format of the request body |
| Authorization | Bearer {token} | Yes | JWT token for authentication |

## Request Parameters

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number for pagination (default: 1) |
| per_page | integer | No | Number of items per page (default: 25) |

## Response Formats

### Success Response

- **Code**: 200 OK
- **Content**:

```json
{
  "users": [
    {
      "id": 1,
      "name": "Admin User",
      "email": "admin@example.com",
      "client": {
        "id": 1,
        "name": "Client Name"
      }
    },
    {
      "id": 2,
      "name": "Regular User",
      "email": "user@example.com",
      "client": null
    }
  ],
  "meta": {
    "pagination": {
      "current_page": 1,
      "next_page": 2,
      "prev_page": null,
      "total_pages": 5,
      "total_count": 125
    }
  }
}
```

### Error Responses

- **Code**: 401 Unauthorized
- **Content**:

```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

- **Code**: 403 Forbidden
- **Content**:

```json
{
  "error": "You are not authorized to perform this action."
}
```

## Implementation Details

### Controller

The endpoint is implemented in the `UsersController#index` method, which:
1. Authorizes the User model to ensure the current user has permission to list users
2. Retrieves a paginated list of users using the policy scope
3. Renders the users as JSON with pagination metadata

### Model

The User model includes:
- Authentication via `has_secure_password`
- Optional association with a client
- Email validation for presence and uniqueness
- Password validation for length and confirmation
- Scope for active users

### Policy

The UserPolicy determines authorization:
- Only admin users (users without a client_id) can list all users

### Serializer

The UserSerializer formats the response with:
- User attributes: id, name, email
- Associated client (if any)

### Database Queries

The endpoint performs the following database operations:
1. Retrieves users with pagination
2. Includes associated client data to avoid N+1 queries

## Examples

### Example Request

```bash
curl -X GET \
  https://api.example.com/users?page=1&per_page=10 \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -H 'Content-Type: application/json'
```

### Example Response

```json
{
  "users": [
    {
      "id": 1,
      "name": "Admin User",
      "email": "admin@example.com",
      "client": {
        "id": 1,
        "name": "Client Name"
      }
    },
    {
      "id": 2,
      "name": "Regular User",
      "email": "user@example.com",
      "client": null
    }
  ],
  "meta": {
    "pagination": {
      "current_page": 1,
      "next_page": 2,
      "prev_page": null,
      "total_pages": 5,
      "total_count": 125
    }
  }
}
```

## Common Use Cases

1. **User Management**: Administrators use this endpoint to view and manage all users in the system.
2. **Auditing**: Tracking all users for compliance and security purposes.
3. **Reporting**: Generating reports on user activity and distribution.
4. **User Assignment**: Assigning users to specific clients or roles.

## Related Endpoints

- [Create User](/api/administrative/create_user_endpoint.md): Create a new user
- [Update User](/api/administrative/update_user_endpoint.md): Update an existing user
- [Get User](/api/administrative/get_user_endpoint.md): Retrieve a specific user
- [Current User](/api/administrative/current_user_endpoint.md): Retrieve the current authenticated user

## Notes for AI Agents

### Documentation Agent
- This endpoint returns paginated results, so handle pagination appropriately when retrieving all users
- The response includes metadata about pagination that can be used to navigate through pages

### User Management Agent
- Only admin users can access this endpoint
- Use this endpoint to retrieve all users before performing batch operations
- The client association indicates whether a user is an admin (no client) or a regular user (has client)

### Integration Agent
- Ensure proper authentication headers are included in requests
- Handle pagination to retrieve all users when necessary
- Be aware of the authorization requirements (admin only)

## Technical Debt and Known Issues

- No filtering options are available (e.g., by name, email, or client)
- No sorting options are implemented
- The endpoint doesn't support searching for specific users
- No option to include/exclude inactive users

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-07-28 | AI Assistant | Initial documentation | 