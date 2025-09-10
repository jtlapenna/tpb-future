# Form Validation Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the form validation patterns implemented in the CMS, focusing on field-level validation, form-level validation, and error display.

## Core Components

### 1. URL Validator
```typescript
export function urlFormatValidator(): ValidatorFn {
  return (control: AbstractControl): { [key: string]: any } => {
    const value = control.value;
    let isValid = true;
    const expression = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/gi;
    const regex = new RegExp(expression);
    if (value && !value.match(regex)) {
      isValid = false;
    }
    return isValid ? null : { 'format': true };
  };
}
```

### 2. Dynamic Field Validation
```typescript
fields.forEach((fieldName) => {
  const field = this.field(fieldName);
  field.setValidators(
    required ? Validators.required : Validators.nullValidator
  );
  field.updateValueAndValidity();
});
```

### 3. Form Error Display
```html
<ng-container *ngIf="field('stock').invalid && field('stock').dirty">
  <div *ngIf="field('stock').errors.required" class="invalid-feedback">
    This field is required
  </div>
  <div *ngIf="field('stock').errors.min" class="invalid-feedback">
    must be greater than or equal to 0
  </div>
  <div *ngIf="field('stock').errors.remoteError" class="invalid-feedback">
    {{ remoteErrors.errors["stock"] }}
  </div>
</ng-container>
```

## Validation Patterns

### 1. Field-Level Validation
- Required fields
- Numeric constraints
- Pattern matching
- Custom validators

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

### 3. Remote Validation
```typescript
setErrors({form, errors}: {form?: FormGroup, errors: any}) {
  if (form) {
    this._form = form;
  }
  this._errors = [];
  this.processErrors(errors);
}
```

## Implementation Patterns

### 1. Form Creation
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

### 2. Dynamic Validation
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

### 3. Error State Management
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

## Best Practices

1. **Validation Configuration**
   - Use appropriate validators for field types
   - Implement custom validators when needed
   - Handle remote validation errors
   - Maintain validation state

2. **Error Display**
   - Show field-level error messages
   - Display form-level error summaries
   - Handle remote error messages
   - Clear error states appropriately

3. **User Experience**
   - Immediate validation feedback
   - Clear error messages
   - Validation state indicators
   - Form submission handling

4. **Performance**
   - Efficient validator execution
   - Optimized error processing
   - State management optimization
   - Form control updates

## Integration Points

1. **Form Module**
   - Reactive forms setup
   - Validator registration
   - Form control management

2. **Error Handling**
   - Remote error integration
   - Error state management
   - Error message display

3. **UI Components**
   - Form control components
   - Error display components
   - Validation indicators

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial form validation patterns documentation 