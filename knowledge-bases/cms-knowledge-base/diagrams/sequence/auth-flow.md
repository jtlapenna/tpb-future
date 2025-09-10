# Authentication Flow

## Overview
This diagram illustrates the authentication flow in the CMS, including JWT token management and session handling.

## Flow Diagram

```mermaid
sequenceDiagram
    participant Client
    participant AuthService
    participant JWTService
    participant API
    participant SessionGuard

    Client->>AuthService: Login Request
    AuthService->>API: Authenticate
    API-->>AuthService: Return JWT Token
    AuthService->>JWTService: Store Token
    JWTService-->>AuthService: Token Stored
    AuthService-->>Client: Login Success

    Note over Client,SessionGuard: Protected Route Access

    Client->>SessionGuard: Access Route
    SessionGuard->>JWTService: Validate Token
    
    alt Valid Token
        JWTService-->>SessionGuard: Token Valid
        SessionGuard->>API: Get Current User
        API-->>SessionGuard: User Data
        SessionGuard-->>Client: Route Access Granted
    else Invalid Token
        JWTService-->>SessionGuard: Token Invalid
        SessionGuard-->>Client: Redirect to Login
    end

    loop Token Refresh
        JWTService->>API: Refresh Token
        API-->>JWTService: New Token
        JWTService->>JWTService: Update Stored Token
    end
```

## Authentication Steps

1. **Initial Login**
   - Client submits credentials
   - Server validates and returns JWT
   - Token stored in local storage
   - User redirected to dashboard

2. **Route Protection**
   - SessionGuard intercepts navigation
   - Token validation check
   - Current user verification
   - Route access control

3. **Token Management**
   - Automatic token refresh
   - Session persistence
   - Secure storage
   - Logout cleanup

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial authentication flow diagram | 