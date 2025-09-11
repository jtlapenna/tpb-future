# Product APIs Analysis

## Product Data Flow

### 1. Product Listing (`/products`)
**Implementation**: `ProductsRepo.index()`
**Purpose**: Fetch paginated product list with caching
**Data Flow**:
1. Check local IndexedDB for cached products
2. If not found, fetch from remote API
3. Save to local storage for offline access
4. Return products with metadata

**Parameters**:
```javascript
{
  page: 1,
  per_page: 25,
  sort_by: 'created_at'
}
```

**Response Structure**:
```javascript
{
  products: [
    {
      id: number,
      name: string,
      description: string,
      price: number,
      stock: number,
      images: string[],
      attributes: {
        thc: number,
        cbd: number,
        strain_type: string
      },
      brand_id: number,
      category_id: number,
      created_at: string,
      updated_at: string
    }
  ],
  meta: {
    current_page: number,
    total_pages: number,
    total_count: number
  }
}
```

### 2. Product Details (`/products/{id}`)
**Implementation**: `ProductsRepo.show()`
**Purpose**: Fetch individual product with local-first strategy
**Data Flow**:
1. Check local IndexedDB first
2. If not found, fetch from remote API
3. Save to local storage
4. Return product data

**Observable Pattern**:
```javascript
show(productId) {
  return new Observable(async subscriber => {
    try {
      // Try local first
      let product = await this.local.show(productId)
      if (product) {
        subscriber.next(product)
        return
      }
      // Fallback to remote
      product = await this.remote.show(productId)
      subscriber.next(product)
      this.local.save(product)
    } catch (e) {
      subscriber.error(e)
    }
  })
}
```

### 3. Product Sync (`/products/maximal`)
**Implementation**: `API.getProductsMinimal()`
**Purpose**: Incremental product synchronization
**Key Features**:
- Date-based filtering (`max_date`)
- Exclude zero-stock products
- Large page size (350 items)
- Redundant data fetching for sync reliability

**Sync Logic**:
```javascript
// Get last update date from localStorage
let updatedAt = new Date(localStorage.getItem('update_date') || '2019-10-31')

// Add 1-minute buffer for sync reliability
if (localStorage.getItem('update_date')) {
  updatedAt.setMinutes(updatedAt.getMinutes() - 1)
}

// Hard reload resets to initial date
if (hardReloadProducts) {
  updatedAt = new Date('2019-10-31')
}
```

### 4. Product Availability Check
**Implementation**: `API.getProductsWhenNoExist()`
**Purpose**: Verify product availability at specific store
**Use Case**: Multi-store kiosk validation

### 5. Product Expiration Verification
**Implementation**: `API.verifyProductsExpiration()`
**Purpose**: Check if products are still valid/not expired
**Data Structure**:
```javascript
{
  store_id: number,
  products: [
    {
      id: number,
      expired_at: string,
      last_updated_at: string
    }
  ],
  kiosk_id: string
}
```

## Local Storage Management

### IndexedDB Schema
**Database**: `kioskDB`
**Version**: 1
**Object Stores**:
- `products` - Product data with `id` as keyPath
- `brands` - Brand data
- `articles` - Article data
- `rfids` - RFID data
- `tags` - Tag data

### Local Storage Operations
**Save Product**:
```javascript
async save(product) {
  return new Promise(async (resolve, reject) => {
    let trans = await this.getReadTransaction()
    trans.oncomplete = () => resolve()
    trans.onerror = e => reject(e)
    
    let store = trans.objectStore('products')
    store.put(product)
  })
}
```

**Get Product**:
```javascript
show(id) {
  return new Promise(async resolve => {
    let trans = await this.getReadTransaction()
    let store = trans.objectStore('products')
    let getProduct = store.get(id)
    getProduct.onsuccess = event => {
      resolve(getProduct.result)
    }
  })
}
```

## Data Transformation

### Product Expiration Logic
```javascript
// Set expiration date to 1 day from now
const expiredDate = new Date()
expiredDate.setDate(expiredDate.getDate() + 1)
product.expired_at = expiredDate.toISOString()

// Filter out zero-stock products
products.filter(p => p.stock > 0)
```

### Stock Management
- **Zero Stock**: Products with `stock === 0` are deleted from local storage
- **Positive Stock**: Products with `stock > 0` are saved with expiration date
- **Sync Strategy**: Server data takes precedence over local data

## Error Handling

### API Error Patterns
```javascript
try {
  const response = await this.remote.index(options)
  // Process response
} catch (e) {
  console.error(e)
  // No user feedback, falls back to local data
}
```

### Network Error Handling
- **Offline**: Falls back to local IndexedDB data
- **API Errors**: Logged to console, no user notification
- **Data Corruption**: No validation or recovery mechanisms

## Performance Considerations

### Caching Strategy
- **Local First**: Always check local storage before remote
- **Background Sync**: No automatic background synchronization
- **Cache Invalidation**: Manual refresh required
- **Memory Usage**: No memory limits on local storage

### Data Loading
- **Pagination**: 25 items per page by default
- **Sync Pages**: 350 items per page for synchronization
- **Lazy Loading**: Not implemented
- **Prefetching**: Not implemented

## Modernization Recommendations

### React Query Implementation
```javascript
// Replace ProductsRepo with React Query
const useProducts = (page = 1, perPage = 25) => {
  return useQuery({
    queryKey: ['products', page, perPage],
    queryFn: () => api.getProducts({ page, per_page: perPage }),
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
    refetchOnWindowFocus: false
  })
}

const useProduct = (id) => {
  return useQuery({
    queryKey: ['product', id],
    queryFn: () => api.getProduct(id),
    enabled: !!id
  })
}
```

### State Management
```javascript
// Redux Toolkit slice for products
const productsSlice = createSlice({
  name: 'products',
  initialState: {
    items: [],
    loading: false,
    error: null
  },
  reducers: {
    setProducts: (state, action) => {
      state.items = action.payload
    }
  }
})
```

### Error Handling
```javascript
// Error boundary for product components
const ProductErrorBoundary = ({ children }) => {
  return (
    <ErrorBoundary
      fallback={<ProductErrorFallback />}
      onError={(error) => {
        console.error('Product error:', error)
        // Send to error tracking service
      }}
    >
      {children}
    </ErrorBoundary>
  )
}
```

### Offline Support
```javascript
// Service worker for offline caching
const cacheProducts = async (products) => {
  const cache = await caches.open('products-v1')
  await cache.put('/api/products', new Response(JSON.stringify(products)))
}
```
