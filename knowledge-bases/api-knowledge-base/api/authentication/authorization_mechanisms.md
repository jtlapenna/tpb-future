---
title: Authorization Mechanisms
description: Detailed documentation of authorization mechanisms used in The Peak Beyond's backend system
last_updated: 2023-08-01
contributors: [AI Assistant]
---

# Authorization Mechanisms

## Version Information
- **Category**: API Documentation
- **Type**: Technical Specification
- **Current Version**: 1.0.0
- **Status**: Current
- **Last Updated**: Mar 12, 03:04 PM
- **Last Reviewer**: System
- **Next Review Due**: Apr 12, 2024

## Version History

### Version 1.0.0 - Mar 12, 03:04 PM
- **Author**: System
- **Reviewer**: System
- **Changes**:
  - Initial documentation creation
  - Added authorization specifications
  - Documented permission system
  - Included role-based access control
- **Related Updates**:
  - authentication_mechanisms.md - 1.0.0
  - authentication_and_authorization.md - 1.0.0

## Dependencies
- **Required By**:
  - authentication_and_authorization.md - 1.0.0
- **Depends On**:
  - authentication_mechanisms.md - 1.0.0
  - api_documentation_summary.md - 1.0.0

## Review History
- **Last Review**: Mar 12, 03:04 PM
  - **Reviewer**: System
  - **Outcome**: Approved
  - **Comments**: Initial version approved

## Maintenance Schedule
- **Review Frequency**: Monthly
- **Next Scheduled Review**: Apr 12, 2024
- **Update Window**: First week of each month
- **Quality Assurance**: Technical review and security testing required

## Overview

The Peak Beyond's backend system implements a policy-based authorization approach using the Pundit gem. This approach ensures that users can only access and modify resources they are authorized to interact with, based on their roles and relationships to the resources.

## Authorization Framework

### Pundit Implementation

The system uses the Pundit gem for authorization, which provides a clean, object-oriented way to define authorization rules:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Knock::Authenticable
  include Pundit
  include Rescuable

  before_action :authenticate_user
end
```

Pundit is included in the `ApplicationController`, making it available to all controllers in the system.

### Policy Structure

Each resource type has a corresponding policy class that defines the authorization rules for that resource:

```ruby
# app/policies/application_policy.rb
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

  def new?
    admin?
  end

  def update?
    admin?
  end

  def edit?
    admin?
  end

  def destroy?
    admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  protected

  def admin?
    user&.admin?
  end
end
```

The `ApplicationPolicy` serves as the base class for all other policies and defines default rules that restrict access to admin users only.

## User Roles and Permissions

### User Roles

The system implements the following user roles:

1. **Admin Users**: Users with the `admin` flag set to `true`
2. **Regular Users**: Users associated with a specific client (store)

### Role-Based Access Control

Access to resources is primarily determined by the user's role:

```ruby
# app/policies/application_policy.rb
def admin?
  user&.admin?
end
```

Admin users have full access to all resources, while regular users have limited access based on their client association.

### Resource Ownership

For many resources, access is further restricted based on ownership or association:

```ruby
# app/policies/store_policy.rb
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
  
  # ...
end
```

Regular users can only access resources associated with their client.

## Policy Examples

### User Policy

The `UserPolicy` allows users to view and update their own information, while admins can manage all users:

```ruby
# app/policies/user_policy.rb
class UserPolicy < ApplicationPolicy
  def show?
    admin? || user == record
  end

  def update?
    admin? || user == record
  end

  def permitted_attributes
    %i[name email password password_confirmation client_id]
  end
end
```

### Store Policy

The `StorePolicy` allows all authenticated users to view stores, but restricts certain operations to admin users:

```ruby
# app/policies/store_policy.rb
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

  def get_inventory_types?
    admin?
  end
  
  # ...
end
```

### Kiosk Policy

The `KioskPolicy` restricts access based on the kiosk's association with a store:

```ruby
# app/policies/kiosk_policy.rb (simplified)
class KioskPolicy < ApplicationPolicy
  def show?
    admin? || record.store.client_id == user.client_id
  end

  def update?
    admin? || record.store.client_id == user.client_id
  end
  
  # ...
end
```

## Authorization Flow

1. User makes a request to an API endpoint
2. Authentication middleware verifies the user's identity
3. Controller action calls Pundit to check authorization
4. Pundit instantiates the appropriate policy with the user and resource
5. Policy method returns true or false based on authorization rules
6. If authorized, the action proceeds; if not, an authorization error is returned

## Policy Scopes

Policy scopes are used to filter collections of resources based on the user's permissions:

```ruby
# Example controller action using policy scope
def index
  @stores = policy_scope(Store)
  render json: @stores
end
```

The policy scope ensures that users only see resources they are authorized to access.

## Attribute-Level Authorization

In addition to action-level authorization, the system implements attribute-level authorization through the `permitted_attributes` method:

```ruby
# app/policies/store_policy.rb
def permitted_attributes
  attrs = [
    :name,
    :enabled_share_email_product, :enabled_continuous_cart, :enabled_share_sms_product, :block_simultaneous_nfc,
    :notifications_title, :notifications_enabled, :notifications_intro,
    :notifications_send_to_customer,
    { notifications_recipients: [] },
    logo_attributes: %i[id url _destroy],
  ]

  admin_attr = %i[
    client_id
    api_client_id api_key api_type dispensary_name sync_frequency sync_frequency_offset
    api_version api_store_id api_automatch api_autopublish
    override_on_sync preserve_category featured_mode sync_tags location_id
    auth0_client_id auth0_client_secret customer_type_filter checkout_type direct_checkout shop_url password
    grant_type client_cova_id client_cova_secret username password_cova company_id location_id_covasoft use_master_category use_total_thc authorization_blaze enable_automate_promotions
    partner_key_blaze inventory_list
  ]

  (
    user.admin? ? attrs + admin_attr : attrs
  ) + [{ settings_attributes: permitted_settings_attributes }]
end
```

This ensures that users can only update attributes they are authorized to modify.

## Multi-Tenancy Authorization

The system implements multi-tenancy authorization through client associations:

1. Each user is associated with a client (except admin users)
2. Each store is associated with a client
3. Each kiosk is associated with a store
4. Policy scopes filter resources based on these associations

This ensures that users can only access resources within their tenant.

## Authorization for API/V1 Endpoints

The API/V1 endpoints use a different authorization approach based on store tokens rather than user roles:

```ruby
# app/controllers/api/v1/application_controller.rb
before_action :authenticate_store, :except => [:ping]
```

The `authenticate_store` method verifies the store token and sets the `current_store` for the request.

## Common Authorization Patterns

### Admin Override

Most policies allow admin users to bypass normal authorization restrictions:

```ruby
def show?
  admin? || record.store.client_id == user.client_id
end
```

### Client-Based Access

Regular users can only access resources associated with their client:

```ruby
def resolve
  if user.admin?
    scope
  else
    scope.owner(user)
  end
end
```

### Self-Management

Users can manage their own resources:

```ruby
def update?
  admin? || user == record
end
```

## Integration with Frontend

### CMS Integration

The CMS frontend integrates with the authorization system by:
1. Displaying only resources the user is authorized to access
2. Showing/hiding UI elements based on the user's permissions
3. Handling authorization errors gracefully

### Kiosk Integration

Kiosks operate with store-level authorization, accessing only resources associated with their store.

## Common Authorization Issues

### Missing Permissions

If a user attempts to access a resource they are not authorized to access, the system returns a 403 Forbidden response.

### Scope Filtering

If a policy scope is not properly implemented, users may see resources they should not have access to.

### Attribute Restrictions

If `permitted_attributes` is not properly implemented, users may be able to update attributes they should not have access to.

## Next Steps

1. Map authorization rules to specific API endpoints
2. Document the client association model in detail
3. Analyze the interaction between authentication and authorization

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-01 | AI Assistant | Initial documentation | 