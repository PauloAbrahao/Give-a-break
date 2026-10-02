# Give a Break - Project Documentation

## Overview

**Give a Break** is an Android digital wellbeing application built with Flutter that helps users take control of their screen time by tracking app usage and setting daily limits with visual overlay warnings.

### Tech Stack

- **Frontend:** Flutter (Dart) with Riverpod for state management
- **Backend:** Android native services (Kotlin)
- **Local Storage:** Hive CE (NoSQL) + SharedPreferences
- **Notifications:** flutter_local_notifications
- **Overlay:** flutter_overlay_window
- **Platform:** Android

---

## Main Functionalities

### 1. Usage Tracking

- Reads app usage via Android's UsageStatsManager
- Tracks total time spent on each app daily
- Tracks number of app launches per day
- Shows last time used for each app
- Provides weekly summary statistics
- Filters to show only user-installed apps (excludes system apps)

### 2. Individual App Limits

- Set daily time limits on any app (0-12 hours in 1-minute increments)
- Set daily opening/launch limits (number of times an app can be opened)
- Enable/disable limits per app independently
- Delete limits when no longer needed

### 3. Routines (Scheduled Limits)

- Create recurring schedules that apply limits to multiple apps at once
- Configure name, description, and active days of the week
- Set start and end times for when the routine is active
- Select multiple apps to include in the routine
- Set daily time limits and opening limits for all apps in the routine
- Customize overlay appearance with colors and emoji icons
- Archive/restore routines for managing old schedules

### 4. Dashboard & Analytics

- Today's usage summary (total screen time + apps used)
- Most used apps list (top 5 user apps)
- Weekly overview chart showing daily screen time trends
- Restricted apps counter

### 5. Real-time Monitoring

- Accessibility Service for instant app launch detection
- Full-screen overlay warning when app limit is exceeded
- Shows app name, used time, and limit
- Customizable overlay colors and icons from routines
- 2-second debounce to prevent overlay spam
- Foreground service keeps monitoring active in background

### 6. Permissions & Onboarding

- Guided onboarding flow with 3 pages
- Permission setup screen requesting all required permissions
- Permission status checking and validation
- Reconnect prompts if accessibility service disconnects

### 7. Settings & Data Management

- Toggle monitoring on/off
- Theme selection (light/dark/system)
- Export limits, routines, and settings to JSON file
- Import previously exported data
- Show onboarding again option

---

## User Cases

### UC1: First-time User Setup

1. User launches the app for the first time
2. Onboarding screens introduce features (3 pages)
3. Permission setup screen requests all required permissions
4. User grants permissions and is redirected to Dashboard
5. User can immediately start viewing usage and setting limits

### UC2: Set a Simple App Limit

1. User navigates to App List screen
2. User searches for or browses to find an app
3. User taps the app to open Detail screen
4. User taps "Set Limit" button
5. User configures time limit using wheel picker (0-12 hours, 0-59 minutes)
6. User confirms selection
7. Limit is applied immediately and synced to Android service

### UC3: Create a Routine

1. User navigates to Routines screen
2. User taps "+" button to create new routine
3. User configures routine name and description
4. User selects active days of the week
5. User sets start and end times
6. User selects apps to include from app browser
7. User sets daily limit and opening limit
8. User optionally customizes overlay color and icon
9. User saves the routine
10. All selected apps receive the configured limits when routine is active

### UC4: View App Usage

1. User opens Dashboard
2. User sees today's usage card (total time + number of apps)
3. User views most used apps list
4. User views weekly usage chart
5. User taps any app to view details and set/adjust limits

### UC5: Limit Exceeded Warning

1. User opens a restricted app while limit is active
2. Accessibility Service detects app launch instantly
3. System checks if routine is active and if limit is exceeded
4. Full-screen overlay appears showing app name, used time, and limit
5. Overlay persists until routine ends or user adjusts the limit

### UC6: Export and Restore Data

1. User goes to Settings and selects Import/Export
2. For export: System creates JSON file with all limits and routines
3. For import: User selects previously exported JSON file
4. All settings are restored to the app

### UC7: Troubleshoot Accessibility Service

1. Dashboard shows warning if service is disconnected
2. User taps "Open Accessibility Settings" button
3. System accessibility settings screen opens
4. User toggles service off and on again
5. Connection is restored and monitoring resumes

---

## Business Rules

### Time Limit Rules

- Maximum daily time limit: 12 hours (720 minutes)
- Minimum increment: 1 minute
- Limit is enforced when daily usage >= dailyLimit seconds
- Duration format: hours (0-12) + minutes (0-59)

### Opening Limit Rules

- Maximum daily openings: User-defined integer (no hard limit)
- Minimum value: 0 (which disables the limit)
- Limit is enforced when app opens >= dailyLimitOpenings count

### Routine Enforcement Rules

- Routine must be enabled AND active (correct day + within time range) to apply
- If routine is inactive (wrong day or outside time range), limits don't apply
- If routine is disabled, all its app limits are disabled
- Multiple apps can share the same routine and limits
- Archived routines don't apply any limits

### Limit Check Logic

- Limit is exceeded if EITHER time limit OR opening limit is reached
- Both conditions are checked independently
- A single exceeded condition triggers the overlay

### Overlay Display Rules

- Overlay shown only when Accessibility Service detects app in foreground
- App must belong to enabled routine OR have enabled individual limit
- Routine must be active (correct day + current time in range)
- Time limit or opening limit must be exceeded
- Minimum 2 seconds between overlays for the same app (debounce)
- Display Over Apps permission must be granted

### Day and Time Scheduling

- Days: Sunday = 0, Monday = 1, Tuesday = 2, ... Saturday = 6
- Time format: HH:mm (24-hour format)
- If no time range is set, routine runs all day on selected days
- If time range is set, limits only apply between start and end time

### Routine Status Definitions

- **Currently Running:** Enabled + active on today + current time within range
- **Upcoming:** Enabled + not running now + next occurrence available within 7 days
- **Disabled:** Explicitly disabled by user
- **Archived:** Archived by user, doesn't contribute to limits

### Data Synchronization

- Limits stored in Hive database for Flutter access
- Limits also synced to SharedPreferences for Android service access
- JSON format used for SharedPreferences storage
- Sync happens on every create/update/delete operation

### Permission Requirements

- Usage Stats Permission: Required for reading usage data
- Display Over Apps: Required for showing overlay warnings
- Accessibility Permission: Required for instant app detection
- Notification Permission: Required for foreground service notification

---

## Project Architecture

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root MaterialApp widget
├── core/
│   ├── constants/               # Colors, strings
│   ├── extensions/              # Duration and routine helpers
│   ├── services/                # Method channels, Hive, notifications
│   └── theme/                   # Material theme
├── data/
│   ├── models/                  # Hive models
│   └── repositories/            # Data access layer
├── domain/
│   └── entities/                # Freezed entities
└── presentation/
    ├── providers/               # Riverpod providers
    ├── screens/                 # UI screens
    └── widgets/                 # Reusable widgets

android/app/src/main/kotlin/
├── MainActivity.kt
├── channels/                    # Method channels
├── receivers/                   # Boot receiver
└── services/                    # Native services
```

---

## Claude Code Guidelines

When working on this codebase, follow these mandatory rules:

### Code Quality

- Write clean, readable code with meaningful variable and function names
- Follow single responsibility principle for functions and classes
- Keep functions small and focused on one task
- Use early returns to reduce nesting
- Avoid magic numbers; use constants or named values
- Remove unused code, imports, and variables

### Best Practices

- Follow Flutter/Dart best practices and conventions
- Use Riverpod patterns consistently with existing code
- Prefer composition over inheritance
- Use immutable data structures where possible (Freezed entities)
- Handle errors appropriately at system boundaries
- Write type-safe code; avoid dynamic types

### Code Style

- Do NOT add comments to the code
- Do NOT add documentation comments or docstrings
- Do NOT add inline explanatory comments
- Let the code be self-documenting through clear naming
- Follow existing code style and formatting in the project
- Use consistent indentation and spacing

### Changes Policy

- Only make changes that are directly requested
- Do not add features beyond what was asked
- Do not refactor code that wasn't part of the request
- Do not add "improvements" or optimizations unless asked
- Keep solutions simple and focused on the task
- A bug fix doesn't need surrounding code cleaned up

### Prohibited Actions

- Do not add type annotations to code you didn't change
- Do not add error handling for scenarios that can't happen
- Do not create abstractions for one-time operations
- Do not design for hypothetical future requirements
- Do not add feature flags or backwards-compatibility shims
- Do not create documentation files unless explicitly requested

### Testing & Validation

- Verify changes work correctly before marking complete
- Check for potential regressions in related functionality
- Ensure changes don't introduce security vulnerabilities
- Validate data at system boundaries (user input, external APIs)

### Git & Commits

- Only commit when explicitly asked
- Use clear, concise commit messages describing the change
- Stage specific files rather than using "git add -A"
- Never commit sensitive files (.env, credentials)
