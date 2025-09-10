# Integration Patterns Analysis

**Version:** 1.2  
**Last Updated:** March 13, 2024

## Overview

The application implements several integration patterns to connect with third-party services and manage API versioning. This document outlines the key patterns identified in the codebase.

## Third-Party Integrations

### 1. POS System Integrations
The application supports multiple Point of Sale (POS) systems:
- Treez (v1.0, v2.0, v2.5)
- Headset
- Flowhub
- Leaflogix
- Shopify (2022-01)
- Covasoft
- Blaze

### 2. Integration Configuration
```typescript
interface IntegrationConfig {
  api_type: string;
  api_key: string;
  api_version: string;
  api_client_id: string;
  api_automatch: boolean;
  api_autopublish: boolean;
  override_on_sync: boolean;
  sync_frequency: number;
  sync_frequency_offset: number;
}
```

### 3. Integration Types

#### POS Integration
- Authentication (OAuth, API Keys)
- Store synchronization
- Product management
- Tax configuration
- Inventory management

#### Payment Gateway Integration
```typescript
class PaymentGateway {
  id: number;
  api_settings: any;
  projects: string[];
  payment_gateway_provider: PaymentGatewayProvider;
}
```

#### Kiosk Integration
```typescript
@Injectable()
export class KioskService extends CrudService<Kiosk> {
  // RFID Product Integration
  rfidsProducts(
    storeId: number, 
    configPage: Page[], 
    assing: AsingFunction,
    rfidType: string = 'KioskProduct'
  ): Observable<RfidProduct[]> {
    // Implementation
  }

  // Display Cloning
  duplicateDisplay(kioskId: number, formCloneValue?: {
    from_store_id: number,
    kiosk_new_name: string
  }): Observable<Kiosk> {
    // Implementation
  }
}
```

#### Tax Integration
```typescript
@Injectable()
export class StoreTaxService extends CrudService<Tax> {
  // Tax Configuration
  private taxConfiguration: TaxConfiguration;

  // Dynamic Resource Paths
  resourcePath({ parentId }: { parentId?: number } = {}): string {
    if (!this.taxConfiguration.isCategory) {
      return `stores/${this.taxConfiguration.storeId}/store_taxes/`;
    }
    if (this.taxConfiguration.isCategory) {
      return `stores/${this.taxConfiguration.storeId}/store_categories/${this.taxConfiguration.categoryId}/store_category_taxes/`;
    }
  }

  // Customer Type Integration
  getCustomerTypeOptions(storeId: number) {
    return this.http.get(`${environment.apiUrl}/stores/${storeId}/tax_customer_types`);
  }

  // Inventory Integration
  getInventoryTypeOptions(
    storeId: number,
    authorization_blaze: string,
    partner_key_blaze: string
  ) {
    return this.http.post(`${environment.apiUrl}/stores/get_inventory_data`, {
      authorization_blaze,
      partner_key_blaze
    });
  }
}
```

## API Versioning

### 1. Version Management
- Version-specific endpoints
- API version configuration per integration
- Backward compatibility support

### 2. Version Implementation
```typescript
get apiVersions() {
  if (this.isTreez()) {
    return [
      { id: 'v1.0', text: 'v1.0' },
      { id: 'v2.0', text: 'v2.0' },
      { id: 'v2.5', text: 'v2.5' }
    ];
  }
  if (this.isShopify()) {
    return [{ id: '2022-01', text: '2022-01' }];
  }
}
```

## Implementation Patterns

### 1. Service Layer
```typescript
@Injectable()
export class StoreSyncService {
  resourcePath(storeId: number) {
    return `${environment.apiUrl}/stores/${storeId}/store_syncs`;
  }

  create(storeId: number, file?: File): Observable<any> {
    // Implementation
  }
}
```

### 2. Error Handling
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

### 3. Webhook Integration
- Endpoint configuration per integration
- Webhook URL management
- Event handling

### 4. RFID Integration
```typescript
// RFID Product Management
interface RfidProduct {
  id: number;
  stock: number;
  rfid_entity_id: string | null;
}

// RFID Sorting
static notAvailableFirstOrder(a: RfidProduct, b: RfidProduct) {
  if (a.stock === 0) { return -1; }
  if (b.stock === 0) { return 1; }
  if (a.rfid_entity_id === null) { return -1; }
  if (b.rfid_entity_id === null) { return 1; }
  return a.id - b.id;
}
```

### 5. Tax Integration Patterns
- Store-level and category-level tax configuration
- Dynamic resource path generation based on context
- Integration with POS systems for tax rates
- Customer type-based tax rules
- Inventory-based tax rules

## Best Practices

1. **Authentication**
   - Secure API key storage
   - OAuth flow implementation
   - Token management

2. **Error Handling**
   - Consistent error format
   - Error tracking with Sentry
   - User-friendly error messages

3. **Sync Management**
   - Configurable sync frequency
   - Progress tracking
   - Error recovery

4. **RFID Management**
   - Stock tracking
   - Entity ID validation
   - Duplicate code prevention
   - Sorting by availability

5. **Tax Management**
   - Hierarchical tax configuration
   - POS system integration
   - Customer type validation
   - Inventory type validation

## Migration Considerations

### React Implementation Example
```typescript
const IntegrationProvider = ({ children }) => {
  const [config, setConfig] = useState({
    apiType: '',
    apiVersion: '',
    apiKey: ''
  });

  const syncData = useCallback(async () => {
    try {
      // Sync implementation
    } catch (error) {
      // Error handling
    }
  }, [config]);

  return (
    <IntegrationContext.Provider value={{ config, syncData }}>
      {children}
    </IntegrationContext.Provider>
  );
};
```

## Dependencies

- `@angular/core`
- `@angular/common/http`
- `rxjs`
- `@sentry/angular`
- Integration-specific packages

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial documentation of integration patterns |
| 1.1 | March 13, 2024 | Added Kiosk and RFID integration patterns |
| 1.2 | March 13, 2024 | Added Tax integration patterns | 