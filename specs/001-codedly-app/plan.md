# Implementation Plan: Codedly Mobile App

**Branch**: `001-codedly-app` | **Date**: 2025-10-31 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/001-codedly-app/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Codedly is a mobile learning platform for teaching Python programming to Indonesian middle and high school students. The app features interactive lessons with a code editor, multiple-choice quizzes, a gamification system (XP, levels, streaks), full bilingual support (Indonesian/English), and offline capability for previously accessed content. The platform uses a clean architecture with clear separation between presentation, domain, and data layers, ensuring maintainability and testability throughout the codebase.

## Technical Context

**Language/Version**: Dart 3.x with Flutter SDK 3.16+ (latest stable)  
**Primary Dependencies**:

- State Management: flutter_riverpod 2.4+ or flutter_bloc 8.1+
- Backend: supabase_flutter 2.0+
- DI: get_it 7.6+, injectable 2.3+
- Localization: flutter_localizations (SDK), intl 0.18+
- Code Editor: flutter_code_editor 0.3+ or re_editor 0.8+
- Local Storage: hive 2.2+, shared_preferences 2.2+
- Testing: flutter_test (SDK), mockito 5.4+, bloc_test 9.1+

**Storage**:

- Remote: Supabase PostgreSQL database for users, modules, lessons, quizzes, progress, XP records
- Local: Hive for offline caching of lesson content, Shared Preferences for user settings and language preference
- Auth: Supabase Auth (email/password, Google SSO)

**Testing**:

- Unit tests: flutter_test with mockito for mocking
- Widget tests: flutter_test for UI components
- Integration tests: flutter_test with patrol or integration_test package
- Test coverage target: 70% minimum for domain and data layers

**Target Platform**:

- Android 7.0+ (API 24+)
- iOS 12.0+
- Mobile-first responsive design supporting phones (4.7" - 6.7") and tablets (7" - 12.9")

**Project Type**: Mobile application (Flutter cross-platform)

**Performance Goals**:

- 60 FPS animations and scrolling
- App startup time < 3 seconds on mid-range devices
- Lesson content load < 2 seconds
- Code editor keystroke latency < 100ms
- XP update/display < 1 second after completion

**Constraints**:

- Dark mode only (no light theme)
- Offline-capable for previously accessed lessons
- Bilingual support mandatory (ID/EN)
- Must work on devices from past 3 years
- Memory usage < 150MB during normal operation
- App size < 50MB download (before expansion files)

**Scale/Scope**:

- Initial target: 5,000 - 10,000 concurrent users
- Content: 5-10 modules with 30-50 lessons total initially
- 100-200 quiz questions across modules
- Expected growth: 50,000+ users within first year
- 20-30 app screens/routes total

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

### I. Clean Code & Architecture ✅

- **Requirement**: MUST organize code into Presentation, Domain, and Data layers with SOLID principles
- **Compliance**: Plan specifies clean architecture with clear layer separation in project structure
- **Status**: PASS - Will be enforced through folder structure and code review

### II. State Management & Dependency Injection ✅

- **Requirement**: MUST use Riverpod/BLoC and GetIt for DI, keep UI separate from business logic
- **Compliance**: Technical context specifies Riverpod or BLoC, GetIt with injectable for DI
- **Status**: PASS - Architecture will enforce separation of concerns

### III. UI/UX Quality & Design System ✅

- **Requirement**: MUST implement Duolingo-inspired design with dark mode, engaging visuals, instant feedback
- **Compliance**: Dark mode only specified, Material 3 design system, gamification UI elements planned
- **Status**: PASS - Design system will be established in Phase 1

### IV. Localization & Internationalization ✅

- **Requirement**: MUST support Bahasa Indonesia and English with ARB files, no hardcoded strings
- **Compliance**: Intl and flutter_localizations specified, bilingual support in constraints
- **Status**: PASS - Localization infrastructure in Phase 0, content in Phase 2

### V. Educational Effectiveness & Content Quality ✅

- **Requirement**: MUST ensure age-appropriate, progressive learning with scaffolded content
- **Compliance**: Content structure in data model supports progressive modules and lessons
- **Status**: PASS - Content quality will be validated during lesson authoring

### VI. Gamification & Learner Engagement ✅

- **Requirement**: MUST implement XP system, levels, streaks, celebratory feedback
- **Compliance**: XP calculation service, level-up animations, streak tracking all specified in requirements
- **Status**: PASS - Gamification logic in domain layer, UI in presentation layer

### VII. Security & Privacy ✅

- **Requirement**: MUST use Supabase Auth securely, validate input, protect tokens, no exposed secrets
- **Compliance**: Supabase Auth specified, secure storage for tokens, input validation in requirements
- **Status**: PASS - Security measures will be implemented in auth and data layers

### VIII. Testing & Quality Assurance ✅

- **Requirement**: MUST write unit tests, widget tests, achieve 70% coverage, use CI
- **Compliance**: Testing dependencies specified (mockito, bloc_test), 70% coverage target set
- **Status**: PASS - Test-driven development will be followed for each feature

### IX. Collaboration & Documentation ✅

- **Requirement**: MUST use Git with conventional commits, document ADRs, provide onboarding docs
- **Compliance**: Git repo active, plan.md and upcoming docs follow documentation standards
- **Status**: PASS - Documentation structure established through speckit process

### Quality Standards ✅

- **Performance**: 60 FPS target, <3s startup, <2s load times specified ✅
- **Accessibility**: Screen reader support, 4.5:1 contrast, text scaling to be implemented ✅
- **Code Quality Gates**: Linting (flutter_lints), CI tests, code review required ✅

### Overall Constitution Compliance: ✅ PASS

All nine core principles are addressed in the technical plan. No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/001-codedly-app/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── auth-api.md      # Authentication endpoints
│   ├── content-api.md   # Lessons, modules, quizzes endpoints
│   ├── progress-api.md  # User progress and XP endpoints
│   └── database-schema.sql  # Supabase table definitions
├── checklists/
│   └── requirements.md  # Spec quality checklist (already created)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

Flutter mobile application following clean architecture principles:

```text
lib/
├── main.dart                    # App entry point, dependency injection setup
├── app.dart                     # MaterialApp configuration, routing, theme
├── core/                        # Shared core functionality
│   ├── di/                      # Dependency injection setup
│   │   ├── injection.dart       # GetIt configuration
│   │   └── injection.config.dart  # Generated injectable config
│   ├── theme/                   # App-wide theming
│   │   ├── app_theme.dart       # Dark theme configuration
│   │   ├── colors.dart          # Color palette (Duolingo-inspired)
│   │   └── typography.dart      # Text styles and scales
│   ├── l10n/                    # Localization
│   │   ├── app_en.arb           # English translations
│   │   ├── app_id.arb           # Indonesian translations
│   │   └── l10n.dart            # Generated localization class
│   ├── constants/               # App-wide constants
│   │   ├── xp_constants.dart    # XP values, level formulas
│   │   └── api_constants.dart   # API endpoints, keys (env-based)
│   ├── utils/                   # Utility functions
│   │   ├── validators.dart      # Email, password validators
│   │   ├── date_helpers.dart    # Date formatting, streak calculation
│   │   └── code_formatter.dart  # Code formatting utilities
│   ├── errors/                  # Error handling
│   │   ├── failures.dart        # Failure types (network, auth, cache)
│   │   └── exceptions.dart      # Custom exceptions
│   └── network/                 # Network utilities
│       ├── network_info.dart    # Connectivity checker
│       └── api_client.dart      # HTTP client wrapper
├── features/                    # Feature modules (clean architecture)
│   ├── auth/                    # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart  # Supabase Auth API
│   │   │   │   └── auth_local_datasource.dart   # Token storage
│   │   │   ├── models/
│   │   │   │   └── user_model.dart  # User data model (JSON)
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart  # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart        # User entity (pure Dart)
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart  # Abstract repository interface
│   │   │   └── usecases/
│   │   │       ├── sign_up.dart     # Sign up use case
│   │   │       ├── sign_in.dart     # Sign in use case
│   │   │       ├── sign_out.dart    # Sign out use case
│   │   │       └── reset_password.dart  # Password reset use case
│   │   └── presentation/
│   │       ├── providers/           # Riverpod providers
│   │       │   └── auth_provider.dart  # Auth state management
│   │       ├── screens/
│   │       │   ├── splash_screen.dart    # Initial loading screen
│   │       │   ├── login_screen.dart     # Login UI
│   │       │   ├── signup_screen.dart    # Sign up UI
│   │       │   └── reset_password_screen.dart  # Password reset UI
│   │       └── widgets/
│   │           ├── auth_text_field.dart  # Custom text input
│   │           └── social_auth_button.dart  # Google SSO button
│   ├── onboarding/              # Onboarding feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── onboarding_local_datasource.dart  # Track completion
│   │   │   └── repositories/
│   │   │       └── onboarding_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── onboarding_page.dart  # Onboarding slide entity
│   │   │   ├── repositories/
│   │   │   │   └── onboarding_repository.dart
│   │   │   └── usecases/
│   │   │       └── complete_onboarding.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── onboarding_provider.dart
│   │       ├── screens/
│   │       │   └── onboarding_screen.dart  # Swipeable slides
│   │       └── widgets/
│   │           ├── onboarding_page_widget.dart
│   │           └── page_indicator.dart
│   ├── home/                    # Home dashboard feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── modules_remote_datasource.dart  # Fetch modules
│   │   │   │   └── modules_local_datasource.dart   # Cache modules
│   │   │   ├── models/
│   │   │   │   └── module_model.dart
│   │   │   └── repositories/
│   │   │       └── modules_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── module.dart
│   │   │   ├── repositories/
│   │   │   │   └── modules_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_all_modules.dart
│   │   │       └── get_user_progress_summary.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── home_provider.dart
│   │       ├── screens/
│   │       │   └── home_screen.dart  # Dashboard with modules, XP, level
│   │       └── widgets/
│   │           ├── module_card.dart       # Module display card
│   │           ├── xp_progress_bar.dart   # XP visualization
│   │           └── streak_indicator.dart  # Streak display
│   ├── lessons/                 # Lessons feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── lessons_remote_datasource.dart
│   │   │   │   └── lessons_local_datasource.dart  # Offline cache
│   │   │   ├── models/
│   │   │   │   ├── lesson_model.dart
│   │   │   │   └── hint_model.dart
│   │   │   └── repositories/
│   │   │       └── lessons_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── lesson.dart
│   │   │   │   └── hint.dart
│   │   │   ├── repositories/
│   │   │   │   └── lessons_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_lessons_by_module.dart
│   │   │       ├── get_lesson_detail.dart
│   │   │       ├── validate_code.dart     # Code validation logic
│   │   │       ├── get_hint.dart
│   │   │       └── complete_lesson.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── lessons_list_provider.dart
│   │       │   └── lesson_detail_provider.dart
│   │       ├── screens/
│   │       │   ├── lessons_list_screen.dart  # Module's lesson list
│   │       │   └── lesson_detail_screen.dart  # Lesson content + editor
│   │       └── widgets/
│   │           ├── lesson_card.dart           # Lesson item in list
│   │           ├── code_editor_widget.dart    # Python code editor
│   │           ├── hint_button.dart           # Hint display
│   │           ├── code_validation_feedback.dart  # Feedback UI
│   │           └── lesson_completion_animation.dart  # Celebration
│   ├── quizzes/                 # Quizzes feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── quizzes_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── quiz_model.dart
│   │   │   │   └── question_model.dart
│   │   │   └── repositories/
│   │   │       └── quizzes_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── quiz.dart
│   │   │   │   └── question.dart
│   │   │   ├── repositories/
│   │   │   │   └── quizzes_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_quiz.dart
│   │   │       ├── submit_answer.dart
│   │   │       └── complete_quiz.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── quiz_provider.dart
│   │       ├── screens/
│   │       │   ├── quiz_screen.dart         # Quiz questions UI
│   │       │   └── quiz_result_screen.dart  # Summary and review
│   │       └── widgets/
│   │           ├── question_card.dart
│   │           ├── answer_option.dart       # Multiple-choice option
│   │           └── answer_feedback.dart     # Correct/incorrect feedback
│   ├── progress/                # Progress tracking & XP feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── progress_remote_datasource.dart
│   │   │   │   └── progress_local_datasource.dart  # Offline queue
│   │   │   ├── models/
│   │   │   │   ├── user_progress_model.dart
│   │   │   │   └── xp_record_model.dart
│   │   │   └── repositories/
│   │   │       └── progress_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user_progress.dart
│   │   │   │   ├── xp_record.dart
│   │   │   │   └── user_level.dart
│   │   │   ├── repositories/
│   │   │   │   └── progress_repository.dart
│   │   │   └── usecases/
│   │   │       ├── award_xp.dart            # XP calculation logic
│   │   │       ├── calculate_level.dart     # Level from XP
│   │   │       ├── update_streak.dart       # Streak management
│   │   │       ├── sync_progress.dart       # Offline sync
│   │   │       └── get_progress_summary.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── xp_provider.dart
│   │       │   └── level_provider.dart
│   │       └── widgets/
│   │           ├── level_up_animation.dart  # Celebratory animation
│   │           ├── xp_badge.dart
│   │           └── progress_chart.dart
│   ├── profile/                 # User profile feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── profile_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_stats_model.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_stats.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_user_stats.dart
│   │   │       └── update_profile.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── profile_provider.dart
│   │       ├── screens/
│   │       │   └── profile_screen.dart  # Stats, achievements, streaks
│   │       └── widgets/
│   │           ├── stats_card.dart
│   │           ├── achievement_badge.dart
│   │           └── streak_calendar.dart
│   └── settings/                # Settings feature
│       ├── data/
│       │   ├── datasources/
│       │   │   └── settings_local_datasource.dart
│       │   ├── models/
│       │   │   └── app_settings_model.dart
│       │   └── repositories/
│       │       └── settings_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── app_settings.dart
│       │   ├── repositories/
│       │   │   └── settings_repository.dart
│       │   └── usecases/
│       │       ├── change_language.dart
│       │       └── get_settings.dart
│       └── presentation/
│           ├── providers/
│           │   └── settings_provider.dart
│           ├── screens/
│           │   └── settings_screen.dart  # Language, account, about
│           └── widgets/
│               └── language_selector.dart
└── shared/                      # Shared widgets and components
    └── widgets/
        ├── loading_indicator.dart
        ├── error_view.dart
        ├── empty_state.dart
        ├── custom_button.dart
        └── custom_app_bar.dart

test/                            # All tests
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── widgets/
│   ├── lessons/
│   │   └── [same structure]
│   └── [other features...]
├── core/
│   └── utils/
└── fixtures/                    # Test data fixtures
    ├── user_fixture.json
    ├── module_fixture.json
    └── lesson_fixture.json

android/                         # Android platform config
ios/                             # iOS platform config
assets/                          # Static assets
├── images/
│   ├── onboarding/
│   ├── mascots/
│   └── badges/
├── animations/                  # Lottie animations
│   └── level_up.json
└── fonts/                       # Custom fonts (if any)

supabase/                        # Supabase configuration (not Flutter code)
├── migrations/                  # Database migrations
│   └── 001_initial_schema.sql
└── functions/                   # Edge functions (if needed)
    └── validate_code/           # Code validation function
```

**Structure Decision**:

This is a **mobile application** using Flutter's feature-based clean architecture. Each feature is self-contained with its own data, domain, and presentation layers, following the constitution's requirement for clear separation of concerns. The structure promotes:

1. **Testability**: Each layer can be tested independently with mocks
2. **Maintainability**: Features are isolated and easy to locate
3. **Scalability**: New features follow the same pattern
4. **Reusability**: Core utilities and shared widgets are centralized
5. **Offline-First**: Local datasources in each feature enable caching

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No constitution violations detected. All architecture decisions align with the established principles.
