# Event-Driven Updates Pattern Validation

## Pattern Overview
The Event-Driven Updates pattern enables real-time propagation of state changes across a distributed system, ensuring that all components maintain synchronized state without constant polling. This pattern is essential for applications requiring immediate reflection of changes across multiple interfaces.

## Validation Evidence

### Backend (Ruby on Rails)

#### WebSocket Implementation with Pusher
```repositories/back-end/app/models/store_product.rb```

The backend implements real-time updates using the Pusher service to broadcast changes:

1. **Lifecycle Hooks for Broadcasting**:
   - The `StoreProduct` model includes hooks to broadcast changes automatically:
   ```ruby
   after_update_commit :broadcast_changes_update
   before_destroy :broadcast_changes_destroy
   ```

2. **Broadcast Methods Implementation**:
   - The `broadcast_changes_destroy` method:
   ```ruby
   def broadcast_changes_destroy
     Rails.logger.info("======= BROADCAST DESTROY ======= #{self.inspect}")
     if has_pusher_env && is_store_open_time
       Pusher.trigger("store_products_#{self.store_id}", 'product_destroyed', {
         product: self.as_json
       })
     end
   end
   ```

   - The `broadcast_changes_update` method:
   ```ruby
   def broadcast_changes_update
     # Skip broadcasting for webhook updates
     if self.latest_update_source == 'webhooks'
       Rails.logger.info("======= IGNORING WEBHOOKS FOR PUSHER ======= STORE_PRODUCT_ID: #{self.id}")
       return
     end

     # Only broadcast if relevant fields have changed
     relevant_fields = ['store_category_id', 'name', 'description', 'stock', 'sku', 'status', 'primary_image_id', 'thumb_image_id', 'brand_id', 'weight', 'status', 'last_updated_websocket', 'tag_list', 'is_medical_only', 'is_full_screen']
     changed_fields = self.previous_changes.keys & relevant_fields
     
     # Broadcast only if changes are relevant and environment supports it
     if changed_fields.any? && !stock_is_equal && has_pusher_env && is_store_open_time
       # Prepare rich payload with associated data
       # Trigger the event through Pusher service
       Pusher.trigger("store_products_#{self.store_id}", 'product_updated', {
         changes: self.previous_changes,
         product: json["product"]
       })
     end
   end
   ```

3. **Last Updated Tracking**:
   Multiple models update a `last_updated_websocket` timestamp field to track changes for real-time propagation:
   ```ruby
   # In models like StoreProductPromotion, Product, etc.
   def notify_store_product_update
     if store_product
       store_product.update_columns(last_updated_websocket: Time.zone.now)
     end
   end
   ```

### Frontend (Vue.js)

#### Pusher Client Integration
```repositories/front-end/src/App.vue```

1. **WebSocket Connection Setup**:
   ```javascript
   // In mounted lifecycle hook
   mounted: function() {
     // Initialize Pusher connection
     let pusher
     const connectPusher = () => {
       try {
         pusher = new Pusher(self.kioskConfig.PUSHER_APP_KEY, {
           cluster: self.kioskConfig.PUSHER_APP_CLUSTER
         })
         
         pusher.connection.bind('connected', function() {
           console.log('Pusher connected to server')
           connectProductWebSocket()
           connectProductDestroyedWebSocket()
         })
       } catch (error) {
         console.log('Error connecting to Pusher', error)
       }
     }
     
     connectPusher()
   }
   ```

2. **Real-time Event Subscriptions**:
   ```javascript
   const connectProductWebSocket = () => {
     const configData = JSON.parse(localStorage.getItem('config_data'))
     try {
       const channel = pusher.subscribe(
         `store_products_${configData.store.id}`
       )
       
       // Listen for product updates
       channel.bind('product_updated', data => {
         const product = data.product
         // Update local state based on received data
         db.getProduct(product.id).then(localProduct => {
           if (!localProduct) {
             if (product.stock > 0 && product.status === 'published') {
               db.saveProduct(product)
               this.fetchedProducts[product.id] = product
               this.parseProducts()
             }
           } else {
             Object.assign(localProduct, product)
             db.saveProduct(localProduct)
             this.parseProducts()
           }
         })
       })
     } catch (error) {
       console.log('Error connecting to Pusher', error)
     }
   }
   
   const connectProductDestroyedWebSocket = () => {
     // Similar pattern for deleted products
     channel.bind('product_destroyed', data => {
       const product = data.product
       this.productsToRemove.push(product)
       
       // Remove from local state
       delete this.fetchedProducts[product.id]
       // Remove from local db
       db.deleteProduct(product)
     })
   }
   ```

#### Socket.IO Integration for Sensors/RFID
```repositories/front-end/src/main.js```

1. **Socket.IO Connection**:
   ```javascript
   if (mergedConfig.RFID_ENABLED) {
     const socket = io('http://localhost:3000')
     
     socket.on('connect', function() {
       console.log('Connect ' + socket.id)
     })
     
     // RFID sensor events
     socket.on('tag_put', function(data) {
       vm.$emit('tag-put', data)
     })
     
     socket.on('tag_remove', function(data) {
       // Handle tag removal
     })
     
     // Ultrasonic sensor events
     socket.on('sensor_uncovered', function(comName) {
       var portNumber = Number(comName.slice(-1))
       vm.$emit('sensor-uncovered', portNumber)
     })
   }
   ```

2. **Event Propagation to Components**:
   In App.vue, these events are captured and processed:
   ```javascript
   // In created hook
   this.$root.$on('tag-put', function(data) {
     // Process RFID tag detection
     // Route to appropriate product page
     self.$router.push({
       name: 'product',
       params: { id: product.id, source: 'RFID' }
     })
   })
   
   this.$root.$on('sensor-uncovered', function(portNumber) {
     // Process sensor events
   })
   ```

### CMS Frontend (Angular)

#### WebSocket Integration for Sensors
```repositories/cms-fe-angular/src/app/kiosks/services/sensor.service.ts```

1. **Socket.IO Client Implementation**:
   ```typescript
   class SocketSensorObserver implements SensorObserver {
     private socket: ReturnType<typeof io>;
     private connectionSubscription: Subscription;
     
     constructor(url: string) {
       this.socket = io(url);
       
       // Connection status observable
       this.available = merge(
         fromEvent(this.socket, 'connect').pipe(mapTo(true)),
         fromEvent(this.socket, 'disconnect').pipe(mapTo(false))
       ).pipe(
         multicast(() => new BehaviorSubject(false))
       );
       
       // Handle tag events
       this.socket.on('tag_put', (tag) => {
         console.log('TAG WAS PUT', tag);
       })
       
       // Ultrasonic sensor events as observables
       const us$ = merge(
         fromEvent(this.socket, 'sensor_uncovered'),
         fromEvent(this.socket, 'sensor_covered'),
       ).pipe(
         map((comName: string) => Number(comName.slice(-1))),
         takeUntil(this.destroyed$)
       );
       
       // RFID events as observables
       const rfid$ = merge(
         fromEvent(this.socket, 'tag_put'),
         fromEvent(this.socket, 'tag_remove').pipe(mapTo(null))
       );
       
       // Combine all sensor values
       this.values = merge(us$, rfid$).pipe(
         takeUntil(this.destroyed$)
       );
     }
     
     // Clean disconnection
     dispose(): void {
       this.socket.disconnect();
       // Clean up subscriptions
     }
   }
   ```

2. **Service Implementation for Components**:
   ```typescript
   @Injectable({
     providedIn: 'root'
   })
   export class SensorService {
     observe(): SensorObserver {
       if (environment.rfidSensorUrl) {
         return new SocketSensorObserver(environment.rfidSensorUrl);
       }
     }
   }
   ```

## Cross-Repository Validation

### Implementation Consistency

| Feature | Backend | Frontend | CMS Frontend |
|---------|---------|----------|--------------|
| WebSocket Technology | Pusher | Pusher & Socket.IO | Socket.IO |
| Event Types | Product updates, deletions | Product updates, deletions, RFID/sensor events | RFID/sensor events |
| Connection Management | Server-side trigger | Client connection handling with error recovery | RxJS Observable pattern |
| State Synchronization | Database changes broadcast | Local state/IndexedDB updates | Reactive state via Observables |

### Validation Findings

1. **Consistent Event Communication**: All three repositories implement event-driven updates using WebSockets, with Pusher for product data synchronization and Socket.IO for sensor/RFID events.

2. **Optimized Broadcasting**: The backend implements selective broadcasting based on:
   - Changed field relevance
   - Business hours (`is_store_open_time`)
   - Update source (ignoring webhook updates)
   - Environment configuration (`has_pusher_env`)

3. **Reactive Programming Patterns**:
   - Vue.js uses event emitters and component hooks
   - Angular uses RxJS Observables with operators like `merge`, `pipe`, and `takeUntil`

4. **Real-time UI Updates**:
   - Product inventory changes immediately reflected
   - RFID/sensor data triggers immediate UI responses
   - Updates propagate across frontend components

5. **Offline-First Approach**:
   - Frontend stores data in IndexedDB
   - Updates local cache before UI rendering
   - Handles disconnections gracefully

## Recommendations

1. **Standardize WebSocket Technology**: Consider consolidating on either Pusher or Socket.IO across all repositories for easier maintenance.

2. **Implement Reconnection Strategies**:
   - Add exponential backoff for reconnection attempts
   - Implement message queuing for failed deliveries

3. **Enhance Security**:
   - Add authentication for WebSocket connections
   - Implement channel authorization in Pusher

4. **Optimize Payload Size**:
   - The current product update payload includes full objects
   - Consider sending only changed fields for better performance

5. **Add Comprehensive Logging**:
   - Implement structured logging for WebSocket events
   - Track connection issues systematically

6. **Testing Enhancements**:
   - Add specialized tests for WebSocket functionality
   - Implement integration tests across repositories

## Conclusion

The Event-Driven Updates pattern is successfully implemented across all three repositories, enabling real-time synchronization of product data, sensor events, and user interface updates. The implementation shows a mature understanding of event-driven architecture principles, with appropriate technology choices for each repository's needs. 