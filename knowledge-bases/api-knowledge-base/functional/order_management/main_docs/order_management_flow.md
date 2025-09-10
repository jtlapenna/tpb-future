# Order Management Flow

## Overview
The Order Management Flow in The Peak Beyond's system handles the creation, processing, and fulfillment of customer orders across different Point of Sale (POS) systems. This flow is critical for the business operations of cannabis dispensaries, enabling customers to place orders through kiosks and staff to manage these orders efficiently.

## User Roles

### Customer
- Browses products on kiosks
- Adds products to cart
- Places orders
- Receives order confirmation and updates

### Store Staff
- Receives order notifications
- Processes orders
- Updates order status
- Fulfills orders

### Store Manager
- Monitors order flow
- Manages order-related settings
- Handles order issues
- Views order reports

### System Administrator
- Configures order-related settings
- Manages POS integrations
- Troubleshoots order processing issues

## Preconditions
1. Store is properly configured in the system
2. POS integration is set up and functioning
3. Products are synced from POS to the system
4. Kiosks are operational and connected to the backend
5. User authentication and authorization are in place

## Core Flow Steps

### 1. Order Creation
1. Customer browses products on a kiosk
2. Customer adds products to cart
3. Customer provides necessary information (e.g., customer ID)
4. Customer submits the order
5. System validates the order (product availability, customer information)
6. System creates the order in the appropriate POS system
7. System stores a record of the order in the local database
8. System sends order notifications to store staff
9. Customer receives order confirmation (if enabled)

### 2. Order Processing
1. Store staff receives notification of new order
2. Staff reviews the order details
3. Staff begins processing the order
4. Staff updates the order status to "IN_PROCESS"
5. System updates the order status in both POS and local database
6. Customer may receive status update notification (if enabled)

### 3. Order Fulfillment
1. Staff completes order preparation
2. Staff updates order status to "PACKED_READY" or "OUT_FOR_DELIVERY"
3. Staff completes the delivery or pickup process
4. Staff marks the order as "COMPLETED"
5. System updates the order status in both POS and local database
6. Customer may receive completion notification (if enabled)

### 4. Order Cancellation (Alternative Flow)
1. Customer or staff initiates order cancellation
2. Staff updates order status to "CANCELED"
3. System updates the order status in both POS and local database
4. Customer may receive cancellation notification (if enabled)
5. System may handle inventory adjustments based on cancellation

## Alternative Paths and Edge Cases

### Order Resumption
- If a customer has an in-progress order, the system can resume and update that order instead of creating a new one
- This is supported by some POS systems (e.g., Treez)

### Order Validation Failures
- If order validation fails (e.g., product not available), the system shows appropriate error messages
- Customer can modify the order and try again

### POS Integration Failures
- If POS integration fails during order creation, the system may store the order locally and retry later
- System administrators are notified of integration failures

### Duplicate Orders
- System handles duplicate order detection and prevention
- If a duplicate order is detected, the system may update the existing order or show an error

## API Endpoints

### Order Creation
- **Endpoint**: `POST /api/v1/:catalog_id/orders`
- **Controller**: `Api::V1::OrdersController#create`
- **Parameters**:
  - `order`: Order details including customer_id, items, notes
  - `catalog_id`: Kiosk ID
- **Response**: Order details including order ID and status

### Order Status Update
- **Endpoint**: `PUT /api/v1/orders/status`
- **Controller**: `Api::V1::OrdersController#status`
- **Parameters**:
  - `order`: Order details including customer_id, order_status, ticket_id
- **Response**: Updated order details

### Order Preview
- **Endpoint**: `POST /api/v1/:catalog_id/orders/preview`
- **Controller**: `Api::V1::OrdersController#preview_order`
- **Parameters**:
  - `order`: Order details for preview
  - `catalog_id`: Kiosk ID
- **Response**: Preview of order details

### Discount Code Validation
- **Endpoint**: `GET /api/v1/:catalog_id/orders/discount`
- **Controller**: `Api::V1::OrdersController#discount`
- **Parameters**:
  - `code`: Discount code
  - `catalog_id`: Kiosk ID
- **Response**: Discount details if valid, error if invalid

## UI Components

### Customer-Facing Components
- Product browsing interface
- Shopping cart
- Order submission form
- Order confirmation screen
- Order status display

### Staff-Facing Components
- Order list view
- Order detail view
- Order status update controls
- Order fulfillment workflow
- Order search and filtering

## Data Models

### Order
- Virtual model representing an order
- Attributes:
  - `customer_id`: Customer identifier
  - `items`: Array of order items
  - `store_id`: Store identifier
  - `id`: Order identifier
  - `notes`: Additional order notes

### OrderItem
- Virtual model representing an item in an order
- Attributes:
  - `product_id`: Product identifier
  - `quantity`: Quantity ordered
  - `order`: Reference to parent order
  - `product_value_id`: Product value identifier (e.g., size, weight)

### CustomerOrder
- Database model storing order information
- Attributes:
  - `customer_id`: Customer identifier
  - `order_id`: Order identifier from POS
  - `store_id`: Store identifier
  - `data`: JSON data containing order details
  - `status`: Order status
  - `amount`: Order total amount
  - `printed_date`: Date when order was printed
  - `printed_id`: Printed order identifier

### OrderCustomer
- Database model storing customer information for orders
- Attributes:
  - `uuid`: Unique identifier
  - `first_name`: Customer first name
  - `last_name`: Customer last name
  - `amount`: Order amount
  - `payed`: Payment status
  - `date`: Order date
  - `kiosks_id`: Kiosk identifier
  - `client_id`: Client identifier

## Integration Points

### POS Systems
The system integrates with multiple POS systems through dedicated order clients:
- **Treez**: `Treez::OrderClient`
- **Flowhub**: `Flowhub::OrderClient`
- **Covasoft**: `Covasoft::OrderClient`
- **Leaflogix**: `Leaflogix::OrderClient`
- **Blaze**: `Blaze::OrderClient`
- **Shopify**: `Shopify::OrderClient`

Each order client implements the following key methods:
- `create!`: Creates a new order in the POS system
- `update!`: Updates an existing order in the POS system
- `update_status!`: Updates the status of an order in the POS system
- `preview!`: Previews an order before submission

### Email Notifications
The system sends email notifications for orders using `OrdersMailer`:
- `new_order`: Sends notification for new or updated orders
- `notify_new_order`: Class method to handle notification logic

Notifications can be sent to:
- Store staff (based on store notification settings)
- Customers (if enabled in store settings)

## Security Considerations

### Authentication and Authorization
- API endpoints require authentication
- Order operations are restricted to authorized users
- Customer information is protected

### Data Validation
- Order data is validated before processing
- Input sanitization prevents injection attacks
- Order amounts and quantities are validated

### POS Integration Security
- Secure API communication with POS systems
- API credentials are stored securely
- Error handling prevents sensitive information exposure

### Customer Data Protection
- Customer information is handled according to privacy regulations
- Personal data is protected in transit and at rest

## Performance Considerations

### Order Processing
- Order creation and updates are handled asynchronously where possible
- Background jobs process notifications to prevent blocking
- Database queries are optimized for order retrieval

### POS Integration
- POS API calls are optimized to minimize latency
- Retry mechanisms handle temporary connectivity issues
- Caching strategies reduce redundant API calls

### Scalability
- The system can handle increasing order volumes
- Database indexes optimize order queries
- Connection pooling manages POS API connections efficiently

## Monitoring and Logging

### Order Tracking
- All order operations are logged
- Order status changes are tracked
- Order history is maintained for auditing

### Error Handling
- POS integration errors are captured and logged
- Order processing errors trigger notifications
- Retry mechanisms attempt to recover from failures

### Performance Metrics
- Order processing times are monitored
- POS API response times are tracked
- System resources are monitored during peak order periods

## Future Improvements

### Order Management Enhancements
- Advanced order filtering and search capabilities
- Batch order processing for efficiency
- Enhanced order analytics and reporting

### POS Integration Improvements
- More robust error recovery mechanisms
- Support for additional POS systems
- Real-time synchronization improvements

### Customer Experience Enhancements
- Real-time order status updates
- Enhanced order history for customers
- Improved order modification capabilities 