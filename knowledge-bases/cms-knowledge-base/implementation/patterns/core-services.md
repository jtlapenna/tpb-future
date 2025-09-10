# Core Service Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the core service patterns implemented in the CMS, focusing on the base CRUD service and its extensions.

## Base CRUD Service Pattern

### Implementation
The base CRUD service (`CrudService<T>`) provides a generic implementation for common CRUD operations:

```typescript
@Injectable()
export abstract class CrudService<T> {
  constructor(protected http: HttpClient) { }
  
  abstract createResource(params: any): T;
  abstract resourceName({ plural }?: { plural?: boolean }): string;
}
```

### Key Features

1. **Generic Type Support**
   - Uses TypeScript generics for type-safe resource handling
   - Enforces consistent resource creation through abstract methods

2. **Resource Management**
   - Standardized path generation
   - Configurable parent-child relationships
   - Dynamic resource naming

3. **API Operations**
   - `all()`: Paginated list with sorting and filtering
   - `get()`: Single resource retrieval
   - `save()`: Combined create/update operation
   - `destroy()`: Resource deletion

4. **Request Customization**
   - Query parameter handling
   - Parent resource support
   - Resource name overrides

## Service Extensions

### List Component Integration
The `CrudListComponent<T>` provides a base implementation for list views:

```typescript
export class CrudListComponent<T> {
  constructor(
    private resourceSrv: CrudService<T>, 
    sidebarSrv: SidebarService
  ) { }
  
  protected loadResources(page?: number, filters?: any)
  onFilterChange(filters: FilterValue[])
  search(especifiedFilter?: {id:string, label:string})
}
```

### Key Features
1. **Pagination Support**
   - Page size configuration
   - Current page tracking
   - Total count management

2. **Sorting Capabilities**
   - Dynamic sort property selection
   - Direction toggling
   - Default sort configuration

3. **Filtering System**
   - Filter value management
   - Search functionality
   - Filter to parameter conversion

## Implementation Examples

### Basic Service Extension
```typescript
@Injectable()
export class LayoutPositionService extends CrudService<LayoutPosition> {
  createResource(params: any): LayoutPosition {
    return new LayoutPosition(params);
  }

  resourceName({plural}: {plural?: boolean} = {}): string {
    return plural ? 'layout_positions' : 'layout_position';
  }
}
```

### Custom Service Implementation
```typescript
@Injectable()
export class StoreSyncService {
  constructor(private http: HttpClient) {}
  
  // Custom implementation for specific business logic
  process(id: number, storeId: number, item: StoreSyncItem): Observable<any>
  finish(id: number, storeId: number): Observable<boolean>
}
```

## Best Practices

1. **Resource Naming**
   - Use consistent singular/plural forms
   - Follow REST conventions
   - Maintain clear parent-child relationships

2. **Error Handling**
   - Implement error catching at service level
   - Transform API errors to application-specific formats
   - Provide meaningful error feedback

3. **Type Safety**
   - Use TypeScript interfaces for models
   - Implement proper type guards
   - Maintain strict type checking

4. **Request Management**
   - Handle request cancellation
   - Implement proper retry strategies
   - Manage request state effectively

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial core service patterns documentation | 