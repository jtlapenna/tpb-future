# Multi-Tenant Architecture Pattern Validation

## Pattern Overview
**Pattern Name**: Multi-Tenant Architecture
**Pattern Description**: A system-wide approach for supporting multiple stores/brands/kiosks across all repositories through tenant isolation, shared services, and tenant-specific resource management.

## Validation Plan

### Implementation Evidence to Collect
- Backend tenant separation mechanisms
- Database schemas and tenant isolation approaches
- Frontend tenant identification and configuration
- CMS tenant management interfaces
- Resource access controls by tenant
- Cross-tenant functionality limitations
- Tenant-specific UI customization

### Validation Criteria
- Clear tenant identification mechanisms
- Data isolation between tenants
- Tenant-specific configuration
- Cross-tenant security boundaries
- Resource allocation by tenant
- Tenant management capabilities
- Tenant-specific customization

## Implementation Areas to Validate

### Backend (Ruby on Rails)
- [x] Database schema tenant isolation
- [x] API endpoint tenant scoping
- [x] Authentication with tenant context
- [x] Authorization with tenant boundaries
- [x] Tenant-specific configuration
- [x] Shared resource management
- [x] Cross-tenant access controls

### CMS Frontend (Angular)
- [x] Tenant selection interfaces
- [x] Tenant-specific management screens
- [x] Tenant isolation in data fetching
- [x] Tenant context in API requests
- [x] User interface tenant awareness
- [x] Tenant-specific configuration management

### Frontend (Vue.js)
- [x] Tenant identification in configuration
- [x] Tenant-specific initialization
- [x] Tenant context in API requests
- [x] Tenant-specific UI customization
- [x] Tenant-specific assets and resources

## Cross-Repository Validation
- [x] Consistent tenant identification across repositories
- [x] Tenant context preservation in cross-repository flows
- [x] Tenant isolation boundaries enforcement
- [x] Authorization consistency across repositories

## Implementation Evidence

### Backend (Ruby on Rails)

#### Database Schema Tenant Isolation
The backend implements a hierarchical tenant model with the following relationships:
```
Client → Store → [Kiosk, StoreCategory, StoreProduct, etc.]
```

Evidence from `app/models/client.rb`:
```ruby
class Client < ApplicationRecord
  has_many :stores, inverse_of: :client, dependent: :nullify
  has_many :users, dependent: :nullify

  validates :name, uniqueness: true, presence: true
end
```

Evidence from `app/models/store.rb`:
```ruby
class Store < ApplicationRecord
  belongs_to :client, inverse_of: :stores, optional: true
  
  has_many :kiosks, dependent: :nullify
  has_many :store_categories, dependent: :nullify
  has_many :store_products, through: :store_categories
  has_many :store_taxes, dependent: :nullify
  has_one :settings, class_name: 'StoreSetting', dependent: :nullify
  
  validates :name, presence: true, uniqueness: { scope: :client_id }
  
  # Store-specific settings
  store :api_settings, accessors: [...], coder: JSON
  store :notification_settings, accessors: [...], coder: JSON
```

The database schema shows clear tenant isolation with proper foreign key relationships from `stores` to `clients` table and from various resources to stores.

#### API Endpoint Tenant Scoping
The backend API controllers enforce tenant isolation through authentication and authorization:

Evidence from `app/controllers/api/v1/application_controller.rb`:
```ruby
class Api::V1::ApplicationController < ActionController::API
  include Knock::Authenticable
  include Rescuable
  before_action :render_error_when_invalid_auth_token, :except => [:ping]
  before_action :authenticate_store, :except => [:ping]
  
  # ...
  
  def kiosk
    current_store.kiosks.find(params[:catalog_id]) if params[:catalog_id]
  end
end
```

API controllers access data through the context of the authenticated store:
```ruby
def find_product
  @product ||= kiosk.kiosk_products.joins(:store_product).merge(
    StoreProduct.published
  ).find_by!(store_product_id: params[:id])  
end
```

#### Authentication with Tenant Context
Authentication for API endpoints includes the tenant (store) identity:

Evidence from `app/models/store.rb`:
```ruby
def self.from_token_payload(payload)
  store = Store.active.find_by(id: payload['sub'], jti: payload['jti'])

  # raise when not found
  if payload['aud'].blank? || payload['jti'].blank? ||
      !payload['aud'].include?('api') || store.blank?
    raise Knock.not_found_exception_class_name
  end

  store
end

def to_token_payload
  payload = { sub: id, aud: [:api], jti: jti }
  payload
end
```

#### Authorization with Tenant Boundaries
Pundit policies enforce tenant boundaries in the backend:

Evidence from `app/policies/store_policy.rb`:
```ruby
class StorePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.owner(user)
      end
    end
  end
  
  # ...
end
```

Evidence from `app/models/store.rb`:
```ruby
scope :owner, lambda { |owner|
  joins(client: :users)
    .merge(User.where(id: owner))
}
```

#### Tenant-specific Configuration
Each store has its own configuration managed through the `StoreSetting` model:

Evidence from `app/models/store_setting.rb`:
```ruby
class StoreSetting < ApplicationRecord
  belongs_to :store, inverse_of: :settings
  
  store :data, accessors: %i[
    admin_email printer_location pos_location main_color secondary_color
    # ... more tenant-specific configuration properties
  ], coder: JSON
end
```

### CMS Frontend (Angular)

#### Tenant Selection Interfaces
The CMS provides interfaces for administrators to select and manage different tenants:

Evidence from `repositories/cms-fe-angular/src/app/stores/store/store.component.html`:
```html
<div class="form-group select">
  <label for="client-select">Client</label>
  <ng-select
    formControlName="client_id"
    placeholder="Select client"
    [clearable]="true"
    bindValue="id"
    bindLabel="text"
    [loading]="clientPaginator.loading"
    (scrollToEnd)="clientPaginator.loadMore()"
    [items]="clientPaginator.options"
    [typeahead]="clientPaginator.searchEvent"
    class="peak"
  >
  </ng-select>
</div>
```

The Store component in the CMS allows administrators to create and manage stores (tenants):
```typescript
export class StoreComponent implements OnInit, OnDestroy {
  resourceForm: FormGroup;
  resource: Store = new Store({});
  clients: Client[] = [];
  // ...
  
  constructor(
    private fb: FormBuilder,
    private resourceSrv: StoreService,
    private clientSrv: ClientService,
    // ...
  ) {
    this.clientPaginator = new AutocompletePaginator(clientSrv);
    // ...
  }
}
```

#### Tenant-specific Management Screens
The CMS provides dedicated screens for managing tenant-specific settings:

Evidence from `repositories/cms-fe-angular/src/app/stores/models/store.ts`:
```typescript
export class Store {
  id: number;
  name: string;
  logo: Asset;
  client: Client = new Client({});
  settings: StoreSettings;
  categories: StoreCategory[] = [];
  token: string;
  // ...
}
```

#### Tenant Isolation in Data Fetching
Services in the CMS maintain tenant isolation when fetching data:

Evidence from `repositories/cms-fe-angular/src/app/stores/services/store-tax.service.ts`:
```typescript
export class StoreTaxService extends CrudService<Tax> {
  private taxConfiguration: TaxConfiguration;

  resourcePath({ parentId }: { parentId?: number } = {}): string {
    if (!this.taxConfiguration.isCategory) {
      return `stores/${this.taxConfiguration.storeId}/store_taxes/`;
    }
    if (this.taxConfiguration.isCategory) {
      return `stores/${this.taxConfiguration.storeId}/store_categories/${this.taxConfiguration.categoryId}/store_category_taxes/`;
    }
  }
}
```

### Frontend (Vue.js)

#### Tenant Identification in Configuration
The frontend application identifies tenants through environment configuration:

Evidence from `repositories/front-end/src/main.js`:
```javascript
// Get store information before mounting the app
if (window.isSecureContext) {
  console.log('Secure context, use cache config')
  document.getElementById('output').innerHTML =
    'Secure context, use cache config'
  useCacheConfig()
}
```

Evidence from `repositories/front-end/src/api/http.js`:
```javascript
const TPB_API_URL = process.env.TPB_API_URL ? process.env.TPB_API_URL : self.kioskConfig.API.URL
const TPB_CATALOG_ID = process.env.TPB_CATALOG_ID ? process.env.TPB_CATALOG_ID : self.kioskConfig.API.CATALOG_ID
const TPB_STORE_TOKEN = process.env.TPB_STORE_TOKEN ? process.env.TPB_STORE_TOKEN : self.kioskConfig.API.TOKEN

export const HTTP = axios.create({
  baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID,
  params: {
    token: TPB_STORE_TOKEN
  }
})
```

#### Tenant Context in API Requests
The frontend preserves tenant context in all API requests:

Evidence from `repositories/front-end/src/api/api.js`:
```javascript
class API {
  http
  constructor() {
    this.http = axios.create({
      baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID,
      params: {
        token: TPB_STORE_TOKEN
      },
      headers: {
        'Cache-Control': 'no-cache',
        Pragma: 'no-cache',
        Expires: '0'
      }
    })
  }
}
```

#### Tenant-specific UI Customization
The frontend supports tenant-specific UI customization:

Evidence from `repositories/front-end/static/js/config.js`:
```javascript
self.kioskConfig = {
  /**
   * UI colors
   * @type {String} Hex color
   */
  // MAIN_COLOR: '#00C796',
  // SECONDARY_COLOR: '#E12291',
  /**
   * Main background
   * @type {String} Media URL, can be an image or a video
   */
  // BACKGROUND: '/static/img/default-background.jpg',
  /**
   * Store logo
   * @type {String} Image URL, transparent PNG
   */
  // STORE_LOGO: '/static/img/default-store-logo.png',
  /**
   * API configuration
   * @param {String} URL
   * @param {String} CATALOG_ID
   * @param {String} TOKEN
   */
  API: {
    URL: 'https://api-prod.thepeakbeyond.com/api/v1',
    CATALOG_ID: 507,
    TOKEN: '...'
  }
}
```

## Implementation Consistency Matrix
| Multi-Tenant Aspect | Backend | CMS Frontend | Frontend |
|---------------------|---------|--------------|----------|
| Tenant Identification | Client → Store hierarchy | Store selector in UI | Environment variables and config |
| Data Isolation | Database schema scoping + Pundit policies | Service-level filtering | API calls with store token |
| Configuration | `StoreSetting` model | Store management UI | Environment/config variables |
| Access Controls | Pundit policies + scopes | Role-based UI display | Token-based isolation |
| UI Customization | N/A | Tenant-specific management | Theme settings per tenant |
| Tenant Management | Full CRUD operations | Admin UI for creation/management | Consumption of tenant config |

## Cross-Repository Consistency

The multi-tenant architecture implementation shows strong consistency across all repositories:
1. **Common Tenant Model**: Client → Store → Resources hierarchy is consistent
2. **Tenant Identification**: Using store IDs and tokens consistently as tenant identifiers
3. **Authorization Boundaries**: Proper tenant isolation in all repositories
4. **Configuration Management**: Tenant-specific settings stored in the backend and respected by frontends

## Recommendations

1. **Tenant Scoping Enhancement**: Consider implementing a more explicit tenant middleware in the backend that automatically scopes all queries to the current tenant without requiring explicit joins in controllers.

2. **Tenant Configuration Caching**: Implement more robust tenant configuration caching in the frontend to reduce configuration requests.

3. **Cross-Tenant Analytics**: Add capabilities to generate cross-tenant reports and analytics for admin users while maintaining strict data isolation for regular users.

4. **Tenant Migration**: Implement tooling to support migrating data between tenants when a client needs to reorganize their store structure.

## Cross-References
- Integration Patterns: `analysis/cross-repo/patterns/integration/integration-patterns.md`
- Final Synthesis: `analysis/cross-repo/final-synthesis.md` 