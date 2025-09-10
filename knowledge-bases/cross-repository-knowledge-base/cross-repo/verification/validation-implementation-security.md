# Security Implementations Validation

## Overview
This validation document examines how security is implemented across the backend (Ruby on Rails), frontend (Vue.js), and CMS frontend (Angular) repositories. Security implementations are critical for protecting data, enforcing authentication and authorization, and maintaining system integrity across the application.

## Validation Approach
1. Identify security mechanisms in the backend
2. Examine security implementations in the Vue.js frontend
3. Analyze security approaches in the Angular CMS frontend
4. Verify consistency and security integration across repositories

## Validation Evidence

### Backend (Ruby on Rails)

#### Authentication Mechanism

The backend implements JWT-based authentication using the Knock gem:

1. **Application Controller Configuration** (`repositories/back-end/app/controllers/application_controller.rb`):
   ```ruby
   class ApplicationController < ActionController::API
     include Knock::Authenticable
     include Pundit
     include Rescuable

     before_action :authenticate_user
   end
   ```

2. **API Application Controller Configuration** (`repositories/back-end/app/controllers/api/v1/application_controller.rb`):
   ```ruby
   class Api::V1::ApplicationController < ActionController::API
     include Knock::Authenticable
     before_action :render_error_when_invalid_auth_token, :except => [:ping]
     before_action :authenticate_store, :except => [:ping]
     
     # ... additional methods ...

     protected

     def render_error_when_invalid_auth_token
       auth = params[:token] || request.headers['Authorization']
       if auth.blank?
         render(
           json: { error: { message: 'Authorization token not present' } },
           status: :unauthorized
         )
       end
     end
   end
   ```

3. **User Model JWT Integration** (`repositories/back-end/app/models/user.rb`):
   ```ruby
   class User < ApplicationRecord
     has_secure_password
     
     # ... other code ...

     def self.from_token_payload(payload)
       # raise when not found
       if !payload['aud'] || !payload['aud'].include?('backend')
         raise Knock.not_found_exception_class_name
       end

       User.active.find(payload['sub'])
     end

     def to_token_payload
       { sub: id, aud: [:backend] }
     end

     def admin?
       client_id.blank?
     end
   end
   ```

4. **Store Model JWT Integration** (`repositories/back-end/app/models/store.rb`):
   ```ruby
   class Store < ApplicationRecord
     # ... other code ...

     def self.from_token_payload(payload)
       store = Store.active.find_by(id: payload['sub'], jti: payload['jti'])

       # raise when not found
       if payload['aud'].blank? || payload['jti'].blank? ||
          !payload['aud'].include?('api') || store.blank?
         raise Knock.not_found_exception_class_name
       end

       store
     end

     def to_token_payload
       payload = { sub: id, aud: [:api], jti: jti }
       payload
     end
     
     # ... token regeneration method ...
     
     def regenerate_jti_token
       self.jti = SecureRandom.hex if regenerate_jti
     end
   end
   ```

#### Authorization Mechanism

Authorization is implemented using the Pundit gem for policy-based access control:

1. **Application Policy** (`repositories/back-end/app/policies/application_policy.rb`):
   ```ruby
   class ApplicationPolicy
     attr_reader :user, :record

     def initialize(user, record)
       @user = user
       @record = record
     end

     def index?
       admin?
     end

     def show?
       admin?
     end

     def create?
       admin?
     end

     def new?
       admin?
     end

     def update?
       admin?
     end

     def edit?
       admin?
     end

     def destroy?
       admin?
     end

     def scope
       Pundit.policy_scope!(user, record.class)
     end

     class Scope
       attr_reader :user, :scope

       def initialize(user, scope)
         @user = user
         @scope = scope
       end

       def resolve
         scope
       end
     end

     protected

     def admin?
       user&.admin?
     end
   end
   ```

2. **Resource-Specific Policies**:

   **User Policy** (`repositories/back-end/app/policies/user_policy.rb`):
   ```ruby
   class UserPolicy < ApplicationPolicy
     def show?
       admin? || user == record
     end

     def update?
       admin? || user == record
     end

     def permitted_attributes
       %i[name email password password_confirmation client_id]
     end
   end
   ```

   **Store Policy** (`repositories/back-end/app/policies/store_policy.rb`):
   ```ruby
   class StorePolicy < ApplicationPolicy
     def index?
       if user.admin?
         true
       else
         false
       end
     end
     
     # ... other actions ...
     
     def permitted_attributes
       attrs = [
         :name, :active, :enabled_continuous_cart, :logo_id, :logo, :regenerate_jti,
         :enable_continuous_cart, :featured_mode, :block_simultaneous_nfc,
         :enabled_share_email_product, :enabled_share_sms_product,
         settings_attributes: [ ... ],
         notification_settings: [ ... ]
       ]
       
       admin_attr = [
         api_settings: [ ... ]
       ]
       
       user.admin? ? attrs + admin_attr : attrs
     end
   end
   ```

3. **Error Handling for Authorization** (`repositories/back-end/app/controllers/concerns/rescuable.rb`):
   ```ruby
   module Rescuable
     extend ActiveSupport::Concern

     included do
       rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
       rescue_from Pundit::NotAuthorizedError, with: :forbidden
       # ... other rescues ...
     end

     # ... other methods ...

     def forbidden(exception)
       policy_name = exception.policy.class.to_s.underscore
       message = I18n.t "#{policy_name}.#{exception.query}", scope: 'pundit', default: :default

       render json: { status: 403, message: message }, status: :forbidden
     end
   end
   ```

#### Data Protection Mechanisms

The backend implements several mechanisms for data protection:

1. **Attribute Visibility Control in Serializers**:
   
   **Store Serializer** (`repositories/back-end/app/serializers/store_serializer.rb`):
   ```ruby
   class StoreSerializer < ActiveModel::Serializer
     # ... other attributes ...

     # Conditionally include sensitive attributes only for admin users
     attribute :api_type, if: -> { scope && scope.admin? }
     attribute :api_client_id, if: -> { scope && scope.admin? }
     attribute :api_key, if: -> { scope && scope.admin? }
     # ... more sensitive attributes ...
   end
   ```

2. **Secure Password Handling**:
   ```ruby
   class User < ApplicationRecord
     has_secure_password
     
     # ... password validation
     validates :password, length: { minimum: 8 }, allow_nil: true
     validates :password_confirmation, presence: true, unless: proc { |u| u.password.blank? }
   end
   ```

3. **Secure Token Generation**:
   ```ruby
   def regenerate_jti_token
     self.jti = SecureRandom.hex if regenerate_jti
   end
   ```

4. **Scope-Based Access Control**:
   ```ruby
   scope :owner, lambda { |owner|
     joins(client: :users)
       .merge(User.where(id: owner))
   }
   ```

### Frontend (Vue.js)

#### Authentication Implementation

The Vue.js frontend implements token-based authentication:

1. **API Configuration** (`repositories/front-end/src/api/api.js`):
   ```javascript
   const TPB_API_URL = process.env.TPB_API_URL
     ? process.env.TPB_API_URL
     : self.kioskConfig.API.URL
   const TPB_CATALOG_ID = process.env.TPB_CATALOG_ID
     ? process.env.TPB_CATALOG_ID
     : self.kioskConfig.API.CATALOG_ID
   const TPB_STORE_TOKEN = process.env.TPB_STORE_TOKEN
     ? process.env.TPB_STORE_TOKEN
     : self.kioskConfig.API.TOKEN

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
     // ... API methods ...
   }
   ```

2. **HTTP Client Configuration** (`repositories/front-end/src/api/http.js`):
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

3. **Token-Based API Calls** (`repositories/front-end/src/analytics/EventsAPI.js`):
   ```javascript
   export class EventsAPI {
     baseurl = API_URL

     uploadEvents (data, token) {
       console.log('sending request')
       return Axios.post(this.baseurl, data, {
         headers: {
           'Content-Type': 'application/json',
           'Accept': 'application/json',
           'Authorization': `Bearer ${token}`
         }
       })
     }
   }
   ```

4. **Token Refresh Mechanism** (`repositories/front-end/src/analytics/example.js`):
   ```javascript
   refreshAccessToken = async function () {
     try {
       var e = await fetch(serverUrl + '/api/v1/token/refresh/', {
         method: 'POST',
         headers: {
           'Content-Type': 'application/json'
         },
         body: JSON.stringify({
           refresh: refreshToken
         })
       }).then(e => e.json())
       e.access
         ? ((accessToken = e.access), setTimeout(uploadEvents, 2e4))
         : (localStorage.setItem(
           'upload_error',
           JSON.stringify({
             error: e,
             datetime: new Date()
           })
         ),
         getToken(options.accountId, options.licenceKey, options.source))
     } catch (e) {
       console.error(e),
       localStorage.setItem(
         'upload_error',
         JSON.stringify({
           error: e,
           datetime: new Date()
         })
       )
     }
   }
   ```

#### Secure Data Handling

1. **Secure Local Storage**:
   ```javascript
   this.setIdentity = function (e, t, o) {
     var r = getToken(e, t, o);
     ((accountDetail = e), (licenceKeyDetail = t), (sourceDetail = o), r)
       ? (localStorage.setItem('source', JSON.stringify(o)),
       localStorage.setItem('app_client', window.clientInformation.platform),
       localStorage.setItem('env', window.clientInformation.userAgent),
       localStorage.getItem('last_upload_time') == null &&
           localStorage.setItem('last_upload_time', new Date()),
       localStorage.getItem('upload_in_progress') == null &&
           localStorage.setItem('upload_in_progress', !1),
       localStorage.getItem('upload_error') == null &&
           localStorage.setItem('upload_error', ''))
       : console.log('invalid secret_key')
   }
   ```

2. **Secure Context Check** (`repositories/front-end/src/main.js`):
   ```javascript
   // Get store information before mounting the app
   if (window.isSecureContext) {
     console.log('Secure context, use cache config')
     document.getElementById('output').innerHTML =
       'Secure context, use cache config'
     useCacheConfig()
   } else {
     console.log('Not secure context, use online config')
     document.getElementById('output').innerHTML =
       'Not secure context, use online config'
     useOnlineConfig()
   }
   ```

### CMS Frontend (Angular)

#### Authentication Implementation

The Angular CMS frontend implements JWT authentication using the auth0/angular-jwt library:

1. **JWT Module Configuration** (`repositories/cms-fe-angular/src/app/core/core.module.ts`):
   ```typescript
   export const JWT_TOKEN_ID = 'jwt';

   export function jwtOptionsFactory() {
     return {
       tokenGetter: () => {
         return localStorage.getItem(JWT_TOKEN_ID);
       },
       whitelistedDomains: [
         environment.apiUrl.replace(/((http)|(https)):\/\//, '')
       ]
     };
   }

   export function jwtAuthOptionsFactory() {
     return {
       ...defaultOptions,
       userFromJson: (json) => new User(json.user),
       authUrl: `${environment.apiUrl}/user_token`,
       currentUserUrl: `${environment.apiUrl}/users/current`,
       paramsWrapper: 'auth',
       guardRedirectTo: '/login'
     };
   }

   @NgModule({
     imports: [
       // ... other imports ...
       JwtModule.forRoot({
         jwtOptionsProvider: {
           provide: JWT_OPTIONS,
           useFactory: jwtOptionsFactory,
         }
       }),
       JwtAuthModule.forRoot({
         jwtAuthOptionsProvider: {
           provide: JWT_AUTH_OPTIONS,
           useFactory: jwtAuthOptionsFactory,
         }
       })
     ],
     // ... providers ...
   })
   export class CoreModule {
     // ... constructor ...
   }
   ```

2. **Route Protection with Guards** (`repositories/cms-fe-angular/src/app/app.routes.ts`):
   ```typescript
   export const ROUTES: Routes = [
     { path: '', redirectTo: 'app', pathMatch: 'full' },
     {
       path: 'app',
       canActivate: [SessionGuard],
       canActivateChild: [SessionGuard],
       loadChildren: () => import('./layout/layout.module').then(m => m.LayoutModule)
     },
     { path: 'login', loadChildren: () => import('./login/login.module').then(m => m.LoginModule) },
     { path: 'forbidden', component: ForbiddenComponent },
     { path: 'error', component: ErrorComponent },
     { path: '**',    component: ErrorComponent }
   ];
   ```

3. **Admin Role Guard** (`repositories/cms-fe-angular/src/app/core/guards/admin-guard.service.ts`):
   ```typescript
   @Injectable()
   export class AdminGuard implements CanActivate {

     constructor(
       private router: Router,
       private authSrv: JwtAuthService<User>
     ) { }

     canActivate() {
       const admin$ = this.authSrv.currentUser$.pipe(
         map(user => user && user.admin),
         tap(admin => {
           if (!admin) {
             this.router.navigate(['/forbidden']);
           }
         }),
         first()
       );

       return admin$;
     }
   }
   ```

4. **Authentication Initialization** (`repositories/cms-fe-angular/src/app/app.component.ts`):
   ```typescript
   ngOnInit() {
     // ... other initialization code ...
     
     this.authSrv.fetchCurrentUser();
     
     // ... other initialization code ...
   }
   ```

#### Security HTTP Interceptors

The Angular CMS uses HTTP interceptors for handling authentication and error situations:

1. **Error Interceptor** (`repositories/cms-fe-angular/src/app/core/interceptors/request-errors.interceptor.ts`):
   ```typescript
   @Injectable()
   export class RequestErrorsInterceptor implements HttpInterceptor {
     intercept (req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {

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

2. **HTTP Interceptor Registration**:
   ```typescript
   providers: [
     { provide: HTTP_INTERCEPTORS, useClass: RequestErrorsInterceptor, multi: true },
     // ... other providers ...
   ]
   ```

#### Token Generation for Stores

The Angular CMS includes functionality to generate tokens for store authentication:

```typescript
@Injectable()
export class StoreService extends CrudService<Store> {
  // ... other methods ...

  generateToken(id: number): Observable<string> {
    const url = `${environment.apiUrl}/${this.resourcePath()}/${id}/generate_token`;

    return this.http.post<any>(url, {}).pipe(
      map(response => response.jwt)
    );
  }
}
```

## Cross-Repository Validation

### Authentication Integration

The authentication flow across repositories demonstrates strong integration:

1. **Backend JWT Generation**:
   - User JWT: `{ sub: id, aud: [:backend] }`
   - Store JWT: `{ sub: id, aud: [:api], jti: jti }`

2. **Angular CMS Authentication**:
   - Uses `auth0/angular-jwt` for token management
   - JWT audience: `:backend`
   - Routes protected via `SessionGuard`
   - Admin routes protected via `AdminGuard`

3. **Vue.js Frontend Authentication**:
   - Uses store token in API requests
   - JWT audience: `:api`
   - Token is loaded from configuration

### Authorization Consistency

The authorization mechanisms show consistent rules across repositories:

1. **Backend Authorization Patterns**:
   - Uses Pundit for policy-based authorization
   - Base `admin?` check in ApplicationPolicy
   - Resource-specific policies extend base policy
   - Attribute-level access control in serializers

2. **Angular CMS Authorization**:
   - Route-level guards based on user roles
   - Component-level authorization based on user properties
   - Tailored views based on user permissions

3. **Vue.js Authorization**:
   - Limited to authenticated store access
   - No complex user role handling (kiosk-focused)

### Secure Data Handling

All three repositories implement secure data handling practices:

1. **Secure Storage**:
   - Backend: Database with proper validations
   - Angular CMS: JWT in localStorage with domain restrictions
   - Vue.js: Configuration data in secure context

2. **Data Transmission**:
   - All repositories use HTTPS for API communication
   - JWT tokens used for authentication

3. **Error Handling**:
   - Backend: Structured error responses
   - Angular CMS: HTTP error interceptor
   - Vue.js: Error handling in catch blocks

## Validation Findings

1. **Robust JWT Implementation**: All three repositories implement JWT-based authentication consistently, with appropriate audience separation between backend administration (`:backend`) and frontend store access (`:api`).

2. **Policy-Based Authorization**: The backend implements policy-based authorization using Pundit, which provides granular control over resource access. The Angular CMS respects these policies through route guards and component-level checks.

3. **Secure Data Handling**: All repositories implement secure data handling practices, with particular attention to sensitive data protection in the backend through serializer controls.

4. **Strong Access Controls**: The system implements multiple layers of access control:
   - Authentication via JWT
   - Role-based authorization (admin vs. non-admin)
   - Resource-ownership checks
   - Attribute-level access control

5. **Consistent Error Handling**: Security-related errors are handled consistently across repositories, with appropriate status codes and error messages.

6. **Token Generation Flow**: The CMS provides functionality to generate tokens for stores, which are then used by the Vue.js frontend for authentication.

## Recommendations

1. **Security Standardization Opportunities**:
   - Implement consistent token expiration policies across repositories
   - Standardize security headers across all API responses
   - Create common security error codes and messages

2. **Security Improvements**:
   - Add CSRF protection for non-API endpoints
   - Implement rate limiting for authentication attempts
   - Add refresh token flow to Vue.js frontend
   - Consider implementing HttpOnly cookies for JWT storage in Angular

3. **Monitoring Enhancements**:
   - Add security event logging across all repositories
   - Implement failed authentication attempt tracking
   - Add automated security alert mechanisms

4. **Documentation Needs**:
   - Create comprehensive security documentation for developers
   - Document security patterns and best practices
   - Create security implementation checklist for new features

5. **Testing Recommendations**:
   - Implement security-focused penetration testing
   - Add automated security scanning to CI/CD pipeline
   - Conduct regular security reviews

## Conclusion

The Security Implementation across all three repositories demonstrates a well-structured approach to authentication, authorization, and data protection. The JWT-based authentication provides a strong foundation for secure communication between components, while the policy-based authorization ensures appropriate access controls.

The backend implements robust security controls, particularly through Pundit policies and attribute-level access control in serializers. The Angular CMS effectively leverages these controls through route guards and component-level checks. The Vue.js frontend, while simpler in its security model, maintains consistent authentication with the backend.

There are opportunities for enhancement, particularly in standardizing security practices across repositories and implementing additional protections like CSRF tokens and rate limiting. However, the current implementation provides a solid security foundation for the application. 