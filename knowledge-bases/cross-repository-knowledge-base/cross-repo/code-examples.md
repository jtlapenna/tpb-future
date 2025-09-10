# Code Examples Reference

## Overview
This document provides concrete code examples that demonstrate key patterns and concepts identified during the cross-repository analysis. These examples serve as reference implementations to illustrate recommended approaches and best practices for future development.

## API Implementation Examples

### RESTful API Controller

```ruby
# Example of a well-structured Rails controller following RESTful principles
class ProductsController < ApplicationController
  # GET /products
  def index
    products = Product.includes(:category).paginate(page: params[:page], per_page: 20)
    
    # Consistent response envelope
    render json: {
      data: products,
      meta: {
        total: products.total_entries,
        page: products.current_page,
        per_page: products.per_page
      }
    }
  end

  # GET /products/:id
  def show
    product = Product.find(params[:id])
    
    render json: {
      data: product
    }
  rescue ActiveRecord::RecordNotFound
    # Consistent error response format
    render json: {
      errors: [{
        code: "NOT_FOUND",
        message: "Product not found",
        field: "id"
      }]
    }, status: :not_found
  end

  # POST /products
  def create
    product = Product.new(product_params)
    
    if product.save
      render json: { data: product }, status: :created
    else
      # Structured validation error response
      render json: { 
        errors: product.errors.map { |field, message| 
          { field: field, message: message, code: "VALIDATION_ERROR" } 
        }
      }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /products/:id
  def update
    product = Product.find(params[:id])
    
    if product.update(product_params)
      render json: { data: product }
    else
      render json: { 
        errors: product.errors.map { |field, message| 
          { field: field, message: message, code: "VALIDATION_ERROR" } 
        }
      }, status: :unprocessable_entity
    end
  end

  # DELETE /products/:id
  def destroy
    product = Product.find(params[:id])
    product.destroy
    
    head :no_content
  end
  
  private
  
  def product_params
    params.require(:product).permit(:name, :price, :description, :category_id)
  end
end
```

### API Service Layer

```ruby
# Example of a service object implementing business logic
class ProductService
  def initialize(logger = Rails.logger)
    @logger = logger
  end
  
  def create_product(params, current_user)
    result = { success: false, product: nil, errors: [] }
    
    begin
      ActiveRecord::Base.transaction do
        # Authorization check
        unless current_user.can?(:create_product)
          raise AuthorizationError.new("Not authorized to create products")
        end
        
        # Create the product
        product = Product.new(params)
        product.created_by = current_user.id
        
        unless product.save
          raise ValidationError.new("Invalid product data", product.errors)
        end
        
        # Create initial inventory record
        inventory = Inventory.create!(
          product_id: product.id,
          quantity: 0,
          status: 'pending'
        )
        
        # Log the product creation
        @logger.info("Product created", {
          product_id: product.id,
          user_id: current_user.id,
          inventory_id: inventory.id
        })
        
        # Publish event for other services
        EventPublisher.publish('product.created', {
          product_id: product.id,
          name: product.name,
          category_id: product.category_id
        })
        
        result[:success] = true
        result[:product] = product
      end
    rescue ValidationError => e
      result[:errors] = e.errors.map { |field, message| 
        { field: field, message: message, code: "VALIDATION_ERROR" }
      }
      @logger.warn("Product creation failed - validation", {
        errors: result[:errors],
        user_id: current_user.id
      })
    rescue AuthorizationError => e
      result[:errors] << { message: e.message, code: "AUTHORIZATION_ERROR" }
      @logger.warn("Product creation failed - authorization", {
        message: e.message,
        user_id: current_user.id
      })
    rescue StandardError => e
      result[:errors] << { message: "An unexpected error occurred", code: "SERVER_ERROR" }
      @logger.error("Product creation failed - unexpected", {
        error: e.message,
        backtrace: e.backtrace.join("\n"),
        user_id: current_user.id
      })
    end
    
    result
  end
  
  # Additional methods for other product operations...
end

# Custom error classes
class ValidationError < StandardError
  attr_reader :errors
  
  def initialize(message, errors)
    super(message)
    @errors = errors
  end
end

class AuthorizationError < StandardError
end
```

## Transaction Management Examples

### Database Transaction Example

```ruby
# Example of proper transaction handling
class OrderProcessor
  def process_order(order_data, user)
    ActiveRecord::Base.transaction do
      # Create the order
      order = Order.create!(
        user_id: user.id,
        status: 'pending',
        total: calculate_total(order_data[:items])
      )
      
      # Create order items
      order_data[:items].each do |item_data|
        order.order_items.create!(
          product_id: item_data[:product_id],
          quantity: item_data[:quantity],
          unit_price: item_data[:price]
        )
      end
      
      # Update inventory
      update_inventory(order_data[:items])
      
      # Process payment
      process_payment(order, order_data[:payment])
      
      # Update order status
      order.update!(status: 'processed')
      
      # Return the created order
      order
    end
  rescue ActiveRecord::RecordInvalid => e
    # Handle validation errors
    Rails.logger.error("Order validation failed: #{e.message}")
    raise OrderProcessingError.new("Validation failed: #{e.message}")
  rescue PaymentProcessingError => e
    # Handle payment failures
    Rails.logger.error("Payment processing failed: #{e.message}")
    raise OrderProcessingError.new("Payment failed: #{e.message}")
  rescue StandardError => e
    # Handle unexpected errors
    Rails.logger.error("Order processing failed: #{e.message}\n#{e.backtrace.join("\n")}")
    raise OrderProcessingError.new("Order processing failed")
  end
  
  private
  
  def calculate_total(items)
    items.sum { |item| item[:price] * item[:quantity] }
  end
  
  def update_inventory(items)
    items.each do |item|
      inventory = Inventory.find_by!(product_id: item[:product_id])
      
      # Ensure sufficient inventory
      if inventory.quantity < item[:quantity]
        raise InventoryError.new("Insufficient inventory for product #{item[:product_id]}")
      end
      
      # Update inventory
      inventory.with_lock do
        inventory.quantity -= item[:quantity]
        inventory.save!
      end
    end
  end
  
  def process_payment(order, payment_data)
    # Payment processing logic
    # ...
    
    # If payment fails, this would raise a PaymentProcessingError
    # which will trigger a transaction rollback
  end
end

class OrderProcessingError < StandardError; end
class InventoryError < StandardError; end
class PaymentProcessingError < StandardError; end
```

### Distributed Transaction Example

```ruby
# Example of coordination between multiple services
class OrderCoordinator
  def initialize
    @payment_service = PaymentService.new
    @inventory_service = InventoryService.new
    @notification_service = NotificationService.new
  end
  
  def place_order(order_data, user)
    # Step 1: Create the order in pending state
    order = create_order(order_data, user)
    
    begin
      # Step 2: Reserve inventory
      reservation_id = reserve_inventory(order)
      
      # Step 3: Process payment
      payment_id = process_payment(order)
      
      # Step 4: Confirm order
      confirm_order(order, reservation_id, payment_id)
      
      # Step 5: Send notifications
      send_notifications(order)
      
      # Return successful result
      { success: true, order_id: order.id }
    rescue StandardError => e
      # Handle failure with compensating actions
      handle_failure(order, e)
      
      # Return failure result
      { success: false, error: e.message }
    end
  end
  
  private
  
  def create_order(order_data, user)
    # Create the order in a pending state
    # ...
  end
  
  def reserve_inventory(order)
    # Call inventory service to reserve inventory
    result = @inventory_service.reserve(
      order_id: order.id,
      items: order.order_items.map { |item| 
        { product_id: item.product_id, quantity: item.quantity } 
      }
    )
    
    if result[:success]
      result[:reservation_id]
    else
      raise InventoryReservationError.new(result[:error])
    end
  end
  
  def process_payment(order)
    # Call payment service to process payment
    result = @payment_service.process(
      order_id: order.id,
      amount: order.total,
      payment_method: order.payment_method
    )
    
    if result[:success]
      result[:payment_id]
    else
      # This will trigger compensation in the rescue block
      raise PaymentProcessingError.new(result[:error])
    end
  end
  
  def confirm_order(order, reservation_id, payment_id)
    # Update order status to confirmed
    order.update!(
      status: 'confirmed',
      reservation_id: reservation_id,
      payment_id: payment_id
    )
  end
  
  def send_notifications(order)
    # Send confirmation notifications
    @notification_service.send_order_confirmation(order)
  end
  
  def handle_failure(order, error)
    # Log the failure
    Rails.logger.error("Order #{order.id} failed: #{error.message}")
    
    # Update order status
    order.update(status: 'failed', error_message: error.message)
    
    # Perform compensating actions based on what succeeded
    
    if error.is_a?(PaymentProcessingError)
      # Payment failed, release inventory reservation
      @inventory_service.release_reservation(order.reservation_id) if order.reservation_id
    end
    
    # No need to reverse the payment if it failed
    
    # Send failure notification to the user
    @notification_service.send_order_failure(order)
  end
end

class InventoryReservationError < StandardError; end
class PaymentProcessingError < StandardError; end
```

## Frontend Component Examples

### Vue.js Component Structure

```javascript
// ProductList.vue - Example of a container component with proper separation of concerns

<template>
  <div class="product-list">
    <!-- Loading state -->
    <div v-if="loading" class="loading-state">
      <loading-spinner />
    </div>
    
    <!-- Error state -->
    <div v-else-if="error" class="error-state">
      <error-message :message="error" @retry="fetchProducts" />
    </div>
    
    <!-- Filter controls -->
    <product-filters 
      v-else
      :categories="categories"
      :selected-category="filters.categoryId"
      :price-range="filters.priceRange"
      @filter-change="handleFilterChange"
    />
    
    <!-- Product grid - presentational component -->
    <product-grid 
      v-if="!loading && !error"
      :products="products" 
      @product-click="handleProductClick"
    />
    
    <!-- Pagination - presentational component -->
    <pagination
      v-if="!loading && !error && totalPages > 1"
      :current-page="currentPage"
      :total-pages="totalPages"
      @page-change="handlePageChange"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';
import LoadingSpinner from '@/components/common/LoadingSpinner.vue';
import ErrorMessage from '@/components/common/ErrorMessage.vue';
import ProductFilters from '@/components/products/ProductFilters.vue';
import ProductGrid from '@/components/products/ProductGrid.vue';
import Pagination from '@/components/common/Pagination.vue';

export default {
  name: 'ProductList',
  
  components: {
    LoadingSpinner,
    ErrorMessage,
    ProductFilters,
    ProductGrid,
    Pagination
  },
  
  data() {
    return {
      filters: {
        categoryId: null,
        priceRange: [0, 1000],
        sortBy: 'name'
      },
      currentPage: 1
    };
  },
  
  computed: {
    ...mapGetters('products', [
      'products',
      'loading',
      'error',
      'categories',
      'totalProducts',
      'perPage'
    ]),
    
    totalPages() {
      return Math.ceil(this.totalProducts / this.perPage);
    }
  },
  
  created() {
    // Load categories when component is created
    this.fetchCategories();
    
    // Initial products fetch
    this.fetchProducts({
      page: this.currentPage,
      ...this.filters
    });
  },
  
  methods: {
    ...mapActions('products', [
      'fetchProducts',
      'fetchCategories'
    ]),
    
    handleFilterChange(newFilters) {
      this.filters = { ...this.filters, ...newFilters };
      this.currentPage = 1; // Reset to first page when filters change
      
      this.fetchProducts({
        page: this.currentPage,
        ...this.filters
      });
    },
    
    handlePageChange(page) {
      this.currentPage = page;
      
      this.fetchProducts({
        page: this.currentPage,
        ...this.filters
      });
    },
    
    handleProductClick(product) {
      this.$router.push({ 
        name: 'product-details', 
        params: { id: product.id } 
      });
    }
  }
};
</script>
```

### Angular Component Example

```typescript
// product-list.component.ts - Example of an Angular component with proper separation of concerns

import { Component, OnInit, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { Subscription } from 'rxjs';
import { ProductService } from '../../services/product.service';
import { CategoryService } from '../../services/category.service';
import { Product } from '../../models/product.model';
import { Category } from '../../models/category.model';
import { ProductFilters } from '../../models/product-filters.model';

@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html',
  styleUrls: ['./product-list.component.scss']
})
export class ProductListComponent implements OnInit, OnDestroy {
  products: Product[] = [];
  categories: Category[] = [];
  filters: ProductFilters = {
    categoryId: null,
    priceRange: [0, 1000],
    sortBy: 'name'
  };
  currentPage = 1;
  totalPages = 1;
  loading = false;
  error: string | null = null;
  
  private subscriptions: Subscription[] = [];
  
  constructor(
    private productService: ProductService,
    private categoryService: CategoryService,
    private router: Router
  ) {}
  
  ngOnInit(): void {
    // Load categories
    this.loadCategories();
    
    // Initial products load
    this.loadProducts();
  }
  
  ngOnDestroy(): void {
    // Clean up subscriptions to prevent memory leaks
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
  
  loadCategories(): void {
    this.loading = true;
    
    const categorySub = this.categoryService.getCategories().subscribe(
      (categories) => {
        this.categories = categories;
      },
      (error) => {
        this.error = 'Failed to load categories';
        console.error('Category loading error:', error);
      }
    );
    
    this.subscriptions.push(categorySub);
  }
  
  loadProducts(): void {
    this.loading = true;
    this.error = null;
    
    const productSub = this.productService.getProducts({
      page: this.currentPage,
      ...this.filters
    }).subscribe(
      (response) => {
        this.products = response.data;
        this.totalPages = Math.ceil(response.meta.total / response.meta.perPage);
        this.loading = false;
      },
      (error) => {
        this.error = 'Failed to load products';
        this.loading = false;
        console.error('Product loading error:', error);
      }
    );
    
    this.subscriptions.push(productSub);
  }
  
  onFilterChange(newFilters: Partial<ProductFilters>): void {
    this.filters = { ...this.filters, ...newFilters };
    this.currentPage = 1; // Reset to first page
    this.loadProducts();
  }
  
  onPageChange(page: number): void {
    this.currentPage = page;
    this.loadProducts();
  }
  
  onProductClick(product: Product): void {
    this.router.navigate(['/products', product.id]);
  }
}
```

## State Management Examples

### Vuex Store Module

```javascript
// store/modules/products.js - Example of a well-structured Vuex module

import productsApi from '@/api/products';

const state = {
  products: [],
  categories: [],
  loading: false,
  error: null,
  totalProducts: 0,
  perPage: 20
};

const getters = {
  products: state => state.products,
  categories: state => state.categories,
  loading: state => state.loading,
  error: state => state.error,
  totalProducts: state => state.totalProducts,
  perPage: state => state.perPage,
};

const actions = {
  // Fetch products with filters
  async fetchProducts({ commit }, params) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      const response = await productsApi.getProducts(params);
      commit('SET_PRODUCTS', response.data);
      commit('SET_TOTAL_PRODUCTS', response.meta.total);
      commit('SET_LOADING', false);
    } catch (error) {
      commit('SET_ERROR', 'Failed to load products');
      commit('SET_LOADING', false);
      console.error('Error fetching products:', error);
    }
  },
  
  // Fetch categories
  async fetchCategories({ commit }) {
    try {
      const response = await productsApi.getCategories();
      commit('SET_CATEGORIES', response.data);
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  },
  
  // Add a product to the cart
  async addToCart({ commit, dispatch }, product) {
    try {
      await productsApi.addToCart(product.id);
      dispatch('cart/fetchCart', null, { root: true }); // Refresh cart
      commit('SET_NOTIFICATION', {
        type: 'success',
        message: `${product.name} added to cart`
      }, { root: true });
    } catch (error) {
      commit('SET_NOTIFICATION', {
        type: 'error',
        message: 'Failed to add product to cart'
      }, { root: true });
      console.error('Error adding to cart:', error);
    }
  }
};

const mutations = {
  SET_PRODUCTS(state, products) {
    state.products = products;
  },
  SET_CATEGORIES(state, categories) {
    state.categories = categories;
  },
  SET_LOADING(state, isLoading) {
    state.loading = isLoading;
  },
  SET_ERROR(state, error) {
    state.error = error;
  },
  SET_TOTAL_PRODUCTS(state, total) {
    state.totalProducts = total;
  }
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
};
```

### Angular Service with State Management

```typescript
// product.service.ts - Example of an Angular service with state management

import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, throwError } from 'rxjs';
import { catchError, tap, map } from 'rxjs/operators';
import { Product } from '../models/product.model';
import { ProductFilters } from '../models/product-filters.model';
import { ApiResponse } from '../models/api-response.model';

@Injectable({
  providedIn: 'root'
})
export class ProductService {
  private productsSubject = new BehaviorSubject<Product[]>([]);
  private loadingSubject = new BehaviorSubject<boolean>(false);
  private errorSubject = new BehaviorSubject<string | null>(null);
  private totalSubject = new BehaviorSubject<number>(0);
  
  public products$ = this.productsSubject.asObservable();
  public loading$ = this.loadingSubject.asObservable();
  public error$ = this.errorSubject.asObservable();
  public total$ = this.totalSubject.asObservable();
  
  private apiUrl = '/api/products';
  
  constructor(private http: HttpClient) {}
  
  getProducts(params: ProductFilters & { page: number }): Observable<ApiResponse<Product[]>> {
    this.loadingSubject.next(true);
    this.errorSubject.next(null);
    
    return this.http.get<ApiResponse<Product[]>>(this.apiUrl, { params: this.formatParams(params) })
      .pipe(
        tap(response => {
          this.productsSubject.next(response.data);
          this.totalSubject.next(response.meta.total);
          this.loadingSubject.next(false);
        }),
        catchError(error => {
          this.loadingSubject.next(false);
          this.errorSubject.next('Failed to load products');
          console.error('Product service error:', error);
          return throwError('An error occurred while fetching products');
        })
      );
  }
  
  getProduct(id: number): Observable<Product> {
    return this.http.get<ApiResponse<Product>>(`${this.apiUrl}/${id}`)
      .pipe(
        map(response => response.data),
        catchError(error => {
          console.error(`Error fetching product ${id}:`, error);
          return throwError(`An error occurred while fetching product ${id}`);
        })
      );
  }
  
  private formatParams(params: any): any {
    // Format parameters for the API
    const formatted: any = {};
    
    if (params.page) formatted.page = params.page;
    if (params.categoryId) formatted.category_id = params.categoryId;
    if (params.sortBy) formatted.sort_by = params.sortBy;
    if (params.priceRange) {
      formatted.min_price = params.priceRange[0];
      formatted.max_price = params.priceRange[1];
    }
    
    return formatted;
  }
}
```

## Related Documentation
- [Knowledge Base Index](index.md) - Main analysis knowledge base entry point
- [Patterns Catalog](patterns-catalog.md) - Detailed pattern reference
- [Concepts Reference](concepts-reference.md) - Key concepts explanations
- [Implementation Plan](../cross-repo/verification/implementation-plan.md) - Recommendations for implementation 