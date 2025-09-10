# Token-Based Authentication Pattern Validation

## Pattern Overview
**Pattern Name**: Token-Based Authentication
**Pattern Description**: A system-wide approach using JSON Web Tokens (JWT) for authentication and authorization across all three repositories, with repository-specific implementations for token generation, storage, and validation.

## Validation Evidence

### Backend (Ruby on Rails)

#### Token Generation and Configuration
**Evidence**: `repositories/back-end/config/initializers/knock.rb`
```ruby
Knock.setup do |config|
  config.token_lifetime = 1.week
  config.token_signature_algorithm = 'HS256'
  config.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }
  config.not_found_exception_class_name = 'ActiveRecord::RecordNotFound'
end
```

**Validation**: The backend uses the Knock gem to implement JWT authentication with a 1-week token lifetime and HS256 signature algorithm.

#### Authentication Controllers
**Evidence**: `repositories/back-end/spec/requests/user_tokens_spec.rb`
```ruby
require 'rails_helper'

RSpec.describe "UserTokens", type: :request do
  describe "POST /user_token" do
    let(:user) { create(:admin) }
    
    it "returns a valid JWT with valid credentials" do
      post "/user_token", params: { 
        auth: { 
          email: user.email, 
          password: "password" 
        } 
      }
      
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to have_key("jwt")
      
      # Verify JWT is valid
      token = JSON.parse(response.body)["jwt"]
      decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base, true, { algorithm: 'HS256' })
      expect(decoded_token.first["sub"]).to eq(user.id)
    end
  end
end
```

**Validation**: The backend implements a `/user_token` endpoint that authenticates users and returns a valid JWT. The token contains the user ID in the `sub` claim and is signed with the application's secret key.

### CMS Frontend (Angular)

#### Authentication Service
**Evidence**: `repositories/cms-fe-angular/src/app/login/login.component.ts`
```typescript
@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {
  // ...
  
  constructor(
    private router: Router,
    private jwtAuth: JwtAuthService,
    private formBuilder: FormBuilder
  ) { }
  
  // ...
  
  login() {
    if (this.loginForm.valid) {
      this.loading = true;
      const payload = {
        auth: {
          email: this.loginForm.get('email').value,
          password: this.loginForm.get('password').value
        }
      };
      this.jwtAuth.login(payload)
        .pipe(first())
        .subscribe(
          data => {
            // Success
            this.router.navigate(['/dashboard']);
          },
          error => {
            // Error handling
            this.loading = false;
            this.error = error;
          }
        );
    }
  }
}
```

**Validation**: The CMS frontend uses Angular's HTTP client with a specialized `JwtAuthService` to authenticate users against the backend's `/user_token` endpoint and obtain a JWT. Upon successful authentication, users are redirected to the dashboard.

### Frontend (Vue.js)

#### Token Storage and API Integration
**Evidence**: `repositories/front-end/src/api/http.js`
```javascript
import axios from 'axios'
import { API_URL, API_TOKEN } from '@/config'

// Create axios instance with base URL
const http = axios.create({
  baseURL: API_URL
})

// Add authorization header with JWT token
http.interceptors.request.use(
  config => {
    config.headers['Authorization'] = `Bearer ${API_TOKEN}`
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

export default http
```

**Evidence**: `repositories/front-end/src/api/api.js`
```javascript
import http from './http'

export default {
  // API methods using the configured HTTP client
  // ...
}
```

**Validation**: The frontend uses a pre-configured token (from environment variables) to authenticate API requests, applying the token as a Bearer token in the Authorization header for all API calls.

### Store Token Generation
**Evidence**: `repositories/cms-fe-angular/src/app/stores/services/store.service.ts`
```typescript
generateToken(storeId: number): Observable<any> {
  return this.http.post(`${environment.apiUrl}/api/v1/stores/${storeId}/generate_token`, {});
}
```

**Validation**: The CMS provides functionality to generate store-specific tokens, which can be used by the frontend to authenticate store-specific API requests.

## Cross-Repository Flow Validation

### User Authentication Flow
1. **Backend**: Configures JWT settings with 1-week lifetime and HS256 algorithm
2. **CMS Frontend**: Authenticates user with email/password via `/user_token` endpoint
3. **Backend**: Validates credentials and returns JWT
4. **CMS Frontend**: Stores JWT in localStorage and includes it in subsequent API requests
5. **Backend**: Validates JWT on protected endpoints and authorizes requests

### Store/Kiosk Authentication Flow
1. **CMS Frontend**: Admin generates store-specific token via the Store Service
2. **Backend**: Creates and returns a store-specific JWT
3. **Frontend**: Configured with the store token from environment variables
4. **Frontend**: Includes token in all API requests via axios interceptors
5. **Backend**: Validates store token and authorizes store-specific access

## Security Validation

### Token Security
- **Signature Verification**: Backend properly verifies token signatures using the application's secret key
- **Expiration**: Tokens expire after 1 week, providing a reasonable security boundary
- **Transport Security**: Tokens are transmitted over HTTPS (inferred from production configurations)

### Storage Security
- **CMS**: Tokens stored in browser localStorage
  - **Risk**: Vulnerable to XSS attacks
  - **Mitigation**: Limited access to CMS (admin users only)
- **Frontend**: Tokens stored in environment variables
  - **Advantage**: Not accessible via browser storage
  - **Challenge**: Requires redeployment for token updates

## Implementation Consistency

| Authentication Aspect | Backend | CMS Frontend | Frontend |
|----------------------|---------|--------------|----------|
| Token Format | JWT | JWT | JWT |
| Generation Method | Knock gem | N/A (consumer) | N/A (pre-configured) |
| Storage | N/A (verifier) | localStorage | Environment variables |
| Transport | Bearer token | Bearer token | Bearer token |
| Authorization | Role-based | N/A | Store/kiosk-based |

## Validation Conclusion

The Token-Based Authentication pattern is **successfully validated** across all three repositories with the following findings:

1. **Consistent Implementation**: All repositories use JWT tokens with Bearer authentication scheme
2. **Appropriate Role Separation**: 
   - Backend serves as token issuer and validator
   - CMS acts as dynamic token consumer (user authentication)
   - Frontend acts as static token consumer (store authentication)
3. **Security Considerations**:
   - Token lifetime (1 week) may be longer than necessary for high-security environments
   - CMS localStorage storage introduces potential XSS vulnerability
4. **Integration Effectiveness**:
   - Authentication flows properly support both user and store authentication scenarios
   - Token validation is consistently implemented

## Recommendations

Based on the validation findings, the following improvements could enhance the authentication pattern:

1. **Reduce Token Lifetime**: Consider shortening token lifetime from 1 week to 1 day or less
2. **Alternative Token Storage for CMS**: Investigate more secure storage options than localStorage
3. **Token Refresh Mechanism**: Implement a token refresh flow to maintain sessions without requiring full re-authentication
4. **Audience Validation**: Add explicit audience validation in token verification to prevent token misuse across contexts

## Cross-References
- Authentication Flow Findings: `analysis/findings/detailed-analysis/auth-flow-findings.md`
- Integration Patterns: `analysis/cross-repo/patterns/integration/integration-patterns.md`
- Security Patterns: `analysis/cross-repo/patterns/security/security-patterns.md` 