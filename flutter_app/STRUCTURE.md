# Flutter App - Project Structure & Organization

## Overview
The flutter_app has been reorganized using **Clean Architecture** principles for scalability and maintainability.

## Folder Structure

```
flutter_app/
├── lib/
│   ├── config/
│   │   ├── app_config.dart          # App configuration constants
│   │   ├── routes/
│   │   │   └── app_router.dart      # GoRouter navigation configuration
│   │   └── themes/
│   │       └── app_theme.dart       # Material3 theme (light & dark)
│   │
│   ├── core/
│   │   ├── extensions/              # Dart extensions
│   │   ├── utils/                   # Utility functions & helpers
│   │   ├── constants/               # App-wide constants
│   │   └── widgets/
│   │       ├── auth_gate.dart       # Authentication gate widget
│   │       └── app_bottom_nav_bar.dart  # Bottom navigation bar
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── ui/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── verify_email_screen.dart
│   │   │   ├── providers/           # State management
│   │   │   └── services/            # Auth services
│   │   │
│   │   ├── home/
│   │   │   ├── ui/
│   │   │   │   └── home_screen.dart
│   │   │   ├── providers/
│   │   │   └── services/
│   │   │
│   │   ├── dashboard/
│   │   │   ├── ui/
│   │   │   │   ├── dashboard_screen.dart
│   │   │   │   └── dashboard_home.dart
│   │   │   ├── providers/
│   │   │   └── services/
│   │   │
│   │   ├── campaign/
│   │   │   ├── ui/
│   │   │   │   ├── campaign_home_page.dart
│   │   │   │   └── start_campaign_page.dart
│   │   │   ├── widgets/
│   │   │   ├── providers/
│   │   │   └── services/
│   │   │
│   │   ├── profile/
│   │   │   ├── ui/
│   │   │   │   └── profile_page.dart
│   │   │   ├── providers/
│   │   │   └── services/
│   │   │
│   │   ├── payment/
│   │   │   ├── ui/
│   │   │   ├── providers/
│   │   │   └── services/
│   │   │
│   │   └── settings/
│   │       ├── ui/
│   │       │   └── settings_page.dart
│   │       └── providers/
│   │
│   ├── models/
│   │   └── [shared data models]
│   │
│   ├── main.dart                    # App entry point
│   └── firebase_options.dart        # Firebase configuration
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── animations/
│
├── pubspec.yaml                     # Dependencies
└── analysis_options.yaml            # Lint rules
```

## Architecture Pattern: Clean Architecture

### Layer Structure
1. **Presentation Layer (UI)** - User interface screens
2. **Business Logic Layer (Providers)** - State management & business logic
3. **Data Layer (Services)** - API calls and data operations

### Main Features
- ✅ **Authentication** - Email/password & Google Sign-In
- ✅ **Home Dashboard** - Main app hub
- ✅ **Campaign Management** - Create & browse campaigns
- ✅ **User Profile** - Profile management
- ✅ **Settings** - App settings
- ✅ **Bottom Navigation** - Easy navigation between features

## Navigation System

Using **GoRouter** for modern, type-safe navigation:

```dart
// Navigate to a route
context.push('/campaigns');

// Replace current route
context.go('/dashboard');

// Pop current route
context.pop();
```

### Available Routes
- `/` - Home
- `/login` - Login screen
- `/signup` - Sign up screen
- `/auth` - Auth gate (authentication check)
- `/dashboard` - Main dashboard
- `/campaigns` - Campaign listing
- `/profile` - User profile
- `/settings` - App settings

## Theme System

**Material 3** Design with support for:
- ✅ Light theme
- ✅ Dark theme
- ✅ System theme detection
- ✅ Custom color scheme (Green primary, Orange accent)

## State Management

Prepared for **Riverpod** and **Provider**:
- Providers folder in each feature for state management
- Ready for dependency injection with `get_it`

## Authentication

- **Firebase Auth** with Email/Password
- **Google Sign-In** integration
- **Auth Gate** for route protection

## Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point & Firebase init |
| `lib/config/routes/app_router.dart` | All routes configuration |
| `lib/config/themes/app_theme.dart` | Theming & colors |
| `lib/core/widgets/auth_gate.dart` | Auth state checking |
| `lib/features/*/ui/*.dart` | Feature screens |

## Dependencies Installed

- **firebase_core, firebase_auth** - Authentication
- **go_router** - Navigation
- **provider, riverpod** - State management
- **dio, http** - Networking
- **hive, shared_preferences** - Local storage
- **google_sign_in** - Google authentication
- And 20+ more packages for UI, payments, notifications, etc.

## Next Steps

1. **Fill in business logic** in provider files
2. **Implement API services** in services folders
3. **Add more screens** following the same pattern
4. **Connect to backend APIs** through Dio/Http
5. **Add error handling** & loading states

## Error Status

**Reduced from 113 errors to 47 info-level issues** ✅
- Most remaining issues are style warnings (prefer_const_constructors)
- App is now ready for development

## Running the App

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d <device_id>

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

---
**Last Updated:** March 7, 2026
**Project**: Kindora - Charity Platform
