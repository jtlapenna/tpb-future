# Mobile-Specific Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the mobile-specific patterns implemented in the CMS, focusing on responsive design, touch interactions, and mobile-optimized components.

## Core Patterns

### 1. Screen Size Detection
The application uses a centralized screen size detection system through the `AppConfig` service:

```typescript
export class AppConfig {
  screens = {
    'xs-max': 543,
    'sm-min': 544,
    'sm-max': 767,
    'md-min': 768,
    'md-max': 991,
    'lg-min': 992,
    'lg-max': 1199,
    'xl-min': 1200
  };

  isScreen(size): boolean {
    const screenPx = window.innerWidth;
    return (screenPx >= this.screens[size + '-min'] || size === 'xs')
      && (screenPx <= this.screens[size + '-max'] || size === 'xl');
  }

  getScreenSize(): string {
    const screenPx = window.innerWidth;
    if (screenPx <= this.screens['xs-max']) { return 'xs'; }
    if ((screenPx >= this.screens['sm-min'])
      && (screenPx <= this.screens['sm-max'])) { return 'sm'; }
    if ((screenPx >= this.screens['md-min'])
      && (screenPx <= this.screens['md-max'])) { return 'md'; }
    if ((screenPx >= this.screens['lg-min'])
      && (screenPx <= this.screens['lg-max'])) { return 'lg'; }
    if (screenPx >= this.screens['xl-min']) { return 'xl'; }
  }
}
```

Features:
- Consistent breakpoint definitions
- Screen size detection methods
- Responsive design support
- Device-specific adaptations

### 2. Touch Interaction
The application implements touch-specific features when touch capabilities are detected:

```typescript
export class LayoutComponent {
  enableSwipeCollapsing(): void {
    const swipe = new Hammer(document.getElementById('content-wrap'));
    
    swipe.on('swipeleft', () => {
      if (this.configFn.isScreen('md')) { return; }
      if (!jQuery('app-layout').is('.nav-collapsed')) {
        this.collapseNavigation();
      }
    });

    swipe.on('swiperight', () => {
      if (this.configFn.isScreen('md')) { return; }
      if (jQuery('app-layout').is('.chat-sidebar-opened')) { return; }
      if (jQuery('app-layout').is('.nav-collapsed')) {
        this.expandNavigation();
      }
    });
  }

  ngOnInit(): void {
    if ('ontouchstart' in window) {
      this.enableSwipeCollapsing();
    }
  }
}
```

Features:
- Touch gesture detection
- Swipe navigation
- Touch feedback
- Gesture-based interactions

### 3. Responsive Navigation
The application adapts navigation based on screen size:

```typescript
export class LayoutComponent {
  checkNavigationState(): void {
    if (this.isNavigationStatic()) {
      if (this.configFn.isScreen('sm')
        || this.configFn.isScreen('xs') || this.configFn.isScreen('md')) {
        this.collapseNavigation();
      }
    } else {
      if (this.configFn.isScreen('lg') || this.configFn.isScreen('xl')) {
        setTimeout(() => {
          this.collapseNavigation();
        }, this.config.settings.navCollapseTimeout);
      } else {
        this.collapseNavigation();
      }
    }
  }
}
```

Features:
- Adaptive navigation
- Mobile-optimized menus
- Screen size-based behavior
- Touch-friendly controls

## Implementation Patterns

### 1. Responsive Components
```typescript
export class NotificationsComponent {
  moveNotificationsDropdown(): void {
    jQuery('.sidebar-status .dropdown-toggle')
      .after(jQuery('[notifications]').detach());
  }

  ngOnInit(): void {
    this.config.onScreenSize(['sm', 'xs'], this.moveNotificationsDropdown);
    if (this.config.isScreen('sm') || this.config.isScreen('xs')) {
      this.moveNotificationsDropdown();
    }
  }
}
```

Features:
- Component repositioning
- Mobile-optimized layouts
- Screen size callbacks
- Dynamic adaptation

### 2. Touch Event Handling
```typescript
export class ChatSidebarComponent {
  ngOnInit(): void {
    if ('ontouchstart' in window) {
      this.enableSwipeCollapsing();
    }
    jQuery(window).on('sn:resize', this.initChatSidebarScroll.bind(this));
  }
}
```

Features:
- Touch event detection
- Gesture support
- Mobile scrolling
- Event delegation

### 3. Mobile-First Design
```scss
// Base mobile styles
.component {
  width: 100%;
  padding: 1rem;
}

// Tablet and up
@media (min-width: $screen-sm-min) {
  .component {
    width: 50%;
    padding: 2rem;
  }
}

// Desktop and up
@media (min-width: $screen-lg-min) {
  .component {
    width: 33.33%;
    padding: 3rem;
  }
}
```

## Best Practices

### 1. Touch Optimization
- Large touch targets
- Touch feedback
- Gesture support
- Touch-first design

### 2. Performance
- Image optimization
- Lazy loading
- Network awareness
- Resource prioritization

### 3. Responsive Design
- Mobile-first approach
- Fluid layouts
- Breakpoint consistency
- Content adaptation

### 4. User Experience
- Touch feedback
- Loading states
- Error handling
- Offline support

## Integration Points

### 1. Screen Size System
- Breakpoint definitions
- Media queries
- Component adaptation
- Layout management

### 2. Touch System
- Event handling
- Gesture recognition
- Touch feedback
- Interaction states

### 3. Navigation
- Mobile menus
- Touch navigation
- Screen adaptation
- Gesture support

## Dependencies
- @angular/core
- Hammer.js
- jQuery (legacy)
- Bootstrap

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial mobile-specific patterns documentation | 