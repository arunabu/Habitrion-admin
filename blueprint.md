# Project Blueprint

## Overview

This is a Flutter-based productivity app designed to help users track their tasks and time management. The app uses Firebase Firestore as its backend database and the `provider` package for state management.

## Features

*   **User Authentication:** The app has a basic authentication wrapper that currently uses a hardcoded default user.
*   **Schedule Viewing:** Users can view a list of their weekly schedules, with progress bars showing the completion of planned tasks.
*   **Task Management:** Users can view daily tasks, and update the time they've spent on each task.
*   **Data Persistence:** All schedule and task data is stored in and retrieved from Firebase Firestore.
*   **Data Import:** The app can import an initial set of tasks from a local JSON file.

## Project Structure

*   **`main.dart`:** The main entry point of the application. It initializes Firebase and sets up the root widget.
*   **`screens/`:** This directory contains the UI of the application.
    *   **`auth_wrapper.dart`:** Handles the authentication flow.
    *   **`schedule_list_screen.dart`:** Displays the list of weekly schedules.
    *   **`day_detail_screen.dart`:** Displays the tasks for a specific day.
*   **`services/`:**
    *   **`firestore_service.dart`:** Contains all the logic for interacting with Firebase Firestore.
*   **`models/`:** This directory contains the data models for the application.
    *   **`user_model.dart`:** Defines the `User`, `Profile`, and `Settings` classes.
    *   **`schedule_model.dart`:** Defines the `Schedule`, `CategoriesSummary`, and `SubcategorySummary` classes.
    *   **`day_model.dart`:** Defines the `Day` and `Task` classes.
*   **`providers/`:**
    *   **`user_provider.dart`:** A `ChangeNotifier` that manages the user's state.

## Current Task: Fix Day of the Week Display Bug

**Plan:**

1.  **Identify the root cause:** The `day_detail_screen.dart` file was not correctly parsing the date from the day's ID, which is stored in Firestore with hyphens (e.g., "2025-11-24"). The code was expecting underscores (e.g., "2025_11_24").
2.  **Implement the fix:** The `_parseDateFromId` function in `lib/screens/day_detail_screen.dart` has been updated to handle both hyphens and underscores by replacing underscores with hyphens before parsing the date.
3.  **Verify the fix:** The user will verify that the days of the week are now displayed correctly in the app.
