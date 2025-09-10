# Kiosk Display Component Example

## Overview
This example demonstrates a complete implementation of a kiosk display component, including TypeScript code, template, styling, and tests.

## Implementation

### Component Class
```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { KioskService } from '@services/kiosk.service';
import { DisplayConfig } from '@models/display.model';

@Component({
  selector: 'app-kiosk-display',
  templateUrl: './kiosk-display.component.html',
  styleUrls: ['./kiosk-display.component.scss']
})
export class KioskDisplayComponent implements OnInit, OnDestroy {
  displayForm: FormGroup;
  loading = false;
  private destroyed$ = new Subject<void>();

  constructor(
    private fb: FormBuilder,
    private kioskService: KioskService
  ) {
    this.createForm();
  }

  ngOnInit(): void {
    this.loadDisplayConfig();
  }

  ngOnDestroy(): void {
    this.destroyed$.next();
    this.destroyed$.complete();
  }

  private createForm(): void {
    this.displayForm = this.fb.group({
      name: ['', [Validators.required]],
      layout: ['menu_boards', [Validators.required]],
      refreshInterval: [30, [Validators.required, Validators.min(0), Validators.max(60)]],
      enabled: [true]
    });
  }

  private loadDisplayConfig(): void {
    this.loading = true;
    this.kioskService.getDisplayConfig()
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: (config: DisplayConfig) => {
          this.displayForm.patchValue(config);
          this.loading = false;
        },
        error: () => {
          this.loading = false;
        }
      });
  }

  onSubmit(): void {
    if (this.displayForm.valid) {
      this.loading = true;
      const config: DisplayConfig = this.displayForm.getRawValue();
      
      this.kioskService.updateDisplayConfig(config)
        .pipe(takeUntil(this.destroyed$))
        .subscribe({
          next: () => {
            this.loading = false;
            // Handle success
          },
          error: () => {
            this.loading = false;
            // Handle error
          }
        });
    }
  }
}
```

### Template
```html
<div class="kiosk-display">
  <h2>Display Configuration</h2>
  
  <form [formGroup]="displayForm" (ngSubmit)="onSubmit()">
    <div class="form-group">
      <label for="name">Display Name</label>
      <input
        id="name"
        type="text"
        formControlName="name"
        class="form-control"
        [class.is-invalid]="displayForm.get('name').invalid && displayForm.get('name').touched"
      >
      <div class="invalid-feedback" *ngIf="displayForm.get('name').errors?.required">
        Display name is required
      </div>
    </div>

    <div class="form-group">
      <label for="layout">Layout Type</label>
      <select
        id="layout"
        formControlName="layout"
        class="form-control"
      >
        <option value="menu_boards">Menu Boards</option>
        <option value="product_grid">Product Grid</option>
        <option value="carousel">Carousel</option>
      </select>
    </div>

    <div class="form-group">
      <label for="refreshInterval">Refresh Interval (seconds)</label>
      <input
        id="refreshInterval"
        type="number"
        formControlName="refreshInterval"
        class="form-control"
        [class.is-invalid]="displayForm.get('refreshInterval').invalid && displayForm.get('refreshInterval').touched"
      >
      <div class="invalid-feedback" *ngIf="displayForm.get('refreshInterval').errors?.min">
        Interval must be at least 0 seconds
      </div>
      <div class="invalid-feedback" *ngIf="displayForm.get('refreshInterval').errors?.max">
        Interval cannot exceed 60 seconds
      </div>
    </div>

    <div class="form-group">
      <div class="custom-control custom-switch">
        <input
          type="checkbox"
          class="custom-control-input"
          id="enabled"
          formControlName="enabled"
        >
        <label class="custom-control-label" for="enabled">Enable Display</label>
      </div>
    </div>

    <button
      type="submit"
      class="btn btn-primary"
      [disabled]="displayForm.invalid || loading"
    >
      <span *ngIf="loading" class="spinner-border spinner-border-sm mr-1"></span>
      Save Configuration
    </button>
  </form>
</div>
```

### Styling
```scss
.kiosk-display {
  padding: 1.5rem;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);

  h2 {
    margin-bottom: 1.5rem;
    color: #333;
  }

  .form-group {
    margin-bottom: 1.25rem;

    label {
      font-weight: 500;
      margin-bottom: 0.5rem;
    }
  }

  .custom-switch {
    padding-left: 2.25rem;
    margin-bottom: 1rem;
  }

  .btn-primary {
    min-width: 150px;

    &:disabled {
      cursor: not-allowed;
    }
  }

  .spinner-border {
    margin-right: 0.5rem;
  }
}
```

### Unit Tests
```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { of, throwError } from 'rxjs';
import { KioskDisplayComponent } from './kiosk-display.component';
import { KioskService } from '@services/kiosk.service';

describe('KioskDisplayComponent', () => {
  let component: KioskDisplayComponent;
  let fixture: ComponentFixture<KioskDisplayComponent>;
  let kioskService: jasmine.SpyObj<KioskService>;

  beforeEach(async () => {
    const spy = jasmine.createSpyObj('KioskService', ['getDisplayConfig', 'updateDisplayConfig']);
    spy.getDisplayConfig.and.returnValue(of({
      name: 'Test Display',
      layout: 'menu_boards',
      refreshInterval: 30,
      enabled: true
    }));

    await TestBed.configureTestingModule({
      declarations: [ KioskDisplayComponent ],
      imports: [ ReactiveFormsModule ],
      providers: [
        { provide: KioskService, useValue: spy }
      ]
    }).compileComponents();

    kioskService = TestBed.inject(KioskService) as jasmine.SpyObj<KioskService>;
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(KioskDisplayComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load display config on init', () => {
    expect(kioskService.getDisplayConfig).toHaveBeenCalled();
    expect(component.displayForm.get('name').value).toBe('Test Display');
  });

  it('should validate form fields', () => {
    const form = component.displayForm;
    form.patchValue({
      name: '',
      refreshInterval: 70
    });

    expect(form.valid).toBeFalse();
    expect(form.get('name').errors?.required).toBeTrue();
    expect(form.get('refreshInterval').errors?.max).toBeTrue();
  });

  it('should handle submit when form is valid', () => {
    const config = {
      name: 'Updated Display',
      layout: 'product_grid',
      refreshInterval: 45,
      enabled: true
    };

    kioskService.updateDisplayConfig.and.returnValue(of(void 0));
    component.displayForm.patchValue(config);
    component.onSubmit();

    expect(kioskService.updateDisplayConfig).toHaveBeenCalledWith(config);
  });

  it('should handle errors during config update', () => {
    kioskService.updateDisplayConfig.and.returnValue(throwError(() => new Error()));
    component.displayForm.patchValue({
      name: 'Test',
      layout: 'menu_boards',
      refreshInterval: 30,
      enabled: true
    });

    component.onSubmit();
    expect(component.loading).toBeFalse();
  });
});
```

## Usage
```typescript
// In your module file
@NgModule({
  declarations: [KioskDisplayComponent],
  imports: [
    CommonModule,
    ReactiveFormsModule
  ],
  exports: [KioskDisplayComponent]
})
export class KioskModule { }

// In your parent component template
<app-kiosk-display></app-kiosk-display>
```

## Best Practices Demonstrated

1. **Component Structure**
   - Clear separation of concerns
   - Proper lifecycle management
   - Type safety
   - Form validation

2. **RxJS Usage**
   - Proper subscription management
   - Error handling
   - Loading state management
   - Cleanup on destroy

3. **Testing**
   - Component creation
   - Service integration
   - Form validation
   - Error scenarios

4. **Styling**
   - BEM methodology
   - Responsive design
   - Accessibility considerations
   - Visual feedback

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial component example | 