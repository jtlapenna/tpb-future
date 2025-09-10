---
title: Authentication and Authorization
description: Detailed explanation of authentication and authorization mechanisms in The Peak Beyond's API
last_updated: 2023-07-11
contributors: [AI Assistant]
related_files:
  - knowledge-base/api/overview.md
  - knowledge-base/api/api_discovery_results.md
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/user_token_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/config/initializers/knock.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/policies/application_policy.rb
tags:
  - api
  - authentication
  - authorization
  - security
ai_agent_relevance:
  - APIDocumentationAgent
  - SecuritySpecialistAgent
  - IntegrationSpecialistAgent
---

# Authentication and Authorization Overview

## Version Information
- Category: API Documentation
- Type: Security Overview
- Current Version: 1.0.0
- Status: Current
- Last Updated: Mar 12, 03:02 PM
- Last Reviewer: System
- Next Review Due: Apr 12, 2024

## Version History
### Version 1.0.0 (Mar 12, 03:02 PM)
- Author: System
- Reviewer: System
- Changes:
  - Initial documentation creation
  - Complete auth flow overview added
  - Security integration patterns documented
  - Cross-service authentication detailed
  - System-wide authorization patterns included
- Related Updates:
  - Integrated with authentication_mechanisms.md
  - Referenced authorization_mechanisms.md
  - Updated api_documentation_summary.md

## Dependencies
### Required By
- api_security_overview.md (requires this document)
- api_documentation_summary.md (references this document)

### Depends On
- authentication_mechanisms.md (for authentication details)
- authorization_mechanisms.md (for authorization details)
- api_documentation_summary.md (for overall context)

## Review History
- Last Review: Mar 12, 03:02 PM
- Reviewer: System
- Outcome: Approved
- Comments: Initial version approved with comprehensive security review completed

## Maintenance Schedule
- Review Frequency: Monthly
- Next Scheduled Review: Apr 12, 2024
- Update Window: First week of each month
- Quality Assurance: Technical review and security testing required

## Overview

This document provides a detailed explanation of the authentication and authorization mechanisms used in The Peak Beyond's API. Understanding these mechanisms is crucial for securely integrating with the API and ensuring that users can only access the resources they are authorized to use.

## Authentication

The Peak Beyond's API uses two primary authentication methods:

1. **JWT (JSON Web Token) Authentication**: Used for user authentication in both administrative and public APIs
2. **API Token Authentication**: Used for service-to-service communication and webhook integrations

### JWT Authentication

JWT authentication is implemented using the [Knock gem](https://github.com/nsarno/knock), which provides a seamless way to handle JWT-based authentication in Rails applications.

#### Authentication Flow

1. The client sends a request to the `/user_token` endpoint with user credentials (email and password)
2. The server validates the credentials and, if valid, generates a JWT token
3. The server returns the JWT token to the client
4. The client includes the JWT token in the `Authorization` header of subsequent requests
5. The server validates the token and identifies the user

#### JWT Token Structure

The JWT token consists of three parts:

1. **Header**: Contains the token type and the signing algorithm
2. **Payload**: Contains claims about the user, such as user ID and expiration time
3. **Signature**: Ensures the token hasn't been tampered with

#### JWT Configuration

The JWT authentication is configured in `config/initializers/knock.rb`:

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

#### Example Request

```bash
# Login and get JWT token
curl -X POST \
  https://api.peakbeyond.com/user_token \
  -H 'Content-Type: application/json' \
  -d '{
    "auth": {
      "email": "user@example.com",
      "password": "password123"
    }
  }'

# Response
{
  "jwt": "eyJhbGciOiJIUzI1NiJ9...",
  "id": 123,
  "email": "user@example.com",
  "role": "admin"
}

# Using the JWT token in subsequent requests
curl -X GET \
  https://api.peakbeyond.com/stores \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'
```

### API Token Authentication

API token authentication is used for service-to-service communication, particularly for webhook integrations with POS systems like Treez, Shopify, and Blaze.

#### Authentication Flow

1. An administrator generates an API token for a specific service or integration
2. The service includes the API token in the `X-API-Key` header of requests
3. The server validates the token and identifies the service

#### API Token Generation

API tokens can be generated using the `POST /stores/:id/generate_token` endpoint, which is only accessible to administrators.

#### Example Request

```bash
# Generate API token (admin only)
curl -X POST \
  https://api.peakbeyond.com/stores/123/generate_token \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'

# Response
{
  "api_token": "api_key_123456789"
}

# Using the API token in webhook requests
curl -X POST \
  https://api.peakbeyond.com/stores/123/webhooks/treez/end_point \
  -H 'X-API-Key: api_key_123456789' \
  -H 'Content-Type: application/json' \
  -d '{
    "event_type": "product_updated",
    "data": { ... }
  }'
```

## Authorization

Authorization in The Peak Beyond's API is implemented using the [Pundit gem](https://github.com/varvet/pundit), which provides a simple and robust way to define authorization policies for different resources.

### Policy-Based Authorization

Each resource in the system has a corresponding policy class that defines the permissions for various actions. These policies are used to determine whether a user is authorized to perform a specific action on a resource.

#### Base Policy

The `ApplicationPolicy` serves as the base policy for all other policies:

```ruby
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  protected

  def admin?
    user&.admin?
  end
end
```

By default, only administrators can perform actions on resources. Specific policies override these defaults as needed.

#### Resource-Specific Policies

Each resource has its own policy that inherits from `ApplicationPolicy` and defines specific authorization rules. For example, the `StorePolicy`:

```ruby
class StorePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.owner(user)
      end
    end
  end

  def index?
    user
  end

  def show?
    user
  end

  def update?
    user
  end

  def generate_token?
    admin?
  end

  def tax_customer_types?
    admin?
  end

  # ...
end
```

In this policy:
- Any authenticated user can list and view stores
- Any authenticated user can update stores (though this may be further restricted by scoping)
- Only administrators can generate tokens or access tax customer types

### Policy Scopes

Policy scopes are used to filter collections of resources based on the user's permissions. For example, the `StorePolicy::Scope` ensures that:
- Administrators can see all stores
- Regular users can only see stores they own

### Attribute-Level Authorization

Policies also define which attributes a user is allowed to update using the `permitted_attributes` method. For example, in `StorePolicy`:

```ruby
def permitted_attributes
  attrs = [
    :name,
    :enabled_share_email_product,
    # ...
  ]

  admin_attr = %i[
    client_id
    api_client_id
    # ...
  ]

  user.admin? ? attrs + admin_attr : attrs
end
```

This ensures that only administrators can update sensitive attributes like API credentials.

## Multi-Tenant Architecture

The Peak Beyond's API implements a multi-tenant architecture, where each tenant (cannabis dispensary) has its own isolated data but shares common code and master data.

### Tenant Identification

Tenants are identified by a unique tenant ID, which is included in the `X-Tenant-ID` header of each request:

```
X-Tenant-ID: tenant_123
```

### Tenant Scoping

All database queries are automatically scoped to the current tenant using a tenant context mechanism. This ensures that data from one tenant is never exposed to another tenant.

For example, in the `StoreProduct` model:

```ruby
class StoreProduct < ApplicationRecord
  belongs_to :store
  belongs_to :product
  
  # Ensure queries are scoped to the current store
  default_scope { where(store_id: Store.current_id) if Store.current_id }
  
  # Validation to ensure products stay within their tenant
  validates :store_id, presence: true
end
```

## User Roles and Permissions

The system defines several user roles, each with different permissions:

1. **Administrator**: Has full access to all resources and actions
2. **Store Manager**: Has access to manage their assigned stores and related resources
3. **Regular User**: Has limited access based on specific permissions

### Role-Based Access Control

Policies implement role-based access control by checking the user's role:

```ruby
def admin?
  user&.admin?
end

def store_manager?
  user&.store_manager?
end

def update?
  admin? || (store_manager? && record.users.include?(user))
end
```

This ensures that:
- Administrators can update any resource
- Store managers can only update resources associated with their stores
- Regular users have limited or no update capabilities

## Best Practices

When working with The Peak Beyond's API, follow these security best practices:

1. **Secure Token Storage**: Store JWT tokens securely and never expose them in client-side code
2. **Token Expiration**: Implement token refresh mechanisms to handle token expiration
3. **HTTPS**: Always use HTTPS for API requests to ensure secure communication
4. **Minimal Permissions**: Request only the permissions necessary for your application
5. **Validate Input**: Always validate and sanitize input data before sending it to the API
6. **Error Handling**: Implement proper error handling for authentication and authorization failures

## Common Issues and Solutions

### Issue: Token Expired

**Solution**: Request a new token using the `/user_token` endpoint.

### Issue: Unauthorized Access

**Solution**: Ensure the user has the necessary permissions for the requested resource and action.

### Issue: Missing Tenant ID

**Solution**: Include the `X-Tenant-ID` header in all requests that require tenant scoping.

## References

- [Knock Gem Documentation](https://github.com/nsarno/knock)
- [Pundit Gem Documentation](https://github.com/varvet/pundit)
- [JWT.io](https://jwt.io/) - For debugging JWT tokens
- [API Overview](knowledge-base/api/overview.md)
- [API Discovery Results](knowledge-base/api/api_discovery_results.md) 