# Codedly - Interactive Python Learning App 🚀

A gamified mobile learning platform for Python programming, built with Flutter and Supabase. Inspired by Duolingo's engaging approach to education.

## 🎯 Project Status

**Current Phase:** Phase 4 Complete - Quizzes & Leaderboard  
**Version:** 0.4.0 (Development)  
**Last Updated:** December 7, 2025

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

#### Phase 4: Quizzes & Leaderboard

- ✅ **Quizzes System**
  - Module & quiz listing with progress (user_progress)
  - Quiz questions (quiz_questions) with multi-language text and options
  - Scoring, pass/fail, XP rewards, streak update, XP history (xp_records)
  - Completion tracking + attempts_count updates
  - RLS-safe Supabase reads via published filters
- ✅ **Leaderboard**
  - XP-based ranking with tie-breaker (earlier XP reached)
  - RPC `get_leaderboard` integration
  - UI with badges, retry, pull-to-refresh, inline error banner
- ✅ **Navigation & Routing**
  - Named routes to avoid circular imports
  - Bottom navigation across Home / Lessons / Leaderboard / Profile

## 🛠 Tech Stack

### Frontend

- **Framework:** Flutter 3.x (Dart 3.9.2)
- **State Management:** flutter_riverpod 2.5.x
- **Architecture:** Clean Architecture
- **Functional Programming:** dartz 0.10.1 (Either<Failure, Success>)
- **Dependency Injection:** get_it 7.7.0 + injectable 2.6.x
- **Local Storage:** Hive 2.2.x

### Backend

- **BaaS:** Supabase (supabase_flutter 2.5.x)
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
   git clone https://github.com/qulDev/codedly.git
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
   - Run `query/database-schema.sql` in SQL Editor
   - Run `query/database-function.sql` in SQL Editor
   - Apply any RLS fixes in `FIX_RLS_ERROR.md` or `ULTIMATE_RLS_FIX.sql` if needed

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

1. **Lesson Coding Flow** - Code editor UX, validation runners, richer hints
2. **Profile & Achievements** - Badges, history, account settings
3. **Production Auth** - Google OAuth keys + deep links
4. **Offline & Caching** - Hive/SP caching for modules/quizzes
5. **Testing & CI** - Widget tests, integration tests, pipeline

## 👥 Contributors

<p align="left">
  <a href="https://github.com/qulDev" title="Contributor 1">
    <img src="https://avatars.githubusercontent.com/u/48212340?v=4" alt="Contributor 1" width="72" height="72" style="border-radius:50%;" />
  </a>
  <a href="https://github.com/VXGN" title="Contributor 2">
    <img src="https://avatars.githubusercontent.com/u/116474723?s=64&v=4" alt="Contributor 2" width="72" height="72" style="border-radius:50%;" />
  </a>
  <a href="https://github.com/Fanndev" title="Contributor 3">
    <img src="https://avatars.githubusercontent.com/u/101954078?s=64&v=4" alt="Contributor 3" width="72" height="72" style="border-radius:50%;" />
  </a>
</p>

## ☕ Buy Me a Coffee

<p>
  <a href="http://buymeacoffee.com/rqull" target="_blank" rel="noreferrer">
    <img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" height="50" />
  </a>
</p>

---

**Built with ❤️ using Flutter and Supabase**
