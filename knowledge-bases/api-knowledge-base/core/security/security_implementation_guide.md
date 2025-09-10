# The Peak Beyond - Security Implementation Guide

## Overview
This guide provides step-by-step instructions for implementing security features in The Peak Beyond's platform. It is intended for developers and covers practical implementation details for various security components.

## Initial Setup

### Environment Configuration
1. Set up required environment variables:
```bash
# Security Configuration
JWT_SECRET=your_secure_secret_here
JWT_EXPIRATION=86400  # 24 hours in seconds
ALLOWED_ORIGINS=https://app.thepeakbeyond.com,https://admin.thepeakbeyond.com
MFA_ENABLED=true
PASSWORD_MIN_LENGTH=12
MAX_LOGIN_ATTEMPTS=5
LOCKOUT_DURATION=1800  # 30 minutes in seconds
```

### Dependency Installation
```ruby
# Gemfile
gem 'jwt'
gem 'bcrypt'
gem 'rack-attack'
gem 'rack-cors'
gem 'pundit'
```

## User Authentication Implementation

### 1. User Model Setup
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: ENV['PASSWORD_MIN_LENGTH'].to_i }
  
  enum role: [:staff, :manager, :admin, :api_user]
  
  def locked?
    failed_attempts >= ENV['MAX_LOGIN_ATTEMPTS'].to_i &&
    last_failed_attempt_at >= ENV['LOCKOUT_DURATION'].to_i.seconds.ago
  end
end
```

### 2. Authentication Service
```ruby
# app/services/authentication_service.rb
class AuthenticationService
  def self.authenticate(email, password)
    user = User.find_by(email: email)
    return nil unless user&.authenticate(password)
    
    if user.locked?
      raise AccountLockoutError, 'Account is locked'
    end
    
    if user.mfa_enabled?
      generate_mfa_token(user)
    else
      generate_access_token(user)
    end
  end
  
  private
  
  def self.generate_access_token(user)
    JwtService.encode(user_id: user.id)
  end
end
```

## Role-Based Access Control Implementation

### 1. Permission Setup
```ruby
# app/models/permission.rb
class Permission < ApplicationRecord
  belongs_to :role
  validates :action, presence: true
  validates :resource, presence: true
end
```

### 2. Role Configuration
```ruby
# app/models/role.rb
class Role < ApplicationRecord
  has_many :permissions
  has_many :users
  
  def self.seed_default_roles
    {
      admin: admin_permissions,
      manager: manager_permissions,
      staff: staff_permissions,
      api_user: api_permissions
    }.each do |role_name, permissions|
      role = Role.find_or_create_by!(name: role_name)
      permissions.each do |permission|
        role.permissions.find_or_create_by!(permission)
      end
    end
  end
end
```

## Security Middleware Implementation

### 1. JWT Authentication Middleware
```ruby
# app/middleware/jwt_authentication.rb
class JwtAuthentication
  def initialize(app)
    @app = app
  end
  
  def call(env)
    token = extract_token(env)
    if token
      begin
        payload = JwtService.decode(token)
        env['current_user'] = User.find(payload['user_id'])
      rescue JWT::DecodeError
        return unauthorized_response
      end
    end
    @app.call(env)
  end
end
```

### 2. Rate Limiting Configuration
```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle high-volume endpoints
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end
  
  # Throttle login attempts
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/api/v1/login' && req.post?
      req.ip
    end
  end
end
```

## Security Monitoring Implementation

### 1. Activity Logging
```ruby
# app/models/security_event.rb
class SecurityEvent < ApplicationRecord
  belongs_to :user, optional: true
  
  enum event_type: [:authentication, :authorization, :security_change]
  
  def self.log(type, details, user = nil)
    create!(
      event_type: type,
      details: details,
      user: user,
      ip_address: Current.request_ip
    )
  end
end
```

### 2. Alert Configuration
```ruby
# app/services/security_alert_service.rb
class SecurityAlertService
  def self.monitor_events
    check_failed_logins
    check_suspicious_activity
    check_permission_changes
  end
  
  private
  
  def self.check_failed_logins
    threshold = 10
    window = 5.minutes
    
    if SecurityEvent.failed_logins.recent(window).count >= threshold
      notify_security_team('High number of failed login attempts detected')
    end
  end
end
```

## Testing Implementation

### 1. Authentication Tests
```ruby
# spec/requests/authentication_spec.rb
RSpec.describe 'Authentication', type: :request do
  describe 'POST /api/v1/login' do
    it 'authenticates valid credentials' do
      user = create(:user, password: 'valid_password')
      
      post '/api/v1/login', params: {
        email: user.email,
        password: 'valid_password'
      }
      
      expect(response).to have_http_status(:success)
      expect(json_response).to include('token')
    end
    
    it 'handles invalid credentials' do
      user = create(:user)
      
      post '/api/v1/login', params: {
        email: user.email,
        password: 'wrong_password'
      }
      
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
```

### 2. Authorization Tests
```ruby
# spec/requests/authorization_spec.rb
RSpec.describe 'Authorization', type: :request do
  describe 'protected endpoints' do
    it 'restricts access based on roles' do
      user = create(:user, role: :staff)
      token = JwtService.encode(user_id: user.id)
      
      get '/api/v1/admin/users', headers: {
        'Authorization': "Bearer #{token}"
      }
      
      expect(response).to have_http_status(:forbidden)
    end
  end
end
```

## Deployment Considerations

### Security Checklist
- [ ] Configure SSL/TLS certificates
- [ ] Set up secure environment variables
- [ ] Enable security headers
- [ ] Configure CORS policies
- [ ] Set up monitoring and alerting
- [ ] Review database security settings
- [ ] Enable audit logging
- [ ] Configure backup systems

### Production Configuration
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.force_ssl = true
  config.ssl_options = { hsts: { subdomains: true } }
  
  config.log_level = :info
  config.log_tags = [:request_id]
  
  config.action_dispatch.default_headers.merge!(
    'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains'
  )
end
```

## Related Documentation
- [Security Architecture](security_architecture.md)
- [API Security Guide](api_security_guide.md)
- [Master Glossary](../../meta/glossary/master_glossary.md)

## Version History
- Initial creation during documentation consolidation
- Added implementation examples and testing guidelines 