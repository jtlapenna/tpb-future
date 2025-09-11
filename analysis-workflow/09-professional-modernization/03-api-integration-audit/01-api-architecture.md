# API Architecture Analysis

## Overview
The legacy application uses a sophisticated API architecture with multiple layers and patterns for data management, caching, and real-time communication.

## Architecture Patterns

### 1. Repository Pattern
**Implementation**: `RemoteRepo.js` + `LocalRepo.js` + `ProductsRepo.js`
**Purpose**: Abstracts data access with local/remote separation
**Key Features**:
- Local-first data access with remote fallback
- IndexedDB for local storage
- Observable pattern for reactive data
- Automatic data synchronization

### 2. Service Layer Pattern
**Implementation**: `api.js` (main API service)
**Purpose**: Centralized API endpoint management
**Key Features**:
- Axios-based HTTP client
- Environment-based configuration
- Token-based authentication
- Cache control headers

### 3. Hybrid Data Strategy
**Implementation**: Local + Remote repositories
**Purpose**: Offline-first with online synchronization
**Key Features**:
- IndexedDB for local persistence
- Automatic sync on network availability
- Conflict resolution strategies
- Data expiration handling

## API Endpoints Analysis

### Product APIs
| Endpoint | Method | Purpose | Parameters | Response |
|----------|--------|---------|------------|----------|
| `/products` | GET | List products | `page`, `per_page`, `sort_by` | `{products: [], meta: {}}` |
| `/products/{id}` | GET | Get product details | `id` | `{product: {}}` |
| `/products/maximal` | GET | Get products with filters | `max_date`, `page`, `per_page`, `exclude_zero` | `{products: []}` |
| `/products/check_products_availability` | GET | Check product availability | `store_id` | `{products: []}` |
| `/products/check_products_expired_status` | POST | Verify product expiration | `store_id`, `products`, `kiosk_id` | `{status: {}}` |

### Brand APIs
| Endpoint | Method | Purpose | Parameters | Response |
|----------|--------|---------|------------|----------|
| `/brands` | GET | List brands | `page`, `per_page`, `sort_by` | `{brands: [], meta: {}}` |

### Category APIs
| Endpoint | Method | Purpose | Parameters | Response |
|----------|--------|---------|------------|----------|
| `/categories` | GET | List categories | `params` | `{categories: []}` |

### Article APIs
| Endpoint | Method | Purpose | Parameters | Response |
|----------|--------|---------|------------|----------|
| `/articles` | GET | List articles | `minimal` | `{articles: []}` |

### Tag APIs
| Endpoint | Method | Purpose | Parameters | Response |
|----------|--------|---------|------------|----------|
| `/tags` | GET | List tags | `featured_tags` | `{tags: []}` |

### Order APIs
| Endpoint | Method | Purpose | Parameters | Response |
|----------|--------|---------|------------|----------|
| `/orders/preview_order` | POST | Calculate taxes | `order_data` | `{taxes: {}}` |

### Customer APIs
| Endpoint | Method | Purpose | Parameters | Response |
|----------|--------|---------|------------|----------|
| `/customers` | POST | Create customer | `customer` | `{customer: {}}` |

### Settings APIs
| Endpoint | Method | Purpose | Parameters | Response |
|----------|--------|---------|------------|----------|
| `/settings` | GET | Get kiosk settings | None | `{settings: {}}` |

## Authentication & Security

### Token-Based Authentication
- **Method**: Query parameter authentication
- **Token Source**: Environment variables or kiosk config
- **Header**: `token: TPB_STORE_TOKEN`
- **Security**: Basic token validation (no JWT)

### Cache Control
- **Headers**: `Cache-Control: no-cache`, `Pragma: no-cache`, `Expires: 0`
- **Strategy**: Always fetch fresh data from server
- **Local Storage**: Used for offline data persistence

## Data Management Patterns

### Local Storage Strategy
- **Database**: IndexedDB with versioning
- **Tables**: `products`, `brands`, `articles`, `rfids`, `tags`
- **Sync Strategy**: Local-first with remote fallback
- **Expiration**: Products expire after 1 day by default

### Data Synchronization
- **Strategy**: Incremental sync based on `updatedAt` timestamps
- **Conflict Resolution**: Server data takes precedence
- **Offline Support**: Full offline functionality with local data
- **Sync Triggers**: Manual refresh or automatic on network availability

## Real-Time Communication

### Firebase Integration
- **Service**: Firebase Messaging + Firestore
- **Purpose**: Real-time order updates and notifications
- **Features**:
  - Push notifications
  - Order status changes
  - Real-time data synchronization
  - Topic-based subscriptions

### WebSocket Alternative
- **Implementation**: Firebase Firestore real-time listeners
- **Use Cases**: Order tracking, inventory updates
- **Fallback**: Polling-based updates

## Error Handling Patterns

### API Error Handling
- **Strategy**: Try-catch with console logging
- **Fallback**: Local data when remote fails
- **User Feedback**: Limited error messaging to users
- **Retry Logic**: None implemented

### Network Error Handling
- **Offline Detection**: Not explicitly implemented
- **Retry Strategy**: Manual refresh required
- **Graceful Degradation**: Falls back to local data

## Performance Optimizations

### Caching Strategy
- **Local Caching**: IndexedDB for all data types
- **Memory Caching**: None implemented
- **CDN**: Not used
- **Compression**: Not implemented

### Data Loading
- **Pagination**: Implemented for all list endpoints
- **Lazy Loading**: Not implemented
- **Prefetching**: Not implemented
- **Batch Operations**: Limited to local storage operations

## Modernization Recommendations

### React Query Migration
- **Current**: Custom repository pattern
- **Target**: React Query with mutations and caching
- **Benefits**: Better caching, error handling, loading states
- **Implementation**: Replace repositories with React Query hooks

### State Management
- **Current**: Vuex with local storage
- **Target**: Redux Toolkit with persistence
- **Benefits**: Better dev tools, predictable state updates
- **Implementation**: Redux Toolkit Query for API state

### Error Handling
- **Current**: Basic try-catch
- **Target**: Error boundaries + toast notifications
- **Benefits**: Better user experience, centralized error handling
- **Implementation**: React Error Boundaries + React Hot Toast

### Authentication
- **Current**: Token-based with query params
- **Target**: JWT with proper headers
- **Benefits**: Better security, standardized auth
- **Implementation**: Axios interceptors + JWT handling

### Real-Time Updates
- **Current**: Firebase Firestore
- **Target**: React Query with real-time subscriptions
- **Benefits**: Better integration with React patterns
- **Implementation**: React Query + Firebase hooks
