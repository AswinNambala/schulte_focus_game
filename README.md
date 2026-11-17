# 🧠 Schulte Focus

[![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-teal)](#architecture)
[![State Management](https://img.shields.io/badge/State-BLoC%20%2F%20Cubit-blue)](https://bloclibrary.dev)
[![Backend](https://img.shields.io/badge/Backend-Firebase-orange?logo=firebase&logoColor=white)](https://firebase.google.com)
[![Offline First](https://img.shields.io/badge/Storage-Hive%20Local%20Cache-yellow)](#offline-first-sync)

**Schulte Focus** is a modern, high-performance cognitive training and visual conditioning application built with Flutter. Rooted in the scientifically proven **Schulte Table** methodology, the app trains peripheral vision, reading speed, mental stamina, and selective attention through dynamic grid challenges and real-time performance analytics.

---

## 📖 Table of Contents

- [About Schulte Tables](#-about-schulte-tables)
- [Key Features](#-key-features)
- [Architecture & Design](#-architecture--design)
- [Project Structure](#-project-structure)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Firebase Setup](#-firebase-setup)
- [Testing](#-testing)
- [Screenshots & Visuals](#-screenshots--visuals)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔬 About Schulte Tables

A **Schulte Table** is a grid of randomly distributed numbers or letters used to develop:
- **Peripheral Vision Expansion:** Learning to absorb visual information across the entire field of view without unnecessary eye saccades.
- **Speed Reading:** Cultivating parallel visual processing to scan paragraphs and text blocks faster.
- **Selective Focus & Concentration:** Suppressing distractions while rapidly identifying sequential targets.
- **Reaction Time & Mental Processing Speed:** Decreasing cognitive latency between visual target acquisition and motor response.

---

## ✨ Key Features

### 🎮 Game Modes & Variations
- **Classic Number Grids:** Standard ascending numeric sequences from 3x3 (Sprint) up to 7x7 (Pro Challenge).
- **Classic Letter Grids (A-Z):** Alphabetical sequence mode to challenge verbal and spatial cognitive pathways.
- **Quick Play Modes:**
  - `Classic 123`: Standard 5x5 (25 cells) numeric grid.
  - `Classic ABC`: Standard 5x5 (25 cells) letter grid.
  - `Speed 3x3`: 9-cell quick sprint for rapid warm-ups.
  - `Challenge 6x6`: 36-cell grid for advanced visual stamina.
- **Dynamic Distractors & Rotations:** Randomized cell angle orientations and distractor rotations designed to elevate focus under visual noise.

### 📈 Adaptive 20-Level Campaign
- **Intelligent Progression:** Dynamic difficulty assessment evaluates completion time and error counts to level up, hold, or recommend reinforcement.
- **Star Rating System:** 1 to 3 stars awarded per level based on strict target thresholds.
- **Persistent Progress:** Automatic state persistence retaining unlocked levels and personal best records.

### 📊 Performance Analytics & Reports
- **Detailed Metrics:** Tracks total sessions, cumulative training time, personal bests, average session times, and millisecond-level per-tap reaction speeds.
- **Interactive Visualizations:** Historical progression graphs and session analysis powered by `fl_chart`.
- **Streak Tracker:** Daily habit and consistency counter to encourage deliberate daily training.

### ♿ Accessibility & Customization
- **Colorblind Support:** Specially designed high-contrast colorblind palette.
- **Tactile & Sound Feedback:** Granular controls for haptic pulses on tap/error and responsive audio cues.
- **Modern Dark UI:** Ergonomic, distraction-free interface built to minimize eye strain during intense focus sessions.

### ☁️ Offline-First & Cloud Sync
- **Local Cache:** High-speed instant gameplay with Hive local storage.
- **Dual Cloud Sync:** Seamless background synchronization with Cloud Firestore whenever connectivity is restored.
- **Authentication:** Secure Firebase Authentication (Google Sign-In & Email/Password) with full guest play support and account deletion compliance.

---

## 🏛️ Architecture & Design

The project strictly adheres to **Clean Architecture** principles separated into feature-driven modules:

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (Widgets, Pages, BLoC / Cubits, Navigation, Theme)   │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│        (Entities, Use Cases, Repository Contracts)     │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                       Data Layer                       │
│    (Models, Data Sources, Hive Cache, Firestore Sync)  │
└────────────────────────────────────────────────────────┘
```

- **Functional Error Handling:** Uses `fpdart` (`Either<Failure, T>`) for explicit, type-safe error management across domain boundaries.
- **State Management:** Predictable state transitions managed via `flutter_bloc` and `equatable`.
- **Dependency Injection:** Centralized, testable service registry powered by `get_it`.
- **Routing:** Deep-link capable declarative routing configured using `go_router` with nested `StatefulShellRoute`.

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/       # App colors, string keys, and global defaults
│   ├── di/              # Service locator (get_it registration)
│   ├── errors/          # Failures and Exception definitions
│   ├── observer/        # Global BlocObserver for state tracking & logging
│   ├── router/          # GoRouter routes and shell navigators
│   ├── theme/           # Dark theme styling, typography, and theme cubit
│   └── utils/           # Haptic helpers and formatting utilities
├── features/
│   ├── auth/            # Sign in, sign up, guest mode & user entity
│   ├── game/            # Grid generation, HUD, cell widgets & game engine
│   ├── home/            # Dashboard, quick-play launcher & streak banner
│   ├── levels/          # 20-level campaign, adaptive difficulty service
│   ├── reports/         # Session metrics, fl_chart visualizations & analytics
│   └── settings/        # Sound, haptics, colorblind mode & profile settings
├── firebase_options.dart# Firebase configuration across platforms
└── main.dart            # App entry point, Hive initialization & multi-bloc setup
```

---

## 🛠️ Tech Stack

| Domain | Technology / Library |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (SDK ^3.5.0) |
| **Language** | [Dart](https://dart.dev) |
| **State Management** | [flutter_bloc](https://pub.dev/packages/flutter_bloc) & [equatable](https://pub.dev/packages/equatable) |
| **Dependency Injection** | [get_it](https://pub.dev/packages/get_it) |
| **Functional Programming**| [fpdart](https://pub.dev/packages/fpdart) |
| **Routing** | [go_router](https://pub.dev/packages/go_router) |
| **Local Persistence** | [hive](https://pub.dev/packages/hive) & [hive_flutter](https://pub.dev/packages/hive_flutter) |
| **Cloud & Backend** | [Firebase Core](https://pub.dev/packages/firebase_core), [Auth](https://pub.dev/packages/firebase_auth), [Firestore](https://pub.dev/packages/cloud_firestore) |
| **Monitoring & Crash** | [Firebase Crashlytics](https://pub.dev/packages/firebase_crashlytics), [Analytics](https://pub.dev/packages/firebase_analytics) |
| **Data Visualization** | [fl_chart](https://pub.dev/packages/fl_chart) |
| **UI & Animations** | [flutter_animate](https://pub.dev/packages/flutter_animate), [google_fonts](https://pub.dev/packages/google_fonts) |

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.5.0 or later)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode (for device emulators and toolchains)
- A configured Git environment

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/schulte_focus.git
   cd schulte_focus
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter environment:**
   ```bash
   flutter doctor
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 🔐 Firebase Setup

The app uses Firebase for user authentication, cloud sync, analytics, and crash monitoring.

1. Ensure the [Firebase CLI](https://firebase.google.com/docs/cli) is installed and authenticated:
   ```bash
   firebase login
   ```
2. Configure your platform targets using FlutterFire:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Enable **Google Sign-In** and **Email/Password** under *Authentication* in your Firebase Console.
4. Create a **Cloud Firestore** database instance in production or test mode.

---

## 🧪 Testing

The test suite covers unit logic, adaptive algorithms, offline sync queues, and BLoC state transitions:

```bash
# Run all unit and widget tests
flutter test

# Run tests with code coverage report
flutter test --coverage
```

### Key Test Suites:
- `test/features/game/table_generator_test.dart`: Validates grid distribution, randomness, and sequencing.
- `test/features/levels/adaptive_difficulty_test.dart`: Tests performance evaluation and level transitions.
- `test/features/reports/offline_sync_test.dart`: Validates Hive queue caching and sync mechanisms.
- `test/features/auth/auth_bloc_test.dart`: Verifies authentication state flow and session handling.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.
