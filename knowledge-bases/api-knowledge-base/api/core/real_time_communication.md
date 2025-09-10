---
title: Real-Time Communication Mechanisms
description: Detailed documentation of real-time communication mechanisms used in The Peak Beyond's backend system
last_updated: 2023-08-01
contributors: [AI Assistant]
---

# Real-Time Communication Documentation

## Version Information
- **Category**: API Documentation
- **Type**: Technical Specification
- **Current Version**: 1.0.0
- **Status**: Current
- **Last Updated**: Mar 12, 03:07 PM
- **Last Reviewer**: System
- **Next Review Due**: Apr 12, 2024

## Version History

### Version 1.0.0 - Mar 12, 03:07 PM
- **Author**: System
- **Reviewer**: System
- **Changes**:
  - Initial documentation creation
  - Added WebSocket specifications
  - Documented event patterns
  - Included connection handling
- **Related Updates**:
  - backend_frontend_integration_summary.md - 1.0.0
  - api_integration_patterns.md - 1.0.0

## Dependencies
- **Required By**:
  - api_integration_patterns.md - 1.0.0
- **Depends On**:
  - backend_frontend_integration_summary.md - 1.0.0
  - api_controllers_and_endpoints.md - 1.0.0

## Review History
- **Last Review**: Mar 12, 03:07 PM
  - **Reviewer**: System
  - **Outcome**: Approved
  - **Comments**: Initial version approved

## Maintenance Schedule
- **Review Frequency**: Monthly
- **Next Scheduled Review**: Apr 12, 2024
- **Update Window**: First week of each month
- **Quality Assurance**: Technical review and WebSocket testing required

# Real-Time Communication Mechanisms

## Overview

The Peak Beyond's backend system implements real-time communication to provide instant updates to clients (CMS and kiosks) when data changes. The primary mechanism for real-time communication is the Pusher service, which provides a pub/sub messaging system.

## Pusher Integration

### Configuration

Pusher is configured in the `config/initializers/pusher.rb` file:

```ruby
require 'pusher'

Pusher.app_id = ENV['PUSHER_APP_ID']
Pusher.key = ENV['PUSHER_KEY']
Pusher.secret = ENV['PUSHER_SECRET']
Pusher.cluster = ENV['PUSHER_CLUSTER']
Pusher.logger = Rails.logger
```

The configuration uses environment variables to set the Pusher credentials, allowing for different configurations in development, staging, and production environments.

### Channel Structure

The system uses a channel-based approach for real-time communication:

1. **Store-specific channels**: `store_products_#{store_id}`
   - Used for broadcasting product updates to all kiosks in a store

2. **Kiosk-specific channels**: `kiosk-#{kiosk_id}`
   - Used for sending updates to specific kiosks

3. **Store-wide channels**: `store-#{store_id}`
   - Used for broadcasting store-wide updates

### Event Types

The system broadcasts several types of events:

1. **product_updated**: When a product is updated
2. **product_destroyed**: When a product is deleted
3. **inventory_updated**: When inventory levels change
4. **promotion_updated**: When promotions are updated

### Broadcasting Updates

The system broadcasts updates when certain models change. For example, the `StoreProduct` model includes methods for broadcasting changes:

```ruby
def broadcast_changes_destroy
  Rails.logger.info("======= BROADCAST DESTROY ======= #{self.inspect}")
  if has_pusher_env && is_store_open_time
    Pusher.trigger("store_products_#{self.store_id}", 'product_destroyed', {
      product: self.as_json
    })
  end
end

def broadcast_changes_update
  if self.latest_update_source == 'webhooks'
    Rails.logger.info("======= IGNORING WEBHOOKS FOR PUSHER ======= STORE_PRODUCT_ID: #{self.id}")
    return
  end

  relevant_fields = ['store_category_id', 'name', 'description', 'stock', 'sku', 'status', 'primary_image_id', 'thumb_image_id', 'brand_id', 'weight', 'status', 'last_updated_websocket', 'tag_list', 'is_medical_only', 'is_full_screen']
  changed_fields = self.previous_changes.keys & relevant_fields
  
  # ... (additional logic)
  
  if changed_fields.any? && !stock_is_equal && has_pusher_env && is_store_open_time
    # ... (prepare data)
    
    Pusher.trigger("store_products_#{self.store_id}", 'product_updated', {
      changes: self.previous_changes,
      product: json["product"]
    })
  end
end
```

### Optimization Strategies

The system implements several optimization strategies for real-time updates:

1. **Time-based filtering**: Updates are only broadcast during store operating hours (8 AM to 11 PM EST)

```ruby
def is_store_open_time
  # get the current time in UTC
  current_time_utc = Time.now.utc

  # convert the time to EST
  current_time_est = current_time_utc.getlocal("-05:00")
  est_time_hour = current_time_est.hour

  return (est_time_hour >= 8 && est_time_hour < 23)
end
```

2. **Change detection**: Updates are only broadcast when relevant fields change

```ruby
relevant_fields = ['store_category_id', 'name', 'description', 'stock', 'sku', 'status', 'primary_image_id', 'thumb_image_id', 'brand_id', 'weight', 'status', 'last_updated_websocket', 'tag_list', 'is_medical_only', 'is_full_screen']
changed_fields = self.previous_changes.keys & relevant_fields
```

3. **Webhook filtering**: Updates triggered by webhooks are not broadcast to avoid duplicate updates

```ruby
if self.latest_update_source == 'webhooks'
  Rails.logger.info("======= IGNORING WEBHOOKS FOR PUSHER ======= STORE_PRODUCT_ID: #{self.id}")
  return
end
```

4. **Equality checking**: Updates that don't actually change values are not broadcast

```ruby
if changed_fields.length === 1 && changed_fields.include?('tag_list')
  lowercase_arrays = self.previous_changes["tag_list"].map { |array| array.map(&:downcase) }
  tag_is_equal = lowercase_arrays[0].sort == lowercase_arrays[1].sort
  if tag_is_equal
    return
  end
end
```

## ActionCable Setup

The system also includes an ActionCable setup, although it appears to be minimally used:

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end

# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
  end
end
```

The ActionCable setup is minimal, suggesting that Pusher is the primary mechanism for real-time communication.

## Client-Side Integration

### Frontend Integration

The frontend (kiosk UI) integrates with Pusher to receive real-time updates:

```javascript
// Example client-side integration
this.pusher = new Pusher('app_key', {
  cluster: 'cluster',
  encrypted: true
});

this.kioskChannel = this.pusher.subscribe(`kiosk-${this.kioskId}`);
this.kioskChannel.bind('product_updated', this.handleProductUpdate);

this.storeChannel = this.pusher.subscribe(`store-${this.storeId}`);
this.storeChannel.bind('inventory_updated', this.handleInventoryUpdate);
```

### Cleanup

The frontend properly cleans up Pusher connections when components are destroyed:

```javascript
// Example cleanup
if (this.pusher) {
  this.pusher.disconnect();
}
```

## Real-Time Update Flow

1. **Data Change**: A model (e.g., StoreProduct) is updated in the database
2. **Change Detection**: The model detects relevant changes in its attributes
3. **Broadcasting**: The model broadcasts the changes to the appropriate Pusher channel
4. **Client Reception**: Clients subscribed to the channel receive the update
5. **UI Update**: Clients update their UI based on the received data

## Security Considerations

### Authentication

Pusher channels are not explicitly authenticated, relying on the secrecy of the channel names for security. This approach is generally acceptable for public data but may not be suitable for sensitive information.

### Data Exposure

Care should be taken to ensure that sensitive data is not broadcast through Pusher channels. The current implementation appears to focus on product and inventory data, which is generally not sensitive.

## Performance Considerations

### Message Size

The system includes a significant amount of data in each Pusher message, which could impact performance for clients with limited bandwidth. Consider optimizing the message payload to include only essential data.

### Broadcast Frequency

The system implements several strategies to limit the frequency of broadcasts, which helps reduce the load on both the server and clients.

## Next Steps

1. Analyze the impact of real-time updates on system performance
2. Consider implementing more granular channels for specific update types
3. Evaluate the security implications of the current real-time communication approach
4. Document the client-side handling of real-time updates

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-01 | AI Assistant | Initial documentation | 