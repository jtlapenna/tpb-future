# The Peak Beyond - API Security Guide

## Overview
This guide provides detailed instructions for implementing security measures in The Peak Beyond's API endpoints. It covers authentication, authorization, and best practices for securing API communications.

## API Authentication

### JWT Implementation
```ruby
# Example JWT token generation
def generate_jwt(user)
  payload = {
    user_id: user.id,
    role: user.role,
    permissions: user.permissions,
    exp: 24.hours.from_now.to_i
  }
  JWT.encode(payload, ENV['JWT_SECRET'], 'HS256')
end

# Example JWT verification
def verify_jwt(token)
  begin
    JWT.decode(token, ENV['JWT_SECRET'], true, algorithm: 'HS256')
  rescue JWT::ExpiredSignature
    raise AuthenticationError, 'Token has expired'
  rescue JWT::DecodeError
    raise AuthenticationError, 'Invalid token'
  end
end
```

### API Key Authentication
- Used for machine-to-machine communication
- Required for API User role
- Rate limiting and usage tracking
- Separate from user authentication

## API Authorization

### Implementing RBAC
```ruby
# Example Pundit policy
class ApiEndpointPolicy
  attr_reader :user, :endpoint

  def initialize(user, endpoint)
    @user = user
    @endpoint = endpoint
  end

  def index?
    user.has_permission?(:read_api)
  end

  def create?
    user.has_permission?(:write_api)
  end
end
```

### Endpoint Security Checklist
- [ ] JWT validation
- [ ] Role verification
- [ ] Permission checking
- [ ] Rate limiting
- [ ] Input validation
- [ ] Response sanitization

## Security Headers

### Required Headers
```ruby
# Example security headers configuration
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '1; mode=block',
  'X-Content-Type-Options' => 'nosniff',
  'Content-Security-Policy' => "default-src 'self'"
}
```

### CORS Configuration
```ruby
# Example CORS configuration
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['ALLOWED_ORIGINS'].split(',')
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

## Error Handling

### Security Error Responses
```ruby
# Example error responses
def handle_authentication_error(error)
  render json: {
    error: 'Authentication failed',
    message: error.message
  }, status: :unauthorized
end

def handle_authorization_error(error)
  render json: {
    error: 'Authorization failed',
    message: 'Insufficient permissions'
  }, status: :forbidden
end
```

## Rate Limiting

### Implementation
```ruby
# Example rate limiting configuration
config.middleware.use Rack::Attack
Rack::Attack.throttle('requests by ip', limit: 300, period: 5.minutes) do |req|
  req.ip
end
```

## Security Monitoring

### API Activity Logging
```ruby
# Example API activity logging
def log_api_activity
  ApiActivity.create(
    user_id: current_user.id,
    endpoint: request.path,
    method: request.method,
    response_status: response.status,
    ip_address: request.remote_ip
  )
end
```

## Best Practices

### Input Validation
```ruby
# Example input validation
class ApiInputValidator
  def self.validate_request(params)
    return false unless params.present?
    return false if params.any? { |k,v| contains_sql_injection?(v) }
    true
  end

  private

  def self.contains_sql_injection?(value)
    # Implementation of SQL injection detection
  end
end
```

### Response Sanitization
```ruby
# Example response sanitization
def sanitize_response(data)
  return unless data.present?
  
  if data.is_a?(Hash)
    data.each { |k,v| data[k] = sanitize_response(v) }
  elsif data.is_a?(Array)
    data.map! { |item| sanitize_response(item) }
  else
    sanitize_value(data)
  end
end
```

## Testing

### Security Testing
```ruby
# Example security test
RSpec.describe 'API Security' do
  describe 'authentication' do
    it 'requires valid JWT token' do
      get '/api/v1/protected-endpoint'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'authorization' do
    it 'enforces role-based access' do
      login_as(regular_user)
      get '/api/v1/admin-only-endpoint'
      expect(response).to have_http_status(:forbidden)
    end
  end
end
```

## Related Documentation
- [Security Architecture](security_architecture.md)
- [Master Glossary](../../meta/glossary/master_glossary.md)

## Version History
- Initial creation during documentation consolidation
- Added code examples and implementation details 