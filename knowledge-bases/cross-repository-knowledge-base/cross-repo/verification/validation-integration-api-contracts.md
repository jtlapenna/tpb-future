# API Contracts Integration Validation

## Overview
This validation document examines the API contracts used across the backend (Ruby on Rails), frontend (Vue.js), and CMS frontend (Angular) repositories. API contracts serve as the primary integration point between these repositories, defining how data is exchanged and ensuring consistent communication.

## Validation Approach
1. Identify API documentation and specification mechanisms
2. Analyze API endpoint definitions in the backend
3. Examine API client implementations in frontends
4. Validate consistency and contract adherence across repositories

## Validation Evidence

### Backend (Ruby on Rails)

#### API Documentation

The backend uses OpenAPI (Swagger) for API documentation:

1. **OpenAPI Configuration** (`repositories/back-end/docs/configurations/api/open_api.yml`):
   ```yaml
   swagger: '2.0'
   info:
     title: PeakBeyondApi
     description: Peak beyond api documentation
     contact:
   ```

#### Contract Validation

The backend implements contract validation through a combination of Dry::Validation contracts and controller-level validations:

1. **Cart Contract** (`repositories/back-end/app/contracts/cart_contract.rb`):
   ```ruby
   class CartContract < Dry::Validation::Contract
     config.messages.backend = :i18n
     config.messages.namespace = :cart
   
     option :store
   
     params do
       required(:cart).hash do
         required(:items).array(:hash) do
           required(:product_id).filled(:integer)
           required(:quantity).filled(:integer, gt?: 0)
         end
       end
     end
   
     rule(:cart) do
       category_info = category_info(value[:items])
   
       limit_status = purchase_limits.map do |purchase_limit|
         state = {
           name: purchase_limit.name,
           max: purchase_limit.limit
         }
   
         weights = purchase_limit.store_category_ids.map { |category| category_info[category][:weight] }
         products = purchase_limit.store_category_ids.map { |category| category_info[category][:products] }
   
         state[:actual] = weights.sum
         state[:products] = products.flatten.sort
         state
       end
   
       purchase_limits_exceeded = limit_status.select { |state| state[:max] < state[:actual] }
   
       if purchase_limits_exceeded.present?
         key.failure(text: :purchase_limit, code: :purchase_limit, limits: purchase_limits_exceeded)
       end
     end
   ```

2. **Contract Usage in Controllers** (`repositories/back-end/app/controllers/api/v1/carts_controller.rb`):
   ```ruby
   def validate
     result = CartContract.new(store: store).call(cart: cart_params)
     
     json = response_api(result)
     
     render json: json, status: :ok
   end
   ```

3. **Standardized Error Response Format** (`repositories/back-end/app/controllers/api/v1/carts_controller.rb`):
   ```ruby
   def response_api(result)
     return { success: true } if result.success?
   
     messages = result.errors.messages.map do |message|
       path = message.path.join('.')
   
       { path: path, message: message.text }.merge(message.meta)
     end
   
     errors = messages.group_by { |e| e[:path] }.each { |_, v| v.each { |message| message.delete(:path) } }
   
     {
       success: false,
       message: result.errors.messages.first.text,
       errors: errors
     }
   end
   ```

#### API Serializers

The backend uses ActiveModel::Serializer to standardize JSON response formats:

1. **Kiosk Serializer** (`repositories/back-end/app/serializers/api/v1/kiosk_serializer.rb`):
   ```ruby
   module Api
     module V1
       class KioskSerializer < ActiveModel::Serializer
         has_many :ad_configs, serializer: AdConfigSerializer
   
         attribute :notifications_send_to_customer, key: :notify_to_customer do
           object.store.notifications_send_to_customer
         end
   
         attribute :notifications_enabled, key: :notify_by_email do
           object.store.notifications_enabled
         end
   
         attribute :api_type do
           object.store.api_type
         end
   
         attributes :sensor_method, :sensor_threshold, :location, :tag_list
   
         has_one :layout, serializer: Api::V1::KioskLayoutSerializer
       end
     end
   end
   ```

2. **Store Serializer** (`repositories/back-end/app/serializers/store_serializer.rb`):
   ```ruby
   class StoreSerializer < ActiveModel::Serializer
     attributes :id, :name, :current_sync_id, :featured_mode, :enabled_share_email_product, :block_simultaneous_nfc,
                :enabled_share_sms_product, :enabled_continuous_cart
   
     has_one :logo
     belongs_to :client
     has_one :settings
     has_many :store_taxes
   
     # Api Integration
     attribute :api_type, if: -> { scope && scope.admin? }
     attribute :api_client_id, if: -> { scope && scope.admin? }
     attribute :api_key, if: -> { scope && scope.admin? }
     # ...additional attributes...
   end
   ```

#### API Routes and Versioning

The backend implements versioned API routes with a standard format:

1. **API Controller Namespace** (`repositories/back-end/app/controllers/api/v1/application_controller.rb`):
   ```ruby
   class Api::V1::ApplicationController < ActionController::API
     include Knock::Authenticable
     include Rescuable
     before_action :render_error_when_invalid_auth_token, :except => [:ping]
     before_action :authenticate_store, :except => [:ping]
     
     def ping
       output = {'pong' => Time.now}.to_json
       render :json => output
     end
   ```

2. **Health Check Endpoints** (`repositories/back-end/app/controllers/api/v1/health_controller.rb`):
   ```ruby
   module Api
     module V1
       class HealthController < ApplicationController
         def index
           render json: { status: 'ok', timestamp: Time.current }
         end
   
         def ping
           render json: { message: 'pong' }
         end
       end
     end
   end
   ```

### Frontend (Vue.js)

#### API Client Implementation

The Vue.js frontend implements a centralized API client for interacting with the backend:

1. **API Configuration** (`repositories/front-end/src/api/http.js`):
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

2. **API Class Definition** (`repositories/front-end/src/api/api.js`):
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
   ```

3. **Resource-Specific API Classes** (`repositories/front-end/src/api/articles/ArticlesRemote.js`):
   ```javascript
   import HTTP from '../http'
   
   export class ArticlesRemote {
     /**
      * Returns store articles
      * @param {minimal:boolean} params of the request
      */
     index (params = {minimal: true}) {
       return HTTP.get('articles', {params: params})
     }
   }
   ```

#### API Request and Response Handling

The Vue.js frontend handles API responses in a consistent manner:

1. **API Method Implementations** (`repositories/front-end/src/api/api.js`):
   ```javascript
   /**
    * Returns remote kiosk settings
    */
   getSettings() {
     return this.http.get('settings').then(response => response.data)
   }
   
   /*
    * Create a customer
    */
   createCustomers(customer) {
     return this.http
       .post('customers', { customer })
       .then(response => response.data.customer)
   }
   ```

### CMS Frontend (Angular)

#### API Service Implementation

The Angular CMS implements a structured approach to API interactions with a base CRUD service:

1. **CRUD Service Base Class** (`repositories/cms-fe-angular/src/app/core/services/crud.service.ts`):
   ```typescript
   @Injectable()
   export abstract class CrudService<T> {
     all({ page, pageSize, sort, filters }: IndexParams = {}, pathOptions?: { parentId?: number, overrideResourceName?: string }): Observable<ReourcesResult<T>> {
       let params = new HttpParams()
         .set('page', page ? page.toString() : '1')
         .set('per_page', pageSize ? pageSize.toString() : '10')
         .set('sort_by', sort ? sort.prop : 'id')
         .set('sort_direction', sort ? sort.direction : 'desc');
   
       for (const key in filters) {
         if (filters.hasOwnProperty(key)) {
           params = params.set(key, filters[key]);
         }
       }
   
       return this.http.get<any>(`${environment.apiUrl}/${this.resourcePath(pathOptions)}`, { params })
         .pipe(
           map(data => {
             const pagination = new Pagination(data.meta);
             if (pageSize) {
               pagination.pageSize = pageSize;
             }
             return {
               pagination,
               resources: data[pathOptions && pathOptions.overrideResourceName ? pathOptions.overrideResourceName : this.resourceName({ plural: true })].map(c => this.createResource(c))
             } as ReourcesResult<T>;
           })
         );
     }
   ```

2. **Resource-Specific Services** (`repositories/cms-fe-angular/src/app/clients/services/client.service.ts`):
   ```typescript
   @Injectable()
   export class ClientService extends CrudService<Client> {
     createResource(params: any): Client {
       return new Client(params);
     }
   
     resourceName({plural}: {plural?: boolean} = {}): string {
       return plural ? 'clients' : 'client';
     }
   }
   ```

3. **Specialized Services** (`repositories/cms-fe-angular/src/app/core/services/assets.service.ts`):
   ```typescript
   @Injectable()
   export class AssetsService {
     constructor(private http: HttpClient) {}
   
     authorizeAsset(resource: string, name: string): Observable<S3UrlData> {
       const params = new HttpParams()
         .set('resource', resource)
         .set('resource_name', name);
   
       return this.http.get<any>(`${environment.apiUrl}/assets/upload_request`, { params }).pipe(
         map(data => data.url_data),
         map(data => ({ uploadUrl: data.upload_url, publicUrl: data.public_url }))
       );
     }
   
     destroy(id: number, resource_type: string) {
       const params = new HttpParams()
         .set('resource_type', resource_type);
       return this.http.delete<any>(`${environment.apiUrl}/assets/${id}`, { params });
     }
   }
   ```

#### Response Handling

The Angular CMS handles API responses by mapping them to model classes:

1. **Article Service** (`repositories/cms-fe-angular/src/app/articles/services/article.service.ts`):
   ```typescript
   @Injectable({
     providedIn: 'root'
   })
   export class ArticleService extends CrudService<Article> {
     createResource(params: any): Article {
       return params as Article;
     }
   
     resourceName({plural}: {plural?: boolean} = {}): string {
       return plural ? 'articles' : 'article';
     }
   }
   ```

## Cross-Repository Validation

### API Contract Consistency

The API contracts across repositories demonstrate consistency in several key areas:

1. **URI Structure**:
   - Backend: Namespaced under `/api/v1/`
   - Vue.js: Uses consistent endpoint paths (`TPB_API_URL + '/' + TPB_CATALOG_ID`)
   - Angular: Uses environment-specific API URL (`${environment.apiUrl}/${this.resourcePath()}`)

2. **Authentication Approach**:
   - Backend: Token-based authentication with JWT
   - Vue.js: Token passed as query parameter
   - Angular: Token handled by HTTP interceptors

3. **Resource Representation**:
   - Backend: Uses ActiveModel::Serializer for consistent JSON structure
   - Vue.js: Direct consumption of API response with minimal transformation
   - Angular: Maps JSON to model classes via `createResource` method

4. **Error Handling**:
   - Backend: Standardized error response format with detailed validation messages
   - Vue.js: Promise-based error handling
   - Angular: RxJS-based error handling with Observable patterns

### API Design Patterns

The repositories implement several consistent API design patterns:

1. **RESTful Resource Modeling**:
   - Resources follow standard CRUD operations
   - Resource names are consistent across repositories
   - Plural nouns for collections, singular for individual resources

2. **Pagination Approach**:
   - Consistent pagination parameters (`page`, `per_page`)
   - Metadata included in response for pagination controls

3. **Query Parameter Conventions**:
   - Filtering via query parameters
   - Sorting via `sort_by` and `sort_direction` parameters

4. **HTTP Method Usage**:
   - GET for retrieval
   - POST for creation
   - PUT for updates
   - DELETE for removal

### Contract Evolution

The API contracts show evidence of evolution over time:

1. **Versioning Strategy**:
   - Explicit version in URI path (`/api/v1/`)
   - No evidence of header-based versioning
   - No formal versioning within the Vue.js or Angular clients

2. **Backward Compatibility**:
   - No explicit backward compatibility mechanisms observed
   - No version negotiation capabilities identified

## Validation Findings

1. **Explicit Contract Definition**: The Rails backend implements explicit contracts using Dry::Validation for request validation, providing a clear, declarative approach to defining API expectations.

2. **Consistent Serialization**: ActiveModel::Serializer provides a standardized approach to JSON structure across all endpoints, ensuring consistent response formats.

3. **Client Abstraction**: Both frontends implement client abstraction layers that encapsulate API interaction details, promoting code reusability and consistency.

4. **Resource-Oriented Design**: All repositories follow a resource-oriented design approach, with consistent resource names and operations.

5. **Type Safety Variation**: The Angular CMS demonstrates stronger type safety through TypeScript interfaces and models, while the Vue.js frontend uses more dynamic typing approaches.

6. **Authentication Consistency**: Authentication mechanisms are consistent across repositories, with token-based approaches predominant.

7. **Limited Contract Testing**: No evident automated contract testing between repositories, creating potential for contract drift over time.

8. **Informal Versioning**: API versioning is implemented but appears to be relatively static, with limited facilities for managing version transitions.

## Recommendations

1. **Formalize API Documentation**:
   - Complete OpenAPI specifications for all endpoints
   - Generate interactive documentation from specifications
   - Create a centralized API documentation site

2. **Implement Contract Testing**:
   - Add Pact or similar contract testing between repositories
   - Include contract tests in CI/CD pipeline
   - Automate verification of contract compatibility

3. **Enhance Type Safety**:
   - Add TypeScript interfaces for API responses in Vue.js frontend
   - Add runtime type checking for critical API interactions

4. **Response Standardization**:
   - Create a style guide for API naming conventions
   - Standardize nested resource parameters
   - Ensure consistent error response formats

5. **API Gateway Considerations**:
   - Evaluate introducing an API gateway for enhanced security and monitoring
   - Consider edge caching strategies for read-heavy endpoints
   - Implement cross-cutting concerns like rate limiting consistently

6. **Versioning Strategy Improvement**:
   - Document the versioning strategy and deprecation policy
   - Add sunset headers for deprecated API features
   - Create a migration guide for version transitions

## Conclusion

The API contracts across the three repositories demonstrate a pragmatic approach to integration, with consistent patterns in endpoint structure, authentication, and error handling. The backend provides OpenAPI documentation, though it could be more tightly integrated with frontend development workflows.

The use of a CRUD service abstraction in the Angular CMS and a centralized API client in the Vue.js frontend promotes consistency in API interactions. However, there is room for improvement in automatic contract enforcement and validation.

Overall, the current implementation provides a solid foundation for cross-repository communication, with identified areas for enhancement in documentation, testing, and standardization. Implementing the recommended improvements would further strengthen API contract reliability and developer experience. 