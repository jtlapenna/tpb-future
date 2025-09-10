# Animation Patterns

**Version:** 1.0  
**Last Updated:** March 13, 2024

## Overview
This document outlines the animation patterns implemented in the CMS application, focusing on transitions, animations, and interactive feedback.

## Core Animation Patterns

### 1. Global Transitions
The application uses consistent transition patterns for interactive elements:

```scss
// Global element transitions
a {
  @include transition(
    background-color .15s ease-in-out,
    border-color .15s ease-in-out,
    color .15s ease-in-out
  );
}

// Button transitions
.btn {
  @include transition(
    background-color .15s ease-in-out,
    border-color .15s ease-in-out
  );
}

// Form control transitions
.form-control {
  @include transition(
    border-color .15s ease-in-out,
    background-color .15s ease-in-out
  );
}
```

Features:
- Consistent timing (150ms)
- Ease-in-out timing function
- Multiple property transitions
- Performance-optimized properties

### 2. View Animations
Angular view transitions for smooth page changes:

```scss
// View enter animation
.fade-up.ng-enter {
  animation: fadeInUp 0.5s;
}

// View leave animation
.fade-up.ng-leave {
  animation: fadeOutUp 0.5s;
}
```

Features:
- Smooth page transitions
- Direction-based animations
- Consistent timing
- Hardware-accelerated transforms

### 3. Loading Animations
```scss
.sk-circle {
  .sk-circle4:before {
    animation-delay: -0.9s;
  }
  .sk-circle5:before {
    animation-delay: -0.8s;
  }
  .sk-circle6:before {
    animation-delay: -0.7s;
  }
}

@keyframes sk-circleFadeDelay {
  0%, 39%, 100% { opacity: 0; }
  40% { opacity: 1; }
}
```

Features:
- Staggered animations
- Smooth transitions
- Visual feedback
- Performance optimization

## Implementation Patterns

### 1. State-Based Animations
```typescript
// Notification animation sequence
setTimeout(() => {
  const notification = jQuery('#notification');
  notification
    .removeClass('hide')
    .addClass('animated fadeIn')
    .one('animationend', () => {
      notification.removeClass('animated fadeIn');
      setTimeout(() => {
        notification
          .addClass('animated fadeOut')
          .one('animationend', () => {
            notification.addClass('hide');
          });
      }, 8000);
    });
}, 4000);
```

Features:
- Sequential animations
- State management
- Cleanup handling
- Timing control

### 2. Interactive Feedback
```typescript
// Form focus animation
this.$el.find('.input-group-addon + .form-control').on('blur focus', function(e) {
  jQuery(this)
    .parents('.input-group')
    [e.type === 'focus' ? 'addClass' : 'removeClass']('focus');
});
```

Features:
- User interaction feedback
- State-based styling
- Smooth transitions
- Visual feedback

### 3. Loading States
```typescript
export class ComponentName {
  loading = false;

  loadData() {
    this.loading = true;
    // Data loading logic
    this.loading = false;
  }
}
```

Features:
- Visual loading indicators
- State transitions
- Error state handling
- Progress feedback

## Best Practices

### 1. Performance
- Use hardware-accelerated properties (transform, opacity)
- Optimize animation duration
- Minimize DOM operations
- Use requestAnimationFrame for complex animations

### 2. User Experience
- Consistent timing across similar animations
- Meaningful transitions that guide users
- Progressive feedback for long operations
- Smooth animations that don't disrupt flow

### 3. Accessibility
- Respect reduced motion preferences
- Provide alternative indicators
- Maintain ARIA states
- Manage focus appropriately

### 4. Mobile Support
- Touch feedback animations
- Gesture-based animations
- Performance optimization for mobile
- Device capability detection

## Integration Points

### 1. Component Integration
- State management for animations
- Event handling and timing
- Lifecycle hooks integration
- Cleanup patterns

### 2. Style System
- Animation variables and mixins
- Transition utilities
- Theme integration
- Reusable animations

### 3. Performance Monitoring
- Animation frame rate tracking
- Memory usage optimization
- Paint performance monitoring
- Jank detection

## Dependencies
- @angular/animations
- @angular/core
- jQuery (legacy)
- SCSS mixins

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial animation patterns documentation 