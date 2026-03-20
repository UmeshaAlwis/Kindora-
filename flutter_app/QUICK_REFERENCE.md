# Quick References Guide

## Project Commands

```bash
# Navigate to flutter app
cd flutter_app

# Install dependencies
flutter pub get

# Run app
flutter run

# Analyze code
flutter analyze

# Format code
dart format lib/

# Build APK
flutter build apk --release

# Hot reload (during development)
# Press 'r' in terminal

# Hot restart
# Press 'R' in terminal
```

## File Organization Rules

### When Adding a New Feature:
1. Create folder under `lib/features/<feature_name>/`
2. Add these subfolders:
   - `ui/` - UI screens and widgets
   - `providers/` - State management
   - `services/` - API calls and business logic
   - `models/` - Data models (if needed)

### Example Structure:
```
features/notifications/
├── ui/
│   ├── notifications_screen.dart
│   └── notification_card.dart
├── providers/
│   └── notifications_provider.dart
├── services/
│   └── notifications_service.dart
└── models/
    └── notification_model.dart
```

## Common Tasks

### Add a New Screen
1. Create file in `features/<feature>/ui/<screen_name>.dart`
2. Create Stateless/Stateful Widget
3. Add route in `config/routes/app_router.dart`
4. Update navigation as needed

### Navigate Between Screens
```dart
// Push screen (add to stack)
context.push('/campaigns');

// Go to screen (replace entire stack)
context.go('/dashboard');

// Pop current screen
context.pop();

// Pop until
context.pop(true);
```

### Use Theme Colors
```dart
// Primary color
Theme.of(context).primaryColor
// or
AppTheme.primaryColor

// Accent color
AppTheme.accentColor

// Error color
Theme.of(context).colorScheme.error
```

### Call Firebase Auth
```dart
// Get current user
final user = FirebaseAuth.instance.currentUser;

// Login
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Logout
await FirebaseAuth.instance.signOut();

// Check auth state
FirebaseAuth.instance.idTokenChanges().listen((user) {
  // user is null if logged out
});
```

### Make API Calls (When Backend Connected)
```dart
// Using Dio (already in pubspec)
import 'package:dio/dio.dart';

final dio = Dio();
final response = await dio.get('/campaigns');
```

## Important Files Reference

| File | Purpose | Location |
|------|---------|----------|
| main.dart | App entry | `lib/main.dart` |
| app_router.dart | Routes | `lib/config/routes/` |
| app_theme.dart | Theme | `lib/config/themes/` |
| auth_gate.dart | Auth check | `lib/core/widgets/` |
| *_screen.dart | Screens | `lib/features/*/ui/` |

## Debugging Tips

1. **Check console for errors**
   ```bash
   flutter run -v  # Verbose mode
   ```

2. **Rebuild app**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Check for null safety issues**
   - Use `?` for nullable types
   - Use `!` only when sure
   - Use `??` for null coalescing

4. **Firebase not connecting?**
   - Check Firebase credentials in `firebase_options.dart`
   - Verify internet connection
   - Check Firebase console settings

## Code Style Guidelines

- Use `const` where possible (for performance)
- Add type annotations (avoid `var` for variables)
- Use CamelCase for classes, snake_case for files
- Document complex functions with comments
- Keep functions small and focused

## Testing Your Changes

```bash
# Run specific file analysis
dart analyze lib/features/campaign/ui/campaign_home_page.dart

# Check for unused imports
dart fix lib/ --apply

# Format entire lib folder
dart format lib/
```

## Getting Help

- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Docs**: https://firebase.google.com/docs
- **GoRouter Docs**: https://pub.dev/packages/go_router
- **Dart Language Tour**: https://dart.dev/guides/language/language-tour

---

**Keep this guide handy for quick reference!** 📖
