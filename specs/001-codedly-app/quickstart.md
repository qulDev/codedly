# Codedly - Local Development Quickstart

This guide will help you set up Codedly for local development on your machine.

---

## Prerequisites

### Required Software

- **Flutter SDK**: 3.16 or higher
  - [Install Flutter](https://docs.flutter.dev/get-started/install)
  - Verify: `flutter --version`
- **Dart SDK**: 3.x (included with Flutter)
  - Verify: `dart --version`
- **Git**: For version control

  - Verify: `git --version`

- **Android Studio** (for Android development):
  - Android SDK 24 or higher (Android 7.0+)
  - Android emulator or physical device
- **Xcode** (for iOS development, macOS only):
  - Xcode 14+
  - iOS Simulator or physical device with iOS 12.0+
  - CocoaPods: `sudo gem install cocoapods`

### Optional but Recommended

- **VS Code** with Flutter extension
- **Supabase CLI**: For local database development
  - Install: `brew install supabase/tap/supabase` (macOS)
  - Or: `npm install -g supabase` (all platforms)

---

## 1. Clone and Setup Repository

```bash
# Clone the repository
git clone <repository-url>
cd codedly

# Verify Flutter installation
flutter doctor
```

**Expected Output**: All checkmarks (✓) for Flutter, Dart, and target platforms.

---

## 2. Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# For iOS (macOS only)
cd ios
pod install
cd ..
```

**Expected Output**: "Got dependencies!" message, no errors.

---

## 3. Supabase Backend Setup

### Option A: Cloud Setup (Recommended for Most)

1. **Create Supabase Project**:

   - Go to [supabase.com](https://supabase.com)
   - Click "New project"
   - Name: `codedly-dev`
   - Set database password (save it securely)
   - Choose region closest to you

2. **Run Database Migration**:

   - Go to SQL Editor in Supabase dashboard
   - Copy contents of `specs/001-codedly-app/contracts/database-schema.sql`
   - Paste and execute

3. **Enable Authentication**:

   - Go to Authentication → Providers
   - Enable Email/Password
   - Enable Google OAuth (optional, for social login)

4. **Get API Keys**:
   - Go to Settings → API
   - Copy `Project URL` and `anon public` key

### Option B: Local Setup (Advanced)

```bash
# Initialize local Supabase
supabase init

# Start local Supabase
supabase start
```

**Note**: Local setup requires Docker.

---

## 4. Configure Environment Variables

Create `.env` file in project root:

```bash
# Supabase Configuration
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Optional: Google OAuth (if using social login)
GOOGLE_CLIENT_ID_ANDROID=xxxxx.apps.googleusercontent.com
GOOGLE_CLIENT_ID_IOS=xxxxx.apps.googleusercontent.com
```

**Security**: Add `.env` to `.gitignore` (already done in template).

---

## 5. Update Configuration Files

### `lib/core/config/app_config.dart`

```dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_DEV_URL_HERE',  // For development
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_DEV_KEY_HERE',  // For development
  );
}
```

**Note**: For production, use `--dart-define` flags with build commands.

---

## 6. Run the App

### Android

```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run
```

### iOS (macOS only)

```bash
# Open iOS simulator
open -a Simulator

# Run app
flutter run
```

### Select Device

If multiple devices available:

```bash
flutter run -d <device-id>
```

---

## 7. Verify Setup

After app launches:

1. **Check Home Screen**: Should see onboarding or login screen
2. **Test Registration**:
   - Create account with email/password
   - Verify user appears in Supabase → Authentication → Users
3. **Test Content Loading**:
   - Login → See modules/lessons (from seed data)
   - Verify no network errors in console

---

## 8. Development Workflow

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/auth_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Generation (GetIt, Riverpod)

```bash
# Generate dependency injection code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch
```

### Linting

```bash
# Analyze code
flutter analyze

# Format code
dart format lib test
```

---

## 9. Common Issues & Solutions

### Issue: "Unable to load asset"

**Solution**: Run `flutter pub get` and restart app.

### Issue: Supabase authentication fails

**Solution**:

- Check `.env` file has correct URL and key
- Verify Supabase project is active
- Check internet connection

### Issue: iOS build fails with CocoaPods error

**Solution**:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter run
```

### Issue: Android build fails with Gradle error

**Solution**:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

### Issue: "Null safety" errors

**Solution**: Ensure Flutter SDK is 3.16+ (`flutter upgrade`).

---

## 10. Useful Commands

| Command                | Description                 |
| ---------------------- | --------------------------- |
| `flutter doctor`       | Check Flutter installation  |
| `flutter pub get`      | Install dependencies        |
| `flutter clean`        | Clean build artifacts       |
| `flutter build apk`    | Build Android APK           |
| `flutter build ios`    | Build iOS app (macOS only)  |
| `flutter pub upgrade`  | Update dependencies         |
| `flutter pub outdated` | Check for outdated packages |

---

## 11. Database Seeding

The database migration includes seed data:

- 1 module: "Introduction to Python"
- 2 lessons: "What is Python?", "Your First Python Program"
- 2 hints per lesson
- 1 quiz with 2 questions

To add more content:

1. Go to Supabase → Table Editor
2. Insert into `modules`, `lessons`, `quizzes`, `quiz_questions`

Or use SQL:

```sql
INSERT INTO modules (title_en, title_id, description_en, ...) VALUES (...);
```

---

## 12. Architecture Overview

```
lib/
├── core/               # Shared utilities, config, theme
├── features/           # Feature modules
│   ├── auth/           # Authentication
│   ├── lessons/        # Interactive lessons
│   ├── quizzes/        # Quiz system
│   ├── progress/       # XP, levels, stats
│   └── settings/       # App settings
├── shared/             # Shared widgets, models
└── main.dart           # App entry point
```

Each feature follows Clean Architecture:

- **Presentation**: UI (screens, widgets), StateNotifiers (Riverpod)
- **Domain**: Business logic, repositories (interfaces)
- **Data**: Repository implementations, data sources (Supabase, Hive)

---

## 13. Next Steps

1. **Read the Spec**: Review `specs/001-codedly-app/spec.md`
2. **Explore Data Model**: See `specs/001-codedly-app/data-model.md`
3. **Review Constitution**: Understand principles in `.specify/memory/constitution.md`
4. **Check Tasks**: See `specs/001-codedly-app/tasks.md` for implementation priorities
5. **Join Team Communication**: (Add Slack/Discord link here)

---

## 14. Getting Help

- **Documentation**: Check `specs/` folder for detailed specs
- **Issues**: File bugs/features in GitHub Issues
- **Team Chat**: (Add communication channel)
- **Code Review**: Submit PRs following conventional commits

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [re_editor Package](https://pub.dev/packages/re_editor)
- [Hive Documentation](https://docs.hivedb.dev/)

---

**You're all set!** 🚀 Start with implementing the authentication module (P1 priority).
