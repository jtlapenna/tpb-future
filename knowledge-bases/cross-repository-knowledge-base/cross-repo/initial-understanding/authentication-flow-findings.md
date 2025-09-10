# Authentication Flow Findings

## Overview
This document analyzes the authentication flow patterns implemented across the three repositories (Frontend, CMS, and Backend). The analysis focuses on token-based authentication mechanisms, middleware/interceptors, and how authentication is handled in each repository.

**Sources Reviewed:**
- Backend: `app/controllers/application_controller.rb`, `app/controllers/api/v1/application_controller.rb`, `app/models/user.rb`, `app/models/store.rb`, `config/initializers/knock.rb`
- CMS: `src/app/core/core.module.ts`, `src/app/core/interceptors/request-errors.interceptor.ts`, `src/app/login/login.component.ts`, `src/app/app.routes.ts`
- Frontend: `src/api/http.js`, `src/api/api.js`

## Key Findings

### Authentication Architecture
- **JWT-Based Authentication**: All three repositories implement JWT (JSON Web Token) based authentication.
- **Role-Based Authentication**: Backend supports two distinct authentication flows:
  - User authentication for CMS (`Knock::Authenticable` with `:backend` audience)
  - Store/kiosk authentication for Frontend (`Knock::Authenticable` with `:api` audience)
- **Token Persistence**: Token storage varies by client:
  - CMS: LocalStorage via `JWT_TOKEN_ID` key
  - Frontend: Environmental configuration through `TPB_STORE_TOKEN`

### Critical Patterns

#### Backend Implementation
- Uses the Knock gem with customized configuration:
  ```ruby
  # config/initializers/knock.rb
  config.token_lifetime = 100.years
  ```
- Token validation through audience claims:
  ```ruby
  # app/models/user.rb
  def self.from_token_payload(payload)
    if !payload['aud'] || !payload['aud'].include?('backend')
      raise Knock.not_found_exception_class_name
    end
    # ...
  end
  ```
- Store/kiosk tokens include a JTI (JWT ID) claim for added security:
  ```ruby
  # app/models/store.rb
  def to_token_payload
    payload = { sub: id, aud: [:api], jti: jti }
    payload
  end
  ```

#### CMS Implementation
- Angular JWT integration:
  ```typescript
  // src/app/core/core.module.ts
  JwtModule.forRoot({
    jwtOptionsProvider: {
      provide: JWT_OPTIONS,
      useFactory: jwtOptionsFactory,
    }
  })
  ```
- JWT token retrieval from localStorage:
  ```typescript
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
  ```
- Login component with authentication service:
  ```typescript
  login() {
    const rawForm = this.loginForm.getRawValue();
    this.error = false;
    this.authSrv.authenticate(rawForm.email, rawForm.password).subscribe(user => {
      // ...
    });
  }
  ```
- Route protection with SessionGuard:
  ```typescript
  // src/app/app.routes.ts
  {
    path: 'app',
    canActivate: [SessionGuard],
    canActivateChild: [SessionGuard],
    // ...
  }
  ```

#### Frontend Implementation
- Axios instance with token in params:
  ```javascript
  // src/api/http.js
  export const HTTP = axios.create({
    baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID,
    params: {
      token: TPB_STORE_TOKEN
    }
  })
  ```
- Tokens loaded from environment variables or configuration:
  ```javascript
  const TPB_STORE_TOKEN = process.env.TPB_STORE_TOKEN 
    ? process.env.TPB_STORE_TOKEN 
    : self.kioskConfig.API.TOKEN
  ```
- No explicit login flow in frontend since it uses a pre-configured token

## Questions & Gaps

### Open Questions
1. How are store/kiosk tokens initially generated and distributed?
2. What's the refresh token strategy for long-lived sessions?
3. How are token revocations handled across systems?

### Areas Needing Investigation
- Error handling consistency across authentication failures
- Security implications of 100-year token lifetime
- Authentication flow for third-party integrations

### Potential Risks
- Long-lived tokens (100 years) without a refresh mechanism 
- Store tokens in frontend code/configuration without secure storage
- Limited token invalidation strategy

## Next Steps
1. Examine backend token generation process
2. Investigate token revocation mechanisms
3. Document authentication-related error handling
4. Assess security implications of current authentication patterns

## Cross-References
- Related to [Cross-Repository Integration Findings](cross-repository-integration-findings.md)
- Related to [API Knowledge Base Findings](api-knowledge-base-findings.md)
- Related to [CMS Knowledge Base Findings](cms-knowledge-base-findings.md)

## Version History
- 1.0.0 (2024-03-21): Initial findings document created 