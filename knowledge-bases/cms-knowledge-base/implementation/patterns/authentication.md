# Authentication Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the authentication patterns implemented in the CMS, focusing on JWT-based authentication, route guards, and user management.

## JWT Authentication

### Configuration
The application uses `@auth0/angular-jwt` and `@yellowspot/jwt-auth-service` for JWT authentication:

```typescript
export const JWT_TOKEN_ID = 'jwt';

export function jwtOptionsFactory() {
  return {
    tokenGetter: () => localStorage.getItem(JWT_TOKEN_ID),
    whitelistedDomains: [environment.apiUrl]
  };
}

export function jwtAuthOptionsFactory() {
  return {
    userFromJson: (json) => new User(json.user),
    authUrl: `${environment.apiUrl}/user_token`,
    currentUserUrl: `${environment.apiUrl}/users/current`,
    paramsWrapper: 'auth',
    guardRedirectTo: '/login'
  };
}
```

### Module Setup
```typescript
@NgModule({
  imports: [
    JwtModule.forRoot({
      jwtOptionsProvider: {
        provide: JWT_OPTIONS,
        useFactory: jwtOptionsFactory,
      }
    }),
    JwtAuthModule.forRoot({
      jwtAuthOptionsProvider: {
        provide: JWT_AUTH_OPTIONS,
        useFactory: jwtAuthOptionsFactory,
      }
    })
  ]
})
```

## Route Protection

### Admin Guard
```typescript
@Injectable()
export class AdminGuard implements CanActivate {
  constructor(
    private router: Router,
    private authSrv: JwtAuthService<User>
  ) { }

  canActivate() {
    return this.authSrv.currentUser$.pipe(
      map(user => user && user.admin),
      tap(admin => {
        if (!admin) {
          this.router.navigate(['/forbidden']);
        }
      }),
      first()
    );
  }
}
```

## User Management

### User Model
```typescript
export class User {
  id: number;
  name: string;
  email: string;
  client: Client;

  constructor(json) {
    this.id = json.id;
    this.name = json.name;
    this.email = json.email;
    this.client = new Client(json.client || {});
  }

  get admin(): boolean {
    return !this.client.id;
  }
}
```

## Authentication Flow

1. **Login Process**
   - User submits credentials
   - JWT token received from `/user_token`
   - Token stored in localStorage
   - User data fetched from `/users/current`

2. **Request Authentication**
   - JWT token attached to requests
   - Token validation on protected routes
   - Automatic token refresh
   - Error handling for invalid tokens

3. **Route Protection**
   - Guards check user authentication
   - Role-based access control
   - Redirect to login for unauthenticated users
   - Forbidden page for unauthorized access

## Implementation Patterns

### Authentication Service
1. **Token Management**
   - Token storage
   - Token retrieval
   - Token refresh
   - Token validation

2. **User Management**
   - Current user state
   - User role checking
   - User data transformation
   - Session management

3. **Route Guards**
   - Authentication checks
   - Role verification
   - Navigation control
   - Redirect handling

## Best Practices

1. **Security**
   - Secure token storage
   - HTTPS-only communication
   - Token expiration handling
   - XSS protection

2. **User Experience**
   - Clear login feedback
   - Automatic redirects
   - Session timeout handling
   - Error messaging

3. **Code Organization**
   - Centralized auth service
   - Reusable guards
   - Clear user model
   - Type safety

4. **Performance**
   - Efficient token management
   - Minimal token size
   - Optimized route protection
   - Caching strategies

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial authentication patterns documentation 