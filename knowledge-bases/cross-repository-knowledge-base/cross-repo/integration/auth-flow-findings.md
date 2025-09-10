# Authentication Flow Analysis

## Overview
This document provides a detailed analysis of authentication mechanisms across the three repositories, examining how authentication flows are implemented, secured, and integrated between components.

**Sources Reviewed:**
- Backend: `app/controllers/user_token_controller.rb`, `app/controllers/api/v1/application_controller.rb`, `config/initializers/knock.rb`
- Frontend: `src/api/http.js`, `src/api/api.js`, `src/analytics/EventsAPI.js`
- CMS: `src/app/core/core.module.ts`, `src/app/login/login.component.ts`
- Integration Tests: `spec/controllers/user_token_controller_spec.rb`, `spec/controllers/api/v1/application_controller_spec.rb`

## Key Findings

### Authentication Architecture

#### JWT-Based Authentication System
- **Centralized JWT Management**: The application uses JWT (JSON Web Token) for all authenticated communication.
- **Different Authentication Audiences**: 
  ```ruby
  # From spec/support/request_helper.rb
  def auth_token(entity)
    payload = { sub: entity.id, aud: [:backend] }
    if entity.is_a?(Store)
      payload[:aud] = [:api]
      payload[:jti] = entity.jti
    end
    Knock::AuthToken.new(payload: payload).token
  end
  ```
- **Token Lifetime Configuration**:
  ```ruby
  # From config/initializers/knock.rb
  config.token_lifetime = 100.years
  ```

### Backend Authentication Implementation

#### Rails Knock Integration
- **Custom Auth Token Controller**: The backend extends Knock's `AuthTokenController` to customize auth response:
  ```ruby
  # From app/controllers/user_token_controller.rb
  class UserTokenController < Knock::AuthTokenController
    skip_before_action :verify_authenticity_token

    def create
      render json: auth_response, status: :created
    end

    private

    def auth_response
      user_serializer = ActiveModelSerializers::SerializableResource.new(entity)
      { jwt: auth_token.token }.merge user_serializer.as_json
    end
  end
  ```

#### API Audience-Specific Authentication
- **API v1 Authentication**: The API controllers use a specific audience check:
  ```ruby
  # From app/controllers/api/v1/application_controller.rb
  include Knock::Authenticable
  before_action :render_error_when_invalid_auth_token, :except => [:ping]
  before_action :authenticate_store, :except => [:ping]
  ```
  
- **Token Validation Middleware**: Ensures token presence before processing requests:
  ```ruby
  # From app/controllers/api/v1/application_controller.rb
  def render_error_when_invalid_auth_token
    auth = params[:token] || request.headers['Authorization']
    if auth.blank?
      render(
        json: { error: { message: 'Authorization token not present' } },
        status: :unauthorized
      )
    end
  end
  ```

### CMS Authentication Implementation

#### Angular JWT Integration
- **JWT Authentication Module**: The CMS uses `@auth0/angular-jwt` for JWT handling:
  ```typescript
  // From src/app/core/core.module.ts
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

- **JWT Service Configuration**: Custom configuration for the JWT service:
  ```typescript
  // From src/app/core/core.module.ts
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

#### Login Flow
- **User Authentication**: Login component handles authentication:
  ```typescript
  // From src/app/login/login.component.ts
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

### Frontend Authentication Implementation

#### Token-Based API Authentication
- **Environment-Based Token**: Frontend uses an environment-based token:
  ```javascript
  // From src/api/api.js
  const TPB_STORE_TOKEN = process.env.TPB_STORE_TOKEN
    ? process.env.TPB_STORE_TOKEN
    : self.kioskConfig.API.TOKEN
  ```

- **Axios HTTP Client Configuration**: Token included in requests:
  ```javascript
  // From src/api/api.js
  constructor() {
    this.http = axios.create({
      baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID,
      params: {
        token: TPB_STORE_TOKEN
      },
      headers: {
        'Cache-Control': 'no-cache',
        Pragma: 'no-cache',
        Expires: '0'
      }
    })
  }
  ```

- **Analytics API Authentication**: Bearer token used for analytics:
  ```javascript
  // From src/analytics/EventsAPI.js
  uploadEvents(data, token) {
    return Axios.post(this.baseurl, data, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
  }
  ```

### Cross-Repository Authentication Flows

#### User Flow (CMS to Backend)
1. **User Login**: CMS collects credentials and sends to `user_token` endpoint
2. **Token Generation**: Backend validates credentials and generates JWT
3. **Token Storage**: CMS stores JWT in localStorage
4. **Authenticated Requests**: JWT included in subsequent requests through HTTP interceptor

#### Store/Kiosk Flow (Frontend to Backend)
1. **Token Initialization**: Frontend retrieves store token from environment or config
2. **Request Configuration**: Axios instance configured with token
3. **Request Execution**: All API calls include the token as query parameter
4. **Token Validation**: Backend validates token audience and jti

### Token Validation and Security

#### Backend Token Validation
- **Knock Authenticable**: Uses the Knock gem's authentication mechanisms:
  ```ruby
  # Inferred from the code
  def authenticate_store
    authenticate_for(Store, :api)
  end
  ```

- **Audience Claim Validation**: Tests confirm audience claim validation:
  ```ruby
  # From spec/controllers/api/v1/application_controller_spec.rb
  context 'with a not valid token (audience)' do
    before do
      user.update!(id: store.id)
      authenticate(user)
    end

    it 'is not authorized' do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end
  ```

#### CMS Token Security
- **Domain Whitelisting**: Only allows token use on whitelisted domains:
  ```typescript
  // From src/app/core/core.module.ts
  whitelistedDomains: [
    environment.apiUrl.replace(/((http)|(https)):\/\//, '')
  ]
  ```

## Integration Challenges and Patterns

### Challenges Identified
1. **Long Token Lifetime**: 100-year token lifetime increases risk if tokens are compromised
2. **Token Audience Management**: Need to maintain separate token audiences for different clients
3. **Frontend Token Storage**: Frontend relies on environment variables for token storage

### Effective Patterns
1. **Audience-Based Authorization**: Clear separation of API vs Backend tokens
2. **JWT Standard Compliance**: Consistent use of JWT standards across repositories
3. **Modular Authentication Services**: Well-factored authentication services in both frontend and CMS

## Questions & Gaps

### Open Questions
1. How is token refresh handled, especially for long-lived sessions?
2. How are token revocation and invalidation implemented?
3. What security mechanisms exist to protect against token theft?

### Areas Needing Investigation
- Token refresh mechanisms
- CSRF protection implementation
- Token revocation strategy
- Multi-factor authentication support

### Potential Risks
- **Long-lived Tokens**: 100-year token lifetime is excessive and poses security risks
- **Query Parameter Token**: Frontend passes token as a query parameter, which could be logged in server logs
- **Limited Token Validation**: Minimal validation beyond audience and jti claims

## Next Steps
1. Document token lifecycle management
2. Analyze token revocation mechanisms
3. Review security implications of current token handling
4. Establish best practices for cross-repository authentication

## Cross-References
- Related to: [API Integration Analysis](./api-integration-findings.md)
- Related to: [Initial Authentication Findings](../initial-understanding/authentication-flow-findings.md)
- Supports: [Cross-Repository Integration](../initial-understanding/cross-repository-integration-findings.md)

## Version History
- 1.0.0 (2024-03-21): Initial findings document created 