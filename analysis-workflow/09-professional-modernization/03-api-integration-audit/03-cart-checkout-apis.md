# Cart & Checkout APIs Analysis

## Cart Management APIs

### 1. Active Cart System
**Implementation**: Vuex store module (`cart.js`)
**Purpose**: Phone number-based cart persistence and management
**Key Features**:
- Phone number as cart identifier
- Cart persistence across sessions
- Merge existing carts with new items
- Real-time cart updates

### 2. Cart API Endpoints

#### Fetch Active Cart
**Endpoint**: `GET /carts`
**Parameters**: `phone_number`
**Purpose**: Retrieve existing cart by phone number
**Response**:
```javascript
{
  id: number,
  phone_number: string,
  items: [
    {
      name: string,
      brand: string,
      price: number,
      product_id: number,
      quantity: number
    }
  ],
  total: number,
  created_at: string,
  updated_at: string
}
```

#### Create or Merge Cart
**Endpoint**: `POST /carts/create_or_merge`
**Purpose**: Create new cart or merge with existing
**Request Body**:
```javascript
{
  phone_number: string,
  cart: {
    items: [
      {
        name: string,
        brand: string,
        price: number,
        product_id: number,
        quantity: number
      }
    ]
  }
}
```
**Response**:
```javascript
{
  id: number,
  is_new: boolean,
  items: [],
  total: number
}
```

#### Add Items to Cart
**Endpoint**: `POST /carts/add_items`
**Purpose**: Add products to existing cart
**Request Body**:
```javascript
{
  phone_number: string,
  cart: {
    items: [
      {
        name: string,
        brand: string,
        price: number,
        product_id: number,
        quantity: number
      }
    ]
  }
}
```

#### Update Cart Item
**Endpoint**: `POST /carts/update_item`
**Purpose**: Update quantity of existing cart item
**Request Body**:
```javascript
{
  phone_number: string,
  product_id: number,
  quantity: number
}
```

#### Check Cart Exists
**Endpoint**: `GET /carts/exists`
**Parameters**: `phone_number`
**Purpose**: Check if cart exists for phone number
**Response**:
```javascript
{
  exists: boolean
}
```

## Checkout Process APIs

### 1. Tax Calculation
**Endpoint**: `POST /orders/preview_order`
**Purpose**: Calculate taxes for order
**Request Body**:
```javascript
{
  cart: {
    items: [
      {
        product_id: number,
        quantity: number,
        price: number
      }
    ]
  },
  customer: {
    phone_number: string,
    email: string
  }
}
```
**Response**:
```javascript
{
  taxes: {
    subtotal: number,
    tax_amount: number,
    total: number
  }
}
```

### 2. Customer Creation
**Endpoint**: `POST /customers`
**Purpose**: Create customer record
**Request Body**:
```javascript
{
  customer: {
    phone_number: string,
    email: string,
    first_name: string,
    last_name: string,
    date_of_birth: string
  }
}
```
**Response**:
```javascript
{
  customer: {
    id: number,
    phone_number: string,
    email: string,
    created_at: string
  }
}
```

## Payment Gateway Integration

### 1. Blaze Payment Gateway
**Component**: `ScreenCheckoutBlaze.vue`
**Features**:
- Aeropay QR code integration
- Customer information collection
- Order confirmation
- Offline mode handling

**Form Fields**:
- First name (conditional)
- Last name (conditional)
- Email (conditional)
- Date of birth (conditional)
- Phone number (conditional)

**Payment Flow**:
1. Collect customer information
2. Generate Aeropay QR code (if enabled)
3. Process payment through Blaze API
4. Confirm order creation

### 2. Multi-Gateway Support
**Supported Gateways**:
- Blaze (Aeropay)
- Shopify
- Leaflogix
- Treez
- Covasoft
- Flowhub

**Gateway Selection**:
```javascript
// Based on configuration
var checkout = false
if (this.$config.POS_TYPE === 'blaze') {
  checkout = 'ScreenCheckoutBlaze'
} else if (this.$config.POS_TYPE === 'shopify') {
  checkout = 'ScreenCheckoutShopify'
}
// ... other gateways
```

## Real-Time Order Tracking

### 1. Firebase Integration
**Service**: `messaging/index.js`
**Purpose**: Real-time order status updates
**Features**:
- Order status changes
- Payment confirmations
- Error notifications

**Firebase Collections**:
- `kiosk/{kioskId}/orders` - Order updates
- `aeropayOrders/{uuid}` - Aeropay order tracking

### 2. Order Status Tracking
**Implementation**: `getOrderChanges()`
**Purpose**: Monitor order status in real-time
**Parameters**:
- `kioskId` - Kiosk identifier
- `orderId` - Order identifier
- `env` - Environment (optional)

**Real-time Updates**:
```javascript
export const getOrderChanges = ({kioskId, orderId, env}, callback) => {
  const ref = doc(firebaseDB, `${env ? `/envs/${env}/` : ''}kiosk/${kioskId}/orders/${orderId}`)
  return onSnapshot(ref, (snapshot) => {
    callback(snapshot.data())
  }, error => {
    console.error(error)
  })
}
```

## Error Handling Patterns

### 1. Cart Error Handling
**Strategy**: Try-catch with state management
**Error States**:
- `isActiveCartNotFound` - Cart not found
- `isLoading` - Loading state
- `isCartActivated` - Cart activation status

**Error Flow**:
```javascript
.catch((error) => {
  console.error('Error fetching cart:', error)
  commit('setIsActiveCartNotFound', true)
  commit('setIsLoading', false)
  throw error
})
```

### 2. Checkout Error Handling
**Strategy**: Component-level error handling
**Error Display**:
```javascript
<div v-bind:class="{ 'checkout__error--is-visible': error }" class="checkout__error">
  {{ error }}
</div>
```

### 3. Network Error Handling
**Strategy**: Offline mode detection
**Implementation**: `OFFLINE` mixin
**Features**:
- Connection status monitoring
- Offline mode UI
- Graceful degradation

## State Management

### 1. Cart State Structure
```javascript
state: {
  isFromActiveCartActivation: false,
  cart: null,
  globalCart: null,
  phoneNumber: null,
  isActiveCartNotFound: false,
  isCartActivated: false,
  isLoading: false,
  wasCartCreated: false,
  isFromSaveCart: false,
  isFromCheckout: false,
  isAddingItemsFromRetrievedCart: false
}
```

### 2. Cart Actions
- `fetchActiveCart(phoneNumber)` - Retrieve cart
- `createOrMergeActiveCart(data)` - Create/merge cart
- `addProductToActiveCart(data)` - Add item
- `updateProductInActiveCart(data)` - Update item
- `cartExists(phoneNumber)` - Check existence

### 3. State Mutations
- `setCart(value)` - Set cart data
- `setPhoneNumber(value)` - Set phone number
- `setIsCartActivated(value)` - Set activation status
- `setIsLoading(value)` - Set loading state
- `resetActiveCartSession()` - Reset all cart state

## Security Considerations

### 1. Authentication
- **Method**: Token-based authentication
- **Storage**: Environment variables
- **Validation**: Server-side token validation

### 2. Data Validation
- **Client-side**: Basic form validation
- **Server-side**: Comprehensive validation
- **Sanitization**: Input sanitization required

### 3. PCI Compliance
- **Payment Data**: Not stored locally
- **Transmission**: HTTPS required
- **Processing**: External payment processors

## Modernization Recommendations

### 1. React Query Implementation
```javascript
// Cart queries
const useCart = (phoneNumber) => {
  return useQuery({
    queryKey: ['cart', phoneNumber],
    queryFn: () => api.getCart(phoneNumber),
    enabled: !!phoneNumber
  })
}

const useAddToCart = () => {
  return useMutation({
    mutationFn: (data) => api.addToCart(data),
    onSuccess: () => {
      queryClient.invalidateQueries(['cart'])
    }
  })
}
```

### 2. Redux Toolkit State Management
```javascript
const cartSlice = createSlice({
  name: 'cart',
  initialState: {
    items: [],
    phoneNumber: null,
    isLoading: false,
    error: null
  },
  reducers: {
    addItem: (state, action) => {
      state.items.push(action.payload)
    },
    updateItem: (state, action) => {
      const item = state.items.find(i => i.id === action.payload.id)
      if (item) {
        item.quantity = action.payload.quantity
      }
    }
  }
})
```

### 3. Error Boundary Implementation
```javascript
const CartErrorBoundary = ({ children }) => {
  return (
    <ErrorBoundary
      fallback={<CartErrorFallback />}
      onError={(error) => {
        // Log to error tracking service
        console.error('Cart error:', error)
      }}
    >
      {children}
    </ErrorBoundary>
  )
}
```

### 4. Real-time Updates with React Query
```javascript
const useOrderStatus = (orderId) => {
  return useQuery({
    queryKey: ['order', orderId],
    queryFn: () => api.getOrder(orderId),
    refetchInterval: 5000, // Poll every 5 seconds
    enabled: !!orderId
  })
}
```

### 5. Form Handling with React Hook Form
```javascript
const CheckoutForm = () => {
  const { register, handleSubmit, formState: { errors } } = useForm()
  
  const onSubmit = (data) => {
    // Process checkout
  }
  
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('firstName', { required: true })} />
      {errors.firstName && <span>First name is required</span>}
    </form>
  )
}
```
