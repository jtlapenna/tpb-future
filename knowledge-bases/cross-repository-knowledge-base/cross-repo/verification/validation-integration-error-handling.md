# Error Handling Integration Point Validation

## Overview
This validation document examines how error handling is implemented, structured, and consistent across the backend (Ruby on Rails), frontend (Vue.js), and CMS frontend (Angular) repositories. The goal is to verify the consistency and correctness of error handling as an integration point between the three repositories.

## Validation Approach
1. Identify error handling mechanisms in the backend
2. Examine error handling in the Vue.js frontend
3. Analyze error handling in the Angular CMS frontend
4. Verify consistency and error propagation across repositories

## Validation Evidence

### Backend (Ruby on Rails)

#### Error Handling Structure

The backend implements a systematic approach to error handling with a focus on:
1. Centralized error handling through concerns
2. Consistent error response formats
3. HTTP status code mapping
4. Exception categorization

The primary error handling mechanisms include:

1. **Rescuable Concern** (`repositories/back-end/app/controllers/concerns/rescuable.rb`):
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
       policy_name = exception.policy.class.to_s.underscore
       message = I18n.t "#{policy_name}.#{exception.query}", scope: 'pundit', default: :default

       render json: { status: 403, message: message }, status: :forbidden
     end

     def bad_request(exception)
       render json: { status: 400, message: exception.message }, status: :bad_request
     end
   end
   ```

2. **External API Error Handling** (`repositories/back-end/app/controllers/concerns/external_api_bridge.rb`):
   ```ruby
   module ExternalApiBridge
     extend ActiveSupport::Concern

     included do
       rescue_from Errors::ExternalApiError, with: :api_integration_error
       rescue_from Errors::ResourceNotUnique, with: :duplicate_resource
     end

     def duplicate_resource(ex)
       message = I18n.t "#{ex.type}.not_unique", scope: 'integration.errors', default: 'not unique'

       render json: { status: 409, message: message }, status: :conflict
     end

     def api_integration_error(ex)
       Rails.logger.error ex
       message = I18n.t(
         'unexpected',
         scope: 'integration.errors',
         message: ex.message,
         default: 'unexpected problem'
       )

       render json: { status: 502, message: message }, status: :bad_gateway
     end
   end
   ```

3. **Controller-Level Error Handling** (Example from `repositories/back-end/app/controllers/api/v1/customers_controller.rb`):
   ```ruby
   class Api::V1::CustomersController < Api::V1::ApplicationController
     include ExternalApiBridge

     # ... other code ...

     private

     def render_method_not_allowed
       message = I18n.t 'errors.not_allowed', scope: 'integration', default: 'method not allowed'
       render(
         json: { status: 405, message: message },
         status: :method_not_allowed
       )
     end
   end
   ```

4. **Base Application Controller Setup** (`repositories/back-end/app/controllers/application_controller.rb`):
   ```ruby
   class ApplicationController < ActionController::API
     include Knock::Authenticable
     include Pundit
     include Rescuable

     before_action :authenticate_user
   end
   ```

#### Error Response Format

The backend consistently uses a structured JSON format for error responses:

1. **Validation Errors**:
   ```json
   {
     "errors": {
       "field_name": ["Error message 1", "Error message 2"]
     }
   }
   ```

2. **General Errors**:
   ```json
   {
     "status": 400,
     "message": "Error message"
   }
   ```

3. **API Integration Errors**:
   ```json
   {
     "status": 502,
     "message": "API integration error: unexpected problem"
   }
   ```

### Frontend (Vue.js)

#### Error Handling Implementation

The Vue.js frontend handles errors primarily through:
1. Axios interceptors/catch blocks
2. Component-level error handling
3. User-friendly error messages
4. Sentry error monitoring

Key implementations include:

1. **API Request Error Handling** (Example from `repositories/front-end/src/components/ScreenCheckoutBlaze.vue`):
   ```javascript
   .catch(function (error) {
     // Order creation error
     Sentry.captureException(error)
     console.log(error.response.data.message, error.response)
     self.isSending = false

     if (self.$gsClient) {
       self.$gsClient.track('Proceed checkout',
         {order: order},
         {status: 'error', error: error.response})
     }

     var serverStatus = parseInt(error.response.status)
     var mess = ''

     switch (serverStatus) {
       case 400:
       case 404:
         mess = 'Couldn\'t process your order. The service is offline. Please ask a staff member to help you.'
         return self.$emit('error', mess)

       case 500:
       case 502:
         var str = error.response.data.message
         var findText = 'error:'
         var res = str.split(findText)
         var keyword = res[1].trim()

         switch (keyword) {
           case 'CUSTOMER_NOT_FOUND':
             mess = 'We couldn\'t process your order. Customer not found.'
             break

           case 'INSUFFICIENT_SELLABLE_QUANTITY':
             mess = 'Order items quantity not available in stock. Please remove some items from your order.'
             break

           default:
             mess = 'An error occurred processing the order. Please ask a staff member to help you.'
             break
         }

         return self.$emit('error', mess)
     }
   })
   ```

2. **Error Event Propagation**:
   Vue.js components propagate errors up the component hierarchy using custom events:
   ```javascript
   this.$emit('error', 'Error message for user')
   ```

3. **Input Validation Error Handling** (Example from `repositories/front-end/src/components/ScreenCheckoutLeaflogix.vue`):
   ```javascript
   validateData () {
     console.log(this.isEmail, this.isName, this.isPhone)

     if (this.showBirthday && this.isBirthDayUnderage) {
       console.error('error on birthday')
       this.$emit('error', 'Please provide a valid birthday.')
       return false
     }

     if (this.isEmail && !this.email) {
       console.error('error on email')
       this.$emit('error', 'Please fill in the fields.')
       return false
     }
     // ... additional validations ...
     return true
   }
   ```

4. **Sentry Error Monitoring** (Multiple components):
   ```javascript
   Sentry.captureException(error)
   ```

#### Error Response Handling

The Vue.js frontend maps backend error responses to user-friendly messages based on HTTP status codes:

1. **HTTP Status Code Mapping**:
   ```javascript
   switch (serverStatus) {
     case 400:
     case 404:
     case 419:
       mess = 'We couldn\'t process your order. We can\'t connect to the point of sale system.'
       return self.$emit('error', mess)

     case 500:
     case 503:
     case 504:
     case 511:
       mess = 'We couldn\'t process your order. Please try again later. Internal server error.'
       return self.$emit('error', mess)

     default:
       mess = 'Sorry, we couldn\'t process the request at this time.'
       return self.$emit('error', mess)
   }
   ```

2. **Error Message Extraction and Processing**:
   ```javascript
   var str = error.response.data.message
   var findText = 'error:'
   var res = str.split(findText)
   var keyword = res[1].trim()

   switch (keyword) {
     case 'Unauthorized':
       mess = 'We couldn\'t validate your identity. The point of sale is offline. Please try again later.'
       break
     // ... additional error cases ...
   }
   ```

### CMS Frontend (Angular)

#### Error Handling Implementation

The Angular CMS frontend implements error handling through:
1. HTTP interceptors
2. RxJS error operators
3. Form validation error handling
4. Component-level error handling
5. Sentry error reporting

Key implementations include:

1. **HTTP Interceptor** (`repositories/cms-fe-angular/src/app/core/interceptors/request-errors.interceptor.ts`):
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

2. **Service-Level Error Handling** (Example from `repositories/cms-fe-angular/src/app/core/services/store-sync.service.ts`):
   ```typescript
   create(storeId: number, file?: File): Observable<any> {
     const formData: FormData = new FormData();
     if (file) {
       formData.append('file', file);
     }

     return this.http.post<any>(this.resourcePath(storeId), formData).pipe(
       map(response => response),
       catchError(response => {
         if (response.error && response.error.errors) {
           return observableThrowError(new SyncError(response.error));
         }
         return observableThrowError(new SyncError(response));
       })
     );
   }
   ```

3. **Form Error Handling** (`repositories/cms-fe-angular/src/app/core/lib/remote-error.ts`):
   ```typescript
   export class RemoteErrors {
     private _errors: any = {};
     private _form;

     constructor(form?: FormGroup, remoteErrors?: any) {
       if (form) {
         this._form = form;
       }

       if (!remoteErrors) { return; }

       this.processErrors(remoteErrors);
     }

     setErrors({form, errors}: {form?: FormGroup, errors: any}) {
       if (form) {
         this._form = form;
       }

       this._errors = [];
       this.processErrors(errors);
     }

     private processErrors(errors) {
       for (const key in errors) {
         if (errors.hasOwnProperty(key)) {
           const keys = key.split('.');
           const field = this.getField(keys[0]);

           if (field && field.control) {
             field.control.markAsDirty();
             field.control.setErrors({'remoteError': true});
             this._errors[field.name] = errors[key].join(' - ');
           }
         }
       }
     }
     // ... additional methods ...
   }
   ```

4. **Component Error Handling** (Example from `repositories/cms-fe-angular/src/app/stores/store/store.component.ts`):
   ```typescript
   saveResource() {
     this.working = true;

     // ... form processing code ...

     try {
       this.resourceSrv.save(rawResource).subscribe(
         (store) => {
           // ... success handling ...
         },
         (data) => {
           this.working = false;
           this.remoteErrors.setErrors(data.error);
           if (this.remoteErrors.empty) {
             this.notificationSrv.error('Error', data.message);
           }
         }
       );
     } catch (error) {
       Sentry.captureException(error);
     }
   }
   ```

5. **Error Routes Configuration** (`repositories/cms-fe-angular/src/app/app.routes.ts`):
   ```typescript
   export const ROUTES: Routes = [
     // ... other routes ...
     { path: 'forbidden', component: ForbiddenComponent },
     { path: 'error', component: ErrorComponent },
     { path: '**',    component: ErrorComponent }
   ];
   ```

#### Error Response Handling

The Angular CMS frontend processes error responses with:

1. **Error Response Parsing**:
   ```typescript
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
   ```

2. **Form Error Mapping**:
   ```typescript
   private processErrors(errors) {
     for (const key in errors) {
       if (errors.hasOwnProperty(key)) {
         const keys = key.split('.');
         const field = this.getField(keys[0]);

         if (field && field.control) {
           field.control.markAsDirty();
           field.control.setErrors({'remoteError': true});
           this._errors[field.name] = errors[key].join(' - ');
         }
       }
     }
   }
   ```

## Cross-Repository Validation

### Error Handling Consistency

| Error Type | Backend (Rails) | Frontend (Vue.js) | CMS Frontend (Angular) |
|------------|----------------|-------------------|------------------------|
| Not Found (404) | `record_not_found` method, JSON error response | Maps to user-friendly message via `$emit('error')` | HTTP interceptor, redirects to error page or shows notification |
| Authorization (403) | `forbidden` method, JSON error response | Maps to authorization error message | Routes to ForbiddenComponent |
| Validation (422) | `unprocessable_entity` method, field-level errors | Maps to form validation errors | RemoteErrors class maps errors to form fields |
| Server Error (500) | Rails error handling, custom error response | Shows general "internal server error" | HTTP interceptor, error notification |
| API Integration (502) | `api_integration_error` method | Custom error message based on API | Error observable in services |

### Error Response Format Consistency

1. **Backend Response Format**:
   ```json
   {
     "errors": { "field": ["Error message"] }  // For validation errors
   }
   ```
   or
   ```json
   {
     "status": 404,
     "message": "Resource not found"  // For general errors
   }
   ```

2. **Frontend Processing**:
   - Vue.js extracts error messages and status codes, translating them to user-friendly notifications
   - Angular parses JSON errors and maps them to form fields or general notifications

3. **User Feedback**:
   - Vue.js: User-friendly error messages through UI components
   - Angular: Form validation errors, toasts/notifications, and error pages

### Error Monitoring Integration

Both frontends implement Sentry for error monitoring:

1. **Vue.js**:
   ```javascript
   Sentry.captureException(error)
   ```

2. **Angular**:
   ```typescript
   Sentry.captureException(error)
   ```

## Validation Findings

1. **Consistent Error Response Structure**: The backend provides consistent error response formats that both frontend applications can handle appropriately. The structure follows RESTful conventions with proper HTTP status codes and JSON error payloads.

2. **Framework-Appropriate Error Handling**:
   - Backend: Uses Rails conventions with concerns and rescue_from
   - Vue.js: Uses Promise catch blocks and component event propagation
   - Angular: Uses RxJS operators and HTTP interceptors

3. **User Experience Focus**: Both frontend applications translate technical error responses into user-friendly messages, though with different approaches:
   - Vue.js: Focused on simple user messaging with specific error handling for different API points
   - Angular: More sophisticated with form-level error mapping and notification services

4. **Error Monitoring**: All three repositories implement error logging, with both frontends using Sentry for error reporting.

5. **Error Recovery Mechanisms**:
   - Backend: Provides appropriate status codes to guide clients
   - Vue.js: Implements retry mechanisms and fallbacks for certain operations
   - Angular: Uses Observable error handling with recovery options

6. **Validation Error Handling**:
   - Backend: Returns field-level validation errors
   - Vue.js: Simple validation with user messaging
   - Angular: Sophisticated form validation mapping

## Recommendations

1. **Standardization Opportunities**:
   - Create a shared error code system across all repositories
   - Standardize error message format in API responses
   - Document expected error responses for all API endpoints

2. **Error Handling Improvements**:
   - Implement more consistent retry mechanisms in frontends
   - Add circuit breakers for external API calls in the backend
   - Enhance error logging with more context

3. **User Experience Enhancements**:
   - Add more specific error recovery suggestions in user interfaces
   - Implement better offline handling in frontends
   - Provide clearer next steps for users when errors occur

4. **Documentation Needs**:
   - Create a comprehensive error handling guide for developers
   - Document common error scenarios and recovery strategies
   - Add error code documentation for API consumers

5. **Testing Recommendations**:
   - Implement systematic error simulation in tests
   - Add integration tests specifically for error scenarios
   - Test error handling consistently across repositories

## Conclusion

The Error Handling integration point demonstrates a well-structured implementation across all three repositories, with appropriate mechanisms for each technology stack. While the specific implementation details differ based on framework capabilities, the overall approach provides consistent and user-friendly error handling.

The backend provides a solid foundation with structured error responses, which both frontends consume effectively. The Vue.js frontend focuses on simple, user-friendly error messaging, while the Angular CMS implements more sophisticated error handling with form mapping and notifications.

There are opportunities for standardization and improvement, particularly in error code consistency and recovery mechanisms, but the current implementation provides effective error handling across the system. The recommendations outlined above would enhance the error handling integration, building on the already solid foundation. 