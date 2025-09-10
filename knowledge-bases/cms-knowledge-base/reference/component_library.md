# Component Library Reference

This document provides a reference for the component library used in style migration.

## Core Components

### Layout Components
- Container
- Grid
- Flex
- Box

### Typography Components
- Text
- Heading
- Paragraph
- Link

### Form Components
- Button
- Input
- Select
- Checkbox

## Usage

### Installation
```bash
npm install @style-migration/components
```

### Basic Usage
```jsx
import { Container, Text } from '@style-migration/components';

const MyComponent = () => (
  <Container>
    <Text>Hello World</Text>
  </Container>
);
```

### Customization
```jsx
import { styled } from 'styled-components';
import { Button } from '@style-migration/components';

const CustomButton = styled(Button)`
  // Custom styles
`;
```

## API Reference

### Container Props
- width
- maxWidth
- padding
- margin

### Typography Props
- fontSize
- fontWeight
- lineHeight
- color

### Layout Props
- display
- position
- flexbox
- grid 