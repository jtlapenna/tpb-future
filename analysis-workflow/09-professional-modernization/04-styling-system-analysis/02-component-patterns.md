# Component Styling Patterns

## Navigation Components

### TheNav Component
**Base Class**: `.the-nav`
**Layout Variants**: `--large`, `--sidebar`, `--round`

#### Large Navigation (Home Screen)
```scss
.the-nav--large {
  position: fixed;
  top: 135px;
  right: 70px;
  bottom: 105px;
  left: 980px;
  
  ul {
    margin: 0 -15px;
    width: auto;
  }
  
  .element {
    margin: 0 15px 30px;
    width: calc(50% - 30px);
    height: 200px;
    
    &--large {
      width: calc(100% - 30px);
    }
  }
  
  .number {
    top: 30px;
    left: 30px;
  }
  
  .label {
    right: 60px;
    left: 60px;
    font-size: 50px;
    line-height: 1.12;
  }
  
  .arrow {
    right: 30px;
    bottom: 30px;
  }
}
```

#### Navigation Link Styling
```scss
.the-nav .link {
  display: block;
  position: relative;
  height: 100%;
  border-radius: 20px;
  color: $white;
  transition: all 0.3s ease;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
  }
  
  &.router-link-exact-active {
    background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%);
  }
}
```

#### Navigation Elements
```scss
.the-nav .inner {
  position: relative;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 20px;
}

.the-nav .number {
  position: absolute;
  top: 20px;
  left: 20px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  
  &__text {
    font-size: 16px;
    font-weight: bold;
    color: #ffffff;
    z-index: 2;
  }
  
  &__line {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 30px;
    height: 2px;
    background: #FDDA1A;
    transform: translate(-50%, -50%);
    z-index: 1;
  }
}

.the-nav .label {
  position: absolute;
  right: 20px;
  left: 60px;
  bottom: 20px;
  font-size: 24px;
  font-weight: 300;
  color: #ffffff;
  line-height: 1.2;
}

.the-nav .arrow {
  position: absolute;
  right: 20px;
  bottom: 20px;
  width: 20px;
  height: 20px;
  
  &__line {
    position: absolute;
    top: 50%;
    left: 0;
    width: 15px;
    height: 2px;
    background: #ffffff;
    transform: translateY(-50%);
    
    &:before,
    &:after {
      content: '';
      position: absolute;
      top: 50%;
      left: 50%;
      width: 100%;
      height: 100%;
      background: #ffffff;
      border-radius: 25%;
      transform-origin: 100% 50%;
    }
    
    &:before {
      transform: translate(-50%, -50%) rotateZ(45deg);
    }
    
    &:after {
      transform: translate(-50%, -50%) rotateZ(-45deg);
    }
  }
}
```

## Product Card Components

### ProductCard Base Styling
```scss
.product-card {
  position: relative;
  
  &__card {
    position: relative;
    width: 100%;
    height: 100%;
  }
  
  &__inner {
    position: relative;
    width: 100%;
    height: 100%;
    padding: 60px 0 0; // Full layout
  }
  
  &__info {
    position: absolute;
    top: 335px;
    left: 0;
    width: 100%;
  }
  
  &__first-line {
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 8px;
    
    div:last-child {
      margin: 0;
    }
  }
  
  &__brand {
    font-size: 16px;
    color: rgba(255, 255, 255, 0.7);
    margin-right: 8px;
  }
  
  &__type {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.5);
  }
  
  &__name {
    font-size: 18px;
    font-weight: 600;
    color: #ffffff;
    text-align: center;
    line-height: 1.2;
    margin: 8px 0;
  }
}
```

### Product Card Layout Variants
```scss
// XLarge layout (featured products)
.product-card--xlarge {
  .product-card__inner {
    padding: 180px 10px 0;
  }
  
  .product-card__info {
    top: 360px;
    bottom: 0;
    display: flex;
    align-items: center;
    flex-direction: column;
  }
  
  .product-card__name {
    margin-top: 35px;
    max-height: 2.2em;
    overflow: hidden;
  }
}

// Full layout (product details)
.product-card--full {
  .product-card__inner {
    padding: 60px 0 0;
  }
  
  .product-card__info {
    position: static;
    margin: 8px 0 0;
    flex-shrink: 1;
  }
}

// Shared screen layout
.product-card--sharedscreen {
  min-width: calc(16.6% - 40px) !important;
  
  .product-card__inner {
    padding-left: 10px !important;
    padding-right: 10px !important;
  }
  
  .product-card__name {
    height: 49.6px;
  }
}
```

## Screen Components

### Screen Base Styling
```scss
.screen {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: var(--bg);
  color: $white;
  
  &--home {
    left: 0;
    background: transparent !important;
  }
  
  &--checkout {
    // Checkout specific styles
  }
}
```

### Home Screen Components
```scss
.store-logo {
  position: fixed;
  top: 50px;
  left: 50px;
  object-fit: contain;
  object-position: center;
  opacity: 0.5;
  
  &--horizontal {
    width: 160px;
    height: 60px;
  }
  
  &--vertical {
    width: 60px;
    height: 160px;
  }
}

.catcher {
  position: fixed;
  top: 290px;
  left: 170px;
  width: 600px;
  font: 92px/1.09 var(--font-extralight);
  color: $white;
  
  &--small {
    top: 400px;
    left: 140px;
    width: 740px;
    font-size: 70px;
  }
  
  &__line {
    display: block;
  }
}

.illustration {
  position: fixed;
  top: 630px;
  left: 170px;
  width: 477px;
  height: 353px;
  
  .lottie-container {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 987px;
    height: 730px;
    transform: translate3d(-50%, -50%, 0);
  }
}
```

## Form Components

### Checkout Form Styling
```scss
.checkout__form {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 40px;
}

.checkout__field {
  position: relative;
  
  &--half {
    width: calc(50% - 10px);
    display: inline-block;
  }
  
  .input-osk {
    width: 100%;
    padding: 15px 20px;
    border: 2px solid rgba(255, 255, 255, 0.2);
    border-radius: 10px;
    background: rgba(255, 255, 255, 0.1);
    color: $white;
    font-size: 16px;
    
    &::placeholder {
      color: rgba(255, 255, 255, 0.5);
    }
    
    &:focus {
      border-color: var(--main-color);
      outline: none;
    }
  }
}

.checkout__button {
  position: relative;
  padding: 15px 30px;
  border: none;
  border-radius: 28px;
  background: var(--main-color);
  color: $white;
  font: 18px/56px var(--font-semibold);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  cursor: pointer;
  transition: all 0.3s ease;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(14, 165, 233, 0.3);
  }
  
  &--sending {
    opacity: 0.7;
    cursor: not-allowed;
  }
  
  &--offline {
    filter: grayscale(1);
    cursor: not-allowed;
  }
  
  &__text {
    position: relative;
    z-index: 2;
  }
  
  &__background {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: var(--main-color);
    border-radius: 28px;
    z-index: 1;
  }
}
```

## Modal Components

### Modal Template
```scss
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  
  &--hide-close {
    .modal__close {
      display: none;
    }
  }
  
  &__content {
    background: $charade;
    border-radius: 20px;
    padding: 40px;
    max-width: 90vw;
    max-height: 90vh;
    overflow-y: auto;
  }
  
  &__close {
    position: absolute;
    top: 20px;
    right: 20px;
    width: 40px;
    height: 40px;
    border: none;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 50%;
    color: $white;
    cursor: pointer;
    
    &:hover {
      background: rgba(255, 255, 255, 0.2);
    }
  }
}
```

## Animation Patterns

### GSAP Integration
```scss
// GSAP animation classes
.gsap-fade-in {
  opacity: 0;
  transform: translateY(20px);
}

.gsap-slide-in-left {
  opacity: 0;
  transform: translateX(-50px);
}

.gsap-scale-in {
  opacity: 0;
  transform: scale(0.8);
}

// Animation states
.animate-in {
  opacity: 1;
  transform: translateY(0) translateX(0) scale(1);
}
```

### CSS Transitions
```scss
// Smooth transitions
.transition-smooth {
  transition: all 0.3s ease;
}

.transition-fast {
  transition: all 0.15s ease;
}

.transition-slow {
  transition: all 0.5s ease;
}

// Hover effects
.hover-lift {
  transition: transform 0.3s ease;
  
  &:hover {
    transform: translateY(-4px);
  }
}

.hover-glow {
  transition: box-shadow 0.3s ease;
  
  &:hover {
    box-shadow: 0 8px 25px rgba(14, 165, 233, 0.3);
  }
}
```

## Modernization Strategy

### CSS-in-JS Migration
```typescript
// Styled Components approach
const ProductCard = styled.div<{ layout: string; isFeatured: boolean }>`
  position: relative;
  border-radius: 30px;
  
  ${({ layout }) => {
    switch (layout) {
      case 'xlarge':
        return css`
          .product-card__inner {
            padding: 180px 10px 0;
          }
        `;
      case 'full':
        return css`
          .product-card__inner {
            padding: 60px 0 0;
          }
        `;
      default:
        return css`
          .product-card__inner {
            padding: 20px;
          }
        `;
    }
  }}
  
  ${({ isFeatured }) => isFeatured && css`
    box-shadow: 0 8px 25px rgba(14, 165, 233, 0.3);
  `}
`;
```

### Tailwind CSS Migration
```html
<!-- Navigation component -->
<div class="fixed top-[135px] right-[70px] bottom-[105px] left-[980px]">
  <ul class="flex flex-wrap justify-between gap-5">
    <li class="w-[calc(50%-30px)] h-[200px] rounded-[30px]">
      <a class="block relative h-full rounded-[20px] text-white transition-all duration-300 hover:-translate-y-1 hover:shadow-lg">
        <!-- Content -->
      </a>
    </li>
  </ul>
</div>
```

### CSS Modules Migration
```scss
// ProductCard.module.scss
.productCard {
  position: relative;
  
  &__inner {
    position: relative;
    width: 100%;
    height: 100%;
    padding: 60px 0 0;
  }
  
  &--xlarge {
    .productCard__inner {
      padding: 180px 10px 0;
    }
  }
}
```
