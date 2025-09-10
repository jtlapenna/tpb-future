# Error Handling Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the error handling patterns implemented in the CMS, focusing on HTTP errors, form validation errors, and business logic errors.

## Core Components

### 1. Request Error Interceptor
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
    }
    return observableThrowError(data);
  }
}
```

### 2. Remote Errors Handler
```typescript
export class RemoteErrors {
  private _errors: any = {};
  private _form: FormGroup;

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
}
```

### 3. Sync Error Handler
```typescript
export class SyncError {
  private data: any;
  constructor(json) { this.data = json; }

  get errors(): any[] {
    if (this.data && this.data.errors) {
      return this.data.errors;
    }
    return [];
  }
}
```

## Error Handling Patterns

### 1. HTTP Error Handling
- Global error interception through `RequestErrorsInterceptor`
- Content-type based error processing
- JSON error parsing and transformation
- Error propagation through observables

### 2. Form Error Handling
- Remote error mapping to form fields
- Field-level error state management
- Form-level validation error handling
- Error message aggregation

### 3. Service Error Handling
```typescript
destroy(id: number): Observable<boolean> {
  return this.http.delete<any>(url).pipe(
    map(data => true),
    catchError(response => observableOf(false))
  );
}
```

### 4. Component Error Handling
```typescript
saveResource() {
  try {
    this.resourceSrv.save(rawResource).subscribe(
      success => { /* handle success */ },
      data => {
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

## Error Types

1. **HTTP Errors**
   - Network errors
   - Server errors (500)
   - Client errors (400)
   - Authentication errors (401)
   - Authorization errors (403)

2. **Form Validation Errors**
   - Required field errors
   - Format validation errors
   - Business rule validation errors
   - Remote validation errors

3. **Business Logic Errors**
   - Resource conflicts
   - State inconsistencies
   - Operation failures
   - Sync errors

## Best Practices

1. **Error Transformation**
   - Convert to consistent format
   - Add context when needed
   - Preserve original error data
   - Enable proper error tracking

2. **Error Recovery**
   - Implement retry strategies
   - Provide fallback behavior
   - Clear error states
   - Handle partial failures

3. **User Experience**
   - Clear error messages
   - Field-level error indicators
   - Form-level error summaries
   - Recovery options

4. **Error Tracking**
   - Sentry integration for exceptions
   - Error logging
   - Error analytics
   - Debug information

## Integration Points

1. **HTTP Client**
   - Error interceptor registration
   - Error response handling
   - Error transformation

2. **Forms Module**
   - Form validation integration
   - Error state management
   - Error message display

3. **Notification System**
   - Error notifications
   - Success messages
   - Warning alerts

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial error handling patterns documentation 