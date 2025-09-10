# System Architecture

## Overview
This diagram illustrates the overall system architecture of the CMS, including all major components and their interactions.

## Architecture Diagram

```mermaid
graph TB
    subgraph Frontend [Frontend Layer]
        UI[UI Components]
        Services[Services Layer]
        Guards[Route Guards]
        State[State Management]
    end

    subgraph Core [Core Services]
        Auth[Authentication]
        CRUD[CRUD Service]
        HTTP[HTTP Client]
        Error[Error Handling]
    end

    subgraph Features [Feature Modules]
        Client[Client Management]
        Category[Category Management]
        Kiosk[Kiosk Management]
        Store[Store Management]
    end

    subgraph Integration [Integration Layer]
        Payment[Payment Gateway]
        RFID[RFID Service]
        Tax[Tax Service]
        Display[Display Service]
    end

    subgraph Infrastructure [Infrastructure]
        JWT[JWT Service]
        Socket[Socket Service]
        Cache[Cache Service]
        Logger[Logging Service]
    end

    UI --> Services
    Services --> Core
    Guards --> Auth
    State --> Services

    Core --> Features
    Features --> Integration
    Core --> Infrastructure
    Integration --> Infrastructure

    classDef module fill:#f9f,stroke:#333,stroke-width:2px
    classDef service fill:#bbf,stroke:#333,stroke-width:2px
    classDef infra fill:#bfb,stroke:#333,stroke-width:2px

    class Frontend,Features module
    class Core,Integration service
    class Infrastructure infra
```

## Component Relationships

1. **Frontend Layer**
   - UI Components interact with Services Layer
   - Services Layer manages data flow
   - Route Guards protect navigation
   - State Management handles app state

2. **Core Services**
   - Authentication manages user sessions
   - CRUD Service handles data operations
   - HTTP Client manages API communication
   - Error Handling provides global error management

3. **Feature Modules**
   - Client Management for user/client data
   - Category Management for product categories
   - Kiosk Management for display systems
   - Store Management for retail locations

4. **Integration Layer**
   - Payment Gateway for transactions
   - RFID Service for product tracking
   - Tax Service for calculations
   - Display Service for kiosk management

5. **Infrastructure**
   - JWT Service for token management
   - Socket Service for real-time updates
   - Cache Service for data caching
   - Logging Service for system monitoring

## Dependencies

- Angular 13+
- RxJS
- NgRx
- Socket.io-client
- @auth0/angular-jwt

## Document History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | March 13, 2024 | Initial system architecture diagram | 