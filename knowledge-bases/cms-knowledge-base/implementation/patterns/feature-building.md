# Feature Building Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the core patterns and best practices for building new features in the CMS application, providing a structured approach to feature implementation.

## Core Patterns

### 1. Service Layer Pattern
```typescript
@Injectable()
export class FeatureService extends CrudService<Feature> {
  constructor(protected http: HttpClient) {
    super(http);
  }

  createResource(params: any): Feature {
    return new Feature(params);
  }

  resourceName({ plural }: { plural?: boolean } = {}): string {
    return plural ? 'features' : 'feature';
  }

  // Custom methods for feature-specific operations
  customOperation(id: number): Observable<any> {
    return this.http.get(`${this.resourcePath()}/${id}/custom`);
  }
}
```

Key Features:
- CRUD service extension
- Type-safe operations
- Custom method implementation
- Resource path management

### 2. Component Architecture
```typescript
@Component({
  selector: 'app-feature',
  templateUrl: './feature.component.html'
})
export class FeatureComponent implements OnInit {
  @Input() data: any;
  @Output() update = new EventEmitter<any>();

  resourceForm: FormGroup;
  remoteErrors: RemoteErrors;
  working = false;

  constructor(
    private fb: FormBuilder,
    private featureService: FeatureService,
    private notificationService: NotificationsService
  ) {}

  ngOnInit() {
    this.initializeForm();
  }

  private initializeForm() {
    this.resourceForm = this.fb.group({
      // Form controls
    });
    this.remoteErrors = new RemoteErrors(this.resourceForm);
  }
}
```

Key Features:
- Form-based data management
- Error handling integration
- Loading state management
- Event-based updates

### 3. State Management
```typescript
@Injectable({
  providedIn: 'root'
})
export class FeatureStateService {
  private state$ = new BehaviorSubject<any>(null);

  setState(data: any) {
    this.state$.next(data);
  }

  getState(): Observable<any> {
    return this.state$.asObservable();
  }
}
```

Key Features:
- Observable-based state
- Centralized state management
- Type-safe state updates
- State synchronization

## Implementation Workflow

### 1. Feature Planning
1. Define feature requirements
2. Identify component hierarchy
3. Plan service layer
4. Design state management
5. Outline API integration

### 2. Service Implementation
1. Create feature service extending CrudService
2. Implement required abstract methods
3. Add custom operations
4. Implement error handling

### 3. Component Development
1. Create feature components
2. Implement form handling
3. Add state management
4. Integrate error handling
5. Add loading states

### 4. Integration
1. Register feature module
2. Configure routing
3. Add service providers
4. Implement guards if needed

## Best Practices

### 1. Service Layer
- Extend CrudService for consistent CRUD operations
- Implement type-safe resource creation
- Use proper error handling
- Follow RESTful patterns

### 2. Component Design
- Use reactive forms for data management
- Implement proper error handling
- Manage component state effectively
- Follow single responsibility principle

### 3. State Management
- Use observable patterns
- Implement proper cleanup
- Maintain type safety
- Consider state persistence

### 4. Error Handling
- Use RemoteErrors for form validation
- Implement proper error recovery
- Provide user feedback
- Log errors appropriately

## Common Patterns

### 1. Form Handling
```typescript
createForm() {
  this.resourceForm = this.fb.group({
    name: ['', Validators.required],
    description: [''],
    status: ['active']
  });
  this.remoteErrors = new RemoteErrors(this.resourceForm);
}
```

### 2. API Integration
```typescript
save() {
  if (this.resourceForm.valid) {
    this.working = true;
    this.featureService.save(this.resourceForm.value)
      .pipe(finalize(() => this.working = false))
      .subscribe(
        response => this.handleSuccess(response),
        error => this.handleError(error)
      );
  }
}
```

### 3. Error Management
```typescript
handleError(error: any) {
  if (error.status === 422) {
    this.remoteErrors.setErrors(error.error);
  } else {
    this.notificationService.error('Error', 'Failed to save feature');
  }
}
```

## Dependencies
- @angular/core
- @angular/forms
- @angular/common/http
- rxjs
- angular2-notifications

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial feature building patterns documentation 