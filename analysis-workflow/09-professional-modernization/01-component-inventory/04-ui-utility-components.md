# UI & Utility Components Analysis

## UI Components

### 1. ModalTemplate.vue
**Path**: `src/components/ModalTemplate.vue`
**Purpose**: Reusable modal dialog component
**Complexity**: Moderate
**Key Features**:
- Modal overlay
- Close functionality
- Content slot
- Animation transitions
- Focus management

### 2. Spinner.vue
**Path**: `src/components/Spinner.vue`
**Purpose**: Loading spinner component
**Complexity**: Simple
**Key Features**:
- Loading animation
- Size variants
- Color customization
- Accessibility support

### 3. Slider.vue
**Path**: `src/components/Slider.vue`
**Purpose**: Image/content slider component
**Complexity**: Complex
**Key Features**:
- Touch/swipe support
- Navigation controls
- Auto-play functionality
- Responsive design
- Animation transitions

### 4. ShareButton.vue
**Path**: `src/components/ShareButton.vue`
**Purpose**: Social sharing functionality
**Complexity**: Moderate
**Key Features**:
- Social media sharing
- URL generation
- Share tracking
- Platform-specific handling

### 5. LottieContainer.vue
**Path**: `src/components/LottieContainer.vue`
**Purpose**: Lottie animation wrapper
**Complexity**: Complex
**Key Features**:
- Lottie animation loading
- Animation controls
- Event handling
- Performance optimization

## Specialized Screen Components

### 6. ScreenBrands.vue
**Path**: `src/components/ScreenBrands.vue`
**Purpose**: Brand listing and selection screen
**Complexity**: Moderate
**Key Features**:
- Brand grid display
- Brand filtering
- Brand selection
- Navigation to brand products

### 7. ScreenMenuBoard.vue
**Path**: `src/components/ScreenMenuBoard.vue`
**Purpose**: Menu board display for products
**Complexity**: Complex
**Key Features**:
- Large format display
- Product grid layout
- Touch interactions
- Real-time updates
- Menu board styling

### 8. ScreenHomeVideoImageBackground.vue
**Path**: `src/components/ScreenHomeVideoImageBackground.vue`
**Purpose**: Home screen with video/image background
**Complexity**: Moderate
**Key Features**:
- Video background
- Image fallback
- Content overlay
- Performance optimization

### 9. ScreenHomeQuickCheckout.vue
**Path**: `src/components/ScreenHomeQuickCheckout.vue`
**Purpose**: Quick checkout flow from home
**Complexity**: Complex
**Key Features**:
- Streamlined checkout
- Minimal steps
- Quick payment
- User flow optimization

### 10. ScreenHomeCCC.vue
**Path**: `src/components/ScreenHomeCCC.vue`
**Purpose**: CCC (Cannabis Control Commission) specific home screen
**Complexity**: Moderate
**Key Features**:
- Regulatory compliance display
- CCC-specific messaging
- Compliance information
- Legal requirements

### 11. ScreenHomeSwipe.vue
**Path**: `src/components/ScreenHomeSwipe.vue`
**Purpose**: Swipe-based home screen navigation
**Complexity**: Complex
**Key Features**:
- Touch/swipe gestures
- Navigation transitions
- Mobile optimization
- Gesture recognition

## Utility & Debug Components

### 12. ScreenDebugCache.vue
**Path**: `src/components/ScreenDebugCache.vue`
**Purpose**: Cache debugging and management
**Complexity**: Moderate
**Key Features**:
- Cache status display
- Cache management
- Debug information
- Development tools

### 13. ScreenUploadEvents.vue
**Path**: `src/components/ScreenUploadEvents.vue`
**Purpose**: Event upload and management
**Complexity**: Moderate
**Key Features**:
- Event data upload
- Upload progress
- Error handling
- Data management

### 14. ScreenIframeTest.vue
**Path**: `src/components/ScreenIframeTest.vue`
**Purpose**: Iframe testing component
**Complexity**: Simple
**Key Features**:
- Iframe embedding
- Testing functionality
- Development tool

### 15. ScreenEffectsUses.vue
**Path**: `src/components/ScreenEffectsUses.vue`
**Purpose**: Cannabis effects and uses information
**Complexity**: Moderate
**Key Features**:
- Effects information
- Usage guidelines
- Educational content
- Cannabis information

## Brand & Marketing Components

### 16. TheBrandSlideshow.vue
**Path**: `src/components/TheBrandSlideshow.vue`
**Purpose**: Brand promotional slideshow
**Complexity**: Complex
**Key Features**:
- Image slideshow
- Brand promotion
- Auto-play functionality
- Navigation controls
- Responsive design

## Modernization Notes

### React/Next.js Equivalents
- **ModalTemplate** → React Modal component with portal
- **Spinner** → React loading component with CSS animations
- **Slider** → Swiper.js React or custom slider
- **LottieContainer** → Lottie React library
- **Screen Components** → Next.js pages or route components

### Key Challenges
1. **Lottie Integration** → Lottie React with performance optimization
2. **Touch Gestures** → React-use-gesture or Hammer.js
3. **Video Backgrounds** → React video components with optimization
4. **Slideshow Functionality** → Swiper.js or custom React slider
5. **Debug Tools** → Development-only components with conditional rendering

### Priority for Modernization
1. **High Priority**: ModalTemplate.vue, Spinner.vue, LottieContainer.vue
2. **Medium Priority**: Slider.vue, ScreenBrands.vue, ScreenMenuBoard.vue
3. **Low Priority**: Debug components, specialized screens

### Reusable Patterns
- Modal component with portal rendering
- Loading component with variants
- Slider component with touch support
- Screen wrapper component for consistent layout
- Debug component for development tools

### Performance Considerations
- Lazy loading for heavy components
- Video optimization for backgrounds
- Touch gesture performance
- Animation performance optimization
- Memory management for sliders
