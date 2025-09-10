# Customer Management Flow

## Overview
The Customer Management Flow in The Peak Beyond's system handles the creation, retrieval, and synchronization of customer data across different Point of Sale (POS) systems. This flow is essential for maintaining accurate customer records, enabling personalized experiences, and supporting order processing in cannabis dispensaries.

## User Roles

### Customer
- Provides personal information during registration
- Updates personal information when needed
- Uses customer ID for placing orders

### Store Staff
- Searches for existing customers
- Creates new customer records
- Updates customer information
- Associates customers with orders

### Store Manager
- Manages customer data policies
- Oversees customer data quality
- Handles customer data issues
- Reviews customer analytics

### System Administrator
- Configures customer-related settings
- Manages POS integrations for customer data
- Troubleshoots customer synchronization issues
- Ensures data compliance

## Preconditions
1. Store is properly configured in the system
2. POS integration is set up and functioning
3. User authentication and authorization are in place
4. Data privacy and compliance requirements are addressed
5. Customer data fields are properly configured

## Core Flow Steps

### 1. Customer Creation
1. Store staff or customer initiates customer creation process
2. System presents customer information form
3. Required information is entered (first name, last name, etc.)
4. Optional information is entered (gender, birthday, etc.)
5. System validates the customer data
6. System creates the customer record in the appropriate POS system
7. System stores a record of the customer in the local database
8. System confirms successful customer creation

### 2. Customer Search and Retrieval
1. Store staff or customer initiates customer search
2. Search criteria are entered (name, email, phone, etc.)
3. System queries the database for matching customers
4. System filters and deduplicates results
5. System presents matching customer records
6. Store staff or customer selects the correct customer record
7. System retrieves detailed customer information

### 3. Customer Data Synchronization
1. System initiates customer synchronization job (scheduled or manual)
2. System checks for previous synchronization status
3. System retrieves customer data from POS system
4. System parses and normalizes customer data
5. System updates local customer records
6. System handles conflicts and duplicates
7. System marks synchronization as complete
8. System logs synchronization results

### 4. Customer Data Update (Alternative Flow)
1. Store staff or customer initiates customer data update
2. System retrieves current customer information
3. Updated information is entered
4. System validates the updated data
5. System updates the customer record in the POS system
6. System updates the local customer record
7. System confirms successful update

## Alternative Paths and Edge Cases

### Customer Deduplication
- System detects potential duplicate customer records
- System applies deduplication logic based on name, contact info, and other identifiers
- System prioritizes most recently updated records
- System maintains customer history for audit purposes

### Customer Data Validation Failures
- If customer data validation fails, the system shows appropriate error messages
- User can correct the data and try again
- System logs validation failures for analysis

### POS Integration Failures
- If POS integration fails during customer operations, the system may store changes locally
- System retries failed operations when possible
- System administrators are notified of integration failures

### Customer Privacy and Consent
- System handles customer consent for data collection and processing
- System supports data anonymization or deletion requests
- System maintains audit trail of customer data changes

## API Endpoints

### Customer Creation
- **Endpoint**: `POST /api/v1/:catalog_id/customers`
- **Controller**: `Api::V1::CustomersController#create`
- **Parameters**:
  - `customer`: Customer details including first_name, last_name, gender, birthday, email, phone, drivers_license, notes
  - `catalog_id`: Kiosk ID
- **Response**: Customer details including customer ID and status

### Customer Search and Retrieval
- **Endpoint**: `GET /api/v1/:catalog_id/customers`
- **Controller**: `Api::V1::CustomersController#index`
- **Parameters**:
  - `catalog_id`: Kiosk ID
  - `first_name`: Customer first name (optional)
  - `last_name`: Customer last name (optional)
  - `phone`: Customer phone (optional)
  - `email`: Customer email (optional)
  - `driver_license`: Customer driver's license (optional)
  - `birthday`: Customer birthday (optional)
- **Response**: List of matching customer records

## UI Components

### Customer-Facing Components
- Customer registration form
- Customer profile view
- Customer information update form
- Customer order history view

### Staff-Facing Components
- Customer search interface
- Customer creation form
- Customer detail view
- Customer edit form
- Customer order history view

## Data Models

### Customer
- Database model representing a customer
- Attributes:
  - `customer_id`: Customer identifier
  - `store_id`: Store identifier
  - `external_account_id`: External account identifier
  - `first_name`: Customer first name
  - `last_name`: Customer last name
  - `gender`: Customer gender
  - `birthday`: Customer birthday
  - `email`: Customer email
  - `phone`: Customer phone
  - `drivers_license`: Customer driver's license
  - `notes`: Additional customer notes
  - `status`: Customer status (active, inactive)
  - `last_modified_date_utc`: Last modification date

### CustomerSync
- Database model representing a customer synchronization job
- Attributes:
  - `store_id`: Store identifier
  - `external_account_id`: External account identifier
  - `status`: Synchronization status (pending, in_progress, failed, finished)

## Integration Points

### POS Systems
The Customer Management Flow integrates with various Point of Sale (POS) systems to synchronize customer data:

- **Treez**: Integration via Treez API for customer creation and retrieval
- **Flowhub**: Integration via Flowhub API for customer retrieval
- **Leaflogix**: Integration via Leaflogix API for customer creation and retrieval
- **Covasoft**: Integration via Covasoft API for customer retrieval
- **Blaze**: Integration via Blaze API for customer retrieval

### Customer Synchronization Scheduling
The customer synchronization process is scheduled and managed through several mechanisms:

1. **Store-based Scheduling**: Each store has a method `schedule_customer_sync` that initiates the synchronization process. This method:
   - Creates a new `CustomerSyncJob` for the store
   - Sets appropriate parameters for the sync process
   - Ensures the job is queued with proper uniqueness constraints

2. **Periodic Scheduling**: Customer synchronization is typically scheduled to run:
   - On a daily basis during off-peak hours
   - After major POS system updates
   - On-demand when triggered by store administrators

3. **Uniqueness Constraints**: To prevent duplicate synchronization jobs:
   - The `CustomerSyncJob` uses Sidekiq's uniqueness feature with `unique: :until_executed`
   - The job checks if a sync is already in progress before starting a new one
   - Only one sync job per store can run at a time

### Error Handling Strategies

Each POS client implements specific error handling strategies to ensure robust customer data synchronization:

1. **Treez Customer Client**:
   - Handles HTTP errors with specific status code handling (401, 404, 500)
   - Implements retry logic for transient network issues
   - Logs detailed error information for debugging
   - Returns standardized error responses to the calling code

2. **Flowhub Customer Client**:
   - Uses exception handling for API communication errors
   - Implements timeout handling for slow responses
   - Validates response data before processing
   - Returns nil with error logging when customer retrieval fails

3. **Leaflogix Customer Client**:
   - Implements comprehensive exception handling
   - Validates customer data before submission
   - Handles duplicate customer scenarios with merge logic
   - Logs detailed error information to Airbrake

4. **Covasoft and Blaze Customer Clients**:
   - Implement basic error handling for API communication
   - Log errors to the application logger
   - Return empty arrays for failed customer retrievals
   - Include error details in the response for debugging

5. **Global Error Handling**:
   - All POS client errors are captured in the `CustomerSync` model
   - Failed synchronizations are marked with status `failed`
   - Error details are stored for administrative review
   - Airbrake notifications are sent for critical failures

### Background Jobs
The Customer Management Flow relies on background jobs for asynchronous processing:

- **CustomerSyncJob**: Responsible for synchronizing customer data from POS systems
- **CustomerImportJob**: Handles bulk customer imports from CSV or other formats

## Security Considerations

### Authentication and Authorization
- API endpoints require authentication
- Customer operations are restricted to authorized users
- Customer data access is controlled based on user roles

### Data Validation
- Customer data is validated before processing
- Input sanitization prevents injection attacks
- Data format validation ensures data integrity

### POS Integration Security
- Secure API communication with POS systems
- API credentials are stored securely
- Error handling prevents sensitive information exposure

### Customer Data Protection
- Customer information is handled according to privacy regulations
- Personal data is protected in transit and at rest
- Data retention policies are implemented

## Performance Considerations

### Customer Search Optimization
- Database indexes optimize customer queries
- Search algorithms handle partial matches and typos
- Result pagination manages large result sets

### POS Integration
- POS API calls are optimized to minimize latency
- Retry mechanisms handle temporary connectivity issues
- Caching strategies reduce redundant API calls

### Synchronization Efficiency
- Incremental synchronization reduces data transfer
- Background processing prevents UI blocking
- Scheduled synchronization balances freshness and system load

## Monitoring and Logging

### Customer Operations Tracking
- All customer operations are logged
- Customer data changes are tracked
- Customer history is maintained for auditing

### Error Handling
- POS integration errors are captured and logged
- Customer data validation errors are tracked
- Retry mechanisms attempt to recover from failures

### Performance Metrics
- Customer operation response times are monitored
- POS API response times are tracked
- Synchronization job performance is measured

## Future Improvements

### Customer Management Enhancements
- Advanced customer search capabilities
- Customer segmentation and tagging
- Enhanced customer analytics
- Customer loyalty program integration

### POS Integration Improvements
- More robust error recovery mechanisms
- Support for additional POS systems
- Real-time customer data synchronization

### Customer Experience Enhancements
- Self-service customer profile management
- Customer preferences management
- Personalized recommendations based on customer data

## Relationship with Other Flows

### Order Management Flow

The Customer Management Flow has a direct relationship with the Order Management Flow:

1. **Customer Identification for Orders**:
   - When a customer places an order, the Order Management Flow uses the Customer Management Flow to identify and validate the customer
   - Customer details are attached to orders for compliance and personalization
   - Customer purchase history is updated when orders are completed

2. **Shared Data Models**:
   - The `Customer` model is referenced by the `Order` model
   - Customer attributes influence order processing (e.g., loyalty status, purchase limits)
   - Order history is accessible through the customer record

3. **API Integration Points**:
   - The Order Management API endpoints often require customer information
   - Customer validation occurs during order creation
   - Customer notifications may be triggered by order status changes

4. **POS System Integration**:
   - Both flows interact with the same POS systems
   - Customer data synchronization may trigger order data updates
   - Consistent error handling strategies are employed across both flows

5. **UI Components**:
   - Customer selection is a key step in the order creation process
   - Customer details are displayed during order review
   - Customer history may influence product recommendations

This relationship ensures that customer data is consistently used throughout the ordering process, from initial customer identification to order completion and history tracking. 