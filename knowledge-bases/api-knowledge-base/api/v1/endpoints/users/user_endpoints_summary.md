---
title: User Endpoints Summary
description: Overview of all user-related API endpoints
last_updated: 2023-07-28
contributors: [AI Assistant]
---

# User Endpoints Summary

## Overview

The User endpoints provide functionality for managing user accounts within the system. These endpoints allow for creating, retrieving, updating, and listing users, as well as retrieving the currently authenticated user's information.

## Authentication and Authorization

All User endpoints require authentication via JWT token. Authorization rules vary by endpoint:

- **Admin Users**: Users without a client_id are considered administrators and can access all User endpoints and perform operations on any user.
- **Regular Users**: Users with a client_id can only view and update their own information.

## Available Endpoints

| Endpoint | Method | URL | Description | Authorization |
|----------|--------|-----|-------------|--------------|
| [List Users](/api/administrative/list_users_endpoint.md) | GET | /users | Retrieves a paginated list of all users | Admin only |
| [Create User](/api/administrative/create_user_endpoint.md) | POST | /users | Creates a new user | Admin only |
| [Update User](/api/administrative/update_user_endpoint.md) | PUT | /users/:id | Updates an existing user | Admin for any user, regular users for themselves only |
| [Get User](/api/administrative/get_user_endpoint.md) | GET | /users/:id | Retrieves a specific user | Admin for any user, regular users for themselves only |
| [Current User](/api/administrative/current_user_endpoint.md) | GET | /users/current | Retrieves the currently authenticated user | Any authenticated user |

## User Model

The User model includes the following key attributes:

- **id**: Unique identifier for the user
- **name**: The user's full name
- **email**: The user's email address (must be unique)
- **password_digest**: Securely stored password hash (not returned in API responses)
- **client_id**: Optional reference to a client (null for admin users)
- **active**: Boolean indicating if the user is active

## Common Response Format

All User endpoints return user data in a consistent format:

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

1. **User Management**: Administrators can create, view, update, and list all users in the system.
2. **Profile Management**: Users can view and update their own profile information.
3. **Authentication**: The Current User endpoint can be used to verify authentication and retrieve user details.
4. **Role-Based Access**: The client association determines a user's role and permissions.

## Implementation Notes

- The User model uses `has_secure_password` for password management.
- Email addresses must be unique across all users.
- Passwords are validated for minimum length and confirmation.
- The UserPolicy controls authorization for each action.
- The UserSerializer formats user data for API responses.

## Technical Considerations

- Passwords are never returned in API responses.
- JWT tokens are used for authentication.
- Pagination is implemented for the List Users endpoint.
- The client association determines a user's role (admin vs. regular user).

## Related Resources

- [Authentication Documentation](/api/authentication/overview.md)
- [Client Endpoints](/api/administrative/client_endpoints_summary.md)

## Notes for AI Agents

### Documentation Agent
- User endpoints follow a consistent RESTful pattern
- Authorization is based on the user's role (admin vs. regular user)
- The client association is key to understanding user permissions

### User Management Agent
- Admin users can manage all users
- Regular users can only manage their own information
- The Current User endpoint is useful for retrieving the authenticated user's details

### Integration Agent
- Ensure proper authentication headers are included in all requests
- Handle pagination for the List Users endpoint
- Be aware of the authorization requirements for each endpoint

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-07-28 | AI Assistant | Initial documentation | 