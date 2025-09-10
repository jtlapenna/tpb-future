---
title: Create User
description: API endpoint for creating a new user in the system
last_updated: 2023-07-28
contributors: [AI Assistant]
---

# Create User

## Overview

The Create User endpoint allows for the creation of new user accounts in the system. This endpoint is typically used by administrators to set up accounts for new staff members or clients.

## Endpoint Details

- **URL**: `POST /users`
- **Method**: `POST`
- **Authentication**: Required (JWT token)
- **Authorization**: Only admin users can create new users

## Request Headers

| Header | Value | Required | Description |
|--------|-------|----------|-------------|
| Content-Type | application/json | Yes | Specifies the format of the request body |
| Authorization | Bearer {token} | Yes | JWT token for authentication |

## Request Body

```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "password": "securepassword",
  "password_confirmation": "securepassword",
  "client_id": 1
}
```

### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | string | Yes | The full name of the user |
| email | string | Yes | The email address of the user (must be unique) |
| password | string | Yes | The user's password (must meet length requirements) |
| password_confirmation | string | Yes | Confirmation of the password (must match password) |
| client_id | integer | No | The ID of the client the user belongs to (if not provided, user will be an admin) |

## Response Formats

### Success Response

- **Code**: 201 Created
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

- **Code**: 422 Unprocessable Entity
- **Content**:

```json
{
  "errors": {
    "email": ["has already been taken"],
    "password": ["is too short (minimum is 8 characters)"],
    "password_confirmation": ["doesn't match Password"]
  }
}
```

## Implementation Details

### Controller

The endpoint is implemented in the `UsersController#create` method, which:
1. Authorizes the User model to ensure the current user has permission to create users
2. Attempts to create a new user with the permitted attributes
3. Renders the user as JSON if successful, or returns errors if validation fails

### Model

The User model includes:
- Authentication via `has_secure_password`
- Optional association with a client
- Email validation for presence and uniqueness
- Password validation for length and confirmation
- Scope for active users

### Policy

The UserPolicy determines authorization and permitted attributes:
- Only admin users (users without a client_id) can create new users
- Permitted attributes include: name, email, password, password_confirmation, client_id

### Serializer

The UserSerializer formats the response with:
- User attributes: id, name, email
- Associated client (if any)

### Database Queries

The endpoint performs the following database operations:
1. Validates that the email is unique
2. Creates a new user record
3. Associates the user with a client if client_id is provided

## Examples

### Example Request

```bash
curl -X POST \
  https://api.example.com/users \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "password": "securepassword",
    "password_confirmation": "securepassword",
    "client_id": 1
  }'
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

1. **User Onboarding**: Creating accounts for new staff members or clients
2. **Admin Creation**: Setting up administrator accounts for system management
3. **Client User Management**: Creating users associated with specific clients
4. **Account Recovery**: Creating new accounts when users cannot recover existing ones

## Related Endpoints

- [List Users](/api/administrative/list_users_endpoint.md): Retrieve a list of all users
- [Update User](/api/administrative/update_user_endpoint.md): Update an existing user
- [Get User](/api/administrative/get_user_endpoint.md): Retrieve a specific user
- [Current User](/api/administrative/current_user_endpoint.md): Retrieve the current authenticated user

## Notes for AI Agents

### Documentation Agent
- The password is never returned in the response
- The client association determines the user's role (admin vs. regular user)

### User Management Agent
- Only admin users can create new users
- Users without a client_id are considered administrators
- Ensure password and password_confirmation match
- Validate email uniqueness before attempting to create a user

### Integration Agent
- Ensure proper authentication headers are included in requests
- Handle validation errors appropriately
- Be aware of the authorization requirements (admin only)
- Store the returned user ID for future reference

## Technical Debt and Known Issues

- No email verification process is implemented
- No password complexity requirements beyond minimum length
- No option to set the user's active status during creation (defaults to active)
- No support for creating multiple users in a single request

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-07-28 | AI Assistant | Initial documentation | 