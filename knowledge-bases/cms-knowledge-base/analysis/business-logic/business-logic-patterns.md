# Business Logic Patterns Analysis

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview

This document outlines the business logic patterns identified in the existing codebase, focusing on validation, data flow, and business rule implementations.

## Form Validation Patterns

### 1. Dynamic Field Validation
```typescript
fields.forEach((fieldName) => {
  const field = this.field(fieldName);
  field.setValidators(
    required ? Validators.required : Validators.nullValidator
  );
  field.updateValueAndValidity();
});
```

Key patterns:
- Dynamic validator assignment
- Field-specific validation rules
- Validation state management

### 2. Remote Error Handling
```typescript
export class RemoteErrors {
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

## Business Rules Implementation

### 1. Payment Gateway Integration
```typescript
setGatewayProviderFields(option, value?: any) {
  const formObject = {};
  if (option) {
    (option.fields as string[]).forEach((element) => {
      formObject[element] = [
        value && value[element] ? value[element] : null,
        [Validators.required]
      ];
    });
    this.paymentGatewayForm.setControl(
      'api_settings',
      this.fb.group(formObject)
    );
  }
}
```

### 2. RFID Management
```typescript
save() {
  const data = this.form.getRawValue();
  if (this.form.invalid) {
    (this.form.get('products') as FormArray).controls.forEach((form) => {
      form.markAllAsTouched();
      if (form.get('rfid').hasError('required')) {
        form.setErrors({ required: true });
      }
    });
    return;
  }
  data.products = data.products.map((p) => {
    return { rfid: (p.rfid + '').trim(), ...p };
  });
}
```

## Data Flow Patterns

### 1. HTTP Error Handling
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
}
```

### 2. Form State Management
```typescript
createForm() {
  this.resourceForm = this.fb.group({
    id: [this.gatewayProviderId, []],
    name: [
      (paymentGatewayProvider && paymentGatewayProvider.name) || null,
      [Validators.required]
    ],
    fields: this.formBuilder.array([])
  });
}
```

## Validation Strategies

### 1. Field-Level Validation
```typescript
setCheckoutValidation($event) {
  if ($event.id === 'leaflogix') {
    this.resourceForm
      .get('checkout_type')
      .setValidators([Validators.required]);
  } else {
    this.resourceForm.get('checkout_type').clearValidators();
    this.field('seamless_checkout').patchValue(null);
  }
}
```

### 2. Form-Level Validation
```typescript
getPaginationTimeValidators(): any[] {
  let validators = [];
  if (
    this.resource.home_layout == 'on_sale' ||
    this.resource.home_layout == 'menu_boards'
  ) {
    validators = [Validators.required, Validators.min(0), Validators.max(60)];
  }
  return validators;
}
```

## Error Handling Patterns

### 1. Remote Error Processing
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

### 2. Form Error Display
```html
<ng-container *ngIf="field('name').invalid && field('name').dirty">
  <div *ngIf="field('name').errors.required" class="invalid-feedback">
    This field is required
  </div>
  <div *ngIf="field('name').errors.remoteError" class="invalid-feedback">
    {{ remoteErrors.errors["name"] }}
  </div>
</ng-container>
```

## Best Practices

1. **Form Validation**
   - Dynamic validator assignment
   - Remote error handling
   - Field-level validation
   - Form-level validation

2. **Business Rules**
   - Clear separation of concerns
   - Reusable validation logic
   - Consistent error handling
   - Type safety

3. **Data Flow**
   - HTTP interceptors
   - Error handling
   - State management
   - Form state tracking

4. **Error Management**
   - Consistent error format
   - User-friendly messages
   - Remote error handling
   - Form error display

## Dependencies

- `@angular/forms`: Form handling
- `@angular/common/http`: HTTP client
- `rxjs`: Reactive programming
- `angular2-notifications`: User notifications

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial documentation of business logic patterns | 