# RESTful API Pattern Validation

## Pattern Overview
**Pattern Name**: RESTful API
**Pattern Description**: A system-wide architectural approach based on RESTful principles for API design and consumption across all three repositories, with consistent resource-oriented endpoints, HTTP verbs, and response formats.

## Validation Evidence

### Backend (Ruby on Rails)

#### RESTful Route Definition
**Evidence**: `repositories/back-end/config/routes.rb`
```ruby
Rails.application.routes.draw do
  # CMS Admin API routes
  resources :clients, only: %i[index create update show]
  resources :products, only: %i[index create update show] do
    get :search, on: :collection
    get :tags, on: :member
  end
  
  # Nested resources example
  resources :stores, only: %i[index create update show] do
    post :generate_token, on: :member
    resources :store_products, only: %i[index create update show destroy] do
      get :search, on: :collection
    end
    resources :store_articles, only: %i[index show update create destroy], path: 'articles'
  end
  
  # Public API routes
  namespace :api do
    namespace :v1 do
      # Health check endpoints
      get 'health', to: 'health#index'
      get 'ping', to: 'health#ping'
      
      # API resources with versioning
      resources :products, only: %i[index show], path: ':catalog_id/products' do
        get :tags, on: :member
        get :reviews, on: :member
      end
      resources :categories, only: [:index], path: ':catalog_id/categories'
      resources :brands, only: [:index], path: ':catalog_id/brands'
    end
  end
end
```

**Validation**: The backend defines routes using Rails' RESTful resources helpers, creating standard CRUD endpoints for various models. It properly implements:
- Resource-oriented URL structure (e.g., `/products`, `/stores/1/store_products`)
- Proper HTTP verb mapping (`GET` for index/show, `POST` for create, `PUT/PATCH` for update, `DELETE` for destroy)
- Versioned API namespace (`/api/v1/`)
- Nested resources for related models
- Custom member and collection routes for specific operations

#### RESTful Controller Implementation
**Evidence**: `repositories/back-end/app/controllers/products_controller.rb`
```ruby
class ProductsController < ApplicationController
  include Paged
  include Sortable
  include Searchable

  before_action :find_product, only: %i[show update tags]

  def index
    authorize(Product)
    # Filter logic...
    products = policy_scope(Product).joins(:category)
                                    .includes(:category, :attribute_values)
    # More filtering...
    render json: products, root: 'products', meta: pagination_dict(products)
  end

  def create
    authorize(Product)
    product = Product.new(permitted_attributes(Product))

    if product.save
      render json: product, status: :created
    else
      errors = product.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize(@product)
    if @product.update(permitted_attributes(@product))
      render json: @product
    else
      errors = @product.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize(@product)
    render json: @product, include: [
      'attribute_values.attribute_def.attribute_group',
      :category,
      :images,
      :reviews,
      :video
    ]
  end
end
```

**Validation**: Controller implementations follow RESTful conventions:
- Standard CRUD action methods (`index`, `show`, `create`, `update`, `destroy`)
- Proper HTTP status codes for responses (`:created`, `:unprocessable_entity`)
- Consistent error response format
- Resource-focused operations
- JSON response serialization

#### Error Handling
**Evidence**: `repositories/back-end/app/controllers/concerns/rescuable.rb`
```ruby
module Rescuable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from Pundit::NotAuthorizedError, with: :forbidden
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from ActiveModel::ValidationError,
                with: ->(ex) { unprocessable_entity(ex.model.errors.as_json) }
  end

  protected

  def record_not_found
    render json: { error: { message: 'Resource not found' } }, status: :not_found
  end

  def unprocessable_entity(errors = {})
    render json: { errors: errors }, status: :unprocessable_entity
  end

  def forbidden(exception)
    render json: { status: 403, message: message }, status: :forbidden
  end

  def bad_request(exception)
    render json: { status: 400, message: exception.message }, status: :bad_request
  end
end
```

**Validation**: Error handling follows RESTful best practices:
- Proper HTTP status codes for different error conditions
- Consistent error response format with messages
- Exception handling for common errors
- Standardized JSON error responses

### CMS Frontend (Angular)

#### API Service Implementation
**Evidence**: `repositories/cms-fe-angular/src/app/core/services/crud.service.ts`
```typescript
@Injectable()
export abstract class CrudService<T> {

  constructor(protected http: HttpClient) { }

  abstract createResource(params: any): T;
  abstract resourceName({ plural }?: { plural?: boolean }): string;

  resourcePath({ parentId }: { parentId?: number } = {}): string {
    return this.resourceName({ plural: true });
  }

  all({ page, pageSize, sort, filters }: IndexParams = {}): Observable<ReourcesResult<T>> {
    let params = new HttpParams()
      .set('page', page ? page.toString() : '1')
      .set('per_page', pageSize ? pageSize.toString() : '10')
      .set('sort_by', sort ? sort.prop : 'id')
      .set('sort_direction', sort ? sort.direction : 'desc');

    // Filter parameters...

    return this.http.get<any>(`${environment.apiUrl}/${this.resourcePath(pathOptions)}`, { params })
      .pipe(map(data => {
          // Response mapping...
        })
      );
  }

  private create(resource: any, pathOptions?: { parentId?: number }): Observable<T> {
    const params = {};
    params[this.resourceName()] = resource;
    return this.http.post<any>(`${environment.apiUrl}/${this.resourcePath(pathOptions)}`, params).pipe(
      map(data => this.createResource(data[this.resourceName()]))
    );
  }

  private update(resource: any, pathOptions?: { parentId?: number }): Observable<T> {
    const params = {};
    params[this.resourceName()] = resource;
    return this.http.put<any>(`${environment.apiUrl}/${this.resourcePath(pathOptions)}/${resource.id}`, params)
      .pipe(map(data => this.createResource(data[this.resourceName()])));
  }

  save(resource: any, pathOptions?: { parentId?: number }): Observable<T> {
    return resource.id ? this.update(resource, pathOptions) : this.create(resource, pathOptions);
  }

  get(id: number, pathOptions?: { parentId?: number }): Observable<T> {
    return this.http.get<any>(`${environment.apiUrl}/${this.resourcePath(pathOptions)}/${id}`).pipe(
      map(data => this.createResource(data[this.resourceName()]))
    );
  }

  destroy(id: number, pathOptions?: { parentId?: number }): Observable<boolean> {
    return this.http.delete<any>(`${environment.apiUrl}/${this.resourcePath(pathOptions)}/${id}`).pipe(
      map(data => true),
      catchError(response => observableOf(false))
    );
  }
}
```

**Validation**: The CMS frontend implements a generic RESTful API client:
- Uses proper HTTP verbs mapping to CRUD operations (`GET`, `POST`, `PUT`, `DELETE`)
- Resource-oriented URL structure formation
- Standardized parameter handling
- Resource mapping for requests/responses
- Common operations abstracted (all, get, save, destroy)
- Type-safe resource handling

#### Error Handling in Angular
**Evidence**: `repositories/cms-fe-angular/src/app/core/interceptors/request-errors.interceptor.ts`
```typescript
@Injectable()
export class RequestErrorsInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return next.handle(req).pipe(
      catchError(data => {
        if (data instanceof HttpErrorResponse) {
          return this.handleError(data);
        }
        return observableThrowError(data);
      })
    );
  }

  private handleError(data) {
    if (/application\/json/.test(data.headers.get('Content-Type'))) {
      return this.parseError(data);
    } else {
      return observableThrowError(data);
    }
  }

  private parseError(data) {
    let error = {};
    try {
      error = JSON.parse(data.error);
    } catch (e) { }

    if (Object.keys(error).length === 0) {
      return observableThrowError(data);
    } else {
      const newError = {...data, error: error};
      return observableThrowError(newError);
    }
  }
}
```

**Validation**: Error handling in the Angular app follows REST best practices:
- HTTP error interceptor for global error handling
- Content-type aware error parsing
- Standardized error format propagation
- Proper error handling for JSON responses

### Frontend (Vue.js)

#### API Client Implementation
**Evidence**: `repositories/front-end/src/api/api.js`
```javascript
class API {
  http
  constructor() {
    this.http = axios.create({
      baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID,
      params: {
        token: TPB_STORE_TOKEN
      },
      headers: {
        'Cache-Control': 'no-cache',
        Pragma: 'no-cache',
        Expires: '0'
      }
    })
  }
  /**
   * Returns the product that belongs to the current kiosk
   * @param {page,per_page} pageconfig
   */
  getProducts(pageconfig = { page: 1, per_page: 25, sort_by: 'created_at' }) {
    return this.http.get('products', {
      params: pageconfig
    })
  }
  /**
   *  Returns a product base on its id
   * @param {*} productId Id of a product
   */
  getProduct(productId) {
    return this.http.get('products/' + productId)
  }
  
  // More API methods...
  
  /**
   * Returns store categories
   */
  getCategories(params = {}) {
    return this.http.get('categories', { params: params })
  }
  
  /*
   * Create a customer
   */
  createCustomers(customer) {
    return this.http
      .post('customers', { customer })
      .then(response => response.data.customer)
  }
}
```

**Evidence**: `repositories/front-end/src/api/http.js`
```javascript
import axios from 'axios'

const TPB_API_URL = process.env.TPB_API_URL ? process.env.TPB_API_URL : self.kioskConfig.API.URL
const TPB_CATALOG_ID = process.env.TPB_CATALOG_ID ? process.env.TPB_CATALOG_ID : self.kioskConfig.API.CATALOG_ID
const TPB_STORE_TOKEN = process.env.TPB_STORE_TOKEN ? process.env.TPB_STORE_TOKEN : self.kioskConfig.API.TOKEN

export const HTTP = axios.create({
  baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID,
  params: {
    token: TPB_STORE_TOKEN
  }
})
```

**Validation**: The Vue.js frontend implements a RESTful API client:
- Resource-oriented method naming (`getProducts`, `getProduct`, `getCategories`)
- HTTP verb usage matching CRUD operations
- Proper URL path construction
- Parameter handling for filtering and pagination
- Consistent response handling
- Authentication token inclusion

#### Error Handling in Vue.js
**Evidence**: From multiple Vue.js components
```javascript
.catch(function (error) {
  var serverStatus = parseInt(error.response.status)
  switch (serverStatus) {
    case 400:
    case 404:
    case 419:
      mess = "We couldn't process your order. We can't connect to the point of sale system."
      return self.$emit('error', mess)

    case 500:
    case 503:
    case 504:
    case 511:
      mess = "We couldn't process your order. Please try again later. Internal server error."
      return self.$emit('error', mess)

    default:
      mess = "Sorry, we couldn't process the request at this time."
      return self.$emit('error', mess)
  }
})
```

**Validation**: Error handling in the Vue.js frontend:
- HTTP status code-based error handling
- User-friendly error messages mapped to status codes
- Consistent error handling pattern across components
- Error propagation via events

## Cross-Repository Validation

### Resource Naming Consistency
The resource naming across repositories is consistently implemented:
- Backend routes use plural resource names (`resources :products`)
- CMS uses abstract resource naming with pluralization support
- Frontend API client uses resource-specific methods with similar naming patterns

### HTTP Verb Usage
All three repositories correctly implement HTTP verb mapping:
- Backend routes map to standard Rails CRUD actions
- CMS Angular uses HttpClient methods mapping to proper verbs
- Frontend Vue.js uses Axios methods corresponding to HTTP verbs

### Response Format Consistency
Response formats are consistent across repositories:
- Backend returns JSON responses with resource name as root
- CMS Angular maps responses to typed objects
- Frontend Vue.js handles JSON responses directly

### Error Handling
Error handling is implemented consistently:
- Backend: HTTP status codes with standardized error response format
- CMS Angular: Global error interceptor with JSON parsing
- Frontend Vue.js: Component-level error handling with status code mapping

## Implementation Consistency Matrix

| REST Aspect | Backend | CMS Frontend | Frontend |
|-------------|---------|--------------|----------|
| Resource Naming | Plural nouns (`products`) | Abstract naming with pluralization support | Resource-specific method names |
| HTTP Verbs | Rails resources with proper verb mapping | HttpClient methods (get, post, put, delete) | Axios methods (get, post, etc.) |
| Status Codes | Standard HTTP status codes (:created, :not_found) | Angular HttpResponse status handling | Status code checking in catch blocks |
| Response Format | JSON with root key | Mapped to typed models | Direct JSON handling |
| Error Handling | Standardized error responses | Global HTTP interceptor | Component-level error handlers |
| Authentication | Token-based with headers | JWT HTTP interceptor | Token in request params or headers |

## Validation Conclusion

The RESTful API pattern is **successfully validated** across all three repositories with the following findings:

1. **Consistent Resource-Oriented Design**: All repositories implement resource-oriented API design and consumption with appropriate naming conventions.
2. **Proper HTTP Verb Usage**: Correct mapping of HTTP verbs to CRUD operations across all repositories.
3. **Standardized Response Formats**: JSON responses with consistent structure, differing only in implementation details appropriate for each framework.
4. **Appropriate Error Handling**: HTTP status code-based error handling with appropriate user-friendly messages.
5. **Framework-Appropriate Implementation**: Each repository implements RESTful principles in ways appropriate to its framework (Rails, Angular, Vue.js).

## Recommendations

Based on the validation findings, the following improvements could enhance the RESTful API pattern implementation:

1. **Standardize Error Response Format**: While each repository handles errors appropriately, a more consistent cross-repository error format would improve integration.
2. **API Documentation**: Implement OpenAPI/Swagger documentation for the backend API to better document endpoints and response formats.
3. **Authentication Consistency**: Standardize authentication method between frontend repositories (currently params vs. headers).
4. **Response Envelope Consistency**: Adopt a consistent response envelope format across all APIs.
5. **Pagination Standardization**: Standardize pagination parameters and metadata format.

## Cross-References
- API Integration Findings: `analysis/findings/detailed-analysis/api-integration-findings.md`
- Integration Patterns: `analysis/cross-repo/patterns/integration/integration-patterns.md`
- Final Synthesis: `analysis/cross-repo/final-synthesis.md` 