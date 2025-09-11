# Product Components Analysis

## Core Product Components

### 1. ProductCard.vue
**Path**: `src/components/ProductCard.vue`
**Purpose**: Main product display card component
**Complexity**: Complex
**Key Features**:
- Product image display
- Price formatting
- Add to cart functionality
- Product attributes (THC, CBD, etc.)
- Sale/promotion indicators
- Responsive design

### 2. ProductCardBlank.vue
**Path**: `src/components/ProductCardBlank.vue`
**Purpose**: Placeholder product card for loading states
**Complexity**: Simple
**Key Features**:
- Skeleton loading animation
- Consistent sizing with ProductCard
- Loading state indicators

### 3. ProductCardSale.vue
**Path**: `src/components/ProductCardSale.vue`
**Purpose**: Specialized product card for sale items
**Complexity**: Moderate
**Key Features**:
- Sale price display
- Original price strikethrough
- Sale badge/indicator
- Enhanced visual styling

### 4. ProductCardMenuBoard.vue
**Path**: `src/components/ProductCardMenuBoard.vue`
**Purpose**: Product card optimized for menu board display
**Complexity**: Moderate
**Key Features**:
- Large format display
- Menu board specific styling
- Touch-optimized interactions

### 5. ProductImage.vue
**Path**: `src/components/ProductImage.vue`
**Purpose**: Reusable product image component
**Complexity**: Moderate
**Key Features**:
- Image lazy loading
- Fallback handling
- Multiple image support
- Responsive sizing

### 6. ProductGraphs.vue
**Path**: `src/components/ProductGraphs.vue`
**Purpose**: Product data visualization (THC/CBD charts)
**Complexity**: Complex
**Key Features**:
- Chart.js integration
- Data visualization
- Interactive graphs
- Responsive charts

## Product Screen Components

### 7. ScreenProduct.vue
**Path**: `src/components/ScreenProduct.vue`
**Purpose**: Individual product detail screen
**Complexity**: Complex
**Key Features**:
- Product details display
- Image gallery
- Add to cart functionality
- Product specifications
- Related products

### 8. ScreenProductImage.vue
**Path**: `src/components/ScreenProductImage.vue`
**Purpose**: Full-screen product image display
**Complexity**: Moderate
**Key Features**:
- Full-screen image view
- Zoom functionality
- Image navigation
- Touch gestures

### 9. ScreenProductVideo.vue
**Path**: `src/components/ScreenProductVideo.vue`
**Purpose**: Product video display screen
**Complexity**: Moderate
**Key Features**:
- Video player integration
- Video controls
- Full-screen video
- Video metadata display

### 10. ScreenProducts.vue
**Path**: `src/components/ScreenProducts.vue`
**Purpose**: Product listing/grid screen
**Complexity**: Complex
**Key Features**:
- Product grid layout
- Filtering and sorting
- Pagination
- Search functionality
- Category filtering

### 11. ScreenProductsPromotions.vue
**Path**: `src/components/ScreenProductsPromotions.vue`
**Purpose**: Promotional products display
**Complexity**: Moderate
**Key Features**:
- Sale items display
- Promotion highlighting
- Special pricing display
- Promotional messaging

## Product Display Variants

### 12. ScreenFeaturedProducts.vue
**Path**: `src/components/ScreenFeaturedProducts.vue`
**Purpose**: Featured products showcase
**Complexity**: Moderate
**Key Features**:
- Featured product highlighting
- Special layout
- Promotional styling
- Curated product selection

### 13. ScreenHomeCards.vue
**Path**: `src/components/ScreenHomeCards.vue`
**Purpose**: Product cards on home screen
**Complexity**: Moderate
**Key Features**:
- Home screen product display
- Quick access to products
- Compact card format

### 14. ScreenHomeSplitCards.vue
**Path**: `src/components/ScreenHomeSplitCards.vue`
**Purpose**: Split-screen product display
**Complexity**: Moderate
**Key Features**:
- Dual product display
- Side-by-side layout
- Comparison functionality

### 15. ScreenHomeSpotlight.vue
**Path**: `src/components/ScreenHomeSpotlight.vue`
**Purpose**: Spotlight product display
**Complexity**: Moderate
**Key Features**:
- Single product focus
- Large format display
- Spotlight styling
- Featured product emphasis

### 16. ScreenHomeSpotlightCards.vue
**Path**: `src/components/ScreenHomeSpotlightCards.vue`
**Purpose**: Multiple spotlight products
**Complexity**: Moderate
**Key Features**:
- Multiple spotlight products
- Carousel/slider functionality
- Spotlight card layout

## Modernization Notes

### React/Next.js Equivalents
- **ProductCard** → React component with TypeScript interfaces
- **Product Screens** → Next.js pages with dynamic routing
- **ProductImage** → Next.js Image component with optimization
- **ProductGraphs** → Chart.js React wrapper or Recharts

### Key Challenges
1. **Image Optimization** → Next.js Image component
2. **Chart Integration** → Recharts or Chart.js React
3. **Touch Gestures** → React-use-gesture
4. **Video Integration** → React video player
5. **State Management** → Redux Toolkit for product state
6. **Responsive Design** → CSS Grid/Flexbox or Tailwind

### Priority for Modernization
1. **High Priority**: ProductCard.vue, ScreenProduct.vue, ScreenProducts.vue
2. **Medium Priority**: ProductImage.vue, ProductGraphs.vue
3. **Low Priority**: Specialized display variants (can be consolidated)

### Reusable Patterns
- Product card component with variants
- Image component with lazy loading
- Chart component for data visualization
- Screen wrapper component for consistent layout
