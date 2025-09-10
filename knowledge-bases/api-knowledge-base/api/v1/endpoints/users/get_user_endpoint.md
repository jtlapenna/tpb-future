---
title: Get User
description: API endpoint for retrieving a specific user's information
last_updated: 2023-07-28
contributors: [AI Assistant]
---

# Get User

## Overview

The Get User endpoint retrieves detailed information about a specific user in the system. This endpoint can be used by administrators to view any user's details, or by users to view their own information.

## Endpoint Details

- **URL**: `GET /users/:id`
- **Method**: `GET`
- **Authentication**: Required (JWT token)
- **Authorization**: Admin users can view any user, regular users can only view themselves

## Request Headers

| Header | Value | Required | Description |
|--------|-------|----------|-------------|
| Content-Type | application/json | Yes | Specifies the format of the request body |
| Authorization | Bearer {token} | Yes | JWT token for authentication |

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | The ID of the user to retrieve |

## Response Formats

### Success Response

- **Code**: 200 OK
- **Content**:

```json
{
  "id": 123,
  "name": "John Doe",
  "email": "john.doe@example.com",
  "client": {
    "id": 1,
    "name": "Client Name"
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

- **Code**: 404 Not Found
- **Content**:

```json
{
  "error": "User not found"
}
```

## Implementation Details

### Controller

The endpoint is implemented in the `UsersController#show` method, which:
1. Finds the user by ID using the policy scope
2. Authorizes the show action on the user
3. Renders the user as JSON

### Model

The User model includes:
- Authentication via `has_secure_password`
- Optional association with a client
- Email validation for presence and uniqueness
- Password validation for length and confirmation
- Scope for active users

### Policy

The UserPolicy determines authorization:
- Admin users can view any user
- Regular users can only view themselves
- The `show?` method checks if the current user is an admin or if they are viewing their own record

### Serializer

The UserSerializer formats the response with:
- User attributes: id, name, email
- Associated client (if any)

### Database Queries

The endpoint performs the following database operations:
1. Retrieves the user by ID
2. Includes the associated client data to avoid N+1 queries

## Examples

### Example Request

```bash
curl -X GET \
  https://api.example.com/users/123 \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -H 'Content-Type: application/json'
```

### Example Response

```json
{
  "id": 123,
  "name": "John Doe",
  "email": "john.doe@example.com",
  "client": {
    "id": 1,
    "name": "Client Name"
  }
}
```

## Common Use Cases

1. **Profile Viewing**: Users viewing their own profile information
2. **User Management**: Administrators viewing user details for management purposes
3. **User Verification**: Verifying user information before performing operations
4. **Debugging**: Troubleshooting user-related issues

## Related Endpoints

- [List Users](/api/administrative/list_users_endpoint.md): Retrieve a list of all users
- [Create User](/api/administrative/create_user_endpoint.md): Create a new user
- [Update User](/api/administrative/update_user_endpoint.md): Update an existing user
- [Current User](/api/administrative/current_user_endpoint.md): Retrieve the current authenticated user

## Notes for AI Agents

### Documentation Agent
- The password is never returned in the response
- The client association determines the user's role (admin vs. regular user)

### User Management Agent
- Admin users can view any user, regular users can only view themselves
- Use this endpoint to retrieve detailed information about a specific user
- The presence of a client object indicates a regular user, while its absence indicates an admin

### Integration Agent
- Ensure proper authentication headers are included in requests
- Handle 404 errors appropriately when a user doesn't exist
- Be aware of the authorization requirements
- This endpoint can be used to verify that a user exists before attempting to update them

## Technical Debt and Known Issues

- No option to include additional user-related data (e.g., activity logs, permissions)
- No versioning information for tracking changes to user data
- No caching mechanism for frequently accessed user profiles

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-07-28 | AI Assistant | Initial documentation | 