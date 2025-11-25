# Project Blueprint

## Overview

This project is a Flutter application that displays a weekly task schedule. The application reads task data from a local JSON file and presents it in a daily, weekly, and chart-based view. The application is styled with a dark theme and uses the `fl_chart` package for data visualization.

## Style and Design

*   **Theme:** Dark theme with a black background and white text.
*   **Font:** Default Flutter font.
*   **Layout:** The main screen is a tabbed view with three tabs: "Day", "Week", and "Charts".
    *   The "Day" tab displays a list of tasks for the current day.
    *   The "Week" tab displays a list of tasks for the entire week.
    *   The "Charts" tab displays a set of charts that visualize the task data.
*   **Responsiveness:** The `DayDetailScreen` is responsive. On wider screens, it displays a two-column layout with the task list on the left and charts on the right. On narrower screens (like mobile), the layout switches to a single-column, scrollable view to prevent overflow.

## Features

*   **Task Data:** The application reads task data from a local JSON file (`nextweekstask.json`).
*   **Daily View:** The "Day" tab displays a list of tasks for the current day, with each task showing the activity, category, subcategory, planned hours, and actual hours.
*   **Weekly View:** The "Week" tab displays a list of tasks for the entire week, with each day's tasks grouped together.
*   **Chart View:** The "Charts" tab displays the following charts:
    *   A pie chart showing the breakdown of tasks by category.
    *   A pie chart showing the breakdown of tasks by subcategory.
    *   A bar chart showing the planned vs. actual hours for each task.

## Current Plan

*This section will be updated with the plan for the current requested change.*
