# Project Blueprint

## Overview

This document outlines the plan for a complete UI overhaul of the Flutter application to create a modern and stylish "To-Do List" application. The goal is to build a visually stunning and highly usable interface with a dark theme, custom fonts, and smooth animations.

## Style, Design, and Features

### 1. **Visual Design & Theme**
- **Color Palette**: A sophisticated dark theme will be the foundation.
  - **Background**: `Color(0xFF0D0D0D)` (A deep, dark charcoal)
  - **Primary UI Elements**: `Color(0xFF2F80ED)` (A vibrant blue for buttons and borders)
  - **Accent Color**: `Color(0xFFFFFFFF)` (White for text and key icons)
- **Typography**: We will use the `google_fonts` package.
  - **Headings** (`My To-Do List`): `GoogleFonts.lato()` for a clean and modern look.
  - **Body Text** (Task names): Default Flutter fonts for readability.
- **Iconography**: Material Design icons will be used for clarity (add, delete).
- **Effects**: Input fields and buttons will have rounded corners and a subtle border to create a modern look.

### 2. **Application Layout & Structure**
- **Main Screen (`todo_screen.dart`)**: The screen will be built using a `Column` widget.
  - **Top Section (Input Field)**: A `Row` containing a `TextField` and an `ElevatedButton` for adding new tasks.
  - **Bottom Section (Task List)**: A `ListView` to display the list of tasks. Each task will have a delete button.

### 3. **State Management**
- The `_tasks` list will be managed locally within the `_TodoScreenState`.

## Action Plan for Current Change

1.  **Create To-Do Screen**: Create `lib/todo_screen.dart` and implement the "To-Do List" UI.
2.  **Update `main.dart`**: Update `lib/main.dart` to use the new `TodoScreen` and a new, modern theme.
3.  **Dependencies**: Add `google_fonts` to `pubspec.yaml`.
4.  **Build and Deploy**: Build the web application and deploy it to Firebase Hosting.
