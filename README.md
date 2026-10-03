# Give a Break

**Give a Break** is an Android digital wellbeing app built with Flutter. It helps you take back control of your screen time: it tracks how much you use each app and lets you set daily limits. When you go over a limit, it shows a full-screen overlay warning.

## Purpose

Phones make it easy to lose hours to apps without noticing. Give a Break makes that usage visible and gives you tools to set boundaries:

- **See** how much time you spend on each app, how often you open it, and how your usage changes over the week.
- **Limit** individual apps by daily time or by number of launches.
- **Schedule** routines that apply limits to groups of apps on certain days and at certain times (for example, "Work hours, Mon–Fri, 09:00–18:00").
- **Interrupt** with a full-screen overlay the moment you open an app that has hit its limit.

All data stays on the device. Nothing is sent to a server.

## Features

| Feature | Description |
|---|---|
| Usage tracking | Daily time, launch count and last used time per app, read from Android `UsageStatsManager`. Only user-installed apps are shown. |
| App limits | Daily time limit (0–12 h, set in 1-minute steps) and/or a daily launch limit, which you can turn on or off per app. |
| Routines | Recurring schedules with a name, description, active days, a time range, a list of apps, limits, and a custom overlay color and emoji. Routines can be archived and restored. |
| Dashboard | Today's screen time, top 5 apps, a weekly chart, and how many apps are restricted. |
| Real-time monitoring | An Accessibility Service detects app launches instantly. A foreground service keeps monitoring running in the background. Overlays have a 2-second debounce. |
| Onboarding | A 3-page introduction followed by guided permission setup. |
| Settings | Turn monitoring on or off, choose a light, dark or system theme, and export or import limits, routines and settings as JSON. |

### Limit rules

- An app is blocked when its time limit **or** its launch limit is reached.
- A routine applies only when it is **enabled**, **not archived**, and **active**: today is one of its days, and the current time is inside its range. With no time range, it runs all day.
- Days are numbered from `0` (Sunday) to `6` (Saturday). Times use the 24-hour `HH:mm` format.

## Tech Stack

- **Flutter / Dart** (SDK `^3.10.7`) for the UI and app logic
- **Kotlin** for the native Android services: Accessibility Service, foreground monitor service, overlay, boot receiver
- **Platform:** Android only

### Main libraries

| Library | Purpose |
|---|---|
| [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) / [`riverpod_annotation`](https://pub.dev/packages/riverpod_annotation) | State management |
| [`hive_ce`](https://pub.dev/packages/hive_ce) / [`hive_ce_flutter`](https://pub.dev/packages/hive_ce_flutter) | Local NoSQL storage for limits, routines and settings |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Syncs limits as JSON so the native Android services can read them |
| [`flutter_overlay_window`](https://pub.dev/packages/flutter_overlay_window) | Draws the full-screen warning over other apps |
| [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) | Shows the foreground service notification and other alerts |
| [`installed_apps`](https://pub.dev/packages/installed_apps) | Lists installed apps with their names and icons |
| [`permission_handler`](https://pub.dev/packages/permission_handler) | Checks and requests runtime permissions |
| [`fl_chart`](https://pub.dev/packages/fl_chart) | Draws the weekly usage chart |
| [`file_picker`](https://pub.dev/packages/file_picker) | Picks files for JSON import and export |
| [`package_info_plus`](https://pub.dev/packages/package_info_plus) | Reads the app version |
| [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) | Generates the native splash screen |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart `>=3.10.7`
- Android SDK / Android Studio (the app targets SDK 34)
- A physical Android device or an emulator. A real device works best, because the app relies on usage stats, overlay and accessibility APIs.

Check your setup:

```bash
flutter doctor
```

### Installation

```bash
git clone <repository-url>
cd give-a-break
flutter pub get
```

### Code generation

The project uses Freezed, Riverpod, Hive and JSON generators. Run this after changing any annotated model, entity or provider:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Use `watch` instead of `build` to regenerate automatically during development.

### Run

```bash
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Required Permissions

The app asks for these permissions during onboarding:

| Permission | Why it is needed |
|---|---|
| **Usage Access** (`PACKAGE_USAGE_STATS`) | Read app usage time and launch counts |
| **Display over other apps** (`SYSTEM_ALERT_WINDOW`) | Show the limit-exceeded overlay |
| **Accessibility Service** | Detect app launches instantly |
| **Notifications** (`POST_NOTIFICATIONS`) | Show the foreground service notification |
| Battery optimization exemption | Keep monitoring alive in the background |
| Boot completed | Restart monitoring after the device reboots |

> If the Accessibility Service disconnects (some OEMs kill it), the dashboard shows a warning. Open **Accessibility Settings**, then turn the service off and on again.

## Project Structure

```
lib/
├── main.dart                    # Entry point (Hive + notifications init)
├── app.dart                     # Root MaterialApp
├── core/
│   ├── constants/               # Colors, strings
│   ├── extensions/              # Duration and routine helpers
│   ├── services/                # Method channels, Hive, notifications, overlay
│   └── theme/                   # Material theme
├── data/
│   ├── models/                  # Hive models (+ generated adapters)
│   └── repositories/            # Data access layer
├── domain/
│   └── entities/                # Freezed entities
└── presentation/
    ├── providers/               # Riverpod providers
    ├── screens/                 # Dashboard, app list, app detail, routines, settings, onboarding...
    └── widgets/                 # Reusable widgets
```

## How It Works

1. **Flutter** saves limits and routines in **Hive**. On every create, update or delete, it also syncs them to **SharedPreferences** as JSON.
2. The native **Accessibility Service** sees when an app comes to the foreground.
3. **LimitChecker** (Kotlin) reads the synced limits, checks whether a routine is active, and compares today's usage and launch count with the limits.
4. If a limit has been reached, **OverlayService** shows the full-screen warning with the app name, the time used, and the limit. It uses the routine's color and icon when the app belongs to a routine.
5. A **foreground service** keeps monitoring running, and **BootReceiver** restarts it after a reboot.

## Demo

### Individual App Limit
<img width="300" height="700" alt="1-compressed" src="https://github.com/user-attachments/assets/d15cc23f-7439-4fec-8ddb-faae721f7439" />

### Routines & App Limits
<img width="300" height="700" alt="2-compressed" src="https://github.com/user-attachments/assets/37ff6bf3-ae09-43e0-b721-10816298eec8" />

### Configs
<img width="300" height="700" alt="3-compressed" src="https://github.com/user-attachments/assets/ea716c92-492f-4e98-bbbb-60bdeb5a5c1c" />


