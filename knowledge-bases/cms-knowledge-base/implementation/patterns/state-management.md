# State Management Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the state management patterns implemented in the CMS, focusing on the service-based approach using RxJS.

## Core State Types

### 1. Service-Based State
```typescript
@Injectable({
  providedIn: 'root'
})
export class CurrentStoreService {
  public storeId$: ReplaySubject<number> = new ReplaySubject(1);
  
  setStore(id: number) {
    this.storeId$.next(id);
  }
  
  getCurrentStore(): Observable<number> {
    return this.storeId$.asObservable();
  }
}
```

### 2. Component State
```typescript
export class StoreComponent implements OnDestroy {
  private destroyed$ = new Subject<void>();
  public loading = false;
  public errors: any = {};
  
  ngOnDestroy() {
    this.destroyed$.next();
    this.destroyed$.complete();
  }
}
```

### 3. Form State
```typescript
export class ProductFormComponent {
  resourceForm = this.fb.group({
    name: ['', Validators.required],
    category_id: [null, Validators.required],
    description: ['']
  });
  
  remoteErrors = new RemoteErrors(this.resourceForm);
}
```

## State Management Types

### 1. Global Application State
- Current store/kiosk selection
- Authentication state
- UI preferences
- Feature flags

### 2. Resource State
- CRUD operations state
- Cache management
- Pagination state
- Filter state

### 3. UI State
- Loading indicators
- Error messages
- Modal states
- Form states

## Implementation Patterns

### 1. Observable State
```typescript
@Injectable()
export class SidebarService {
  private stateChanges = new EventEmitter<any>();
  
  onChanges(): Observable<any> {
    return this.stateChanges;
  }
  
  toggle(state: any): void {
    this.stateChanges.emit(state);
  }
}
```

### 2. State Synchronization
```typescript
@Component({})
export class ProductListComponent implements OnInit {
  constructor(private currentStore: CurrentStoreService) {}
  
  ngOnInit() {
    this.currentStore.storeId$
      .pipe(
        takeUntil(this.destroyed$),
        switchMap(id => this.loadProducts(id))
      )
      .subscribe();
  }
}
```

### 3. State Cleanup
```typescript
export class BaseComponent implements OnDestroy {
  protected destroyed$ = new Subject<void>();
  
  ngOnDestroy() {
    this.destroyed$.next();
    this.destroyed$.complete();
  }
}
```

## Best Practices

### 1. State Isolation
- Keep state close to where it's used
- Use appropriate service scope
- Minimize global state
- Clear state ownership

### 2. Subscription Management
- Always cleanup subscriptions
- Use appropriate RxJS operators
- Handle memory leaks
- Use takeUntil pattern

### 3. State Updates
- Immutable state changes
- Atomic updates
- Consistent error handling
- State validation

### 4. Performance
- Use appropriate Subject types
- Implement caching where needed
- Optimize subscription chains
- Minimize state updates

## Common Patterns

### 1. State Initialization
```typescript
ngOnInit() {
  this.initializeState();
  this.setupSubscriptions();
  this.loadInitialData();
}
```

### 2. State Reset
```typescript
resetState() {
  this.loading = false;
  this.errors = {};
  this.data = null;
}
```

### 3. Error State
```typescript
handleError(error: any) {
  this.errors = error;
  this.loading = false;
  this.notifyError();
}
```

## Dependencies
- RxJS
- @angular/core
- @angular/forms
- Core services

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial state management patterns documentation 