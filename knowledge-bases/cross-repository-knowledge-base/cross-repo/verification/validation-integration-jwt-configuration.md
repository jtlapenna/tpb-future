# JWT Configuration Integration Point Validation

## Overview
The JWT (JSON Web Token) Configuration integration point provides a standardized authentication mechanism across all repositories in the system. This validation document examines how JWT authentication is implemented, configured, and utilized across the backend (Ruby on Rails), frontend (Vue.js), and CMS frontend (Angular) repositories.

## Validation Evidence

### Backend (Ruby on Rails)

#### JWT Configuration Setup

The backend repository uses the Knock gem for JWT authentication, configured in `repositories/back-end/config/initializers/knock.rb`:

```ruby
Knock.setup do |config|
  config.token_lifetime = 100.years
  config.token_signature_algorithm = 'HS256'
  config.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }
  # Other configurations...
end
```

Key configuration elements:
- Token lifetime set to 100 years (effectively non-expiring)
- HS256 algorithm used for token signing
- Rails application's secret key base used for token signing

#### Token Generation Controller

User token generation is handled by `repositories/back-end/app/controllers/user_token_controller.rb`:

```ruby
class UserTokenController < Knock::AuthTokenController
  def create
    response.headers['Authorization'] = "Bearer #{auth_token.token}"
    render json: { jwt: auth_token.token }, status: :created
  end
end
```

This controller inherits from Knock's `AuthTokenController` and provides a custom `create` method that returns the JWT token in both the response headers and the response body.

#### User Model JWT Integration

The User model (`repositories/back-end/app/models/user.rb`) includes methods for JWT payload handling:

```ruby
class User < ApplicationRecord
  # Other model code...
  
  def self.from_token_payload(payload)
    # Find user from JWT payload
  end
  
  def to_token_payload
    # Convert user to JWT payload
  end
end
```

#### Token Validation and Testing

Token validation is tested in `repositories/back-end/spec/requests/user_tokens_spec.rb`, which verifies:
- Successful authentication returns a valid JWT
- The JWT has the correct structure (three parts separated by periods)
- Authentication with invalid credentials fails

### Frontend (Vue.js)

#### Token Storage and Management

The frontend stores JWT tokens in the browser's localStorage as seen in multiple files:

1. In `repositories/front-end/sesion.js` and `repositories/front-end/src/analytics/example.js`:
```javascript
getToken = async function(e, t, o) {
  try {
    // API request to obtain token
    var a = await fetch(serverUrl + "/api/v1/token/", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(r)
    }).then(e => e.json());
    
    return !!a.result && (accessToken = a.access_token, refreshToken = a.refresh, setTimeout(getToken, a.refresh_lifetime, e, t, o), !0)
  } catch (r) {
    // Error handling
  }
};
```

2. Token refresh mechanism in the same files:
```javascript
refreshAccessToken = async function() {
  try {
    var e = await fetch(serverUrl + "/api/v1/token/refresh/", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh: refreshToken })
    }).then(e => e.json());
    
    e.access ? (accessToken = e.access, setTimeout(uploadEvents, 2e4)) : 
      // Error handling
  } catch (e) {
    // Error handling
  }
}
```

#### Token Usage in API Requests

JWT tokens are included in API request headers:

```javascript
storeResponse = await fetch(serverUrl + "/api/v1/upload-events/", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    Authorization: "Bearer " + accessToken
  },
  body: JSON.stringify(body_data)
}).then(e => e.json())
```

#### Hardcoded Tokens

The frontend includes some hardcoded JWT tokens in configuration files:

1. In `repositories/front-end/not.env`:
```
TPB_STORE_TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjQ3ODk3NTE1NTQsInN1YiI6MTcsImF1ZCI6WyJhcGkiXSwianRpIjoiMmVlNjVlYzQyOGNjMjc3MWI3Nzg1YjhjZTE4OTdlOWEifQ.gepFPVNaob3p-geHS3wjY6gjUPqaBNJK-SxMrUJFF7Y"
```

2. In `repositories/front-end/static/js/config.js` and similar files:
```javascript
API: {
  URL: 'https://api-prod.thepeakbeyond.com/api/v1',
  CATALOG_ID: 507,
  TOKEN: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjQ3ODkxNDc5MjMsInN1YiI6MTc3LCJhdWQiOlsiYXBpIl0sImp0aSI6IjE2MTBlN2UyNGMzMjEyZWNiZjc0YmRmNzJlOGViOTc4In0.1Ix9m_EErhmCMRrxkDcnaC9X7AzsRSOtqDzFHZ5kZ04'
}
```

### CMS Frontend (Angular)

#### JWT Module Configuration

The CMS frontend utilizes `@auth0/angular-jwt` and a custom JWT authentication service from `@yellowspot/jwt-auth-service`, as configured in `repositories/cms-fe-angular/src/app/core/core.module.ts`:

```typescript
export const JWT_TOKEN_ID = 'jwt';

export function jwtOptionsFactory() {
  return {
    tokenGetter: () => {
      return localStorage.getItem(JWT_TOKEN_ID);
    },
    whitelistedDomains: [
      environment.apiUrl.replace(/((http)|(https)):\/\//, '')
    ]
  };
}

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

@NgModule({
  imports: [
    // Other imports...
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
  ],
  // Other module configuration...
})
export class CoreModule { /* ... */ }
```

The configuration includes:
- Token storage in localStorage with key 'jwt'
- Whitelisted domains for JWT usage
- API endpoints for authentication and user information
- User model mapping

#### Authentication Flow

The login component (`repositories/cms-fe-angular/src/app/login/login.component.ts`) handles user authentication:

```typescript
login() {
  const rawForm = this.loginForm.getRawValue();
  this.error = false;
  this.authSrv.authenticate(rawForm.email, rawForm.password).subscribe(user => {
    this.error = false;
    this.router.navigate(['/app', 'dashboard']);
  }, error => {
    this.error = true;
  });
}
```

#### Route Protection

Routes are protected using the `SessionGuard` from the JWT authentication service:

```typescript
export const ROUTES: Routes = [
  { path: '', redirectTo: 'app', pathMatch: 'full' },
  {
    path: 'app',
    canActivate: [SessionGuard],
    canActivateChild: [SessionGuard],
    loadChildren: () => import('./layout/layout.module').then(m => m.LayoutModule)
  },
  { path: 'login', loadChildren: () => import('./login/login.module').then(m => m.LoginModule) },
  // Other routes...
];
```

#### Token Generation for Stores

The CMS frontend includes functionality to generate JWT tokens for stores:

```typescript
generateToken(id: number): Observable<string> {
  const url = `${environment.apiUrl}/${this.resourcePath()}/${id}/generate_token`;
  return this.http.post<any>(url, {}).pipe(
    map(response => response.jwt)
  );
}
```

## Cross-Repository Validation

### JWT Implementation Consistency

| Feature | Backend | Frontend | CMS Frontend |
|---------|---------|----------|--------------|
| Token Format | JWT | JWT | JWT |
| Token Storage | N/A (server) | localStorage | localStorage |
| Authentication Endpoint | `/user_token` | `/api/v1/token/` | `/user_token` |
| Token Refresh | N/A (long-lived) | Implemented | Via library |
| Authorization Header | `Bearer {token}` | `Bearer {token}` | `Bearer {token}` |

### Validation Findings

1. **Consistent JWT Format**: All repositories use the standard JWT format with three parts (header, payload, signature).

2. **Token Generation**: The backend provides endpoints for token generation used by both frontend applications.

3. **Authentication Flow**:
   - Backend: Handles token generation and validation
   - Frontend: Implements login and token storage with refresh capability
   - CMS Frontend: Uses Angular libraries for JWT authentication with route protection

4. **Security Considerations**:
   - Backend uses Rails secret key for signing
   - Token lifetime is extremely long (100 years)
   - Authentication headers properly structured with Bearer prefix

5. **Integration Points**:
   - Backend provides consistent token endpoints for both frontends
   - Frontend applications store tokens similarly but use different libraries
   - CMS has more sophisticated JWT handling with route guards

6. **Token Usage**: All repositories use the JWT tokens in the Authorization header for API requests.

## Recommendations

1. **Security Improvements**:
   - Reduce token lifetime from 100 years to a more reasonable duration (e.g., 1-24 hours)
   - Implement consistent token refresh mechanism across all applications
   - Move hardcoded tokens out of source code into environment variables

2. **Standardization**:
   - Standardize JWT library usage across frontend applications
   - Ensure consistent token storage and retrieval methods

3. **Error Handling**:
   - Improve error handling for authentication failures
   - Implement standardized session expiration handling

4. **Testing**:
   - Enhance test coverage for authentication flows
   - Add integration tests specifically for authentication across repositories

5. **Documentation**:
   - Create developer documentation on the authentication flow
   - Document token payload structure and validation requirements

## Conclusion

The JWT Configuration integration point is successfully implemented across all three repositories, providing a consistent authentication mechanism throughout the system. While there are some implementation differences between the frontend applications, the core JWT functionality works consistently. Security improvements and standardization would enhance the overall quality of this integration point. 