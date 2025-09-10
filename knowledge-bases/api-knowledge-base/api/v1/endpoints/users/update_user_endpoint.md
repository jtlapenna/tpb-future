---
title: Update User
description: API endpoint for updating an existing user's information
last_updated: 2023-07-28
contributors: [AI Assistant]
---

# Update User

## Overview

The Update User endpoint allows for modifying an existing user's information in the system. This endpoint can be used by administrators to update any user's details, or by users to update their own information.

## Endpoint Details

- **URL**: `PUT /users/:id`
- **Method**: `PUT`
- **Authentication**: Required (JWT token)
- **Authorization**: Admin users can update any user, regular users can only update themselves

## Request Headers

| Header | Value | Required | Description |
|--------|-------|----------|-------------|
| Content-Type | application/json | Yes | Specifies the format of the request body |
| Authorization | Bearer {token} | Yes | JWT token for authentication |

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | The ID of the user to update |

### Request Body

```json
{
  "name": "Updated Name",
  "email": "updated.email@example.com",
  "password": "newpassword",
  "password_confirmation": "newpassword",
  "client_id": 2
}
```

### Body Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | string | No | The updated full name of the user |
| email | string | No | The updated email address of the user (must be unique) |
| password | string | No | The user's new password (must meet length requirements) |
| password_confirmation | string | No | Confirmation of the new password (must match password) |
| client_id | integer | No | The ID of the client the user belongs to (admin only) |

## Response Formats

### Success Response

- **Code**: 200 OK
- **Content**:

```json
{
  "id": 123,
  "name": "Updated Name",
  "email": "updated.email@example.com",
  "client": {
    "id": 2,
    "name": "New Client Name"
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

The endpoint is implemented in the `UsersController#update` method, which:
1. Finds the user by ID using the policy scope
2. Authorizes the update action on the user
3. Attempts to update the user with the permitted attributes
4. Renders the updated user as JSON if successful, or returns errors if validation fails

### Model

The User model includes:
- Authentication via `has_secure_password`
- Optional association with a client
- Email validation for presence and uniqueness
- Password validation for length and confirmation
- Scope for active users

### Policy

The UserPolicy determines authorization and permitted attributes:
- Admin users can update any user
- Regular users can only update themselves
- Permitted attributes include: name, email, password, password_confirmation, client_id

### Serializer

The UserSerializer formats the response with:
- User attributes: id, name, email
- Associated client (if any)

### Database Queries

The endpoint performs the following database operations:
1. Retrieves the user by ID
2. Validates that the email is unique (if being updated)
3. Updates the user record with the provided attributes

## Examples

### Example Request

```bash
curl -X PUT \
  https://api.example.com/users/123 \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Updated Name",
    "email": "updated.email@example.com"
  }'
```

### Example Response

```json
{
  "id": 123,
  "name": "Updated Name",
  "email": "updated.email@example.com",
  "client": {
    "id": 1,
    "name": "Client Name"
  }
}
```

## Common Use Cases

1. **Profile Updates**: Users updating their own profile information
2. **Password Changes**: Users or administrators changing passwords
3. **Role Changes**: Administrators changing a user's client association
4. **Contact Information Updates**: Updating email addresses or names

## Related Endpoints

- [List Users](/api/administrative/list_users_endpoint.md): Retrieve a list of all users
- [Create User](/api/administrative/create_user_endpoint.md): Create a new user
- [Get User](/api/administrative/get_user_endpoint.md): Retrieve a specific user
- [Current User](/api/administrative/current_user_endpoint.md): Retrieve the current authenticated user

## Notes for AI Agents

### Documentation Agent
- The password is never returned in the response
- The client association determines the user's role (admin vs. regular user)
- Only the fields that need to be updated should be included in the request

### User Management Agent
- Admin users can update any user, regular users can only update themselves
- Changing a user's client_id effectively changes their role
- Password updates require both password and password_confirmation fields
- Fields not included in the request will remain unchanged

### Integration Agent
- Ensure proper authentication headers are included in requests
- Handle validation errors appropriately
- Be aware of the authorization requirements
- Use PATCH instead of PUT if only updating specific fields

## Technical Debt and Known Issues

- No email verification process when updating email addresses
- No password complexity requirements beyond minimum length
- No option to update a user's active status
- No support for updating multiple users in a single request
- No audit trail of user changes

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-07-28 | AI Assistant | Initial documentation | 