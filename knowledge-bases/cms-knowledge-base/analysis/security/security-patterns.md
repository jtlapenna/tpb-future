# Security Patterns Analysis

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview

This document outlines the security patterns identified in the existing codebase, focusing on authentication, authorization, and data protection mechanisms.

## Authentication

### 1. JWT Authentication
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

Key features:
- JWT token-based authentication
- Token storage in localStorage
- Whitelisted domains configuration
- Current user endpoint integration

### 2. Login Implementation
```typescript
@Component({
  selector: 'app-login'
})
export class LoginComponent {
  login() {
    const rawForm = this.loginForm.getRawValue();
    this.authSrv.authenticate(rawForm.email, rawForm.password).subscribe(user => {
      this.router.navigate(['/app', 'dashboard']);
    });
  }
}
```

## Authorization

### 1. Route Guards
```typescript
@Injectable()
export class AdminGuard implements CanActivate {
  canActivate() {
    const admin$ = this.authSrv.currentUser$.pipe(
      map(user => user && user.admin),
      tap(admin => {
        if (!admin) {
          this.router.navigate(['/forbidden']);
        }
      }),
      first()
    );
    return admin$;
  }
}
```

### 2. Protected Routes
```typescript
const routes: Routes = [
  { path: 'app',
    canActivate: [SessionGuard],
    canActivateChild: [SessionGuard],
    loadChildren: () => import('./layout/layout.module').then(m => m.LayoutModule)
  },
  { path: 'clients', 
    canActivate: [AdminGuard], 
    loadChildren: () => import('../clients/clients.module').then(m => m.ClientsModule) 
  }
]
```

## Session Management

### 1. User Session
```typescript
export function jwtAuthOptionsFactory() {
  return {
    ...defaultOptions,
    userFromJson: (json) => new User(json.user),
    authUrl: `${environment.apiUrl}/user_token`,
    currentUserUrl: `${environment.apiUrl}/users/current`,
    paramsWrapper: 'auth',
    guardRedirectTo: '/login'
  };
}
```

### 2. Session Validation
- Session guard for protected routes
- Automatic redirection to login
- Current user state management

## Error Tracking

### 1. Sentry Integration
```typescript
Sentry.init({
  dsn: environment.SENTRY_DSN,
  integrations: [
    new Integrations.BrowserTracing({
      routingInstrumentation: Sentry.routingInstrumentation,
    }),
  ],
  tracesSampleRate: 1.0,
  environment: environment.production ? "production" : "development"
})
```

## API Security

### 1. HTTP Interceptors
```typescript
{ 
  provide: HTTP_INTERCEPTORS, 
  useClass: RequestErrorsInterceptor, 
  multi: true 
}
```

### 2. Token Generation
```typescript
generateToken(id: number): Observable<string> {
  const url = `${environment.apiUrl}/${this.resourcePath()}/${id}/generate_token`;
  return this.http.post<any>(url, {}).pipe(
    map(response => response.jwt)
  );
}
```

## Role-Based Access Control

### 1. Admin Access
```typescript
admin$ = this.authSrv.currentUser$.pipe(
  map(user => user && user.admin),
  shareReplay(1)
);
```

### 2. Protected Components
- Admin-only routes and components
- Role-based UI elements
- Permission-based actions

## Best Practices

1. **Authentication**
   - JWT token management
   - Secure password handling
   - Session timeout handling

2. **Authorization**
   - Route protection
   - Component-level access control
   - Resource-based permissions

3. **API Security**
   - Token-based authentication
   - Request/response interceptors
   - Error handling

4. **Error Tracking**
   - Sentry integration
   - Environment-specific tracking
   - User context preservation

## Dependencies

- `@auth0/angular-jwt`: JWT handling
- `@yellowspot/jwt-auth-service`: Authentication service
- `@sentry/angular`: Error tracking
- `@angular/router`: Route protection

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial documentation of security patterns | 