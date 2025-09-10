---
title: Authentication Mechanisms
description: Detailed documentation of authentication mechanisms used in The Peak Beyond's backend system
last_updated: 2023-08-01
contributors: [AI Assistant]
---

# Authentication Mechanisms

## Version Information
- Category: API Documentation
- Type: Security Specification
- Current Version: 1.0.0
- Status: Current
- Last Updated: Mar 12, 03:03 PM
- Last Reviewer: System
- Next Review Due: Apr 12, 2024

## Version History
### Version 1.0.0 (Mar 12, 03:03 PM)
- Author: System
- Reviewer: System
- Changes:
  - Initial documentation creation
  - Authentication specifications added
  - Token management system documented
  - Session handling patterns included
  - Security best practices outlined
- Related Updates:
  - Updated api_documentation_summary.md to reference new auth specs
  - Linked with authorization_mechanisms.md for complete auth flow

## Dependencies
### Required By
- authentication_and_authorization.md (requires this document)
- api_security_overview.md (requires this document)

### Depends On
- api_documentation_summary.md (for overall context)
- authorization_mechanisms.md (for complete auth flow)

## Review History
- Last Review: Mar 12, 03:03 PM
- Reviewer: System
- Outcome: Approved
- Comments: Initial version approved with security review completed

## Maintenance Schedule
- Review Frequency: Monthly
- Next Scheduled Review: Apr 12, 2024
- Update Window: First week of each month
- Quality Assurance: Technical review and security testing required

## Overview

The Peak Beyond's backend system implements a multi-layered authentication approach to secure different types of API endpoints. The system primarily uses JWT (JSON Web Token) authentication via the Knock gem, with specialized authentication mechanisms for different API contexts.

## Authentication Types

The system implements three main types of authentication:

1. **JWT Authentication**: Used for admin API endpoints and CMS access
2. **Store Token Authentication**: Used for webhook endpoints from POS systems
3. **Catalog Token Authentication**: Used for public API endpoints accessed by kiosks

## JWT Authentication

### Implementation

JWT authentication is implemented using the Knock gem, which provides a seamless way to handle JWT tokens in Rails applications.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Knock::Authenticable
  include Pundit
  include Rescuable

  before_action :authenticate_user
end
```

The `authenticate_user` method is provided by Knock and verifies the JWT token in the request headers. If the token is valid, it sets the `current_user` object for the request.

### Token Generation

JWT tokens are generated through the `UserTokenController`, which extends Knock's `AuthTokenController`:

```ruby
# app/controllers/user_token_controller.rb
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

The controller customizes the response to include both the JWT token and the user information in a single response.

### Authentication Flow

1. Client sends credentials (email/password) to `/user_token` endpoint
2. Server validates credentials and generates a JWT token
3. Token is returned to the client along with user information
4. Client includes token in the `Authorization` header for subsequent requests
5. Server validates token and identifies the user for each request

### Token Structure

The JWT token contains the following claims:
- **sub**: User ID
- **exp**: Expiration timestamp
- **iat**: Issued at timestamp

### Token Expiration

Tokens have a configurable expiration time, typically set to 24 hours. After expiration, clients must request a new token.

## Store Token Authentication

### Implementation

Store token authentication is used for webhook endpoints that receive updates from POS systems. Each store has a unique token that must be included in webhook requests.

```ruby
# app/controllers/api/v1/application_controller.rb
class Api::V1::ApplicationController < ActionController::API
  include Knock::Authenticable
  include Rescuable
  before_action :render_error_when_invalid_auth_token, :except => [:ping]
  before_action :authenticate_store, :except => [:ping]
  
  # ...
  
  protected

  def render_error_when_invalid_auth_token
    auth = params[:token] || request.headers['Authorization']
    if auth.blank?
      render(
        json: { error: { message: 'Authorization token not present' } },
        status: :unauthorized
      )
    end
  end
  
  # ...
end
```

### Token Generation

Store tokens are generated through the `generate_token` endpoint on the `StoresController`:

```ruby
# From routes.rb
resources :stores, only: %i[index create update show] do
  # ...
  post :generate_token, on: :member
  # ...
end
```

### Authentication Flow

1. Admin generates a store token through the CMS
2. Token is configured in the POS system
3. POS system includes token in webhook requests
4. Server validates the token and identifies the store

## Catalog Token Authentication

### Implementation

Catalog token authentication is used for public API endpoints accessed by kiosks. Each kiosk (catalog) has a unique token that must be included in API requests.

The token is typically included as a query parameter (`token`) or in the `Authorization` header.

### Token Usage

The catalog token is used to identify the kiosk and its associated store, allowing the API to return store-specific data.

```ruby
# app/controllers/api/v1/application_controller.rb
def kiosk
  current_store.kiosks.find(params[:catalog_id]) if params[:catalog_id]
end
```

## Authentication Bypass

Certain endpoints bypass authentication for specific purposes:

1. **Ping Endpoint**: The `/api/v1/ping` endpoint bypasses authentication to allow health checks.

```ruby
# app/controllers/api/v1/application_controller.rb
before_action :render_error_when_invalid_auth_token, :except => [:ping]
before_action :authenticate_store, :except => [:ping]
  
def ping
  output = {'pong' => Time.now}.to_json
  render :json => output
end
```

## Security Considerations

### HTTPS

All API endpoints should be accessed over HTTPS to prevent token interception.

### Token Storage

Clients should store tokens securely:
- Browser clients should use secure HTTP-only cookies or secure local storage
- Mobile clients should use secure storage mechanisms
- Kiosks should use secure storage with appropriate access controls

### Token Refresh

The system does not implement token refresh. When a token expires, clients must authenticate again to obtain a new token.

## Integration with Frontend

### CMS Integration

The CMS frontend integrates with JWT authentication:
1. User logs in through the login form
2. CMS stores the JWT token securely
3. CMS includes the token in all API requests
4. CMS handles token expiration by redirecting to the login page

### Kiosk Integration

Kiosks integrate with catalog token authentication:
1. Kiosk is configured with a catalog token during setup
2. Kiosk includes the token in all API requests
3. Kiosk handles authentication errors by displaying appropriate messages

## Common Authentication Issues

### Token Expiration

If a token expires, the server will return a 401 Unauthorized response. Clients should handle this by redirecting to the login page or requesting a new token.

### Invalid Tokens

If a token is invalid or tampered with, the server will return a 401 Unauthorized response. This could indicate a security issue and should be logged.

### Missing Tokens

If a token is missing from a request that requires authentication, the server will return a 401 Unauthorized response with a message indicating that the token is missing.

## Next Steps

1. Analyze authorization mechanisms to understand how permissions are enforced
2. Document the user roles and permissions system
3. Map authentication to specific API endpoints and their requirements

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-01 | AI Assistant | Initial documentation | 