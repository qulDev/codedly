# Codedly - Interactive Python Learning App 🚀

A gamified mobile learning platform for Python programming, built with Flutter and Supabase. Inspired by Duolingo's engaging approach to education.

## 🎯 Project Status

**Current Phase:** Phase 3 Complete - Authentication & Home Dashboard  
**Version:** 0.3.0 (Development)  
**Last Updated:** October 31, 2025

### ✅ Completed Features

#### Phase 1: Setup & Configuration

- ✅ Flutter project initialization (Flutter 3.x, Dart 3.9.2)
- ✅ Folder structure (Clean Architecture)
- ✅ Git repository setup
- ✅ Linting and formatting configuration
- ✅ Environment variables (.env template)
- ✅ Test structure

#### Phase 2: Foundation

- ✅ Theme system (Dark mode, Duolingo colors)
- ✅ Typography and color constants
- ✅ Localization (English & Indonesian - 43 strings)
- ✅ Dependency Injection (GetIt + Injectable)
- ✅ Core utilities (validators, date helpers, XP constants, network info)
- ✅ Error handling (Failures & Exceptions)
- ✅ Shared widgets (LoadingIndicator, ErrorView, EmptyState, CustomButton, CustomAppBar)

#### Phase 3: Authentication & Home

- ✅ **Authentication System**

  - Clean Architecture (domain/data/presentation layers)
  - Supabase integration (email/password auth)
  - Sign-in & Sign-up screens with validation
  - Auth state management (Riverpod StateNotifier)
  - Auto-profile creation with database triggers
  - Google OAuth UI ready (needs credentials)

- ✅ **Onboarding Flow**

  - 4-page interactive introduction
  - PageView with smooth animations
  - Skip/Back/Next/Get Started navigation
  - Updates `onboarding_completed` flag
  - Beautiful illustrations and messaging

- ✅ **Home Dashboard**

  - Welcome message with user's name
  - Real-time stats cards (XP, Level, Streak)
  - Lesson module cards with progress
  - Bottom navigation (4 tabs)
  - Pull-to-refresh functionality
  - Loading states

- ✅ **User Stats Feature**
  - Complete domain/data/presentation layers
  - Supabase integration for stats retrieval
  - Auto-loads on home screen
  - XP/Level/Streak tracking ready
  - Network connectivity checking

## 🛠 Tech Stack

### Frontend

- **Framework:** Flutter 3.x (Dart 3.9.2)
- **State Management:** flutter_riverpod 2.6.1
- **Architecture:** Clean Architecture
- **Functional Programming:** dartz 0.10.1 (Either<Failure, Success>)
- **Dependency Injection:** get_it 7.7.0 + injectable 2.5.2
- **Local Storage:** Hive 2.2.3

### Backend

- **BaaS:** Supabase (supabase_flutter 2.10.3)
- **Database:** PostgreSQL with Row Level Security (RLS)

## 🗄 Database Schema

### Tables (9)

1. **user_profiles** - User account data
2. **user_stats** - Aggregated statistics (XP, level, streak)
3. **modules** - Learning modules
4. **lessons** - Individual lessons with code challenges
5. **lesson_hints** - Hints for lessons
6. **quizzes** - Assessments
7. **quiz_questions** - Multiple choice questions
8. **user_progress** - Completion tracking
9. **xp_records** - XP transaction history

### RPC Functions (NEW!)

- `add_xp(user_id, xp_amount)` - Adds XP and recalculates level
- `update_streak(user_id)` - Updates daily streak
- `complete_lesson(user_id, lesson_id, xp)` - Completes lesson workflow
- `complete_quiz(user_id, quiz_id, score, xp)` - Completes quiz workflow

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.16+ (stable)
- Dart 3.9.2+
- Supabase account (free tier works)

### Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd codedly
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure environment**

   - Copy `.env.example` to `.env`
   - Add your Supabase URL and anon key

4. **Set up Supabase**

   - Create a new Supabase project
   - Run `specs/001-codedly-app/contracts/database-schema.sql` in SQL Editor
   - Run `specs/001-codedly-app/contracts/database-functions.sql` in SQL Editor (NEW!)

5. **Run code generation**

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 🎨 Design System

### Colors

- **Primary:** #58CC02 (Duolingo Green)
- **Secondary:** #1CB0F6 (Sky Blue)
- **Background:** #1F1F1F (Dark)

### Theme

- Dark mode only
- Duolingo-inspired visual language

## 📊 XP & Leveling System

### XP Formula

```dart
// Level calculation: floor((-1 + sqrt(1 + 8*xp/100))/2) + 1
int calculateLevel(int totalXp) {
  return ((-1 + sqrt(1 + 8 * totalXp / 100)) ~/ 2) + 1;
}
```

## 📝 Next Steps

1. **Lessons Feature** - Build lesson list, code editor, Python execution
2. **Quiz System** - Multiple choice questions, scoring, results
3. **Profile Screen** - User details, achievements, settings
4. **Gamification UI** - Level progress bars, XP animations

---

**Built with ❤️ using Flutter and Supabase**
