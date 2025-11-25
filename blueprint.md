# Project Blueprint

## Overview

This project is a Flutter application that displays a weekly task schedule. The application reads task data from a local JSON file and presents it in a daily, weekly, and chart-based view. The application is styled with a dark theme and uses the `fl_chart` package for data visualization.

## Style and Design

*   **Theme:** Dark theme with a black background and white text.
*   **Font:** Default Flutter font.
*   **Layout:** The `DayDetailScreen` features a highly responsive layout. It uses a `LayoutBuilder` to intelligently divide the horizontal space between the task list and the charts panel. The task list maintains a consistent width, while the charts panel dynamically expands to fill the remaining area, ensuring a minimum width for readability. The entire content area scrolls horizontally if the combined width exceeds the screen size, preventing overflow issues.
*   **Chart Layout:** The `ChartsPanel` is also fully responsive. It uses a `LayoutBuilder` and a `Wrap` widget to arrange the charts. The pie charts are positioned side-by-side on wider screens and wrap to a new line on narrower screens. The bar chart is displayed below, spanning the full width of the panel. This ensures an optimal and space-efficient presentation across all devices.

## Features

*   **Task Data:** The application reads task data from a local JSON file (`nextweekstask.json`).
*   **Daily View:** The "Day" tab displays a list of tasks for the current day, with each task showing the activity, category, subcategory, planned hours, and actual hours.
*   **Weekly View:** The "Week" tab displays a list of tasks for the entire week, with each day's tasks grouped together.
*   **Chart View:** The "Charts" tab displays the following charts in a responsive layout:
    *   A pie chart showing the breakdown of tasks by category.
    *   A pie chart showing the breakdown of tasks by subcategory.
    *   A bar chart showing the planned vs. actual hours for each task.

## Current Plan

*All requested changes have been implemented.*
