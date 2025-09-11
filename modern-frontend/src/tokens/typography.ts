// Typography tokens extracted from legacy font system
export const typography = {
  fontFamily: {
    primary: 'Muli, sans-serif',
    extralight: 'muliextralight',
    light: 'mulilight',
    regular: 'muliregular',
    semibold: 'mulisemibold',
    bold: 'mulibold',
    extrabold: 'muliextrabold',
    black: 'muliblack',
  },
  fontWeight: {
    extralight: 200,
    light: 300,
    regular: 400,
    semibold: 600,
    bold: 700,
    extrabold: 800,
    black: 900,
  },
  fontSize: {
    xs: '12px',
    sm: '14px',
    base: '16px',
    lg: '18px',
    xl: '20px',
    '2xl': '24px',
    '3xl': '30px',
    '4xl': '36px',
    '5xl': '48px',
    '6xl': '60px',
    '7xl': '72px',
    '8xl': '92px',  // Legacy catcher text size
    '9xl': '96px',
  },
  lineHeight: {
    tight: 1.09,    // Legacy catcher line height
    normal: 1.2,
    relaxed: 1.21,  // Legacy label line height
    loose: 1.5,     // Legacy body line height
  },
} as const;

export type TypographyKey = keyof typeof typography;
