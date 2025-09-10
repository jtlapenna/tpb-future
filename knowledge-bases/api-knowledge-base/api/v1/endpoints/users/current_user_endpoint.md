---
title: Current User
description: API endpoint for retrieving the currently authenticated user's information
last_updated: 2023-07-28
contributors: [AI Assistant]
---

# Current User

## Overview

The Current User endpoint retrieves information about the currently authenticated user. This endpoint is commonly used for retrieving the user's profile information after login or for verifying the current authentication state.

## Endpoint Details

- **URL**: `GET /users/current`
- **Method**: `GET`
- **Authentication**: Required (JWT token)
- **Authorization**: Any authenticated user can access this endpoint

## Request Headers

| Header | Value | Required | Description |
|--------|-------|----------|-------------|
| Content-Type | application/json | Yes | Specifies the format of the request body |
| Authorization | Bearer {token} | Yes | JWT token for authentication |

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

## Implementation Details

### Controller

The endpoint is implemented in the `UsersController#current` method, which:
1. Uses the current_user method provided by the authentication system
2. Renders the current user as JSON

### Model

The User model includes:
- Authentication via `has_secure_password`
- Optional association with a client
- Email validation for presence and uniqueness
- Password validation for length and confirmation
- Scope for active users

### Serializer

The UserSerializer formats the response with:
- User attributes: id, name, email
- Associated client (if any)

### Database Queries

The endpoint performs the following database operations:
1. Retrieves the current user from the authentication context
2. Includes the associated client data to avoid N+1 queries

## Examples

### Example Request

```bash
curl -X GET \
  https://api.example.com/users/current \
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

1. **Profile Information**: Retrieving the current user's profile information
2. **Authentication Verification**: Verifying that the user is properly authenticated
3. **Session Management**: Checking the current user's session state
4. **User Interface Personalization**: Customizing the UI based on the current user's details

## Related Endpoints

- [List Users](/api/administrative/list_users_endpoint.md): Retrieve a list of all users
- [Create User](/api/administrative/create_user_endpoint.md): Create a new user
- [Update User](/api/administrative/update_user_endpoint.md): Update an existing user
- [Get User](/api/administrative/get_user_endpoint.md): Retrieve a specific user

## Notes for AI Agents

### Documentation Agent
- The password is never returned in the response
- The client association determines the user's role (admin vs. regular user)

### User Management Agent
- This endpoint is accessible to all authenticated users
- Use this endpoint to retrieve the current user's information without knowing their ID
- The presence of a client object indicates a regular user, while its absence indicates an admin

### Integration Agent
- Ensure proper authentication headers are included in requests
- This endpoint is useful for initializing user sessions in client applications
- Use this endpoint to verify authentication status before making other API calls

## Technical Debt and Known Issues

- No option to include additional user-related data (e.g., permissions, roles)
- No caching mechanism for frequently accessed current user data
- No refresh mechanism to update the current user data if it changes during the session

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-07-28 | AI Assistant | Initial documentation | 