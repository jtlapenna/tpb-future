# Design Tokens Analysis

## Color System

### Primary Colors
```scss
// SCSS Variables
$black: #000000;
$bluecharcoal: #010D17;    // Primary background
$charade: #2B2D37;         // Secondary background
$ebonyclay: #242B35;       // Tertiary background
$shark: #1A1B21;           // Dark accent
$white: #ffffff;           // Primary text
```

### CSS Custom Properties
```css
:root {
  --main-color: #0ea5e9;      // Primary brand color (blue)
  --bg: #010D17;              // Main background
  --navs-color: #FDDA1A;      // Navigation accent (yellow)
  --font-extralight: 'muliextralight';
  --font-light: 'mulilight';
  --font-regular: 'muliregular';
  --font-semibold: 'mulisemibold';
  --font-bold: 'mulibold';
  --font-extrabold: 'muliextrabold';
  --font-black: 'muliblack';
}
```

### Color Usage Patterns
- **Background**: `$bluecharcoal` (#010D17) - Dark blue primary
- **Cards/Components**: `$charade` (#2B2D37) - Darker gray
- **Text**: `$white` (#ffffff) - White text on dark backgrounds
- **Accent**: `--main-color` (#0ea5e9) - Blue for interactive elements
- **Navigation**: `--navs-color` (#FDDA1A) - Yellow for nav highlights

## Typography System

### Font Family
**Primary Font**: Muli (Google Fonts)
- **Extralight**: `muliextralight` - 200 weight
- **Light**: `mulilight` - 300 weight  
- **Regular**: `muliregular` - 400 weight
- **Semibold**: `mulisemibold` - 600 weight
- **Bold**: `mulibold` - 700 weight
- **Extrabold**: `muliextrabold` - 800 weight
- **Black**: `muliblack` - 900 weight

### Font Loading
```scss
@font-face {
  font-family: 'muliextralight';
  src: url('~@/assets/fonts/muli-extralight-webfont.woff2') format('woff2');
  font-weight: normal;
  font-style: normal;
}
// ... similar for all weights
```

### Typography Scale
```scss
// Base typography
body {
  font: 20px/1.5 var(--font-light);
}

// Component typography patterns
.product-card__name {
  font: 1.4em/1.21 var(--font-extrabold);
}

.checkout__button__text {
  font: 18px/56px var(--font-semibold);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.the-nav .label {
  font: 1.4em/1.21 var(--font-extrabold);
}
```

## Spacing System

### Layout Spacing
```scss
// Fixed positioning patterns
.store-logo {
  top: 50px;
  left: 50px;
}

.catcher {
  top: 290px;
  left: 170px;
  width: 600px;
}

.illustration {
  top: 630px;
  left: 170px;
  width: 477px;
  height: 353px;
}

.the-nav--large {
  top: 135px;
  right: 70px;
  bottom: 105px;
  left: 980px;
}
```

### Component Spacing
```scss
// Product card spacing
.product-card__inner {
  padding: 60px 0 0;  // Full layout
  padding: 180px 10px 0;  // XLarge layout
}

// Navigation spacing
.the-nav--large .element {
  margin: 0 15px 30px;
  width: calc(50% - 30px);
}

// Form spacing
.checkout__field {
  margin-bottom: 20px;
}
```

## Border Radius System

### Component Radius
```scss
// Navigation elements
.the-nav .element {
  border-radius: 30px;
}

// Product cards
.product-card {
  border-radius: 30px;
}

// Buttons
.checkout__button {
  border-radius: 28px;
}

// Scrollbars
::-webkit-scrollbar-thumb {
  border-radius: 25px;
}
```

## Shadow System

### Box Shadows
```scss
// Navigation hover effects
.the-nav .link:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
}

// Button backgrounds
.button__background {
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
```

## Animation System

### Keyframe Animations
```scss
@keyframes wave-pulse {
  0% { transform: scale(0); opacity: 1; }
  65% { transform: scale(0.8); opacity: 1; }
  80% { transform: scale(1); opacity: 0; }
  100% { transform: scale(0); opacity: 0; }
}

@keyframes alpha-pulse {
  0% { opacity: 1; }
  30% { opacity: 0.5; }
  60% { opacity: 1; }
  100% { opacity: 1; }
}

@keyframes loading {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@keyframes card-flip {
  0% { transform: perspective(100em) rotateY(0); }
  5% { transform: perspective(100em) rotateY(-10deg); }
  15% { transform: perspective(100em) rotateY(2deg); }
  20% { transform: perspective(100em) rotateY(0); }
  100% { transform: perspective(100em) rotateY(0); }
}
```

### Transition Patterns
```scss
// Hover transitions
.the-nav .link {
  transition: all 0.3s ease;
}

.the-nav .link:hover {
  transform: translateY(-2px);
}

// Loading states
.the-nav .number,
.the-nav .label {
  transition: opacity 0.1s linear 0s;
}
```

## Layout System

### Grid Patterns
```scss
// Navigation grid
.the-nav ul {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 20px;
}

// Product grid
.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}
```

### Flexbox Patterns
```scss
// Centered content
.product-card__first-line {
  display: flex;
  align-items: center;
  justify-content: center;
}

// Vertical layouts
.checkout__form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}
```

## Responsive Breakpoints

### Breakpoint Variables
```scss
// Media query breakpoints
$md-breakpoint: 768px;
$lg-breakpoint: 1024px;
$xl-breakpoint: 1200px;
```

### Responsive Patterns
```scss
// Sidebar responsive behavior
@media (min-width: $md-breakpoint) {
  .the-sidebar {
    width: $sidebar-width;
    height: 100%;
  }
}

// Product card responsive sizing
.product-card--sharedscreen {
  min-width: calc(16.6% - 40px) !important;
}
```

## Modernization Strategy

### CSS Custom Properties Migration
```css
:root {
  /* Color tokens */
  --color-primary: #0ea5e9;
  --color-background: #010D17;
  --color-surface: #2B2D37;
  --color-text: #ffffff;
  --color-accent: #FDDA1A;
  
  /* Typography tokens */
  --font-family-primary: 'Muli', sans-serif;
  --font-weight-light: 300;
  --font-weight-regular: 400;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
  --font-weight-extrabold: 800;
  
  /* Spacing tokens */
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;
  --space-xl: 32px;
  --space-2xl: 48px;
  
  /* Border radius tokens */
  --radius-sm: 5px;
  --radius-md: 10px;
  --radius-lg: 20px;
  --radius-xl: 30px;
  
  /* Shadow tokens */
  --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.1);
  --shadow-md: 0 8px 25px rgba(0, 0, 0, 0.3);
  --shadow-lg: 0 16px 50px rgba(0, 0, 0, 0.5);
}
```

### Component Token Mapping
```typescript
// TypeScript design tokens
export const tokens = {
  colors: {
    primary: '#0ea5e9',
    background: '#010D17',
    surface: '#2B2D37',
    text: '#ffffff',
    accent: '#FDDA1A'
  },
  typography: {
    fontFamily: 'Muli, sans-serif',
    weights: {
      light: 300,
      regular: 400,
      semibold: 600,
      bold: 700,
      extrabold: 800
    }
  },
  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    lg: '24px',
    xl: '32px',
    '2xl': '48px'
  }
} as const;
```
