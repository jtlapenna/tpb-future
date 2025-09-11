// Spacing tokens extracted from legacy positioning system
export const spacing = {
  // Base spacing scale
  px: '1px',
  0: '0',
  1: '4px',
  2: '8px',
  3: '12px',
  4: '16px',
  5: '20px',
  6: '24px',
  8: '32px',
  10: '40px',
  12: '48px',
  16: '64px',
  20: '80px',
  24: '96px',
  32: '128px',
  40: '160px',
  48: '192px',
  56: '224px',
  64: '256px',
  
  // Legacy specific spacing values
  storeLogoTop: '50px',
  storeLogoLeft: '50px',
  catcherTop: '290px',
  catcherLeft: '170px',
  catcherWidth: '600px',
  illustrationTop: '630px',
  illustrationLeft: '170px',
  illustrationWidth: '477px',
  illustrationHeight: '353px',
  navTop: '135px',
  navRight: '70px',
  navBottom: '105px',
  navLeft: '980px',
} as const;

export type SpacingKey = keyof typeof spacing;
