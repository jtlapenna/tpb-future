# Component-Specific Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the component-specific patterns implemented in the CMS, focusing on reusable components, their implementation patterns, and best practices.

## Core Components

### 1. Modal Component
The application uses a reusable modal component for consistent dialog behavior:

```typescript
@Component({
  selector: 'app-tpb-modal',
  templateUrl: './tpb-modal.component.html'
})
export class TpbModalComponent implements OnInit {
  @Input('modalTitle') modalTitle: String;
  @Input('useCancelButton') useCancelButton: boolean;
  @Input('saveString') saveString: string;
  public onSave: () => void;
  public showModal: boolean = false;
  public showContent: boolean = false;

  openModal() {
    this.showModal = true;
    setTimeout(() => this.showContent = true, 300);
  }

  closeModal() {
    this.showModal = false;
    this.showContent = false;
  }
}
```

Features:
- Configurable title and buttons
- Animation support
- Accessibility integration
- Event handling

### 2. Select Components
The application provides specialized select components for different use cases:

```typescript
@Component({
  providers: [{
    provide: NG_VALUE_ACCESSOR,
    useExisting: forwardRef(() => SelectStoreProductComponent),
    multi: true,
  }]
})
export class SelectStoreProductComponent implements ControlValueAccessor {
  @Input() placeholder: string;
  @Input() filters: any = {};
}
```

Features:
- Form control integration
- Custom value accessors
- Filtering support
- Loading states

### 3. Filter Component
```typescript
@Component({})
export class FilterComponent {
  @Input() filters: FilterValue[] = [];
  @Output() filterChange = new EventEmitter<FilterValue[]>();
}
```

Features:
- Dynamic filter management
- Event-based updates
- Reusable filtering logic
- State management

## Implementation Patterns

### 1. Form Control Components
```typescript
@Component({
  providers: [{
    provide: NG_VALUE_ACCESSOR,
    useExisting: forwardRef(() => CustomInputComponent),
    multi: true
  }]
})
export class CustomInputComponent implements ControlValueAccessor {
  writeValue(value: any): void {}
  registerOnChange(fn: any): void {}
  registerOnTouched(fn: any): void {}
}
```

Key patterns:
- ControlValueAccessor implementation
- Two-way binding support
- Form integration
- Validation support

### 2. List Components
```typescript
export class CrudListComponent<T> {
  @ViewChild("tableTmpl") table: any;
  loading = false;
  rows: T[] = [];
  columns = [];
  page: Pagination = new Pagination();
  sort = { direction: "desc", prop: "id" };
}
```

Features:
- Generic type support
- Pagination handling
- Sorting functionality
- Loading states

### 3. Upload Components
```typescript
export class ImageUploaderComponent {
  @Input() multiple = false;
  @Output() imagesChanges = new EventEmitter<Image[]>();
  
  onImagesChanges(images: Image[]) {
    const imagesJson = images.map(i => i.toJson());
    this.imagesChanges.emit(imagesJson);
  }
}
```

Features:
- File type validation
- Progress tracking
- Error handling
- Preview support

## Component Communication

### 1. Parent-Child Communication
```typescript
@Component({})
export class ParentComponent {
  @ViewChild(ChildComponent) child: ChildComponent;
  
  ngAfterViewInit() {
    this.child.someMethod();
  }
}
```

Patterns:
- ViewChild decorators
- Input/Output bindings
- Service-based communication
- Event emitters

### 2. Component State
```typescript
export class ComponentName implements OnDestroy {
  private destroyed$ = new Subject<void>();
  public loading = false;
  public errors: any = {};
  
  ngOnDestroy() {
    this.destroyed$.next();
    this.destroyed$.complete();
  }
}
```

Features:
- Local state management
- Cleanup patterns
- Error handling
- Loading states

## Best Practices

### 1. Component Design
- Single responsibility
- Encapsulated styles
- Clear interfaces
- Proper lifecycle management

### 2. Performance
- OnPush change detection
- Async pipes
- Trackby functions
- Memory management

### 3. Accessibility
- ARIA attributes
- Keyboard navigation
- Focus management
- Screen reader support

### 4. Testing
- Component isolation
- Service mocking
- Event testing
- State verification

## Integration Points

### 1. Form Module
- ReactiveFormsModule
- Custom validators
- Form controls
- Value accessors

### 2. Routing
- Route guards
- Navigation
- Parameter handling
- Child routes

### 3. Services
- HTTP client
- State management
- Error handling
- Data transformation

## Dependencies
- @angular/core
- @angular/forms
- @angular/common
- @angular/router
- ngx-bootstrap
- ng-select

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial component-specific patterns documentation | 