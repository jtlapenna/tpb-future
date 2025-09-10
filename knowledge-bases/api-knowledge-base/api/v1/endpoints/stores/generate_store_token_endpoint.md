---
title: Generate Store Token
description: API endpoint for generating a new JWT token for a store in the system
last_updated: 2023-07-13
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/stores_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/models/store.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/store_policy.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/config/initializers/knock.rb
tags:
  - api
  - administrative
  - stores
  - authentication
  - jwt
ai_agent_relevance:
  - APIDocumentationAgent
  - StoreManagementAgent
  - IntegrationSpecialistAgent
  - SecurityAgent
---

# Generate Store Token

## Overview

This endpoint allows admin users to generate a new JWT (JSON Web Token) for a specific store in the system. The token can be used for authenticating API requests made on behalf of the store, particularly for integration with kiosks and other client applications. When a new token is generated, the previous token becomes invalid due to the regeneration of the store's JTI (JWT ID).

## Endpoint Details

- **URL**: `POST /stores/:id/generate_token`
- **API Version**: v1
- **Authentication**: Required (JWT Token)
- **Authorization**: Admin users only
- **Rate Limit**: Standard API rate limits apply

## Request

### Headers

| Header | Description | Required |
|--------|-------------|----------|
| Authorization | Authentication token in the format "Bearer {token}" | Yes |

### Path Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| id | The unique identifier of the store for which to generate a token | Yes |

### Request Body

No request body is required for this endpoint.

## Response

### Success Response (201 Created)

```json
{
  "jwt": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjNlNDU2Ny1lODliLTEyZDMtYTQ1Ni00MjY2MTQxNzQwMDAiLCJhdWQiOlsiYXBpIl0sImp0aSI6ImFiYzEyM2RlZjQ1NiJ9.signature"
}
```

The response includes a single field:

| Field | Description | Type |
|-------|-------------|------|
| jwt | The newly generated JWT token for the store | string |

The JWT token consists of three parts separated by dots:
1. **Header**: Contains the token type and the signing algorithm (e.g., HS256)
2. **Payload**: Contains claims about the store, including:
   - `sub`: The store ID (subject)
   - `aud`: The audience (["api"])
   - `jti`: The JWT ID (a unique identifier for the token)
3. **Signature**: Ensures the token hasn't been tampered with

### Error Responses

| Status Code | Description | Example |
|-------------|-------------|---------|
| 401 Unauthorized | Authentication required | `{"error": "You need to sign in or sign up before continuing."}` |
| 403 Forbidden | Insufficient permissions | `{"error": "You are not authorized to perform this action."}` |
| 404 Not Found | Store not found | `{"error": "Couldn't find Store with 'id'=123"}` |
| 422 Unprocessable Entity | Token generation failed | `{"error": "Failed to generate token"}` |

## Implementation Details

- **Controller**: `StoresController#generate_token`
- **Model**: `Store`
- **Policy**: `StorePolicy#generate_token?`
- **Database Queries**: 
  - Select query to find the store by ID
  - Update query to update the store's JTI field

### Authorization

The endpoint uses the `StorePolicy#generate_token?` method to determine if the user is authorized to generate a token for the store. Only admin users are allowed to generate tokens:

```ruby
def generate_token?
  admin?
end
```

### Token Generation Process

The token generation process involves the following steps:

1. The controller sets the `regenerate_jti` attribute on the store to `true`
2. The store is saved, triggering the `regenerate_jti_token` callback
3. The callback generates a new random JTI using `SecureRandom.hex`
4. The store's token payload is created with the store ID, audience, and new JTI
5. The Knock gem creates a JWT token using the payload and the application's secret key
6. The token is returned in the response

### Implementation Code

```ruby
def generate_token
  authorize @store
  @store.regenerate_jti = true
  @store.save!

  payload = @store.to_token_payload
  token = Knock::AuthToken.new(payload: payload).token
  render json: { jwt: token }, status: :created
end
```

The `to_token_payload` method in the Store model creates the payload for the JWT token:

```ruby
def to_token_payload
  payload = { sub: id, aud: [:api], jti: jti }
  payload
end
```

The `regenerate_jti_token` callback in the Store model generates a new JTI:

```ruby
def regenerate_jti_token
  self.jti = SecureRandom.hex if regenerate_jti
end
```

### JWT Configuration

The JWT tokens are configured in `config/initializers/knock.rb`:

```ruby
Knock.setup do |config|
  # Token lifetime (set to 100 years for long-lived tokens)
  config.token_lifetime = 100.years

  # Default signature algorithm is HS256
  # config.token_signature_algorithm = 'HS256'

  # Secret key used to sign tokens (defaults to Rails secret_key_base)
  # config.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }
end
```

## Examples

### Example Request

```bash
curl -X POST \
  https://api.peakbeyond.com/stores/123e4567-e89b-12d3-a456-426614174000/generate_token \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

### Example Response

```json
{
  "jwt": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjNlNDU2Ny1lODliLTEyZDMtYTQ1Ni00MjY2MTQxNzQwMDAiLCJhdWQiOlsiYXBpIl0sImp0aSI6ImFiYzEyM2RlZjQ1NiJ9.signature"
}
```

## Common Use Cases

1. **Initial Kiosk Setup**: Generate a token for a store when setting up a new kiosk
2. **Token Rotation**: Regularly rotate tokens for security purposes
3. **Token Revocation**: Revoke access for a compromised token by generating a new one
4. **API Integration**: Generate a token for third-party integrations with the store's data

## Related Endpoints

- [`GET /stores/:id`](get_store_endpoint.md): Get a specific store
- [`PUT /stores/:id`](update_store_endpoint.md): Update a store
- [`GET /stores/:id/tax_customer_types`](tax_customer_types_endpoint.md): Get tax customer types for a store

## Notes for AI Agents

- **APIDocumentationAgent**: The Generate Store Token endpoint is critical for authentication in the API. Make sure to document the token format and usage.
- **StoreManagementAgent**: When generating a new token, be aware that any existing tokens for the store will become invalid. This may disrupt active kiosk sessions.
- **IntegrationSpecialistAgent**: Store tokens have a very long lifetime (100 years) but can be invalidated by generating a new token. Plan your integration accordingly.
- **SecurityAgent**: Consider implementing a token rotation policy to regularly generate new tokens for stores, especially in high-security environments.

## Technical Debt and Known Issues

- The token lifetime is set to 100 years, which is extremely long and could pose a security risk if tokens are compromised.
- There's no mechanism to revoke a specific token without invalidating all tokens for a store.
- The endpoint doesn't provide a way to specify the token's audience or expiration time.
- There's no audit logging for token generation events, which could be useful for security monitoring.

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2023-07-13 | Initial documentation | AI Assistant | 