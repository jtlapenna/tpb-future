---
title: CMS Login Flow
description: Documentation of the authentication flow for The Peak Beyond's CMS application
last_updated: 2023-08-02
contributors: [AI Assistant]
---

# CMS Login Flow

## Overview

The Login Flow is the entry point to The Peak Beyond's Content Management System (CMS). It allows authorized users to authenticate themselves and gain access to the CMS functionality based on their role and permissions. This flow implements JWT-based authentication and includes security measures such as rate limiting and session management.

## User Roles

- **Admin**: Full access to all CMS features
- **Store Manager**: Access to store-specific features
- **Content Manager**: Access to content management features
- **Inventory Manager**: Access to inventory management features
- **Reporting User**: Access to reporting features only

## Preconditions

- User has a valid CMS account
- User knows their email and password
- User has internet connectivity
- User is using a supported browser

## Flow Steps

1. **Access Login Page**
   - Components: LoginPageComponent, LoginFormComponent
   - State: Initial state, no authentication
   - API Calls: None
   - User Interaction: User navigates to the CMS login URL
   - System Response: System displays the login page with email and password fields

2. **Enter Credentials**
   - Components: LoginFormComponent, InputComponent, ButtonComponent
   - State: Form inputs being populated
   - API Calls: None
   - User Interaction: User enters email and password
   - System Response: System validates input format (client-side validation)

3. **Submit Login Form**
   - Components: LoginFormComponent, LoadingIndicatorComponent
   - State: Loading state, form submission in progress
   - API Calls: POST `/user_token` with `{ auth: { email, password } }`
   - User Interaction: User clicks "Login" button
   - System Response: System shows loading indicator, disables form

4. **Process Authentication**
   - Components: LoginFormComponent, AlertComponent
   - State: Authentication processing
   - API Calls: None (waiting for response from previous call)
   - User Interaction: None (waiting)
   - System Response: System processes the authentication response

5. **Handle Successful Login**
   - Components: LoginFormComponent, RedirectComponent
   - State: Authentication successful, JWT token received
   - API Calls: GET `/users/current` (to get user details)
   - User Interaction: None (automatic)
   - System Response: System stores JWT token, fetches user details, redirects to dashboard

6. **Initialize Dashboard**
   - Components: DashboardComponent, HeaderComponent, SidebarComponent
   - State: Authenticated state, user details loaded
   - API Calls: Various API calls to load dashboard data
   - User Interaction: None (automatic)
   - System Response: System displays the dashboard with user-specific content

## Alternative Paths

### A1. Remember Me Option

If the user selects "Remember Me" during login:

1. After step 5, the system stores the JWT token with a longer expiration
2. On subsequent visits, the system attempts to use the stored token
3. If the token is valid, the user is automatically logged in

### A2. Forgot Password

If the user clicks "Forgot Password":

1. User is redirected to the password reset request page
2. User enters their email address
3. System sends a password reset link to the email
4. User clicks the link and sets a new password
5. User is redirected back to the login page

### A3. Single Sign-On (SSO)

If SSO is configured for the organization:

1. User clicks "Login with SSO" button
2. User is redirected to the identity provider
3. User authenticates with the identity provider
4. User is redirected back to the CMS with an authentication token
5. System validates the token and logs the user in

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Invalid credentials | Display error message, allow retry with rate limiting |
| Account locked | Display message about account being locked, provide contact information |
| Password expired | Redirect to password change screen |
| Browser cookies disabled | Display message about enabling cookies |
| Session timeout | Redirect to login page with message about session expiration |
| Concurrent logins | Allow multiple sessions or enforce single session based on configuration |

## Error States

| Error | Handling |
|-------|----------|
| Network error | Display error message with retry option |
| Server error (5xx) | Display generic error message, log details for troubleshooting |
| API unavailable | Display maintenance message |
| Rate limit exceeded | Display message about too many attempts, suggest waiting |
| Invalid token | Clear token, redirect to login page |

## Performance Considerations

1. **Token Storage**: JWT token is stored in browser storage (localStorage or sessionStorage)
2. **Token Refresh**: Implement token refresh mechanism to extend session without re-login
3. **Form Validation**: Client-side validation to reduce server roundtrips
4. **Error Caching**: Cache error responses to prevent repeated failed requests
5. **Lazy Loading**: Login module is loaded on demand to reduce initial load time

## Related Flows

- [Password Reset Flow](password_reset_flow.md)
- [Logout Flow](logout_flow.md)
- [Account Settings Flow](account_settings_flow.md)
- [Two-Factor Authentication Flow](two_factor_authentication_flow.md)

## Components Used

| Component | Role | Description |
|-----------|------|-------------|
| LoginPageComponent | Container | Main container for the login page |
| LoginFormComponent | Form | Handles the login form and submission |
| InputComponent | UI | Reusable input field with validation |
| ButtonComponent | UI | Reusable button with loading state |
| LoadingIndicatorComponent | UI | Shows loading state during API calls |
| AlertComponent | UI | Displays error and success messages |
| RedirectComponent | Utility | Handles redirects after login |

## API Endpoints Used

| Endpoint | Method | Purpose | Request Data | Response Data |
|----------|--------|---------|--------------|---------------|
| `/user_token` | POST | Authenticate user | `{ auth: { email, password } }` | `{ jwt: string }` |
| `/users/current` | GET | Get current user details | None (JWT in header) | User object |

## Diagrams

### Sequence Diagram

```
User                    LoginComponent               AuthService                 API
 |                            |                           |                        |
 |---(1) Access Login Page--->|                           |                        |
 |                            |                           |                        |
 |<---(2) Display Login Form--|                           |                        |
 |                            |                           |                        |
 |---(3) Enter Credentials--->|                           |                        |
 |                            |                           |                        |
 |---(4) Submit Form--------->|                           |                        |
 |                            |                           |                        |
 |                            |---(5) Login Request------>|                        |
 |                            |                           |                        |
 |                            |                           |---(6) POST /user_token>|
 |                            |                           |                        |
 |                            |                           |<---(7) JWT Token-------|
 |                            |                           |                        |
 |                            |<---(8) Login Success------|                        |
 |                            |                           |                        |
 |                            |---(9) Get User Details--->|                        |
 |                            |                           |                        |
 |                            |                           |---(10) GET /users/current>|
 |                            |                           |                        |
 |                            |                           |<---(11) User Object----|
 |                            |                           |                        |
 |                            |<---(12) User Details------|                        |
 |                            |                           |                        |
 |<---(13) Redirect to Dashboard-|                        |                        |
 |                            |                           |                        |
```

### State Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Unauthenticated│────>│  Authenticating │────>│  Authenticated  │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                        │
        │                       │                        │
        ▼                       ▼                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│ Password Reset  │     │  Auth Error     │     │ Session Timeout │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Security Considerations

1. **HTTPS**: All authentication traffic is encrypted using HTTPS
2. **JWT Storage**: Tokens are stored securely and not accessible via JavaScript
3. **Token Expiration**: Tokens have a limited lifetime and require refresh
4. **CSRF Protection**: Implemented for all authenticated requests
5. **Rate Limiting**: Login attempts are rate-limited to prevent brute force attacks
6. **Audit Logging**: All login attempts (successful and failed) are logged
7. **Input Validation**: All user inputs are validated on both client and server

## Testing

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| Valid Login | Login with valid credentials | Successful login, redirect to dashboard |
| Invalid Password | Login with invalid password | Error message, remain on login page |
| Invalid Email | Login with invalid email | Error message, remain on login page |
| Empty Fields | Submit form with empty fields | Validation errors, form not submitted |
| Account Locked | Login to locked account | Error message about account being locked |
| Remember Me | Login with "Remember Me" checked | Token persists across browser sessions |
| Session Timeout | Wait for session to expire | Redirect to login page with message |

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-02 | AI Assistant | Initial documentation of login flow | 