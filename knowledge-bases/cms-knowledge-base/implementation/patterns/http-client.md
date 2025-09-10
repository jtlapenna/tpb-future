# HTTP Client Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the HTTP client patterns implemented in the CMS, focusing on request handling, response transformation, and error management.

## Core HTTP Patterns

### Base HTTP Service
The application uses Angular's `HttpClient` with custom interceptors and service wrappers:

```typescript
@Injectable()
export abstract class CrudService<T> {
  constructor(protected http: HttpClient) { }
  
  // HTTP methods with type-safe responses
  get<T>(url: string): Observable<T>
  post<T>(url: string, body: any): Observable<T>
  put<T>(url: string, body: any): Observable<T>
  delete<T>(url: string): Observable<T>
}
```

### Request Configuration

1. **URL Construction**
   ```typescript
   resourcePath({ parentId }: { parentId?: number } = {}): string {
     return this.resourceName({ plural: true });
   }
   ```

2. **Query Parameters**
   ```typescript
   let params = new HttpParams()
     .set('page', page.toString())
     .set('per_page', pageSize.toString())
     .set('sort_by', sort.prop)
     .set('sort_direction', sort.direction);
   ```

3. **Request Body**
   ```typescript
   const params = {};
   params[this.resourceName()] = resource;
   return this.http.post(url, params);
   ```

## Response Handling

### Data Transformation
```typescript
return this.http.get<any>(url).pipe(
  map(data => {
    const pagination = new Pagination(data.meta);
    return {
      pagination,
      resources: data[this.resourceName({ plural: true })]
        .map(c => this.createResource(c))
    };
  })
);
```

### File Upload
```typescript
export class AssetsService {
  authorizeAsset(resource: string, name: string): Observable<S3UrlData> {
    const params = new HttpParams()
      .set('resource', resource)
      .set('resource_name', name);

    return this.http.get<any>(url, { params }).pipe(
      map(data => data.url_data),
      map(data => ({
        uploadUrl: data.upload_url,
        publicUrl: data.public_url
      }))
    );
  }
}
```

## Error Handling

### Global Error Interceptor
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

### Service-Level Error Handling
```typescript
destroy(id: number): Observable<boolean> {
  return this.http.delete<any>(url).pipe(
    map(data => true),
    catchError(response => observableOf(false))
  );
}
```

## Implementation Patterns

### Resource Services
1. **Base CRUD Operations**
   - Standard CRUD endpoints
   - Resource transformation
   - Error handling

2. **Specialized Operations**
   - Custom endpoints
   - Complex data transformations
   - File uploads

3. **Response Mapping**
   - Type-safe responses
   - Data normalization
   - Error transformation

## Best Practices

1. **Request Configuration**
   - Use type-safe request bodies
   - Configure appropriate headers
   - Handle query parameters consistently

2. **Response Handling**
   - Transform responses to domain models
   - Handle pagination consistently
   - Normalize data structures

3. **Error Management**
   - Use global error interceptor
   - Implement service-specific error handling
   - Provide meaningful error messages

4. **Performance**
   - Implement request caching where appropriate
   - Use proper RxJS operators
   - Handle request cancellation

## Testing Patterns

```typescript
describe('TagsService', () => {
  let service: TagsService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [TagsService]
    });

    service = TestBed.get(TagsService);
    httpMock = TestBed.get(HttpTestingController);
  });

  it('should return tags', (done) => {
    service.search('tag').subscribe(tags => {
      expect(tags).toEqual(['tag 1', 'tag 2']);
      done();
    });

    httpMock.expectOne(url).flush({
      tags: [
        { name: 'tag 1' },
        { name: 'tag 2' }
      ]
    });
  });
});
```

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial HTTP client patterns documentation | 