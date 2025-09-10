---
title: State Management Approach
description: Documentation of the state management approach in The Peak Beyond's frontend applications
last_updated: 2023-08-01
contributors: [AI Assistant]
---

# State Management Approach

## Overview

This document outlines the state management approach used in The Peak Beyond's frontend applications (Kiosk UI and CMS). It describes how the applications manage state, handle data flow, and maintain consistency across components.

*Note: This document is based on system documentation and will be refined once we have access to the frontend codebase.*

## State Management Architecture

The frontend applications likely use NgRx for state management, following the Redux pattern. This provides a predictable state container with a unidirectional data flow.

### Core Concepts

1. **Store**: A single source of truth for application state
2. **Actions**: Events that describe state changes
3. **Reducers**: Pure functions that specify how state changes in response to actions
4. **Selectors**: Functions that extract specific pieces of state
5. **Effects**: Handle side effects like API calls

### State Structure

The application state is likely organized into feature slices:

```typescript
// Example state interface
interface AppState {
  auth: AuthState;
  products: ProductsState;
  categories: CategoriesState;
  cart: CartState;
  orders: OrdersState;
  ui: UiState;
}

interface AuthState {
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
}

interface ProductsState {
  entities: { [id: number]: Product };
  ids: number[];
  selectedProductId: number | null;
  loading: boolean;
  error: string | null;
}

// Additional state interfaces...
```

## State Management Implementation

### Store Configuration

The store is configured at the application level:

```typescript
// Example store configuration
@NgModule({
  imports: [
    StoreModule.forRoot(reducers, {
      metaReducers,
      runtimeChecks: {
        strictStateImmutability: true,
        strictActionImmutability: true
      }
    }),
    EffectsModule.forRoot([AuthEffects, ProductEffects, CartEffects]),
    StoreDevtoolsModule.instrument({
      maxAge: 25,
      logOnly: environment.production
    })
  ],
  // ...
})
export class AppModule { }
```

### Actions

Actions are defined using NgRx's createAction function:

```typescript
// Example actions
export const loadProducts = createAction('[Products] Load Products');
export const loadProductsSuccess = createAction(
  '[Products] Load Products Success',
  props<{ products: Product[] }>()
);
export const loadProductsFailure = createAction(
  '[Products] Load Products Failure',
  props<{ error: string }>()
);

export const selectProduct = createAction(
  '[Products] Select Product',
  props<{ productId: number }>()
);

// Additional actions...
```

### Reducers

Reducers handle state changes in response to actions:

```typescript
// Example reducer
const initialState: ProductsState = {
  entities: {},
  ids: [],
  selectedProductId: null,
  loading: false,
  error: null
};

export const productsReducer = createReducer(
  initialState,
  on(loadProducts, state => ({
    ...state,
    loading: true,
    error: null
  })),
  on(loadProductsSuccess, (state, { products }) => {
    const entities = products.reduce((acc, product) => ({
      ...acc,
      [product.id]: product
    }), {});
    
    return {
      ...state,
      entities,
      ids: products.map(product => product.id),
      loading: false
    };
  }),
  on(loadProductsFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),
  on(selectProduct, (state, { productId }) => ({
    ...state,
    selectedProductId: productId
  }))
);
```

### Selectors

Selectors extract specific pieces of state:

```typescript
// Example selectors
export const selectProductsState = createFeatureSelector<ProductsState>('products');

export const selectProductEntities = createSelector(
  selectProductsState,
  state => state.entities
);

export const selectProductIds = createSelector(
  selectProductsState,
  state => state.ids
);

export const selectAllProducts = createSelector(
  selectProductEntities,
  selectProductIds,
  (entities, ids) => ids.map(id => entities[id])
);

export const selectProductsLoading = createSelector(
  selectProductsState,
  state => state.loading
);

export const selectProductsError = createSelector(
  selectProductsState,
  state => state.error
);

export const selectSelectedProductId = createSelector(
  selectProductsState,
  state => state.selectedProductId
);

export const selectSelectedProduct = createSelector(
  selectProductEntities,
  selectSelectedProductId,
  (entities, selectedId) => selectedId ? entities[selectedId] : null
);
```

### Effects

Effects handle side effects like API calls:

```typescript
// Example effects
@Injectable()
export class ProductEffects {
  loadProducts$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loadProducts),
      switchMap(() =>
        this.productService.getProducts().pipe(
          map(products => loadProductsSuccess({ products })),
          catchError(error => of(loadProductsFailure({ error: error.message })))
        )
      )
    )
  );
  
  constructor(
    private actions$: Actions,
    private productService: ProductService
  ) {}
}
```

## State Management Patterns

### Component Integration

Components interact with the store using the Store service:

```typescript
// Example component
@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html'
})
export class ProductListComponent implements OnInit {
  products$: Observable<Product[]>;
  loading$: Observable<boolean>;
  error$: Observable<string | null>;
  
  constructor(private store: Store<AppState>) {
    this.products$ = this.store.select(selectAllProducts);
    this.loading$ = this.store.select(selectProductsLoading);
    this.error$ = this.store.select(selectProductsError);
  }
  
  ngOnInit(): void {
    this.store.dispatch(loadProducts());
  }
  
  selectProduct(productId: number): void {
    this.store.dispatch(selectProduct({ productId }));
  }
}
```

### Container/Presentational Pattern

The applications likely follow the container/presentational pattern:

```typescript
// Example container component
@Component({
  selector: 'app-product-list-container',
  template: `
    <app-product-list
      [products]="products$ | async"
      [loading]="loading$ | async"
      [error]="error$ | async"
      (selectProduct)="onSelectProduct($event)"
    ></app-product-list>
  `
})
export class ProductListContainerComponent implements OnInit {
  products$: Observable<Product[]>;
  loading$: Observable<boolean>;
  error$: Observable<string | null>;
  
  constructor(private store: Store<AppState>) {
    this.products$ = this.store.select(selectAllProducts);
    this.loading$ = this.store.select(selectProductsLoading);
    this.error$ = this.store.select(selectProductsError);
  }
  
  ngOnInit(): void {
    this.store.dispatch(loadProducts());
  }
  
  onSelectProduct(productId: number): void {
    this.store.dispatch(selectProduct({ productId }));
  }
}

// Example presentational component
@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html'
})
export class ProductListComponent {
  @Input() products: Product[] | null = null;
  @Input() loading: boolean | null = false;
  @Input() error: string | null = null;
  @Output() selectProduct = new EventEmitter<number>();
  
  onSelectProduct(productId: number): void {
    this.selectProduct.emit(productId);
  }
}
```

### Entity Adapter Pattern

The applications likely use NgRx Entity for managing collections:

```typescript
// Example entity adapter
export const productsAdapter = createEntityAdapter<Product>({
  selectId: product => product.id,
  sortComparer: (a, b) => a.name.localeCompare(b.name)
});

export const initialState: ProductsState = productsAdapter.getInitialState({
  selectedProductId: null,
  loading: false,
  error: null
});

export const productsReducer = createReducer(
  initialState,
  on(loadProducts, state => ({
    ...state,
    loading: true,
    error: null
  })),
  on(loadProductsSuccess, (state, { products }) =>
    productsAdapter.setAll(products, {
      ...state,
      loading: false
    })
  ),
  on(loadProductsFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),
  on(selectProduct, (state, { productId }) => ({
    ...state,
    selectedProductId: productId
  }))
);

// Entity adapter selectors
export const {
  selectIds,
  selectEntities,
  selectAll,
  selectTotal
} = productsAdapter.getSelectors(selectProductsState);
```

## State Management by Feature

### Authentication State

The authentication state manages user authentication:

```typescript
// Example authentication state
interface AuthState {
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
}

// Example authentication actions
export const login = createAction(
  '[Auth] Login',
  props<{ credentials: Credentials }>()
);
export const loginSuccess = createAction(
  '[Auth] Login Success',
  props<{ user: User; token: string }>()
);
export const loginFailure = createAction(
  '[Auth] Login Failure',
  props<{ error: string }>()
);
export const logout = createAction('[Auth] Logout');
```

### Product Catalog State

The product catalog state manages products and categories:

```typescript
// Example product catalog state
interface ProductsState {
  entities: { [id: number]: Product };
  ids: number[];
  selectedProductId: number | null;
  loading: boolean;
  error: string | null;
}

interface CategoriesState {
  entities: { [id: number]: Category };
  ids: number[];
  selectedCategoryId: number | null;
  loading: boolean;
  error: string | null;
}
```

### Cart State

The cart state manages the shopping cart:

```typescript
// Example cart state
interface CartState {
  items: CartItem[];
  total: number;
  loading: boolean;
  error: string | null;
}

// Example cart actions
export const addToCart = createAction(
  '[Cart] Add Item',
  props<{ product: Product; quantity: number }>()
);
export const removeFromCart = createAction(
  '[Cart] Remove Item',
  props<{ productId: number }>()
);
export const updateCartItemQuantity = createAction(
  '[Cart] Update Item Quantity',
  props<{ productId: number; quantity: number }>()
);
export const clearCart = createAction('[Cart] Clear Cart');
```

### UI State

The UI state manages UI-specific state:

```typescript
// Example UI state
interface UiState {
  sidebarOpen: boolean;
  activeModal: string | null;
  theme: 'light' | 'dark';
  notifications: Notification[];
}

// Example UI actions
export const toggleSidebar = createAction('[UI] Toggle Sidebar');
export const openModal = createAction(
  '[UI] Open Modal',
  props<{ modalId: string }>()
);
export const closeModal = createAction('[UI] Close Modal');
export const setTheme = createAction(
  '[UI] Set Theme',
  props<{ theme: 'light' | 'dark' }>()
);
export const addNotification = createAction(
  '[UI] Add Notification',
  props<{ notification: Notification }>()
);
export const removeNotification = createAction(
  '[UI] Remove Notification',
  props<{ id: string }>()
);
```

## Real-Time State Updates

The applications handle real-time updates through effects:

```typescript
// Example real-time update effect
@Injectable()
export class ProductEffects {
  // ... other effects
  
  realTimeUpdates$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initializeRealTimeUpdates),
      switchMap(() =>
        this.pusherService.getChannel('store_products').pipe(
          mergeMap(channel => {
            const productUpdated$ = fromEvent(channel, 'product_updated').pipe(
              map((data: any) => updateProductSuccess({ product: data.product }))
            );
            
            const productDeleted$ = fromEvent(channel, 'product_destroyed').pipe(
              map((data: any) => deleteProductSuccess({ productId: data.product.id }))
            );
            
            return merge(productUpdated$, productDeleted$);
          })
        )
      )
    )
  );
}
```

## State Persistence

The applications likely persist certain parts of the state:

```typescript
// Example meta-reducer for state persistence
export function localStorageSyncReducer(reducer: ActionReducer<AppState>): ActionReducer<AppState> {
  return localStorageSync({
    keys: ['auth', 'cart', 'ui'],
    rehydrate: true
  })(reducer);
}

export const metaReducers: MetaReducer<AppState>[] = [
  localStorageSyncReducer
];
```

## Performance Considerations

1. **Memoized Selectors**: Use createSelector for memoization to prevent unnecessary recalculations
2. **OnPush Change Detection**: Use OnPush change detection with observables for better performance
3. **Entity Adapter**: Use NgRx Entity for efficient collection management
4. **Lazy Loading**: Lazy load feature modules with their own state
5. **Debouncing Actions**: Debounce frequent actions to reduce state updates

## Next Steps

To complete the state management documentation, we need to:

1. **Obtain Frontend Codebase Access**: To verify the actual implementation of state management
2. **Analyze Store Structure**: Document the actual store structure
3. **Document Actions and Reducers**: Document the actual actions and reducers
4. **Map State to Components**: Document how components interact with the store

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-01 | AI Assistant | Initial state management documentation based on system overview | 