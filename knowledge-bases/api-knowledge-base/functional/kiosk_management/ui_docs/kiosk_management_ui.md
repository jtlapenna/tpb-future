---
title: Kiosk Management UI Components
description: Detailed documentation of the UI components used in the kiosk management flow, including screenshots and interaction patterns
last_updated: 2023-08-16
contributors: [AI Assistant]
related_files:
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/kiosks_controller.rb
  - thepeakbeyond-aim-tpb-be-7ec9ac972df9/app/controllers/kiosk_layouts_controller.rb
tags:
  - ui
  - kiosk
  - management
  - components
ai_agent_relevance:
  - KioskManagementAgent
  - UIDesignAgent
---

# Kiosk Management UI Components

## Overview

This document provides detailed information about the UI components used in the kiosk management flow of The Peak Beyond's system. These components enable administrators and store managers to create, configure, and manage kiosks, including layout configuration, product association, and RFID integration.

## Kiosk Management Dashboard

### Kiosk List View

The Kiosk List View is the main entry point for kiosk management, displaying all kiosks accessible to the user.

**Key Components:**
- **Kiosk Cards**: Display basic information about each kiosk, including name, status, and store association
- **Filter Controls**: Allow filtering kiosks by store, status, and other criteria
- **Search Bar**: Enables searching for specific kiosks by name
- **Create Button**: Initiates the kiosk creation process
- **Pagination Controls**: Navigate through multiple pages of kiosks

**Interactions:**
- Clicking a kiosk card navigates to the detailed view for that kiosk
- Clicking the create button opens the kiosk creation form
- Using filter controls updates the displayed kiosks based on selected criteria
- Entering text in the search bar filters kiosks by name

### Kiosk Detail View

The Kiosk Detail View provides comprehensive information about a specific kiosk and access to all configuration options.

**Key Components:**
- **Kiosk Header**: Displays kiosk name, status, and basic information
- **Tab Navigation**: Provides access to different sections of kiosk configuration
  - Overview
  - Layout Configuration
  - Product Management
  - RFID Configuration
  - Settings
- **Action Buttons**: Provide quick access to common actions
  - Edit Kiosk
  - Clone Kiosk
  - Delete Kiosk
  - Activate/Deactivate Kiosk

**Interactions:**
- Clicking tabs navigates between different configuration sections
- Clicking action buttons triggers the corresponding action
- Editing basic information updates the kiosk details

## Kiosk Creation and Editing

### Kiosk Creation Form

The Kiosk Creation Form allows users to create new kiosks with basic configuration.

**Key Components:**
- **Name Field**: Input for the kiosk name
- **Store Selector**: Dropdown to select the store association
- **Status Toggle**: Switch to set the initial status (active/inactive)
- **Template Selector**: Dropdown to select the initial layout template
- **Submit Button**: Creates the kiosk with the specified configuration
- **Cancel Button**: Cancels the creation process

**Interactions:**
- Entering information in the form fields updates the kiosk configuration
- Clicking the submit button creates the kiosk and navigates to the detail view
- Clicking the cancel button returns to the kiosk list view without creating a kiosk

### Kiosk Edit Form

The Kiosk Edit Form allows users to modify basic kiosk information.

**Key Components:**
- **Name Field**: Input for updating the kiosk name
- **Status Toggle**: Switch to update the kiosk status
- **Submit Button**: Saves the changes to the kiosk
- **Cancel Button**: Cancels the editing process

**Interactions:**
- Modifying information in the form fields updates the kiosk configuration
- Clicking the submit button saves the changes and returns to the detail view
- Clicking the cancel button returns to the detail view without saving changes

### Kiosk Clone Form

The Kiosk Clone Form allows users to create a new kiosk based on an existing one.

**Key Components:**
- **Name Field**: Input for the new kiosk name
- **Store Selector**: Dropdown to select the store for the new kiosk
- **Clone Options**: Checkboxes to select which aspects to clone
  - Layout Configuration
  - Product Associations
  - RFID Configuration
- **Submit Button**: Creates the cloned kiosk
- **Cancel Button**: Cancels the cloning process

**Interactions:**
- Entering information in the form fields configures the cloned kiosk
- Selecting clone options determines which aspects are copied to the new kiosk
- Clicking the submit button creates the cloned kiosk and navigates to its detail view
- Clicking the cancel button returns to the original kiosk's detail view

## Layout Configuration

### Layout Editor

The Layout Editor allows users to configure the visual appearance and behavior of a kiosk.

**Key Components:**
- **Template Selector**: Dropdown to select the layout template
- **Home Layout Options**: Radio buttons to select the home screen layout style
  - Grid
  - List
  - Carousel
- **Navigation Style Options**: Radio buttons to select the navigation style
  - Tabbed
  - Sidebar
  - Dropdown
- **Color Pickers**: Controls to select colors for various UI elements
  - Background Color
  - Primary Color
  - Secondary Color
  - Text Color
- **Font Selector**: Dropdown to select the font family
- **Welcome Message Editor**: Text area to edit the welcome message
- **Preview Panel**: Shows a live preview of the layout configuration
- **Save Button**: Saves the layout configuration
- **Reset Button**: Resets changes to the last saved configuration

**Interactions:**
- Changing any configuration option updates the preview panel in real-time
- Clicking the save button applies the configuration to the kiosk
- Clicking the reset button discards unsaved changes
- Changing the template displays a confirmation dialog warning about potential loss of configuration

### Asset Manager

The Asset Manager allows users to upload and manage assets used in the kiosk layout.

**Key Components:**
- **Asset List**: Displays all assets associated with the kiosk
- **Upload Button**: Opens the file selector to upload new assets
- **Asset Preview**: Shows a preview of the selected asset
- **Asset Properties Panel**: Displays and allows editing of asset properties
  - Name
  - Description
  - Tags
  - Usage Location
- **Delete Button**: Removes the selected asset
- **Replace Button**: Replaces the selected asset with a new one

**Interactions:**
- Clicking an asset in the list selects it and displays its preview and properties
- Clicking the upload button opens a file selector to add new assets
- Editing properties updates the asset metadata
- Clicking the delete button removes the asset after confirmation
- Clicking the replace button allows uploading a new asset to replace the selected one

## Product Management

### Product Association Manager

The Product Association Manager allows users to associate products with a kiosk.

**Key Components:**
- **Product Filter Controls**: Allow filtering available products
  - Category Filter
  - Brand Filter
  - Search Bar
- **Available Products List**: Displays products that can be associated with the kiosk
- **Associated Products List**: Displays products currently associated with the kiosk
- **Add/Remove Buttons**: Move products between the available and associated lists
- **Position Controls**: Allow reordering associated products
- **Featured Toggle**: Marks products as featured on the kiosk
- **Bulk Action Controls**: Apply actions to multiple products
  - Add All
  - Remove All
  - Feature Selected
- **Save Button**: Saves the product associations
- **Cancel Button**: Discards unsaved changes

**Interactions:**
- Selecting products in either list enables relevant action buttons
- Clicking add/remove buttons moves products between lists
- Using position controls changes the display order of products on the kiosk
- Toggling the featured status marks products for prominent display
- Clicking the save button applies the changes to the kiosk
- Clicking the cancel button discards unsaved changes

### Product Filter Configuration

The Product Filter Configuration allows users to set up automatic product filtering criteria.

**Key Components:**
- **Filter Mode Selector**: Radio buttons to select the filtering mode
  - Manual Selection
  - All Products
  - By Category
  - By Brand
  - Custom Rules
- **Category Selector**: Multi-select dropdown to select categories (when By Category is selected)
- **Brand Selector**: Multi-select dropdown to select brands (when By Brand is selected)
- **Rule Builder**: Interface to create custom filtering rules (when Custom Rules is selected)
  - Condition Type Selector
  - Condition Value Input
  - Add Condition Button
  - Condition List
- **Apply Button**: Applies the filter configuration
- **Cancel Button**: Discards unsaved changes

**Interactions:**
- Selecting a filter mode displays the relevant configuration options
- Building custom rules adds conditions to the filter
- Clicking the apply button saves the filter configuration and updates the associated products
- Clicking the cancel button discards unsaved changes

## RFID Configuration

### RFID Manager

The RFID Manager allows users to configure RFID functionality for a kiosk.

**Key Components:**
- **RFID Status Toggle**: Enables or disables RFID functionality
- **Sensitivity Slider**: Adjusts the sensitivity of RFID detection
- **Timeout Setting**: Sets the timeout period for RFID interactions
- **Product Association Table**: Lists products with their RFID tags
  - Product Name
  - Product ID
  - RFID Tag
  - Status
  - Actions
- **Add Association Button**: Opens the RFID association form
- **Test Mode Button**: Activates RFID test mode
- **Save Button**: Saves the RFID configuration
- **Cancel Button**: Discards unsaved changes

**Interactions:**
- Adjusting settings updates the RFID configuration
- Clicking the add association button opens the RFID association form
- Clicking action buttons in the table allows editing or removing associations
- Activating test mode allows testing RFID functionality
- Clicking the save button applies the configuration to the kiosk
- Clicking the cancel button discards unsaved changes

### RFID Association Form

The RFID Association Form allows users to associate RFID tags with products.

**Key Components:**
- **Product Selector**: Dropdown to select a product
- **RFID Tag Input**: Field to enter the RFID tag identifier
- **Tag Scanner Button**: Activates the RFID scanner to detect tags
- **Submit Button**: Creates the association
- **Cancel Button**: Closes the form without creating an association

**Interactions:**
- Selecting a product and entering an RFID tag creates an association
- Clicking the tag scanner button activates the scanner to automatically detect and fill in the tag
- Clicking the submit button creates the association and adds it to the table
- Clicking the cancel button closes the form without creating an association

## Settings and Administration

### Kiosk Settings Panel

The Kiosk Settings Panel allows users to configure advanced settings for a kiosk.

**Key Components:**
- **General Settings Section**
  - Auto-Refresh Interval
  - Session Timeout
  - Idle Timeout
  - Language Selector
- **Hardware Settings Section**
  - Screen Orientation
  - Touch Sensitivity
  - RFID Reader Configuration
  - Printer Configuration
- **Integration Settings Section**
  - POS Integration Options
  - Analytics Integration Options
  - Third-Party Service Connections
- **Maintenance Section**
  - Restart Kiosk Button
  - Update Software Button
  - Clear Cache Button
  - Diagnostic Tools
- **Save Button**: Applies the settings
- **Reset to Defaults Button**: Resets all settings to default values

**Interactions:**
- Adjusting settings updates the kiosk configuration
- Clicking action buttons in the maintenance section performs the corresponding action
- Clicking the save button applies the settings to the kiosk
- Clicking the reset button restores default settings after confirmation

## Interaction Patterns

### Drag and Drop

Several components in the kiosk management interface use drag and drop interactions:

- **Product Ordering**: Dragging products in the associated products list to reorder them
- **Layout Configuration**: Dragging UI elements in the layout editor to position them
- **Asset Management**: Dragging assets to upload or position them in the layout

### Inline Editing

The interface uses inline editing for efficient updates:

- **Kiosk List**: Clicking status indicators toggles between active and inactive
- **Product Association**: Clicking featured indicators toggles featured status
- **RFID Table**: Clicking RFID tags allows editing them directly in the table

### Progressive Disclosure

Complex functionality is revealed progressively:

- **Layout Editor**: Advanced options are initially hidden and can be expanded
- **Product Filter Configuration**: Custom rule options appear only when custom rules are selected
- **RFID Configuration**: Advanced settings are revealed in an expandable panel

### Contextual Actions

Actions are presented contextually based on the selected item and user permissions:

- **Kiosk List**: Different actions are available based on kiosk status and user role
- **Product Association**: Actions change based on whether products are selected
- **RFID Configuration**: Test mode options appear only when test mode is activated

## Accessibility Considerations

The kiosk management interface implements several accessibility features:

- **Keyboard Navigation**: All interactions can be performed using keyboard shortcuts
- **Screen Reader Support**: All components include appropriate ARIA labels and roles
- **Color Contrast**: UI elements maintain sufficient contrast for readability
- **Text Scaling**: Interface properly scales when text size is increased
- **Focus Indicators**: Visible focus indicators help keyboard users navigate

## Responsive Design

The interface adapts to different screen sizes:

- **Desktop**: Full-featured interface with side-by-side panels
- **Tablet**: Adapted layout with collapsible sections
- **Mobile**: Simplified interface with sequential workflow

## Error Handling

The interface provides clear feedback for errors:

- **Validation Errors**: Form fields display inline validation messages
- **API Errors**: Error notifications explain issues and suggest solutions
- **Connection Issues**: Offline mode allows continued work with synchronization when reconnected

## Future UI Enhancements

Planned improvements to the kiosk management interface:

- **Bulk Editing**: Enhanced tools for managing multiple kiosks simultaneously
- **Layout Templates Library**: Expanded library of pre-configured templates
- **Visual Rule Builder**: Improved interface for creating complex product filter rules
- **Real-time Kiosk Preview**: Live preview of kiosk interface as seen by customers
- **Analytics Dashboard**: Integrated analytics for kiosk performance and usage 