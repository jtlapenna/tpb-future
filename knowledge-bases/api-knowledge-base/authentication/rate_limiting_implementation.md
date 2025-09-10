# Rate Limiting Implementation Documentation

## Overview
The Peak Beyond's backend system implements rate limiting at multiple levels to protect API endpoints and external service integrations from abuse. This document details the current rate limiting implementation.

## Core Components

### API Rate Limiting
1. IP-Based Throttling
   - Limit: 300 requests per 5 minutes
   - Scope: All API endpoints
   - Implementation: Rack::Attack

2. Token-Based Throttling
   - Limit: 1000 requests per 5 minutes
   - Scope: Authenticated endpoints
   - Implementation: Rack::Attack

### POS Integration Rate Limiting

1. Treez API
   - Implements SpikeArrestViolation handling
   - Exponential backoff retry strategy
   - Maximum 4 retries
   - Dynamic rate limit calculation

## Implementation Details

### API Rate Limiting Configuration
```ruby
# config/initializers/rack_attack.rb
Rack::Attack.throttle('requests by IP', limit: 300, period: 5.minutes) do |req|
  req.ip
end

Rack::Attack.throttle('requests by token', limit: 1000, period: 5.minutes) do |req|
  req.env['HTTP_AUTHORIZATION']
end
```

### POS Integration Rate Limiting
```ruby
# app/lib/treez/api_client.rb
rescue Treez::SpikeArrestViolation => e
  if retries < 4 && e.rate_limit.present?
    retries += 1
    rate_limits_to_wait = rand(1..(2 ** (retries - 1) + 1))
    sleep (e.rate_limit * rate_limits_to_wait)
    retry
  end
```

### Error Handling

1. API Rate Limit Exceeded
   - Status Code: 429
   - Error Code: RATE_LIMIT_EXCEEDED
   - Response Format: JSON

2. POS Rate Limit Exceeded
   - Custom error class: Treez::SpikeArrestViolation
   - Includes rate limit information
   - Implements automatic retry with backoff

## Monitoring and Alerts

1. Rate Limit Usage Tracking
   ```ruby
   StatsD.gauge('api.rate_limit_usage', (count.to_f / rate_limit) * 100)
   ```

2. Warning Thresholds
   - 80% of limit: Warning log
   - 95% of limit: Integration notification

## Current Implementation

### Rate Limit Checking
```ruby
def rate_limited?(request)
  key = "rate_limit:#{client_ip}"
  # Implementation details
end

def rate_limit_exceeded
  render json: {
    status: "error",
    error: {
      code: "RATE_LIMIT_EXCEEDED",
      message: "Rate limit exceeded"
    }
  }, status: 429
end
```

### POS System Rate Limits
```ruby
def get_rate_limit(pos_system, endpoint)
  # Dynamic rate limit calculation based on POS system and endpoint
end

def handle_rate_limiting
  # Rate limit handling implementation
end
```

## Integration Points

1. External Service Rate Limits
   - Treez API: Dynamic rate limiting
   - Other POS systems: System-specific limits

2. Client Rate Limits
   - IP-based restrictions
   - Token-based quotas
   - Store-specific limits

## Current Limitations

1. Rate Limit Configuration
   - Fixed limits per IP/token
   - No dynamic adjustment
   - Limited granularity

2. Monitoring
   - Basic StatsD metrics
   - Limited historical data
   - No predictive alerts

## Testing

Rate limit testing is implemented in:
- API client specs
- Integration tests
- POS system mocks

## Related Files

1. Configuration
   - config/initializers/rack_attack.rb

2. Implementation
   - app/lib/treez/api_client.rb
   - app/lib/treez/treez_error.rb

3. Test Files
   - spec/lib/treez/api_client_spec.rb 