# Authentication Implementation Documentation

## Overview
The Peak Beyond's backend system uses JWT (JSON Web Token) based authentication implemented through the Knock gem. This document details the current authentication implementation.

## Core Components

### JWT Configuration
- **Token Lifetime**: 100 years (effectively non-expiring)
- **Signature Algorithm**: HS256 (default)
- **Secret Key**: Rails application secret_key_base
- **Exception Handling**: Uses ActiveRecord::RecordNotFound for user lookup failures

### Authentication Flow
1. Client sends credentials to authentication endpoint
2. Server validates credentials and generates JWT
3. Client includes JWT in Authorization header for subsequent requests
4. Server validates token for protected endpoints

### Security Settings
- Token-based authentication
- Bearer token scheme
- No token expiration (configured for 100 years)
- Uses Rails secret_key_base for token signing

## Implementation Details

### Initializer Configuration
```ruby
# config/initializers/knock.rb
Knock.setup do |config|
  config.token_lifetime = 100.years
  # Uses default HS256 algorithm
  # Uses Rails secret_key_base for signing
end
```

### Protected Resources
All controllers requiring authentication include:
- API endpoints (app/controllers/api/v1/*)
- Admin controllers
- Store management endpoints
- User management endpoints

### Authentication Headers
- Format: `Authorization: Bearer <token>`
- Token must be included in all protected API requests

### Error Handling
- Invalid token: Returns 401 Unauthorized
- Missing token: Returns 401 Unauthorized
- User not found: Returns 404 Not Found
- Invalid credentials: Returns 401 Unauthorized

## Integration Points

### POS System Authentication
- Bearer token authentication
- API key management
- Store-specific credentials

### External Service Authentication
- EzTexting: Username/password
- Shopify: API key/secret
- Headset: API token
- Pusher: App credentials

## Current Limitations

1. Token Expiration
   - Tokens set to not expire (100 years)
   - No refresh token mechanism
   - No token revocation

2. Security Considerations
   - No rate limiting on auth endpoints
   - No IP-based restrictions
   - No multi-factor authentication

## Testing

Authentication testing is implemented in:
- Controller specs using `authenticate` helper
- Request specs with token generation
- API acceptance tests with apiKey documentation

## Related Files

1. Configuration
   - config/initializers/knock.rb
   - config/initializers/eager_load_knock.rb

2. Controllers
   - app/controllers/secured_controller.rb
   - app/controllers/user_token_controller.rb
   - app/controllers/api/v1/application_controller.rb

3. Test Support
   - spec/support/request_helper.rb
   - spec/controllers/secured_controller_spec.rb
   - spec/controllers/user_token_controller_spec.rb 