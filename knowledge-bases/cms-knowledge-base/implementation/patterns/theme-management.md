# Theme Management Patterns
Version: 1.0
Last Updated: March 13, 2024

## Overview
This document outlines the theme management patterns used in the CMS application, including color schemes, typography, spacing, and responsive design integration.

## Core Components

### 1. Theme Provider
```typescript
const theme = {
  colors: {
    primary: '#00C796',
    secondary: '#eee',
    success: '#419641',
    info: '#5dc4bf',
    warning: '#EE991B',
    danger: '#dd5826',
    text: '#555',
    headings: '#351B64',
    link: '#7168DF'
  },
  typography: {
    fontFamily: {
      primary: 'Roboto, sans-serif',
      secondary: 'ProximaNova, sans-serif',
      semibold: 'ProximaNovaSemiBold, sans-serif'
    },
    fontSize: {
      root: '14px',
      base: '1rem',
      larger: '15px',
      mini: '13px'
    }
  }
};
```

### 2. Breakpoint System
```typescript
const breakpoints = {
  xs: '0',
  sm: '576px',
  md: '768px',
  lg: '992px',
  xl: '1200px'
};

const media = {
  up: (breakpoint: keyof typeof breakpoints) => `
    @media (min-width: ${breakpoints[breakpoint]})
  `,
  down: (breakpoint: keyof typeof breakpoints) => `
    @media (max-width: ${breakpoints[breakpoint]})
  `
};
```

## Implementation Patterns

### 1. Theme Integration
- Theme Provider wrapping for global theme access
- Consistent theme variable usage across components
- Dynamic theme switching support

### 2. Color Management
- Semantic color naming conventions
- Color scheme organization
- Accessibility-compliant contrast ratios

### 3. Typography System
- Font family hierarchy
- Responsive font scaling
- Consistent text styles

### 4. Responsive Design
- Breakpoint-based adaptations
- Mobile-first approach
- Device-specific optimizations

## Best Practices

### 1. Theme Consistency
- Use theme variables for all styles
- Maintain a single source of truth for design tokens
- Document any deviations from the theme system

### 2. Performance
- Use dynamic styles sparingly
- Implement code splitting for large style bundles
- Optimize critical CSS rendering

### 3. Accessibility
- Ensure sufficient color contrast
- Support system color scheme preferences
- Maintain readable typography scales

## Integration Points

### 1. Component Integration
```typescript
const StyledComponent = styled.div`
  background-color: ${props => props.theme.colors.primary};
  font-family: ${props => props.theme.typography.fontFamily.primary};
  font-size: ${props => props.theme.typography.fontSize.base};
  
  ${props => props.theme.media.up('md')`
    font-size: ${props.theme.typography.fontSize.larger};
  `}
`;
```

### 2. Theme Switching
```typescript
const AppThemeProvider: React.FC = ({ children }) => (
  <ThemeProvider theme={theme}>
    {children}
  </ThemeProvider>
);
```

## Dependencies
- styled-components
- Theme Provider
- Media query utilities

## Document History
- Version 1.0 (March 13, 2024): Initial documentation of theme management patterns 