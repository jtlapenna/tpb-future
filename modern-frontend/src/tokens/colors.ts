// Design tokens extracted from legacy SCSS system
export const colors = {
  // Primary colors from legacy _colors.scss
  black: '#000000',
  bluecharcoal: '#010D17',    // Primary background
  charade: '#2B2D37',         // Secondary background
  ebonyclay: '#242B35',       // Tertiary background
  shark: '#1A1B21',           // Dark accent
  white: '#ffffff',           // Primary text
  
  // CSS custom properties from legacy system
  mainColor: '#0ea5e9',       // Primary brand color (blue)
  bg: '#010D17',              // Main background
  navsColor: '#FDDA1A',       // Navigation accent (yellow)
  
  // Semantic colors for modern system
  success: '#10b981',
  warning: '#f59e0b',
  error: '#ef4444',
  info: '#3b82f6',
  
  // Opacity variants
  textSecondary: 'rgba(255, 255, 255, 0.7)',
  textTertiary: 'rgba(255, 255, 255, 0.5)',
  surfaceOverlay: 'rgba(0, 0, 0, 0.8)',
  surfaceHover: 'rgba(255, 255, 255, 0.1)',
  surfaceActive: 'rgba(255, 255, 255, 0.2)',
} as const;

export type ColorKey = keyof typeof colors;
