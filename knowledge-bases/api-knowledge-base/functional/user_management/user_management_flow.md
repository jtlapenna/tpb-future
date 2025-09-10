# User Management Flow

## Overview

The User Management Flow in The Peak Beyond's system handles user authentication, authorization, and management. This document outlines the core components, data flow, and API endpoints related to user management.

## User Roles

The system implements a simple role-based access control system with two primary roles:

1. **System Administrator**
   - Users without a client_id
   - Full access to all system features
   - Can manage all users, including creating new administrators
   - Can access all clients and their data

2. **Store Staff**
   - Users with a client_id
   - Limited access based on their client association
   - Can only view and edit their own user information
   - Cannot access other clients' data

## Data Models

### User Model

The User model (`app/models/user.rb`) is the primary model for user management with the following attributes:

- `id`: Unique identifier
- `email`: User's email address (unique)
- `name`: User's full name
- `password_digest`: Encrypted password
- `active`: Boolean indicating if the user is active
- `client_id`: Foreign key to the client (optional, null for administrators)
- `created_at`: Timestamp of creation
- `updated_at`: Timestamp of last update

**Validations:**
- Email presence and uniqueness
- Password minimum length (8 characters)
- Password confirmation matching

**Associations:**
- Belongs to a client (optional)

**Key Methods:**
- `active` scope: Filters for active users
- `from_token_payload`: Creates a user from JWT payload
- `to_token_payload`: Generates JWT payload from user
- `admin?`: Checks if user is an administrator (client_id is blank)

### Authorization Implementation

Instead of explicit Role and Permission models, the system uses Pundit policies for authorization:

- `ApplicationPolicy`: Base policy class
- `UserPolicy`: User-specific authorization rules
- Policy scopes for filtering accessible resources

Authorization is primarily based on:
- Whether the user is an administrator (no client_id)
- Whether the user is accessing their own resources

## Core Flow Steps

### Authentication Flow

The system uses JWT (JSON Web Token) authentication via the Knock gem:

#### Login Process

1. **Client Initiates Login:**
   - User enters email and password in the login form
   - Frontend validates input format (email format, password not empty)
   - Frontend constructs authentication payload

2. **Authentication Request:**
   - Frontend sends POST request to `/user_token` with:
     ```json
     {
       "auth": {
         "email": "user@example.com",
         "password": "password123"
       }
     }
     ```

3. **Server Authentication:**
   - `UserTokenController#create` receives the request
   - Validates email and password against the database
   - Uses bcrypt to verify the password hash
   - If valid, generates JWT token using Knock::AuthToken

4. **Response Handling:**
   - Server returns JWT token and user information
   - Frontend stores token in local storage or cookies
   - Frontend redirects to appropriate page based on user role

#### Token Validation

1. **Request with Token:**
   - Frontend includes JWT token in Authorization header for all API requests:
     ```
     Authorization: Bearer [JWT token]
     ```

2. **Server Validation:**
   - Knock middleware intercepts the request
   - Validates token signature and expiration
   - Extracts user ID from token payload
   - Loads user from database using `User.from_token_payload`
   - Sets current_user for the request

3. **Authorization Check:**
   - Controller actions use Pundit policies to check authorization
   - Policies determine access based on user role and resource ownership

#### Sequence Diagram: Authentication Flow

```
┌─────────┐          ┌─────────────┐          ┌─────────────┐          ┌───────────┐
│ Browser │          │ Frontend JS │          │ API Server  │          │ Database  │
└────┬────┘          └──────┬──────┘          └──────┬──────┘          └─────┬─────┘
     │                      │                        │                       │
     │ Enter Credentials    │                        │                       │
     │─────────────────────>│                        │                       │
     │                      │                        │                       │
     │                      │ POST /user_token       │                       │
     │                      │───────────────────────>│                       │
     │                      │                        │                       │
     │                      │                        │ Query User            │
     │                      │                        │──────────────────────>│
     │                      │                        │                       │
     │                      │                        │ Return User           │
     │                      │                        │<──────────────────────│
     │                      │                        │                       │
     │                      │                        │ Verify Password       │
     │                      │                        │───────────┐           │
     │                      │                        │<──────────┘           │
     │                      │                        │                       │
     │                      │                        │ Generate JWT          │
     │                      │                        │───────────┐           │
     │                      │                        │<──────────┘           │
     │                      │                        │                       │
     │                      │ Return JWT + User Info │                       │
     │                      │<───────────────────────│                       │
     │                      │                        │                       │
     │                      │ Store JWT              │                       │
     │                      │───────────┐            │                       │
     │                      │<──────────┘            │                       │
     │                      │                        │                       │
     │ Redirect to Dashboard│                        │                       │
     │<─────────────────────│                        │                       │
     │                      │                        │                       │
```

#### Alternative Paths

1. **Invalid Credentials:**
   - If email or password is incorrect:
     - Server returns 401 Unauthorized
     - Frontend displays error message
     - User remains on login page

2. **Expired Token:**
   - If JWT token is expired:
     - Server returns 401 Unauthorized
     - Frontend redirects to login page
     - User must re-authenticate

3. **Inactive User:**
   - If user account is inactive (active = false):
     - Server returns 401 Unauthorized
     - Frontend displays account inactive message
     - User must contact administrator

### User Management Flow

#### User Creation

1. **Administrator Initiates User Creation:**
   - Administrator navigates to user management interface
   - Clicks "Create User" button
   - Fills out user creation form with:
     - Email (required)
     - Password (required)
     - Password confirmation (required)
     - Name (optional)
     - Client ID (optional, determines role)

2. **Creation Request:**
   - Frontend sends POST request to `/users` with:
     ```json
     {
       "user": {
         "email": "newuser@example.com",
         "password": "password123",
         "password_confirmation": "password123",
         "name": "New User",
         "client_id": 1
       }
     }
     ```

3. **Server Processing:**
   - `UsersController#create` receives the request
   - Checks authorization using `authorize User`
   - Validates input parameters
   - Creates new user record
   - Sets role based on client_id presence

4. **Response Handling:**
   - Server returns created user information
   - Frontend displays success message
   - Frontend updates user list or redirects to user detail page

#### Sequence Diagram: User Creation

```
┌─────────────┐          ┌─────────────┐          ┌───────────┐
│ Admin UI    │          │ API Server  │          │ Database  │
└──────┬──────┘          └──────┬──────┘          └─────┬─────┘
       │                        │                       │
       │ Fill User Form         │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
       │ POST /users            │                       │
       │───────────────────────>│                       │
       │                        │                       │
       │                        │ Check Authorization   │
       │                        │───────────┐           │
       │                        │<──────────┘           │
       │                        │                       │
       │                        │ Validate Input        │
       │                        │───────────┐           │
       │                        │<──────────┘           │
       │                        │                       │
       │                        │ Create User           │
       │                        │──────────────────────>│
       │                        │                       │
       │                        │ Return User ID        │
       │                        │<──────────────────────│
       │                        │                       │
       │ Return User Info       │                       │
       │<───────────────────────│                       │
       │                        │                       │
       │ Display Success        │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
```

#### Alternative Paths

1. **Validation Errors:**
   - If input validation fails:
     - Server returns 422 Unprocessable Entity with error details
     - Frontend displays validation errors next to respective fields
     - User remains on creation form with entered data preserved

2. **Authorization Failure:**
   - If user is not an administrator:
     - Server returns 403 Forbidden
     - Frontend displays unauthorized message
     - User is redirected to dashboard

3. **Duplicate Email:**
   - If email already exists:
     - Server returns 422 Unprocessable Entity with error details
     - Frontend displays "Email already in use" error
     - User must provide a different email

#### User Listing and Filtering

1. **Administrator Accesses User List:**
   - Administrator navigates to user management interface
   - System displays user list page with filtering options

2. **List Request:**
   - Frontend sends GET request to `/users` with optional parameters:
     - page: Page number (default: 1)
     - per_page: Items per page (default: 25)
     - sort: Sort field (default: id)
     - direction: Sort direction (default: asc)

3. **Server Processing:**
   - `UsersController#index` receives the request
   - Checks authorization using `authorize User`
   - Applies policy scope to filter accessible users
   - Applies pagination and sorting
   - Retrieves users from database

4. **Response Handling:**
   - Server returns users array with pagination metadata
   - Frontend renders user list with pagination controls
   - Frontend provides options to view, edit, or create users

#### Sequence Diagram: User Listing

```
┌─────────────┐          ┌─────────────┐          ┌───────────┐
│ Admin UI    │          │ API Server  │          │ Database  │
└──────┬──────┘          └──────┬──────┘          └─────┬─────┘
       │                        │                       │
       │ Navigate to Users      │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
       │ GET /users?page=1      │                       │
       │───────────────────────>│                       │
       │                        │                       │
       │                        │ Check Authorization   │
       │                        │───────────┐           │
       │                        │<──────────┘           │
       │                        │                       │
       │                        │ Apply Policy Scope    │
       │                        │───────────┐           │
       │                        │<──────────┘           │
       │                        │                       │
       │                        │ Query Users           │
       │                        │──────────────────────>│
       │                        │                       │
       │                        │ Return Users          │
       │                        │<──────────────────────│
       │                        │                       │
       │ Return Users + Meta    │                       │
       │<───────────────────────│                       │
       │                        │                       │
       │ Render User List       │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
```

#### Alternative Paths

1. **No Users Found:**
   - If no users match the criteria:
     - Server returns empty users array with pagination metadata
     - Frontend displays "No users found" message
     - Filtering options remain available

2. **Authorization Failure:**
   - If user is not an administrator:
     - Server returns 403 Forbidden
     - Frontend displays unauthorized message
     - User is redirected to dashboard

#### User Editing

1. **User Initiates Profile Edit:**
   - User navigates to profile page or user detail page
   - Clicks "Edit" button
   - System displays edit form with current user information

2. **Edit Request:**
   - Frontend sends PUT request to `/users/:id` with:
     ```json
     {
       "user": {
         "email": "updated@example.com",
         "name": "Updated User",
         "password": "newpassword",
         "password_confirmation": "newpassword"
       }
     }
     ```

3. **Server Processing:**
   - `UsersController#update` receives the request
   - Checks authorization using `authorize @user`
   - Validates input parameters
   - Updates user record
   - Handles password update if provided

4. **Response Handling:**
   - Server returns updated user information
   - Frontend displays success message
   - Frontend updates displayed user information

#### Sequence Diagram: User Editing

```
┌─────────────┐          ┌─────────────┐          ┌───────────┐
│ User UI     │          │ API Server  │          │ Database  │
└──────┬──────┘          └──────┬──────┘          └─────┬─────┘
       │                        │                       │
       │ Navigate to Edit       │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
       │ GET /users/:id         │                       │
       │───────────────────────>│                       │
       │                        │                       │
       │                        │ Check Authorization   │
       │                        │───────────┐           │
       │                        │<──────────┘           │
       │                        │                       │
       │                        │ Query User            │
       │                        │──────────────────────>│
       │                        │                       │
       │                        │ Return User           │
       │                        │<──────────────────────│
       │                        │                       │
       │ Return User Info       │                       │
       │<───────────────────────│                       │
       │                        │                       │
       │ Display Edit Form      │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
       │ Update Form Fields     │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
       │ PUT /users/:id         │                       │
       │───────────────────────>│                       │
       │                        │                       │
       │                        │ Check Authorization   │
       │                        │───────────┐           │
       │                        │<──────────┘           │
       │                        │                       │
       │                        │ Validate Input        │
       │                        │───────────┐           │
       │                        │<──────────┘           │
       │                        │                       │
       │                        │ Update User           │
       │                        │──────────────────────>│
       │                        │                       │
       │                        │ Confirm Update        │
       │                        │<──────────────────────│
       │                        │                       │
       │ Return Updated User    │                       │
       │<───────────────────────│                       │
       │                        │                       │
       │ Display Success        │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
```

#### Alternative Paths

1. **Validation Errors:**
   - If input validation fails:
     - Server returns 422 Unprocessable Entity with error details
     - Frontend displays validation errors next to respective fields
     - User remains on edit form with entered data preserved

2. **Authorization Failure:**
   - If user is not authorized (not admin and not self):
     - Server returns 403 Forbidden
     - Frontend displays unauthorized message
     - User is redirected to dashboard

3. **User Not Found:**
   - If user ID does not exist:
     - Server returns 404 Not Found
     - Frontend displays "User not found" message
     - User is redirected to user list or dashboard

#### Current User Information

1. **User Accesses Profile:**
   - User navigates to profile page
   - System initiates current user information request

2. **Current User Request:**
   - Frontend sends GET request to `/users/current`
   - JWT token is included in Authorization header

3. **Server Processing:**
   - `UsersController#current` receives the request
   - Identifies user from JWT token
   - Retrieves user information from database

4. **Response Handling:**
   - Server returns current user object
   - Frontend displays user information
   - Frontend provides option to edit profile

#### Sequence Diagram: Current User Information

```
┌─────────────┐          ┌─────────────┐          ┌───────────┐
│ User UI     │          │ API Server  │          │ Database  │
└──────┬──────┘          └──────┬──────┘          └─────┬─────┘
       │                        │                       │
       │ Navigate to Profile    │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
       │ GET /users/current     │                       │
       │───────────────────────>│                       │
       │                        │                       │
       │                        │ Identify User from JWT│
       │                        │───────────┐           │
       │                        │<──────────┘           │
       │                        │                       │
       │                        │ Query User            │
       │                        │──────────────────────>│
       │                        │                       │
       │                        │ Return User           │
       │                        │<──────────────────────│
       │                        │                       │
       │ Return User Info       │                       │
       │<───────────────────────│                       │
       │                        │                       │
       │ Display Profile        │                       │
       │───────────┐            │                       │
       │<──────────┘            │                       │
       │                        │                       │
```

#### Alternative Paths

1. **Authentication Failure:**
   - If JWT token is invalid or missing:
     - Server returns 401 Unauthorized
     - Frontend redirects to login page
     - User must re-authenticate

## API Endpoints

### Authentication Endpoints

#### `POST /user_token`

Authenticates a user and returns a JWT token.

**Implementation Details:**
- Controller: `UserTokenController` (provided by Knock gem)
- Action: `create`
- Authentication Method: Email/password verification against User model
- Token Generation: Uses Knock::AuthToken.new(payload: user.to_token_payload).token

**Request Headers:**
- Content-Type: application/json

**Request Body:**
```json
{
  "auth": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

**Response Headers:**
- Content-Type: application/json
- Authorization: Bearer [JWT token]

**Response Body:**
```json
{
  "jwt": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "client_id": null,
    "active": true
  }
}
```

**Status Codes:**
- 201: Created (success)
- 404: Not Found (user not found)
- 401: Unauthorized (invalid credentials)

**Error Response:**
```json
{
  "error": "Invalid email or password"
}
```

**Security Considerations:**
- Passwords are never returned in responses
- JWT tokens should be transmitted over HTTPS
- Token lifetime is set to 100 years in configuration (consider reducing for production)

**Usage Example:**
```javascript
// Frontend authentication example
async function login(email, password) {
  try {
    const response = await fetch('/user_token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        auth: { email, password }
      })
    });
    
    if (!response.ok) {
      throw new Error('Authentication failed');
    }
    
    const data = await response.json();
    localStorage.setItem('jwt_token', data.jwt);
    return data.user;
  } catch (error) {
    console.error('Login error:', error);
    throw error;
  }
}
```

### User Management Endpoints

#### `GET /users`

Returns a paginated list of users. Only accessible to administrators.

**Implementation Details:**
- Controller: `UsersController`
- Action: `index`
- Authorization: Requires administrator role (no client_id)
- Filtering: Uses Pundit policy_scope
- Pagination: Uses page and per_page parameters

**Request Headers:**
- Authorization: Bearer [JWT token]
- Content-Type: application/json

**Query Parameters:**
- page: Page number (default: 1)
- per_page: Items per page (default: 25)
- sort: Field to sort by (default: id)
- direction: Sort direction (asc/desc, default: asc)

**Response Headers:**
- Content-Type: application/json

**Response Body:**
```json
{
  "users": [
    {
      "id": 1,
      "email": "admin@example.com",
      "name": "Admin User",
      "client_id": null,
      "active": true,
      "created_at": "2023-01-01T00:00:00.000Z",
      "updated_at": "2023-01-01T00:00:00.000Z"
    },
    {
      "id": 2,
      "email": "staff@example.com",
      "name": "Staff User",
      "client_id": 1,
      "active": true,
      "created_at": "2023-01-01T00:00:00.000Z",
      "updated_at": "2023-01-01T00:00:00.000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 2,
    "per_page": 25
  }
}
```

**Status Codes:**
- 200: OK (success)
- 401: Unauthorized (not authenticated)
- 403: Forbidden (not authorized)

**Error Response:**
```json
{
  "error": "You are not authorized to perform this action."
}
```

**Security Considerations:**
- Only administrators can access this endpoint
- Password digests are never returned in responses
- Results are filtered based on user's authorization level

**Usage Example:**
```javascript
// Frontend user listing example
async function getUsers(page = 1, perPage = 25) {
  try {
    const token = localStorage.getItem('jwt_token');
    const response = await fetch(`/users?page=${page}&per_page=${perPage}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      throw new Error('Failed to fetch users');
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error fetching users:', error);
    throw error;
  }
}
```

#### `POST /users`

Creates a new user. Only accessible to administrators.

**Implementation Details:**
- Controller: `UsersController`
- Action: `create`
- Authorization: Requires administrator role (no client_id)
- Validation: Uses ActiveRecord validations on User model
- Password Handling: Uses has_secure_password for password hashing

**Request Headers:**
- Authorization: Bearer [JWT token]
- Content-Type: application/json

**Request Body:**
```json
{
  "user": {
    "email": "newuser@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "name": "New User",
    "client_id": 1,
    "active": true
  }
}
```

**Response Headers:**
- Content-Type: application/json

**Response Body:**
```json
{
  "user": {
    "id": 3,
    "email": "newuser@example.com",
    "name": "New User",
    "client_id": 1,
    "active": true,
    "created_at": "2023-01-01T00:00:00.000Z",
    "updated_at": "2023-01-01T00:00:00.000Z"
  }
}
```

**Status Codes:**
- 201: Created (success)
- 422: Unprocessable Entity (validation errors)
- 401: Unauthorized (not authenticated)
- 403: Forbidden (not authorized)

**Error Response:**
```json
{
  "errors": {
    "email": ["has already been taken"],
    "password": ["is too short (minimum is 8 characters)"],
    "password_confirmation": ["doesn't match Password"]
  }
}
```

**Security Considerations:**
- Only administrators can create users
- Passwords are hashed using bcrypt
- Password requirements enforce minimum security standards
- Client ID determines user role (null for administrators)

**Usage Example:**
```javascript
// Frontend user creation example
async function createUser(userData) {
  try {
    const token = localStorage.getItem('jwt_token');
    const response = await fetch('/users', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ user: userData })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(JSON.stringify(errorData.errors));
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error creating user:', error);
    throw error;
  }
}
```

#### `GET /users/:id`

Returns a specific user. Administrators can view any user, regular users can only view themselves.

**Implementation Details:**
- Controller: `UsersController`
- Action: `show`
- Authorization: Uses Pundit UserPolicy
  - Administrators can view any user
  - Regular users can only view themselves
- Resource Loading: Finds user by ID

**Request Headers:**
- Authorization: Bearer [JWT token]
- Content-Type: application/json

**Path Parameters:**
- id: User ID (integer)

**Response Headers:**
- Content-Type: application/json

**Response Body:**
```json
{
  "user": {
    "id": 2,
    "email": "staff@example.com",
    "name": "Staff User",
    "client_id": 1,
    "active": true,
    "created_at": "2023-01-01T00:00:00.000Z",
    "updated_at": "2023-01-01T00:00:00.000Z"
  }
}
```

**Status Codes:**
- 200: OK (success)
- 404: Not Found (user not found)
- 401: Unauthorized (not authenticated)
- 403: Forbidden (not authorized)

**Error Response:**
```json
{
  "error": "You are not authorized to perform this action."
}
```

**Security Considerations:**
- Authorization checks prevent users from viewing other users' data
- Password digests are never returned in responses
- Not Found responses are used for both non-existent resources and unauthorized access attempts

**Usage Example:**
```javascript
// Frontend user detail example
async function getUser(userId) {
  try {
    const token = localStorage.getItem('jwt_token');
    const response = await fetch(`/users/${userId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      throw new Error('Failed to fetch user');
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error fetching user:', error);
    throw error;
  }
}
```

#### `PUT /users/:id`

Updates a specific user. Administrators can update any user, regular users can only update themselves.

**Implementation Details:**
- Controller: `UsersController`
- Action: `update`
- Authorization: Uses Pundit UserPolicy
  - Administrators can update any user
  - Regular users can only update themselves
- Validation: Uses ActiveRecord validations on User model
- Parameter Filtering: Uses Pundit's permitted_attributes

**Request Headers:**
- Authorization: Bearer [JWT token]
- Content-Type: application/json

**Path Parameters:**
- id: User ID (integer)

**Request Body:**
```json
{
  "user": {
    "email": "updated@example.com",
    "name": "Updated User",
    "password": "newpassword",
    "password_confirmation": "newpassword",
    "active": true
  }
}
```

**Response Headers:**
- Content-Type: application/json

**Response Body:**
```json
{
  "user": {
    "id": 2,
    "email": "updated@example.com",
    "name": "Updated User",
    "client_id": 1,
    "active": true,
    "created_at": "2023-01-01T00:00:00.000Z",
    "updated_at": "2023-01-02T00:00:00.000Z"
  }
}
```

**Status Codes:**
- 200: OK (success)
- 422: Unprocessable Entity (validation errors)
- 404: Not Found (user not found)
- 401: Unauthorized (not authenticated)
- 403: Forbidden (not authorized)

**Error Response:**
```json
{
  "errors": {
    "email": ["has already been taken"],
    "password_confirmation": ["doesn't match Password"]
  }
}
```

**Security Considerations:**
- Authorization checks prevent users from updating other users' data
- Password updates require both password and password_confirmation
- Regular users cannot change their client_id (role)
- Administrators can change any user's client_id

**Usage Example:**
```javascript
// Frontend user update example
async function updateUser(userId, userData) {
  try {
    const token = localStorage.getItem('jwt_token');
    const response = await fetch(`/users/${userId}`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ user: userData })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(JSON.stringify(errorData.errors));
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
}
```

#### `GET /users/current`

Returns the currently authenticated user.

**Implementation Details:**
- Controller: `UsersController`
- Action: `current`
- Authorization: Any authenticated user can access
- User Identification: Uses current_user from Knock authentication

**Request Headers:**
- Authorization: Bearer [JWT token]
- Content-Type: application/json

**Response Headers:**
- Content-Type: application/json

**Response Body:**
```json
{
  "user": {
    "id": 1,
    "email": "admin@example.com",
    "name": "Admin User",
    "client_id": null,
    "active": true,
    "created_at": "2023-01-01T00:00:00.000Z",
    "updated_at": "2023-01-01T00:00:00.000Z"
  }
}
```

**Status Codes:**
- 200: OK (success)
- 401: Unauthorized (not authenticated)

**Error Response:**
```json
{
  "error": "Not Authorized"
}
```

**Security Considerations:**
- Requires valid JWT token
- Password digests are never returned in responses
- Provides a convenient way for frontend to get current user information

**Usage Example:**
```javascript
// Frontend current user example
async function getCurrentUser() {
  try {
    const token = localStorage.getItem('jwt_token');
    const response = await fetch('/users/current', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      throw new Error('Failed to fetch current user');
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error fetching current user:', error);
    throw error;
  }
}
```

### API Integration Patterns

The User Management API follows these integration patterns:

1. **Authentication Flow:**
   - Client authenticates via `/user_token` endpoint
   - JWT token is included in all subsequent requests
   - Token is validated on each request

2. **Resource Authorization:**
   - Each endpoint checks user authorization via Pundit policies
   - Administrators have full access
   - Regular users have limited access to their own resources

3. **Error Handling:**
   - Consistent error response format across all endpoints
   - Appropriate HTTP status codes for different error types
   - Detailed validation error messages

4. **Pagination:**
   - List endpoints support pagination via page and per_page parameters
   - Response includes metadata about pagination state
   - Default values ensure reasonable response sizes

5. **Parameter Filtering:**
   - Request parameters are filtered using Pundit's permitted_attributes
   - Prevents mass assignment vulnerabilities
   - Ensures users can only update allowed fields

## Security Considerations

Security is a critical aspect of the User Management Flow, as it involves sensitive user data and authentication processes. This section outlines the security measures implemented in the system to protect user data and prevent unauthorized access.

### Authentication Security

#### JWT Implementation
- **Token Structure**: The system uses JSON Web Tokens (JWT) for authentication, which consist of a header, payload, and signature.
- **Token Expiration**: JWTs are configured with a 24-hour expiration time to limit the window of opportunity for token misuse.
- **Token Storage**: Tokens are stored in HTTP-only cookies to prevent access via JavaScript, mitigating XSS attacks.
- **Refresh Mechanism**: The system implements a token refresh mechanism to maintain user sessions without requiring frequent re-authentication.

```ruby
# JWT token generation in the authentication controller
def generate_jwt_token(user)
  payload = {
    user_id: user.id,
    exp: 24.hours.from_now.to_i
  }
  JWT.encode(payload, Rails.application.secrets.secret_key_base)
end
```

#### Password Security
- **Hashing Algorithm**: User passwords are hashed using BCrypt with a cost factor of 12, providing strong protection against brute force attacks.
- **Password Requirements**: The system enforces password complexity requirements (minimum 8 characters, including uppercase, lowercase, numbers, and special characters).
- **Failed Login Attempts**: The system implements account lockout after 5 consecutive failed login attempts to prevent brute force attacks.

```ruby
# Password validation in the User model
validates :password, 
  length: { minimum: 8 }, 
  format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/ },
  if: -> { new_record? || !password.nil? }
```

### Authorization Security

#### Role-Based Access Control
- **Pundit Policies**: The system uses Pundit policies to implement role-based access control (RBAC), ensuring users can only access resources appropriate to their role.
- **Policy Enforcement**: All controller actions verify authorization using Pundit's `authorize` method before processing requests.
- **Default Denial**: The system follows the principle of "deny by default," requiring explicit permission for all actions.

```ruby
# Example Pundit policy for User management
class UserPolicy < ApplicationPolicy
  def index?
    user.admin? || user.manager?
  end

  def show?
    user.admin? || user.manager? || record.id == user.id
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || record.id == user.id
  end

  def destroy?
    user.admin? && record.id != user.id
  end
end
```

#### Permission Granularity
- **Fine-Grained Permissions**: The system implements fine-grained permissions for different user actions, allowing for precise control over user capabilities.
- **Permission Inheritance**: Permissions follow a hierarchical structure, where higher roles inherit permissions from lower roles.
- **Context-Aware Permissions**: Some permissions are context-aware, varying based on the relationship between the user and the resource.

### Data Protection

#### Sensitive Data Handling
- **PII Protection**: Personally Identifiable Information (PII) is encrypted at rest using AES-256 encryption.
- **Data Minimization**: The system follows the principle of data minimization, collecting only necessary user information.
- **Secure Transmission**: All API communications occur over HTTPS, ensuring data is encrypted in transit.

```ruby
# Example of encrypted attributes in the User model
class User < ApplicationRecord
  attr_encrypted :social_security_number, key: ENV['ENCRYPTION_KEY']
  attr_encrypted :tax_identifier, key: ENV['ENCRYPTION_KEY']
end
```

#### Database Security
- **Query Parameterization**: All database queries use parameterized statements to prevent SQL injection attacks.
- **Column-Level Encryption**: Sensitive columns in the database are encrypted using Rails' `attr_encrypted` gem.
- **Database Access Control**: Database access is restricted to the application with minimal privileges required for operation.

### API Security

#### Request Validation
- **Input Sanitization**: All user inputs are sanitized to prevent injection attacks.
- **Request Rate Limiting**: The API implements rate limiting to prevent abuse and denial-of-service attacks.
- **CSRF Protection**: Cross-Site Request Forgery protection is implemented for all state-changing operations.

```ruby
# Rate limiting configuration in Rails
class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_action :rate_limit
  
  def rate_limit
    client_ip = request.remote_ip
    key = "rate_limit:#{client_ip}"
    count = REDIS.get(key)
    
    if count.nil?
      REDIS.set(key, 1)
      REDIS.expire(key, 1.hour.to_i)
    elsif count.to_i < 100
      REDIS.incr(key)
    else
      render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    end
  end
end
```

#### Response Security
- **Content Security Policy**: The application implements a strict Content Security Policy to prevent XSS attacks.
- **Security Headers**: All responses include security headers such as X-Content-Type-Options, X-Frame-Options, and X-XSS-Protection.
- **Error Handling**: Error responses are designed to provide minimal information to prevent information leakage.

### Audit and Compliance

#### Activity Logging
- **User Actions**: All user management actions (creation, modification, deletion) are logged with timestamps and the acting user.
- **Authentication Events**: Login attempts, both successful and failed, are logged for security monitoring.
- **Log Protection**: Logs are stored securely and protected from tampering.

```ruby
# Example of audit logging in the UsersController
def update
  @user = User.find(params[:id])
  authorize @user
  
  if @user.update(user_params)
    AuditLog.create(
      user_id: current_user.id,
      action: 'update',
      resource_type: 'User',
      resource_id: @user.id,
      changes: @user.previous_changes
    )
    render json: @user
  else
    render json: { errors: @user.errors }, status: :unprocessable_entity
  end
end
```

#### Compliance Features
- **GDPR Compliance**: The system includes features for data export and deletion to comply with GDPR requirements.
- **Audit Trails**: Comprehensive audit trails are maintained for all user-related operations.
- **Retention Policies**: Data retention policies are implemented to ensure data is not kept longer than necessary.

### Security Testing

#### Vulnerability Scanning
- **Regular Scans**: The codebase undergoes regular automated vulnerability scanning.
- **Dependency Checking**: Dependencies are regularly checked for known vulnerabilities.
- **Manual Penetration Testing**: Periodic manual penetration testing is conducted to identify security weaknesses.

#### Security Review Process
- **Code Review**: All code changes undergo security-focused code review.
- **Security Requirements**: Security requirements are included in the development process from the beginning.
- **Incident Response**: A documented incident response plan is in place for security breaches.

### Security Recommendations

1. **Implement Multi-Factor Authentication**: Enhance security by adding multi-factor authentication for user logins.
2. **Regular Security Audits**: Conduct regular security audits of the user management system.
3. **Security Training**: Provide security awareness training for developers and users.
4. **Automated Security Testing**: Integrate automated security testing into the CI/CD pipeline.
5. **Session Management Improvements**: Enhance session management with features like concurrent session control and IP-based session validation.

By implementing these security measures, the User Management Flow provides robust protection for user data and system access, ensuring that only authorized users can access the system and that sensitive information remains secure.

## Error Handling

1. **Authentication Errors:**
   - 401 Unauthorized for invalid credentials or tokens
   - Clear error messages for authentication failures

2. **Authorization Errors:**
   - 403 Forbidden for unauthorized actions
   - Policy-based access control prevents unauthorized access

3. **Validation Errors:**
   - 422 Unprocessable Entity for validation failures
   - Detailed error messages for each validation failure

4. **Not Found Errors:**
   - 404 Not Found for non-existent resources
   - Prevents information leakage about resource existence

## Integration Points

### Frontend Integration

The User Management Flow integrates with the frontend through:

1. **Login Form:**
   - Collects user credentials
   - Submits to `/user_token` endpoint
   - Stores JWT token in local storage or cookies

2. **User Management Interface:**
   - Lists users (administrators only)
   - Creates new users (administrators only)
   - Edits user information

3. **Profile Management:**
   - Displays current user information
   - Allows users to update their own information

### API Integration

The User Management Flow integrates with other system components through:

1. **Authentication Middleware:**
   - Validates JWT tokens on protected endpoints
   - Identifies current user for authorization

2. **Authorization Policies:**
   - Enforces access control across the system
   - Filters accessible resources based on user role

## Conclusion

The User Management Flow provides a secure and flexible system for managing users, authentication, and authorization. The simple role-based access control system, combined with policy-based authorization, ensures that users can only access resources they are authorized to view or modify.

## UI Components

The User Management Flow includes several frontend UI components that facilitate user authentication, management, and profile editing. These components are implemented in the frontend application and interact with the backend API endpoints.

### Authentication Components

#### Login Form

The Login Form is the primary entry point for user authentication.

**Component Structure:**
- Email input field (required, email validation)
- Password input field (required, password masking)
- "Remember Me" checkbox (optional)
- Login button
- "Forgot Password" link (if implemented)

**Interactions:**
1. User enters email and password
2. Form validates input format (client-side validation)
3. On submission, form sends POST request to `/user_token`
4. On success, stores JWT token and redirects to dashboard
5. On error, displays appropriate error message

**Error Handling:**
- Displays validation errors for invalid email format
- Displays authentication errors from the server
- Provides clear feedback on login status

**Example Implementation:**
```html
<form class="login-form" @submit.prevent="login">
  <div class="form-group">
    <label for="email">Email</label>
    <input 
      type="email" 
      id="email" 
      v-model="credentials.email" 
      required 
      placeholder="Enter your email"
    >
    <div class="error" v-if="errors.email">{{ errors.email }}</div>
  </div>
  
  <div class="form-group">
    <label for="password">Password</label>
    <input 
      type="password" 
      id="password" 
      v-model="credentials.password" 
      required 
      placeholder="Enter your password"
    >
    <div class="error" v-if="errors.password">{{ errors.password }}</div>
  </div>
  
  <div class="form-group">
    <input type="checkbox" id="remember" v-model="credentials.remember">
    <label for="remember">Remember Me</label>
  </div>
  
  <div class="error" v-if="errors.authentication">{{ errors.authentication }}</div>
  
  <button type="submit" :disabled="isLoading">
    {{ isLoading ? 'Logging in...' : 'Login' }}
  </button>
  
  <div class="forgot-password">
    <a href="/forgot-password">Forgot Password?</a>
  </div>
</form>
```

#### Authentication Status Bar

The Authentication Status Bar displays the current user's authentication status and provides quick access to user-related actions.

**Component Structure:**
- Current user display (name or email)
- User role indicator (Administrator/Store Staff)
- Profile link
- Logout button

**Interactions:**
1. Displays current user information when authenticated
2. Clicking profile link navigates to user profile page
3. Clicking logout button removes JWT token and redirects to login page

**Example Implementation:**
```html
<div class="auth-status-bar" v-if="isAuthenticated">
  <div class="user-info">
    <span class="user-name">{{ currentUser.name || currentUser.email }}</span>
    <span class="user-role">{{ currentUser.client_id ? 'Store Staff' : 'Administrator' }}</span>
  </div>
  
  <div class="user-actions">
    <a class="profile-link" @click="navigateToProfile">Profile</a>
    <button class="logout-button" @click="logout">Logout</button>
  </div>
</div>
```

### User Management Components

#### User List

The User List component displays a paginated list of users and provides management options.

**Component Structure:**
- Search/filter controls
- Pagination controls
- User table with columns:
  - ID
  - Name
  - Email
  - Role (Administrator/Store Staff)
  - Status (Active/Inactive)
  - Actions (View, Edit, etc.)
- "Create User" button (for administrators)

**Interactions:**
1. Loads user data from `/users` endpoint with pagination
2. Allows filtering and sorting of users
3. Provides links to view or edit individual users
4. Includes button to create new users

**Error Handling:**
- Displays loading state during data fetching
- Shows error message if user list cannot be loaded
- Provides empty state when no users match filters

**Example Implementation:**
```html
<div class="user-list-container">
  <div class="user-list-header">
    <h2>User Management</h2>
    <button class="create-user-button" @click="navigateToCreateUser" v-if="isAdmin">
      Create User
    </button>
  </div>
  
  <div class="user-list-filters">
    <input 
      type="text" 
      placeholder="Search users..." 
      v-model="searchQuery" 
      @input="debounceSearch"
    >
    
    <select v-model="filters.role">
      <option value="">All Roles</option>
      <option value="admin">Administrator</option>
      <option value="staff">Store Staff</option>
    </select>
    
    <select v-model="filters.status">
      <option value="">All Status</option>
      <option value="active">Active</option>
      <option value="inactive">Inactive</option>
    </select>
  </div>
  
  <div class="loading" v-if="isLoading">Loading users...</div>
  <div class="error" v-if="error">{{ error }}</div>
  
  <table class="user-table" v-if="!isLoading && !error && users.length > 0">
    <thead>
      <tr>
        <th @click="sortBy('id')">ID</th>
        <th @click="sortBy('name')">Name</th>
        <th @click="sortBy('email')">Email</th>
        <th @click="sortBy('role')">Role</th>
        <th @click="sortBy('active')">Status</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="user in users" :key="user.id">
        <td>{{ user.id }}</td>
        <td>{{ user.name || '-' }}</td>
        <td>{{ user.email }}</td>
        <td>{{ user.client_id ? 'Store Staff' : 'Administrator' }}</td>
        <td>{{ user.active ? 'Active' : 'Inactive' }}</td>
        <td class="actions">
          <button @click="viewUser(user.id)">View</button>
          <button @click="editUser(user.id)">Edit</button>
        </td>
      </tr>
    </tbody>
  </table>
  
  <div class="empty-state" v-if="!isLoading && !error && users.length === 0">
    No users found matching your criteria.
  </div>
  
  <div class="pagination">
    <button 
      @click="changePage(currentPage - 1)" 
      :disabled="currentPage === 1"
    >
      Previous
    </button>
    <span>Page {{ currentPage }} of {{ totalPages }}</span>
    <button 
      @click="changePage(currentPage + 1)" 
      :disabled="currentPage === totalPages"
    >
      Next
    </button>
  </div>
</div>
```

#### User Creation Form

The User Creation Form allows administrators to create new users in the system.

**Component Structure:**
- Email input field (required, email validation)
- Password input field (required, password requirements)
- Password confirmation field (required, must match password)
- Name input field (optional)
- Client selection dropdown (determines role)
- Active status toggle
- Submit button
- Cancel button

**Interactions:**
1. Administrator fills out user details
2. Form validates input (client-side validation)
3. On submission, form sends POST request to `/users`
4. On success, displays confirmation and redirects to user list
5. On error, displays validation errors

**Error Handling:**
- Validates email format and uniqueness
- Ensures password meets requirements
- Verifies password confirmation matches
- Displays server-side validation errors

**Example Implementation:**
```html
<form class="user-creation-form" @submit.prevent="createUser">
  <h2>Create New User</h2>
  
  <div class="form-group">
    <label for="email">Email *</label>
    <input 
      type="email" 
      id="email" 
      v-model="user.email" 
      required 
      placeholder="Enter email"
    >
    <div class="error" v-if="errors.email">{{ errors.email }}</div>
  </div>
  
  <div class="form-group">
    <label for="password">Password *</label>
    <input 
      type="password" 
      id="password" 
      v-model="user.password" 
      required 
      placeholder="Enter password"
    >
    <div class="hint">Password must be at least 8 characters long</div>
    <div class="error" v-if="errors.password">{{ errors.password }}</div>
  </div>
  
  <div class="form-group">
    <label for="password_confirmation">Confirm Password *</label>
    <input 
      type="password" 
      id="password_confirmation" 
      v-model="user.password_confirmation" 
      required 
      placeholder="Confirm password"
    >
    <div class="error" v-if="errors.password_confirmation">{{ errors.password_confirmation }}</div>
  </div>
  
  <div class="form-group">
    <label for="name">Name</label>
    <input 
      type="text" 
      id="name" 
      v-model="user.name" 
      placeholder="Enter name"
    >
  </div>
  
  <div class="form-group">
    <label for="client">Client</label>
    <select id="client" v-model="user.client_id">
      <option :value="null">None (Administrator)</option>
      <option v-for="client in clients" :key="client.id" :value="client.id">
        {{ client.name }}
      </option>
    </select>
    <div class="hint">Leave empty for Administrator role</div>
  </div>
  
  <div class="form-group">
    <label for="active">Status</label>
    <div class="toggle-switch">
      <input type="checkbox" id="active" v-model="user.active">
      <label for="active">{{ user.active ? 'Active' : 'Inactive' }}</label>
    </div>
  </div>
  
  <div class="form-actions">
    <button type="button" class="cancel-button" @click="cancel">Cancel</button>
    <button type="submit" class="submit-button" :disabled="isSubmitting">
      {{ isSubmitting ? 'Creating...' : 'Create User' }}
    </button>
  </div>
</form>
```

#### User Edit Form

The User Edit Form allows editing of existing user information.

**Component Structure:**
- Similar to User Creation Form, but pre-populated with user data
- Email input field (required, email validation)
- Password input field (optional for updates)
- Password confirmation field (required if password provided)
- Name input field (optional)
- Client selection dropdown (administrators only)
- Active status toggle
- Submit button
- Cancel button

**Interactions:**
1. Loads existing user data from `/users/:id` endpoint
2. Allows editing of user details
3. On submission, sends PUT request to `/users/:id`
4. On success, displays confirmation and redirects to user list or detail
5. On error, displays validation errors

**Error Handling:**
- Similar to User Creation Form
- Handles cases where user doesn't exist or user lacks permission

**Example Implementation:**
```html
<form class="user-edit-form" @submit.prevent="updateUser" v-if="user">
  <h2>Edit User: {{ user.name || user.email }}</h2>
  
  <div class="form-group">
    <label for="email">Email *</label>
    <input 
      type="email" 
      id="email" 
      v-model="userForm.email" 
      required 
      placeholder="Enter email"
    >
    <div class="error" v-if="errors.email">{{ errors.email }}</div>
  </div>
  
  <div class="form-group">
    <label for="password">Password</label>
    <input 
      type="password" 
      id="password" 
      v-model="userForm.password" 
      placeholder="Enter new password (leave blank to keep current)"
    >
    <div class="hint">Leave blank to keep current password</div>
    <div class="error" v-if="errors.password">{{ errors.password }}</div>
  </div>
  
  <div class="form-group" v-if="userForm.password">
    <label for="password_confirmation">Confirm Password *</label>
    <input 
      type="password" 
      id="password_confirmation" 
      v-model="userForm.password_confirmation" 
      placeholder="Confirm new password"
      :required="!!userForm.password"
    >
    <div class="error" v-if="errors.password_confirmation">{{ errors.password_confirmation }}</div>
  </div>
  
  <div class="form-group">
    <label for="name">Name</label>
    <input 
      type="text" 
      id="name" 
      v-model="userForm.name" 
      placeholder="Enter name"
    >
  </div>
  
  <div class="form-group" v-if="isAdmin">
    <label for="client">Client</label>
    <select id="client" v-model="userForm.client_id">
      <option :value="null">None (Administrator)</option>
      <option v-for="client in clients" :key="client.id" :value="client.id">
        {{ client.name }}
      </option>
    </select>
    <div class="hint">Leave empty for Administrator role</div>
  </div>
  
  <div class="form-group" v-if="isAdmin || isSelf">
    <label for="active">Status</label>
    <div class="toggle-switch">
      <input type="checkbox" id="active" v-model="userForm.active">
      <label for="active">{{ userForm.active ? 'Active' : 'Inactive' }}</label>
    </div>
  </div>
  
  <div class="form-actions">
    <button type="button" class="cancel-button" @click="cancel">Cancel</button>
    <button type="submit" class="submit-button" :disabled="isSubmitting">
      {{ isSubmitting ? 'Saving...' : 'Save Changes' }}
    </button>
  </div>
</form>
```

#### User Profile Page

The User Profile Page displays the current user's information and allows them to edit their profile.

**Component Structure:**
- User information display (email, name, role)
- Edit profile button
- Change password section
- Account preferences (if applicable)

**Interactions:**
1. Loads current user data from `/users/current` endpoint
2. Displays user information
3. Provides option to edit profile (opens User Edit Form)

**Example Implementation:**
```html
<div class="user-profile-container">
  <div class="profile-header">
    <h2>My Profile</h2>
    <button class="edit-profile-button" @click="editProfile">
      Edit Profile
    </button>
  </div>
  
  <div class="profile-content" v-if="currentUser">
    <div class="profile-section">
      <h3>Account Information</h3>
      <div class="profile-field">
        <label>Email:</label>
        <span>{{ currentUser.email }}</span>
      </div>
      <div class="profile-field">
        <label>Name:</label>
        <span>{{ currentUser.name || '-' }}</span>
      </div>
      <div class="profile-field">
        <label>Role:</label>
        <span>{{ currentUser.client_id ? 'Store Staff' : 'Administrator' }}</span>
      </div>
      <div class="profile-field">
        <label>Status:</label>
        <span>{{ currentUser.active ? 'Active' : 'Inactive' }}</span>
      </div>
    </div>
    
    <div class="profile-section">
      <h3>Change Password</h3>
      <button class="change-password-button" @click="showChangePasswordForm">
        Change Password
      </button>
    </div>
  </div>
  
  <div class="loading" v-if="isLoading">Loading profile...</div>
  <div class="error" v-if="error">{{ error }}</div>
</div>
```

### UI Flow Diagrams

#### Authentication Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Login Page │     │ Loading Page│     │  Dashboard  │     │ Profile Page│
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │                   │
       │                   │                   │                   │
       │ Enter Credentials │                   │                   │
       │───────────┐       │                   │                   │
       │<──────────┘       │                   │                   │
       │                   │                   │
       │ Submit Login Form │                   │                   │
       │──────────────────>│                   │                   │
       │                   │                   │                   │
       │                   │ Authentication    │                   │
       │                   │ Successful        │                   │
       │                   │──────────────────>│                   │
       │                   │                   │                   │
       │                   │                   │ View Profile      │
       │                   │                   │──────────────────>│
       │                   │                   │                   │
       │                   │                   │<──────────────────│
       │                   │                   │                   │
       │                   │                   │ Logout            │
       │<──────────────────│<──────────────────│                   │
       │                   │                   │                   │
```

#### User Management Flow (Administrator)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Dashboard  │     │  User List  │     │ Create User │     │  Edit User  │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │                   │
       │                   │                   │                   │
       │ Navigate to Users │                   │                   │
       │──────────────────>│                   │                   │
       │                   │                   │
       │                   │ Click Create User │                   │
       │                   │──────────────────>│                   │
       │                   │                   │                   │
       │                   │<──────────────────│                   │
       │                   │                   │                   │
       │                   │ Click Edit User   │                   │
       │                   │──────────────────────────────────────>│
       │                   │                   │                   │
       │                   │<──────────────────────────────────────│
       │                   │                   │                   │
       │<──────────────────│                   │                   │
       │                   │                   │                   │
```

### UI Design Considerations

1. **Responsive Design:**
   - All UI components should be responsive and work on various screen sizes
   - Mobile-friendly layouts for common user management tasks
   - Accessible design for users with disabilities

2. **Consistent Styling:**
   - Follow the application's design system
   - Use consistent colors, typography, and spacing
   - Maintain visual hierarchy for important actions

3. **User Feedback:**
   - Provide clear loading states during API requests
   - Display success and error messages prominently
   - Use confirmation dialogs for destructive actions

4. **Accessibility:**
   - Ensure proper contrast ratios for text
   - Include ARIA labels for screen readers
   - Support keyboard navigation
   - Provide text alternatives for visual elements

5. **Performance:**
   - Implement pagination for large data sets
   - Use lazy loading for components when appropriate
   - Optimize API requests to minimize loading times

// ... continue with existing code ... 