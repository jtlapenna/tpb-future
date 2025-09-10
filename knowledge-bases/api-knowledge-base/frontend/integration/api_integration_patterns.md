---
title: API Integration Patterns
description: Documentation of API integration patterns in The Peak Beyond's frontend applications
last_updated: 2023-08-01
contributors: [AI Assistant]
---

# API Integration Patterns

## Overview

This document outlines the API integration patterns used in The Peak Beyond's frontend applications (Kiosk UI and CMS). It describes how the frontend communicates with the backend API, handles authentication, manages data fetching, and implements real-time updates.

*Note: This document is based on system documentation and will be refined once we have access to the frontend codebase.*

## API Client Architecture

The frontend applications likely implement a service-based API client architecture using Angular's HttpClient:

```typescript
// Example API service structure
@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = environment.apiUrl;
  
  constructor(private http: HttpClient) {}
  
  get<T>(endpoint: string, params?: HttpParams): Observable<T> {
    return this.http.get<T>(`${this.baseUrl}/${endpoint}`, { params });
  }
  
  post<T>(endpoint: string, data: any): Observable<T> {
    return this.http.post<T>(`${this.baseUrl}/${endpoint}`, data);
  }
  
  put<T>(endpoint: string, data: any): Observable<T> {
    return this.http.put<T>(`${this.baseUrl}/${endpoint}`, data);
  }
  
  delete<T>(endpoint: string): Observable<T> {
    return this.http.delete<T>(`${this.baseUrl}/${endpoint}`);
  }
}
```

This base service is then extended by domain-specific services:

```typescript
// Example domain-specific service
@Injectable({
  providedIn: 'root'
})
export class ProductService {
  constructor(private api: ApiService) {}
  
  getProducts(categoryId?: number): Observable<Product[]> {
    const params = categoryId ? new HttpParams().set('category_id', categoryId.toString()) : undefined;
    return this.api.get<Product[]>('store_products', params);
  }
  
  getProduct(id: number): Observable<Product> {
    return this.api.get<Product>(`store_products/${id}`);
  }
  
  // Additional methods...
}
```

## Authentication Integration

### JWT Authentication (CMS)

The CMS application uses JWT authentication to secure API requests:

```typescript
// Example authentication service
@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private tokenKey = 'auth_token';
  
  constructor(private api: ApiService) {}
  
  login(email: string, password: string): Observable<AuthResponse> {
    return this.api.post<AuthResponse>('user_token', { auth: { email, password } })
      .pipe(
        tap(response => this.setToken(response.jwt))
      );
  }
  
  logout(): void {
    localStorage.removeItem(this.tokenKey);
  }
  
  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }
  
  setToken(token: string): void {
    localStorage.setItem(this.tokenKey, token);
  }
  
  isAuthenticated(): boolean {
    return !!this.getToken();
  }
}
```

An HTTP interceptor adds the JWT token to outgoing requests:

```typescript
// Example auth interceptor
@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  constructor(private authService: AuthService) {}
  
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = this.authService.getToken();
    
    if (token) {
      const authReq = req.clone({
        headers: req.headers.set('Authorization', `Bearer ${token}`)
      });
      return next.handle(authReq);
    }
    
    return next.handle(req);
  }
}
```

### Catalog Token Authentication (Kiosk UI)

The Kiosk UI uses catalog token authentication:

```typescript
// Example kiosk service
@Injectable({
  providedIn: 'root'
})
export class KioskService {
  private catalogId: string | null = null;
  private catalogToken: string | null = null;
  
  constructor(private api: ApiService) {}
  
  initialize(catalogId: string, catalogToken: string): void {
    this.catalogId = catalogId;
    this.catalogToken = catalogToken;
  }
  
  getCatalogId(): string | null {
    return this.catalogId;
  }
  
  getCatalogToken(): string | null {
    return this.catalogToken;
  }
  
  buildUrl(endpoint: string): string {
    return `api/v1/${this.catalogId}/${endpoint}`;
  }
  
  getProducts(categoryId?: number): Observable<Product[]> {
    const params = new HttpParams()
      .set('token', this.catalogToken || '')
      .set('category_id', categoryId?.toString() || '');
    
    return this.api.get<Product[]>(this.buildUrl('store_products'), params);
  }
  
  // Additional methods...
}
```

## Request Patterns

### Resource Fetching

The applications use standard patterns for fetching resources:

```typescript
// Example component using a service
@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html'
})
export class ProductListComponent implements OnInit {
  products: Product[] = [];
  loading = false;
  error: string | null = null;
  
  constructor(private productService: ProductService) {}
  
  ngOnInit(): void {
    this.loadProducts();
  }
  
  loadProducts(categoryId?: number): void {
    this.loading = true;
    this.error = null;
    
    this.productService.getProducts(categoryId)
      .pipe(
        finalize(() => this.loading = false)
      )
      .subscribe(
        products => this.products = products,
        error => this.error = 'Failed to load products'
      );
  }
}
```

### Pagination

For paginated resources, the applications implement pagination handling:

```typescript
// Example paginated request
getProducts(page = 1, perPage = 20, categoryId?: number): Observable<PaginatedResponse<Product>> {
  const params = new HttpParams()
    .set('page', page.toString())
    .set('per_page', perPage.toString());
    
  if (categoryId) {
    params = params.set('category_id', categoryId.toString());
  }
  
  return this.api.get<PaginatedResponse<Product>>('store_products', params);
}
```

### Filtering and Sorting

The applications support filtering and sorting through query parameters:

```typescript
// Example filtering and sorting
getProducts(filters?: ProductFilters, sort?: SortOption): Observable<Product[]> {
  let params = new HttpParams();
  
  if (filters) {
    if (filters.categoryId) {
      params = params.set('category_id', filters.categoryId.toString());
    }
    if (filters.brandId) {
      params = params.set('brand_id', filters.brandId.toString());
    }
    if (filters.tags && filters.tags.length) {
      params = params.set('tags', filters.tags.join(','));
    }
    // Additional filters...
  }
  
  if (sort) {
    params = params.set('sort_by', sort.field);
    params = params.set('sort_direction', sort.direction);
  }
  
  return this.api.get<Product[]>('store_products', params);
}
```

## Response Handling

### Data Transformation

The applications transform API responses into application models:

```typescript
// Example model interface
interface Product {
  id: number;
  name: string;
  description: string;
  price: number;
  stock: number;
  images: Image[];
  attributes: Attribute[];
  // Additional properties...
}

// Example transformation
getProduct(id: number): Observable<Product> {
  return this.api.get<ApiProduct>(`store_products/${id}`)
    .pipe(
      map(apiProduct => this.transformProduct(apiProduct))
    );
}

private transformProduct(apiProduct: ApiProduct): Product {
  return {
    id: apiProduct.id,
    name: apiProduct.name,
    description: apiProduct.description,
    price: parseFloat(apiProduct.price),
    stock: parseInt(apiProduct.stock, 10),
    images: apiProduct.images.map(img => this.transformImage(img)),
    attributes: apiProduct.attribute_values.map(attr => this.transformAttribute(attr)),
    // Additional transformations...
  };
}
```

### Error Handling

The applications implement centralized error handling:

```typescript
// Example error interceptor
@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  constructor(private errorService: ErrorService) {}
  
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return next.handle(req).pipe(
      catchError(error => {
        if (error instanceof HttpErrorResponse) {
          if (error.status === 401) {
            // Handle unauthorized
            this.errorService.handleUnauthorized();
          } else if (error.status === 403) {
            // Handle forbidden
            this.errorService.handleForbidden();
          } else if (error.status === 404) {
            // Handle not found
            this.errorService.handleNotFound();
          } else {
            // Handle other errors
            this.errorService.handleError(error);
          }
        }
        
        return throwError(error);
      })
    );
  }
}
```

### Loading States

The applications manage loading states for API requests:

```typescript
// Example loading state management
@Component({
  selector: 'app-product-detail',
  templateUrl: './product-detail.component.html'
})
export class ProductDetailComponent implements OnInit {
  product: Product | null = null;
  loading = false;
  error: string | null = null;
  
  constructor(
    private route: ActivatedRoute,
    private productService: ProductService
  ) {}
  
  ngOnInit(): void {
    this.route.params.subscribe(params => {
      const productId = +params['id'];
      this.loadProduct(productId);
    });
  }
  
  loadProduct(id: number): void {
    this.loading = true;
    this.error = null;
    
    this.productService.getProduct(id)
      .pipe(
        finalize(() => this.loading = false)
      )
      .subscribe(
        product => this.product = product,
        error => this.error = 'Failed to load product'
      );
  }
}
```

## Real-Time Integration

### Pusher Integration

The applications integrate with Pusher for real-time updates:

```typescript
// Example Pusher service
@Injectable({
  providedIn: 'root'
})
export class PusherService {
  private pusher: Pusher;
  private channels: { [key: string]: Channel } = {};
  
  constructor() {
    this.pusher = new Pusher(environment.pusher.key, {
      cluster: environment.pusher.cluster,
      encrypted: true
    });
  }
  
  getChannel(channelName: string): Channel {
    if (!this.channels[channelName]) {
      this.channels[channelName] = this.pusher.subscribe(channelName);
    }
    
    return this.channels[channelName];
  }
  
  unsubscribe(channelName: string): void {
    if (this.channels[channelName]) {
      this.pusher.unsubscribe(channelName);
      delete this.channels[channelName];
    }
  }
  
  disconnect(): void {
    this.pusher.disconnect();
    this.channels = {};
  }
}
```

### Event Handling

The applications handle real-time events:

```typescript
// Example real-time product updates
@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html'
})
export class ProductListComponent implements OnInit, OnDestroy {
  products: Product[] = [];
  private channelName: string;
  
  constructor(
    private productService: ProductService,
    private pusherService: PusherService,
    private kioskService: KioskService
  ) {
    this.channelName = `store_products_${this.kioskService.getStoreId()}`;
  }
  
  ngOnInit(): void {
    this.loadProducts();
    this.subscribeToUpdates();
  }
  
  ngOnDestroy(): void {
    this.pusherService.unsubscribe(this.channelName);
  }
  
  private subscribeToUpdates(): void {
    const channel = this.pusherService.getChannel(this.channelName);
    
    channel.bind('product_updated', (data: any) => {
      this.handleProductUpdate(data);
    });
    
    channel.bind('product_destroyed', (data: any) => {
      this.handleProductDelete(data);
    });
  }
  
  private handleProductUpdate(data: any): void {
    const updatedProduct = data.product;
    const index = this.products.findIndex(p => p.id === updatedProduct.id);
    
    if (index !== -1) {
      this.products[index] = this.productService.transformProduct(updatedProduct);
    }
  }
  
  private handleProductDelete(data: any): void {
    const deletedProductId = data.product.id;
    this.products = this.products.filter(p => p.id !== deletedProductId);
  }
  
  // Additional methods...
}
```

## Caching Strategies

### In-Memory Caching

The applications implement in-memory caching for frequently accessed data:

```typescript
// Example caching service
@Injectable({
  providedIn: 'root'
})
export class CacheService {
  private cache: { [key: string]: CacheEntry } = {};
  
  get<T>(key: string): T | null {
    const entry = this.cache[key];
    
    if (!entry) {
      return null;
    }
    
    if (this.isExpired(entry)) {
      this.remove(key);
      return null;
    }
    
    return entry.value as T;
  }
  
  set<T>(key: string, value: T, ttl: number = 5 * 60 * 1000): void {
    this.cache[key] = {
      value,
      expiry: Date.now() + ttl
    };
  }
  
  remove(key: string): void {
    delete this.cache[key];
  }
  
  clear(): void {
    this.cache = {};
  }
  
  private isExpired(entry: CacheEntry): boolean {
    return entry.expiry < Date.now();
  }
}

interface CacheEntry {
  value: any;
  expiry: number;
}
```

### Cached API Requests

The applications use caching for API requests:

```typescript
// Example cached API service
@Injectable({
  providedIn: 'root'
})
export class ProductService {
  constructor(
    private api: ApiService,
    private cache: CacheService
  ) {}
  
  getProducts(categoryId?: number): Observable<Product[]> {
    const cacheKey = `products_${categoryId || 'all'}`;
    const cachedProducts = this.cache.get<Product[]>(cacheKey);
    
    if (cachedProducts) {
      return of(cachedProducts);
    }
    
    const params = categoryId ? new HttpParams().set('category_id', categoryId.toString()) : undefined;
    
    return this.api.get<Product[]>('store_products', params)
      .pipe(
        tap(products => this.cache.set(cacheKey, products))
      );
  }
  
  // Additional methods...
}
```

## API Integration Patterns by Feature

### Product Catalog Integration

The product catalog integration follows these patterns:

1. **Category Navigation**: Fetch categories, then fetch products by category
2. **Product Listing**: Paginated product fetching with filtering and sorting
3. **Product Details**: Fetch detailed product information by ID
4. **Real-Time Updates**: Subscribe to product updates via Pusher

### Cart and Checkout Integration

The cart and checkout integration follows these patterns:

1. **Cart Management**: Client-side cart management with local storage
2. **Inventory Validation**: Validate inventory before checkout
3. **Order Submission**: Submit order to backend API
4. **Order Confirmation**: Receive and display order confirmation

### User Authentication Integration

The user authentication integration follows these patterns:

1. **Login**: Submit credentials and receive JWT token
2. **Token Storage**: Store token securely in local storage
3. **Token Inclusion**: Include token in API requests
4. **Token Expiration**: Handle token expiration and redirect to login

## Next Steps

To complete the API integration documentation, we need to:

1. **Obtain Frontend Codebase Access**: To verify the actual implementation of these patterns
2. **Analyze API Services**: Document the actual API service implementations
3. **Document Error Handling**: Document the error handling strategies in detail
4. **Map API Endpoints**: Create a comprehensive map of API endpoints used by the frontend

## Changelog

| Date | Author | Description |
|------|--------|-------------|
| 2023-08-01 | AI Assistant | Initial API integration patterns documentation based on system overview | 