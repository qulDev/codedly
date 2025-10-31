# Tasks: Codedly Mobile App

**Input**: Design documents from `/specs/001-codedly-app/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Initialize Flutter project with Dart 3.x and configure pubspec.yaml with core dependencies (flutter_riverpod 2.4+, supabase_flutter 2.0+, get_it 7.6+, injectable 2.3+, hive 2.2+, shared_preferences 2.2+, re_editor 0.8+, flutter_localizations, intl 0.18+)
- [x] T002 Create project folder structure following clean architecture in lib/ (core/, features/, shared/)
- [x] T003 [P] Create core utilities directory structure: lib/core/di/, lib/core/theme/, lib/core/l10n/, lib/core/constants/, lib/core/utils/, lib/core/errors/, lib/core/network/
- [x] T004 [P] Setup Git repository with .gitignore for Flutter, create initial commit
- [x] T005 [P] Configure flutter_lints in analysis_options.yaml with strict rules
- [ ] T006 Setup Supabase project and obtain project URL and anon key
- [ ] T007 Execute database migration using specs/001-codedly-app/contracts/database-schema.sql in Supabase SQL Editor
- [x] T008 Create .env file structure and add to .gitignore (SUPABASE_URL, SUPABASE_ANON_KEY)
- [x] T009 [P] Create test/ folder structure mirroring lib/ structure

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Theme & Localization Foundation

- [ ] T010 [P] Create dark theme configuration in lib/core/theme/app_theme.dart with Duolingo-inspired color palette
- [ ] T011 [P] Define typography styles in lib/core/theme/typography.dart (headings, body, button text)
- [ ] T012 [P] Create color constants in lib/core/theme/colors.dart (primary, accent, success, error, background)
- [ ] T013 [P] Setup localization files: lib/core/l10n/app_en.arb (English reference) and lib/core/l10n/app_id.arb (Indonesian)
- [ ] T014 Configure flutter_localizations in lib/app.dart MaterialApp with supported locales ['en', 'id']
- [ ] T015 Add common UI strings to ARB files (buttons: "continue", "back", "submit"; errors: "network_error", "invalid_input")

### Dependency Injection

- [ ] T016 Create GetIt injection configuration in lib/core/di/injection.dart with @InjectableInit annotation
- [ ] T017 Run build_runner to generate lib/core/di/injection.config.dart for injectable setup
- [ ] T018 Initialize GetIt in lib/main.dart before runApp

### Core Utilities

- [ ] T019 [P] Implement network connectivity checker in lib/core/network/network_info.dart using connectivity_plus
- [ ] T020 [P] Create failure types in lib/core/errors/failures.dart (NetworkFailure, AuthFailure, CacheFailure, ServerFailure)
- [ ] T021 [P] Create custom exceptions in lib/core/errors/exceptions.dart (ServerException, CacheException, NetworkException)
- [ ] T022 [P] Implement input validators in lib/core/utils/validators.dart (email, password, display name)
- [ ] T023 [P] Create date helper utilities in lib/core/utils/date_helpers.dart (streak calculation, date formatting)
- [ ] T024 [P] Define XP constants and formulas in lib/core/constants/xp_constants.dart (level formula, XP rewards)
- [ ] T025 [P] Create API constants in lib/core/constants/api_constants.dart (Supabase URL from env)

### Shared Widgets

- [ ] T026 [P] Create loading indicator widget in lib/shared/widgets/loading_indicator.dart
- [ ] T027 [P] Create error view widget in lib/shared/widgets/error_view.dart with retry button
- [ ] T028 [P] Create empty state widget in lib/shared/widgets/empty_state.dart
- [ ] T029 [P] Create custom button widget in lib/shared/widgets/custom_button.dart with consistent styling
- [ ] T030 [P] Create custom app bar widget in lib/shared/widgets/custom_app_bar.dart

### Data Layer Foundation

- [ ] T031 Initialize Hive in lib/main.dart and register type adapters
- [ ] T032 [P] Initialize Supabase client in lib/main.dart with URL and anon key from environment
- [ ] T033 [P] Setup SharedPreferences for app settings storage

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Account Creation & Onboarding (Priority: P1) 🎯 MVP

**Goal**: Enable new users to create accounts, complete onboarding, and access the home dashboard

**Independent Test**: Install app → Sign up with email/password → Complete onboarding slides → Land on dashboard showing modules and XP (0) at level 1

### Domain Layer - Authentication

- [ ] T034 [P] [US1] Create User entity in lib/features/auth/domain/entities/user.dart (id, email, displayName, languagePreference, onboardingCompleted)
- [ ] T035 [P] [US1] Define AuthRepository interface in lib/features/auth/domain/repositories/auth_repository.dart with signUp, signIn, signOut, getCurrentUser methods
- [ ] T036 [P] [US1] Implement SignUpUseCase in lib/features/auth/domain/usecases/sign_up.dart accepting email and password
- [ ] T037 [P] [US1] Implement SignInUseCase in lib/features/auth/domain/usecases/sign_in.dart
- [ ] T038 [P] [US1] Implement SignOutUseCase in lib/features/auth/domain/usecases/sign_out.dart
- [ ] T039 [P] [US1] Implement GetCurrentUserUseCase in lib/features/auth/domain/usecases/get_current_user.dart

### Data Layer - Authentication

- [ ] T040 [P] [US1] Create UserModel in lib/features/auth/data/models/user_model.dart extending User entity with fromJson and toJson
- [ ] T041 [US1] Implement AuthRemoteDataSource in lib/features/auth/data/datasources/auth_remote_datasource.dart using Supabase Auth (signUp, signIn, signOut, currentSession)
- [ ] T042 [P] [US1] Implement AuthLocalDataSource in lib/features/auth/data/datasources/auth_local_datasource.dart for token caching using flutter_secure_storage
- [ ] T043 [US1] Implement AuthRepositoryImpl in lib/features/auth/data/repositories/auth_repository_impl.dart with error handling and network checks

### Presentation Layer - Authentication

- [ ] T044 [US1] Create AuthProvider (StateNotifierProvider) in lib/features/auth/presentation/providers/auth_provider.dart managing authentication state
- [ ] T045 [P] [US1] Build SplashScreen in lib/features/auth/presentation/screens/splash_screen.dart checking auth status
- [ ] T046 [P] [US1] Build LoginScreen UI in lib/features/auth/presentation/screens/login_screen.dart with email/password fields and login button
- [ ] T047 [P] [US1] Build SignUpScreen UI in lib/features/auth/presentation/screens/signup_screen.dart with email, password, confirm password fields
- [ ] T048 [P] [US1] Create AuthTextField widget in lib/features/auth/presentation/widgets/auth_text_field.dart with validation styling
- [ ] T049 [US1] Integrate AuthProvider with LoginScreen (handle signIn call, show loading, navigate on success)
- [ ] T050 [US1] Integrate AuthProvider with SignUpScreen (handle signUp call, validate passwords match, navigate to onboarding)

### Domain Layer - Onboarding

- [ ] T051 [P] [US1] Create OnboardingPage entity in lib/features/onboarding/domain/entities/onboarding_page.dart (title, description, image)
- [ ] T052 [P] [US1] Define OnboardingRepository interface in lib/features/onboarding/domain/repositories/onboarding_repository.dart
- [ ] T053 [P] [US1] Implement CompleteOnboardingUseCase in lib/features/onboarding/domain/usecases/complete_onboarding.dart

### Data Layer - Onboarding

- [ ] T054 [US1] Implement OnboardingLocalDataSource in lib/features/onboarding/data/datasources/onboarding_local_datasource.dart using SharedPreferences to track completion
- [ ] T055 [US1] Implement OnboardingRepositoryImpl in lib/features/onboarding/data/repositories/onboarding_repository_impl.dart

### Presentation Layer - Onboarding

- [ ] T056 [US1] Create OnboardingProvider in lib/features/onboarding/presentation/providers/onboarding_provider.dart
- [ ] T057 [US1] Build OnboardingScreen in lib/features/onboarding/presentation/screens/onboarding_screen.dart with PageView for swipeable slides
- [ ] T058 [P] [US1] Create OnboardingPageWidget in lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart for individual slides
- [ ] T059 [P] [US1] Create PageIndicator widget in lib/features/onboarding/presentation/widgets/page_indicator.dart (dots showing progress)
- [ ] T060 [US1] Add onboarding content: 3 slides explaining XP system, levels, and module structure (text in ARB files)

### Domain Layer - Home Dashboard

- [ ] T061 [P] [US1] Create Module entity in lib/features/home/domain/entities/module.dart (id, title, description, orderIndex, difficultyLevel, requiredLevel, isPublished)
- [ ] T062 [P] [US1] Define ModulesRepository interface in lib/features/home/domain/repositories/modules_repository.dart
- [ ] T063 [P] [US1] Implement GetAllModulesUseCase in lib/features/home/domain/usecases/get_all_modules.dart
- [ ] T064 [P] [US1] Implement GetUserProgressSummaryUseCase in lib/features/home/domain/usecases/get_user_progress_summary.dart

### Data Layer - Home Dashboard

- [ ] T065 [P] [US1] Create ModuleModel in lib/features/home/data/models/module_model.dart with fromJson
- [ ] T066 [US1] Implement ModulesRemoteDataSource in lib/features/home/data/datasources/modules_remote_datasource.dart querying Supabase modules table
- [ ] T067 [P] [US1] Implement ModulesLocalDataSource in lib/features/home/data/datasources/modules_local_datasource.dart using Hive for caching
- [ ] T068 [US1] Implement ModulesRepositoryImpl in lib/features/home/data/repositories/modules_repository_impl.dart with cache-first strategy

### Presentation Layer - Home Dashboard

- [ ] T069 [US1] Create HomeProvider in lib/features/home/presentation/providers/home_provider.dart fetching modules and user stats
- [ ] T070 [US1] Build HomeScreen in lib/features/home/presentation/screens/home_screen.dart displaying modules list, current XP, and level
- [ ] T071 [P] [US1] Create ModuleCard widget in lib/features/home/presentation/widgets/module_card.dart showing module info and progress
- [ ] T072 [P] [US1] Create XpProgressBar widget in lib/features/home/presentation/widgets/xp_progress_bar.dart visualizing XP toward next level
- [ ] T073 [P] [US1] Create StreakIndicator widget in lib/features/home/presentation/widgets/streak_indicator.dart showing current streak

### Routing & Navigation

- [ ] T074 [US1] Setup routing in lib/app.dart using go_router or Navigator 2.0 (routes: /, /login, /signup, /onboarding, /home)
- [ ] T075 [US1] Implement navigation guard: redirect to /login if user not authenticated, redirect to /home if already logged in

### Localization for US1

- [ ] T076 [P] [US1] Add authentication strings to ARB files (login_title, signup_title, email_label, password_label, confirm_password_label, login_button, signup_button, validation_errors)
- [ ] T077 [P] [US1] Add onboarding strings to ARB files (onboarding_slide1_title, onboarding_slide1_description, onboarding_slide2_title, onboarding_slide2_description, onboarding_slide3_title, onboarding_slide3_description, get_started_button)
- [ ] T078 [P] [US1] Add home dashboard strings to ARB files (home_title, my_progress, current_level, available_modules)

### Testing for US1

- [ ] T079 [P] [US1] Write unit tests for SignUpUseCase in test/features/auth/domain/usecases/sign_up_test.dart using mockito
- [ ] T080 [P] [US1] Write unit tests for AuthRepositoryImpl in test/features/auth/data/repositories/auth_repository_impl_test.dart
- [ ] T081 [P] [US1] Write widget tests for LoginScreen in test/features/auth/presentation/screens/login_screen_test.dart
- [ ] T082 [P] [US1] Write widget tests for OnboardingScreen in test/features/onboarding/presentation/screens/onboarding_screen_test.dart
- [ ] T083 [US1] Write integration test for signup → onboarding → home flow in test/integration/auth_onboarding_test.dart

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently. Users can create accounts, complete onboarding, and see the home dashboard.

---

## Phase 4: User Story 2 - Complete a Python Lesson (Priority: P1) 🎯 MVP

**Goal**: Enable users to access lessons, read content, write code in an editor, receive feedback, and earn XP

**Independent Test**: Login → Select module → Open lesson → Read content → Edit code → Check code → Complete lesson → Earn XP (+10) → See celebration animation

### Domain Layer - Lessons

- [ ] T084 [P] [US2] Create Lesson entity in lib/features/lessons/domain/entities/lesson.dart (id, moduleId, title, content, codeTemplate, expectedOutput, validationType, xpReward, orderIndex)
- [ ] T085 [P] [US2] Create Hint entity in lib/features/lessons/domain/entities/hint.dart (id, lessonId, hintText, orderIndex)
- [ ] T086 [P] [US2] Define LessonsRepository interface in lib/features/lessons/domain/repositories/lessons_repository.dart
- [ ] T087 [P] [US2] Implement GetLessonsByModuleUseCase in lib/features/lessons/domain/usecases/get_lessons_by_module.dart
- [ ] T088 [P] [US2] Implement GetLessonDetailUseCase in lib/features/lessons/domain/usecases/get_lesson_detail.dart
- [ ] T089 [P] [US2] Implement ValidateCodeUseCase in lib/features/lessons/domain/usecases/validate_code.dart with client-side validation (output matching)
- [ ] T090 [P] [US2] Implement GetHintUseCase in lib/features/lessons/domain/usecases/get_hint.dart
- [ ] T091 [P] [US2] Implement CompleteLessonUseCase in lib/features/lessons/domain/usecases/complete_lesson.dart

### Data Layer - Lessons

- [ ] T092 [P] [US2] Create LessonModel in lib/features/lessons/data/models/lesson_model.dart with fromJson and toEntity
- [ ] T093 [P] [US2] Create HintModel in lib/features/lessons/data/models/hint_model.dart
- [ ] T094 [US2] Implement LessonsRemoteDataSource in lib/features/lessons/data/datasources/lessons_remote_datasource.dart querying Supabase lessons and lesson_hints tables
- [ ] T095 [P] [US2] Implement LessonsLocalDataSource in lib/features/lessons/data/datasources/lessons_local_datasource.dart using Hive for offline caching
- [ ] T096 [US2] Implement LessonsRepositoryImpl in lib/features/lessons/data/repositories/lessons_repository_impl.dart with offline support

### Presentation Layer - Lessons List

- [ ] T097 [US2] Create LessonsListProvider in lib/features/lessons/presentation/providers/lessons_list_provider.dart fetching lessons for a module
- [ ] T098 [US2] Build LessonsListScreen in lib/features/lessons/presentation/screens/lessons_list_screen.dart displaying lessons in order with completion status
- [ ] T099 [P] [US2] Create LessonCard widget in lib/features/lessons/presentation/widgets/lesson_card.dart showing title, XP reward, checkmark if completed

### Presentation Layer - Lesson Detail

- [ ] T100 [US2] Create LessonDetailProvider in lib/features/lessons/presentation/providers/lesson_detail_provider.dart managing lesson state, code validation, hints
- [ ] T101 [US2] Build LessonDetailScreen in lib/features/lessons/presentation/screens/lesson_detail_screen.dart with scrollable content and code editor
- [ ] T102 [US2] Integrate re_editor package in CodeEditorWidget lib/features/lessons/presentation/widgets/code_editor_widget.dart with Python syntax highlighting, line numbers, dark theme
- [ ] T103 [P] [US2] Create HintButton widget in lib/features/lessons/presentation/widgets/hint_button.dart showing hint dialog when tapped
- [ ] T104 [P] [US2] Create CodeValidationFeedback widget in lib/features/lessons/presentation/widgets/code_validation_feedback.dart displaying validation results (correct/incorrect)
- [ ] T105 [P] [US2] Create LessonCompletionAnimation widget in lib/features/lessons/presentation/widgets/lesson_completion_animation.dart with confetti or celebration effect
- [ ] T106 [US2] Implement "Check Code" button functionality in LessonDetailScreen calling ValidateCodeUseCase
- [ ] T107 [US2] Implement lesson completion flow: validate → award XP → show animation → mark complete → update UI

### Code Validation Utility

- [ ] T108 [P] [US2] Create CodeValidator utility class in lib/core/utils/code_validator.dart for client-side validation (syntax check, output matching)

### Domain Layer - Progress (XP Award for Lessons)

- [ ] T109 [P] [US2] Create UserProgress entity in lib/features/progress/domain/entities/user_progress.dart (id, userId, contentType, contentId, isCompleted, xpEarned, completedAt)
- [ ] T110 [P] [US2] Create XPRecord entity in lib/features/progress/domain/entities/xp_record.dart
- [ ] T111 [P] [US2] Create UserLevel entity in lib/features/progress/domain/entities/user_level.dart with level and totalXp
- [ ] T112 [P] [US2] Define ProgressRepository interface in lib/features/progress/domain/repositories/progress_repository.dart
- [ ] T113 [P] [US2] Implement AwardXpUseCase in lib/features/progress/domain/usecases/award_xp.dart calculating XP and updating user stats
- [ ] T114 [P] [US2] Implement CalculateLevelUseCase in lib/features/progress/domain/usecases/calculate_level.dart using formula from xp_constants.dart

### Data Layer - Progress

- [ ] T115 [P] [US2] Create UserProgressModel in lib/features/progress/data/models/user_progress_model.dart
- [ ] T116 [P] [US2] Create XPRecordModel in lib/features/progress/data/models/xp_record_model.dart
- [ ] T117 [US2] Implement ProgressRemoteDataSource in lib/features/progress/data/datasources/progress_remote_datasource.dart inserting user_progress and xp_records, updating user_stats
- [ ] T118 [P] [US2] Implement ProgressLocalDataSource in lib/features/progress/data/datasources/progress_local_datasource.dart for offline queue using Hive
- [ ] T119 [US2] Implement ProgressRepositoryImpl in lib/features/progress/data/repositories/progress_repository_impl.dart with optimistic updates and sync queue

### Presentation Layer - XP Display

- [ ] T120 [US2] Create XpProvider in lib/features/progress/presentation/providers/xp_provider.dart listening to XP changes
- [ ] T121 [P] [US2] Create XpBadge widget in lib/features/progress/presentation/widgets/xp_badge.dart displaying +XP animation when awarded
- [ ] T122 [US2] Integrate XpProvider with HomeScreen to update XP display in real-time

### Routing Updates

- [ ] T123 [US2] Add lesson routes to routing configuration: /module/:moduleId/lessons, /lesson/:lessonId

### Localization for US2

- [ ] T124 [P] [US2] Add lesson strings to ARB files (lessons_title, lesson_content, code_editor_placeholder, check_code_button, get_hint_button, hint_title, correct_feedback, incorrect_feedback, lesson_complete_title, xp_earned)

### Testing for US2

- [ ] T125 [P] [US2] Write unit tests for ValidateCodeUseCase in test/features/lessons/domain/usecases/validate_code_test.dart
- [ ] T126 [P] [US2] Write unit tests for CompleteLessonUseCase in test/features/lessons/domain/usecases/complete_lesson_test.dart
- [ ] T127 [P] [US2] Write unit tests for AwardXpUseCase in test/features/progress/domain/usecases/award_xp_test.dart
- [ ] T128 [P] [US2] Write widget tests for LessonDetailScreen in test/features/lessons/presentation/screens/lesson_detail_screen_test.dart
- [ ] T129 [P] [US2] Write widget tests for CodeEditorWidget in test/features/lessons/presentation/widgets/code_editor_widget_test.dart
- [ ] T130 [US2] Write integration test for lesson completion flow in test/integration/lesson_completion_test.dart

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently. Users can complete lessons, write code, get feedback, and earn XP.

---

## Phase 5: User Story 3 - Take a Quiz (Priority: P2)

**Goal**: Enable users to take multiple-choice quizzes, receive instant feedback, and earn bonus XP

**Independent Test**: Login → Select module → Open quiz → Answer questions → See instant feedback → Complete quiz → View summary with score and XP earned

### Domain Layer - Quizzes

- [ ] T131 [P] [US3] Create Quiz entity in lib/features/quizzes/domain/entities/quiz.dart (id, moduleId, title, description, passingScorePercentage, xpPerCorrectAnswer, bonusXpForPerfect, orderIndex)
- [ ] T132 [P] [US3] Create Question entity in lib/features/quizzes/domain/entities/question.dart (id, quizId, questionText, options, correctAnswerIndex, explanation, orderIndex)
- [ ] T133 [P] [US3] Define QuizzesRepository interface in lib/features/quizzes/domain/repositories/quizzes_repository.dart
- [ ] T134 [P] [US3] Implement GetQuizUseCase in lib/features/quizzes/domain/usecases/get_quiz.dart
- [ ] T135 [P] [US3] Implement SubmitAnswerUseCase in lib/features/quizzes/domain/usecases/submit_answer.dart validating answer and returning feedback
- [ ] T136 [P] [US3] Implement CompleteQuizUseCase in lib/features/quizzes/domain/usecases/complete_quiz.dart calculating score, XP, and saving progress

### Data Layer - Quizzes

- [ ] T137 [P] [US3] Create QuizModel in lib/features/quizzes/data/models/quiz_model.dart with fromJson
- [ ] T138 [P] [US3] Create QuestionModel in lib/features/quizzes/data/models/question_model.dart
- [ ] T139 [US3] Implement QuizzesRemoteDataSource in lib/features/quizzes/data/datasources/quizzes_remote_datasource.dart querying Supabase quizzes and quiz_questions tables
- [ ] T140 [US3] Implement QuizzesRepositoryImpl in lib/features/quizzes/data/repositories/quizzes_repository_impl.dart

### Presentation Layer - Quiz

- [ ] T141 [US3] Create QuizProvider in lib/features/quizzes/presentation/providers/quiz_provider.dart managing quiz state, current question, answers, score
- [ ] T142 [US3] Build QuizScreen in lib/features/quizzes/presentation/screens/quiz_screen.dart displaying questions one at a time
- [ ] T143 [P] [US3] Create QuestionCard widget in lib/features/quizzes/presentation/widgets/question_card.dart showing question text and progress (e.g., "Question 3 of 10")
- [ ] T144 [P] [US3] Create AnswerOption widget in lib/features/quizzes/presentation/widgets/answer_option.dart for multiple-choice buttons
- [ ] T145 [P] [US3] Create AnswerFeedback widget in lib/features/quizzes/presentation/widgets/answer_feedback.dart showing correct/incorrect with explanation
- [ ] T146 [US3] Implement answer selection and submission logic in QuizScreen
- [ ] T147 [US3] Build QuizResultScreen in lib/features/quizzes/presentation/screens/quiz_result_screen.dart displaying score summary, total XP, and review option
- [ ] T148 [US3] Integrate CompleteQuizUseCase with QuizProvider to save progress and award XP

### Routing Updates

- [ ] T149 [US3] Add quiz routes to routing configuration: /quiz/:quizId, /quiz/:quizId/result

### Localization for US3

- [ ] T150 [P] [US3] Add quiz strings to ARB files (quiz_title, question_progress, submit_answer_button, correct_answer, incorrect_answer, explanation_label, quiz_complete_title, your_score, review_incorrect_button, continue_button)

### Testing for US3

- [ ] T151 [P] [US3] Write unit tests for SubmitAnswerUseCase in test/features/quizzes/domain/usecases/submit_answer_test.dart
- [ ] T152 [P] [US3] Write unit tests for CompleteQuizUseCase in test/features/quizzes/domain/usecases/complete_quiz_test.dart
- [ ] T153 [P] [US3] Write widget tests for QuizScreen in test/features/quizzes/presentation/screens/quiz_screen_test.dart
- [ ] T154 [US3] Write integration test for quiz completion flow in test/integration/quiz_completion_test.dart

**Checkpoint**: All user stories 1, 2, and 3 should now be independently functional. Users can complete lessons and quizzes to earn XP.

---

## Phase 6: User Story 4 - Track Progress & Level Up (Priority: P2)

**Goal**: Enable users to view their progress, see level-up animations, track streaks, and visualize their learning journey

**Independent Test**: Login → Complete multiple lessons/quizzes → Accumulate XP → Trigger level-up animation → View profile screen with stats (XP, level, modules completed, streak)

### Domain Layer - Profile

- [ ] T155 [P] [US4] Create UserStats entity in lib/features/profile/domain/entities/user_stats.dart (userId, totalXp, currentLevel, streakCount, lastActivityDate, lessonsCompleted, quizzesCompleted, modulesCompleted)
- [ ] T156 [P] [US4] Define ProfileRepository interface in lib/features/profile/domain/repositories/profile_repository.dart
- [ ] T157 [P] [US4] Implement GetUserStatsUseCase in lib/features/profile/domain/usecases/get_user_stats.dart
- [ ] T158 [P] [US4] Implement UpdateProfileUseCase in lib/features/profile/domain/usecases/update_profile.dart for display name changes

### Data Layer - Profile

- [ ] T159 [P] [US4] Create UserStatsModel in lib/features/profile/data/models/user_stats_model.dart
- [ ] T160 [US4] Implement ProfileRemoteDataSource in lib/features/profile/data/datasources/profile_remote_datasource.dart querying Supabase user_stats and user_profiles tables
- [ ] T161 [US4] Implement ProfileRepositoryImpl in lib/features/profile/data/repositories/profile_repository_impl.dart

### Presentation Layer - Profile

- [ ] T162 [US4] Create ProfileProvider in lib/features/profile/presentation/providers/profile_provider.dart
- [ ] T163 [US4] Build ProfileScreen in lib/features/profile/presentation/screens/profile_screen.dart displaying user stats, XP graph, achievements
- [ ] T164 [P] [US4] Create StatsCard widget in lib/features/profile/presentation/widgets/stats_card.dart showing individual stats (lessons completed, quizzes completed)
- [ ] T165 [P] [US4] Create AchievementBadge widget in lib/features/profile/presentation/widgets/achievement_badge.dart (future feature placeholder)
- [ ] T166 [P] [US4] Create StreakCalendar widget in lib/features/profile/presentation/widgets/streak_calendar.dart visualizing activity days

### Level-Up System

- [ ] T167 [P] [US4] Implement UpdateStreakUseCase in lib/features/progress/domain/usecases/update_streak.dart calculating streak based on last activity date
- [ ] T168 [US4] Create LevelProvider in lib/features/progress/presentation/providers/level_provider.dart listening for level changes
- [ ] T169 [P] [US4] Create LevelUpAnimation widget in lib/features/progress/presentation/widgets/level_up_animation.dart with confetti, badge, and "Level Up!" message
- [ ] T170 [US4] Integrate level-up detection in XpProvider: when totalXp crosses level threshold, trigger LevelUpAnimation dialog
- [ ] T171 [US4] Implement streak update logic in ProgressRepositoryImpl: check last_activity_date and update streak_count on each lesson/quiz completion

### Progress Visualization

- [ ] T172 [P] [US4] Create ProgressChart widget in lib/features/progress/presentation/widgets/progress_chart.dart using fl_chart to display XP history over time
- [ ] T173 [P] [US4] Implement GetProgressSummaryUseCase in lib/features/progress/domain/usecases/get_progress_summary.dart fetching user_progress records for visualization

### Home Screen Updates

- [ ] T174 [US4] Update HomeScreen to show progress bars for each module (percentage of lessons completed)
- [ ] T175 [US4] Update XpProgressBar widget to show dynamic XP required for next level based on current level

### Routing Updates

- [ ] T176 [US4] Add profile route to routing configuration: /profile

### Localization for US4

- [ ] T177 [P] [US4] Add profile strings to ARB files (profile_title, total_xp, current_level, streak_days, lessons_completed, quizzes_completed, modules_completed, level_up_title, level_up_message, achievement_unlocked)

### Testing for US4

- [ ] T178 [P] [US4] Write unit tests for CalculateLevelUseCase in test/features/progress/domain/usecases/calculate_level_test.dart verifying level formula
- [ ] T179 [P] [US4] Write unit tests for UpdateStreakUseCase in test/features/progress/domain/usecases/update_streak_test.dart
- [ ] T180 [P] [US4] Write widget tests for ProfileScreen in test/features/profile/presentation/screens/profile_screen_test.dart
- [ ] T181 [US4] Write integration test for level-up flow in test/integration/level_up_test.dart

**Checkpoint**: User Story 4 complete. Users can track their progress, level up with animations, and view comprehensive stats.

---

## Phase 7: User Story 5 - Bilingual Language Selection (Priority: P3)

**Goal**: Enable users to switch app language between English and Bahasa Indonesia with immediate UI updates

**Independent Test**: Login → Navigate to settings → Change language from English to Indonesian → Verify all screens (home, lessons, quizzes, profile) display Indonesian text → Close and reopen app → Verify language persists

### Domain Layer - Settings

- [ ] T182 [P] [US5] Create AppSettings entity in lib/features/settings/domain/entities/app_settings.dart (languageCode, notificationsEnabled)
- [ ] T183 [P] [US5] Define SettingsRepository interface in lib/features/settings/domain/repositories/settings_repository.dart
- [ ] T184 [P] [US5] Implement ChangeLanguageUseCase in lib/features/settings/domain/usecases/change_language.dart
- [ ] T185 [P] [US5] Implement GetSettingsUseCase in lib/features/settings/domain/usecases/get_settings.dart

### Data Layer - Settings

- [ ] T186 [P] [US5] Create AppSettingsModel in lib/features/settings/data/models/app_settings_model.dart
- [ ] T187 [US5] Implement SettingsLocalDataSource in lib/features/settings/data/datasources/settings_local_datasource.dart using SharedPreferences
- [ ] T188 [US5] Implement SettingsRepositoryImpl in lib/features/settings/data/repositories/settings_repository_impl.dart

### Presentation Layer - Settings

- [ ] T189 [US5] Create SettingsProvider in lib/features/settings/presentation/providers/settings_provider.dart managing locale state
- [ ] T190 [US5] Build SettingsScreen in lib/features/settings/presentation/screens/settings_screen.dart with language selector, account info, about section
- [ ] T191 [P] [US5] Create LanguageSelector widget in lib/features/settings/presentation/widgets/language_selector.dart with radio buttons or dropdown for English/Indonesian
- [ ] T192 [US5] Integrate SettingsProvider with lib/app.dart MaterialApp locale property to update app language reactively
- [ ] T193 [US5] Update Supabase queries in all data sources to select localized fields (\_en or \_id) based on current language

### Localization Completion

- [ ] T194 [P] [US5] Complete Indonesian translations in lib/core/l10n/app_id.arb for all existing English strings
- [ ] T195 [P] [US5] Review all screens and ensure no hardcoded strings exist (use AppLocalizations everywhere)
- [ ] T196 [P] [US5] Add settings strings to ARB files (settings_title, language_label, account_label, about_label, english, indonesian)

### Routing Updates

- [ ] T197 [US5] Add settings route to routing configuration: /settings
- [ ] T198 [US5] Add settings icon/button to app bar or navigation drawer

### Testing for US5

- [ ] T199 [P] [US5] Write unit tests for ChangeLanguageUseCase in test/features/settings/domain/usecases/change_language_test.dart
- [ ] T200 [P] [US5] Write widget tests for LanguageSelector in test/features/settings/presentation/widgets/language_selector_test.dart
- [ ] T201 [US5] Write integration test for language switching flow in test/integration/language_switching_test.dart verifying UI updates

**Checkpoint**: User Story 5 complete. App fully supports bilingual interface with persistent language preference.

---

## Phase 8: User Story 6 - Offline Lesson Access (Priority: P3)

**Goal**: Enable users to access previously viewed lessons offline, complete them, and sync progress when reconnected

**Independent Test**: Load lessons while online → Disconnect from internet → Access cached lessons → Complete a lesson → Reconnect → Verify progress syncs automatically

### Offline Sync Implementation

- [ ] T202 [P] [US6] Implement SyncProgressUseCase in lib/features/progress/domain/usecases/sync_progress.dart processing offline queue
- [ ] T203 [US6] Create SyncQueue service in lib/features/progress/data/datasources/sync_queue_service.dart managing Hive progressQueueBox
- [ ] T204 [US6] Implement background sync using workmanager package in lib/core/services/background_sync_service.dart
- [ ] T205 [US6] Update ProgressRepositoryImpl to queue progress updates when offline instead of failing
- [ ] T206 [US6] Implement retry logic with exponential backoff (5s, 15s, 45s) in sync queue processing

### Offline Indicators

- [ ] T207 [P] [US6] Create OfflineIndicator widget in lib/shared/widgets/offline_indicator.dart showing sync status (syncing/synced/offline)
- [ ] T208 [US6] Add OfflineIndicator to app bar in lib/app.dart listening to connectivity and sync queue status
- [ ] T209 [US6] Update lesson screens to show "Cached - Available Offline" badge for cached lessons

### Cache Management

- [ ] T210 [US6] Implement cache refresh strategy in LessonsLocalDataSource: cache lessons for indefinite period, cache modules for 24 hours
- [ ] T211 [US6] Add cache validation: check if lesson content is stale based on updated_at timestamp
- [ ] T212 [US6] Implement cache cleanup: remove old cached data when storage exceeds threshold

### Offline Error Handling

- [ ] T213 [P] [US6] Update error handling in all repositories to distinguish between network errors and other failures
- [ ] T214 [US6] Show user-friendly offline messages when trying to access uncached content: "This content is not available offline. Please connect to the internet."
- [ ] T215 [US6] Implement retry mechanism for failed syncs with user notification after 3 failed attempts

### Testing for US6

- [ ] T216 [P] [US6] Write unit tests for SyncProgressUseCase in test/features/progress/domain/usecases/sync_progress_test.dart
- [ ] T217 [P] [US6] Write tests for SyncQueue service in test/features/progress/data/datasources/sync_queue_service_test.dart
- [ ] T218 [US6] Write integration test for offline lesson access in test/integration/offline_access_test.dart simulating connectivity loss

**Checkpoint**: All user stories (1-6) complete. App fully supports offline access with automatic sync.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final quality checks

### UI Polish

- [ ] T219 [P] Add smooth page transitions between all screens using PageRouteBuilder with fade/slide animations
- [ ] T220 [P] Implement haptic feedback for button presses and completion events using HapticFeedback class
- [ ] T221 [P] Add skeleton loaders for content loading states in lessons and modules lists
- [ ] T222 [P] Optimize images and assets: compress images, use WebP format, lazy load
- [ ] T223 Review and ensure consistent spacing, padding, and typography across all screens

### Performance Optimization

- [ ] T224 [P] Implement code editor performance optimization: debounce validation checks (500ms after typing stops)
- [ ] T225 [P] Add pagination or lazy loading for long lessons lists and quiz questions if needed
- [ ] T226 Profile app performance using Flutter DevTools: check for jank, memory leaks, excessive rebuilds
- [ ] T227 Optimize Supabase queries: add indexes for frequently queried columns (already in schema, verify)

### Security Hardening

- [ ] T228 [P] Audit all input validation: ensure email, password, code submissions are sanitized
- [ ] T229 [P] Verify Supabase Row Level Security (RLS) policies are active and tested: users can only access their own data
- [ ] T230 [P] Ensure API keys and secrets are not exposed in code: use environment variables only
- [ ] T231 Review authentication token storage: confirm using flutter_secure_storage for sensitive data

### Error Handling & Logging

- [ ] T232 [P] Implement global error handler in lib/main.dart catching unhandled exceptions
- [ ] T233 [P] Add logging for critical operations: authentication, XP awards, sync errors using logger package
- [ ] T234 [P] Create user-friendly error messages for common failures (network, auth, validation)

### Accessibility

- [ ] T235 [P] Add semantic labels to all interactive widgets for screen reader support
- [ ] T236 [P] Ensure text contrast meets WCAG AA standards (4.5:1 for body text)
- [ ] T237 [P] Test app with large text size settings (accessibility settings)
- [ ] T238 [P] Add focus indicators for keyboard navigation

### Documentation

- [ ] T239 [P] Update README.md with project description, setup instructions, and architecture overview
- [ ] T240 [P] Document environment variables and setup steps for new developers in docs/setup.md
- [ ] T241 [P] Create API documentation for Supabase endpoints in docs/api.md
- [ ] T242 [P] Document localization process and how to add new translations in docs/localization.md
- [ ] T243 [P] Add code comments for complex business logic (XP calculation, streak logic)

### Testing & CI/CD

- [ ] T244 Setup GitHub Actions workflow in .github/workflows/ci.yml for running tests on push/PR
- [ ] T245 [P] Add test coverage reporting to CI: fail build if coverage < 70%
- [ ] T246 [P] Setup Codemagic or Fastlane for automated builds and deployment to internal testing tracks
- [ ] T247 Run quickstart.md validation: follow setup guide on fresh machine to verify completeness

### Final QA

- [ ] T248 Perform end-to-end testing on physical Android device: signup → lesson → quiz → level up → offline sync
- [ ] T249 Perform end-to-end testing on physical iOS device (if available)
- [ ] T250 Test all user stories independently to confirm they work without dependencies
- [ ] T251 Verify all localization strings are translated and display correctly in both languages
- [ ] T252 Check app performance on low-end device (Android 7.0, 2GB RAM): ensure 60 FPS, <3s startup

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion
- **User Story 2 (Phase 4)**: Depends on Foundational phase completion + US1 (needs auth and home for navigation)
- **User Story 3 (Phase 5)**: Depends on Foundational phase completion + US1 (needs auth) + US2 (uses same progress/XP system)
- **User Story 4 (Phase 6)**: Depends on US2 and US3 completion (needs XP system and progress data)
- **User Story 5 (Phase 7)**: Depends on Foundational phase completion (can be developed in parallel with US1-4, but better after to ensure all strings exist)
- **User Story 6 (Phase 8)**: Depends on US2 completion (builds on lesson caching infrastructure)
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 (Account & Onboarding)**: Foundation only - No dependencies on other stories ✅ Can start first
- **US2 (Lessons)**: Needs US1 (authentication, home dashboard) - Shares progress/XP system with US3
- **US3 (Quizzes)**: Needs US1 (authentication) - Shares progress/XP system with US2 - Can develop in parallel with US2 if progress layer coordinated
- **US4 (Progress Tracking)**: Needs US2 and US3 (requires XP data from lessons and quizzes)
- **US5 (Localization)**: Needs Foundation - Can develop in parallel with US1-4 but better after to ensure all strings exist
- **US6 (Offline)**: Needs US2 (lesson infrastructure) - Extends caching to full offline support

### Parallel Opportunities

#### Within Setup (Phase 1)

- Tasks T003, T004, T005, T009 can run in parallel (different files)

#### Within Foundational (Phase 2)

- Theme tasks (T010-T012) can run in parallel
- Localization setup (T013-T015) can run in parallel
- Core utilities (T019-T025) can run in parallel
- Shared widgets (T026-T030) can run in parallel
- Data layer init (T031-T033) can run in parallel

#### After Foundational Phase

- US1 and US5 can start in parallel (different features)
- After US1 completes: US2 and US3 can develop in parallel with coordination on progress layer
- After US2 completes: US6 can start while US3 is still in progress

#### Within Each User Story

- Domain layer entities and use cases marked [P] can be written in parallel
- Data layer models marked [P] can be written in parallel
- Presentation layer widgets marked [P] can be written in parallel
- Tests marked [P] can be written in parallel

---

## Parallel Example: User Story 2 (Lessons)

```bash
# Domain layer - can all run in parallel:
Task T084: Create Lesson entity
Task T085: Create Hint entity
Task T086: Define LessonsRepository interface
Task T087: Implement GetLessonsByModuleUseCase
Task T088: Implement GetLessonDetailUseCase
Task T089: Implement ValidateCodeUseCase
Task T090: Implement GetHintUseCase
Task T091: Implement CompleteLessonUseCase

# Data layer models - parallel:
Task T092: Create LessonModel
Task T093: Create HintModel

# Presentation widgets - parallel:
Task T099: Create LessonCard widget
Task T103: Create HintButton widget
Task T104: Create CodeValidationFeedback widget
Task T105: Create LessonCompletionAnimation widget

# Tests - parallel:
Task T125: Unit test for ValidateCodeUseCase
Task T126: Unit test for CompleteLessonUseCase
Task T128: Widget test for LessonDetailScreen
Task T129: Widget test for CodeEditorWidget
```

---

## Implementation Strategy

### MVP First (User Stories 1 & 2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Account & Onboarding)
4. **STOP and VALIDATE**: Test US1 independently - can users sign up and see dashboard?
5. Complete Phase 4: User Story 2 (Lessons)
6. **STOP and VALIDATE**: Test US2 independently - can users complete lessons and earn XP?
7. **Deploy MVP**: Now have a functional learning app (signup → lessons → XP)

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 → Test independently → Deploy/Demo (Auth + Dashboard)
3. Add US2 → Test independently → Deploy/Demo (MVP with lessons!)
4. Add US3 → Test independently → Deploy/Demo (Quizzes added)
5. Add US4 → Test independently → Deploy/Demo (Full progress tracking)
6. Add US5 → Test independently → Deploy/Demo (Bilingual support)
7. Add US6 → Test independently → Deploy/Demo (Offline capability)
8. Polish phase → Final QA → Production release

Each story adds value without breaking previous stories.

### Parallel Team Strategy

With 3 developers after Foundational phase:

- **Developer A**: User Story 1 (weeks 1-2)
- **Developer B**: User Story 5 (week 1), then User Story 3 (week 2)
- **Developer C**: Foundation support (week 1), then User Story 2 (week 2)

After US2 completes:

- **Developer A**: User Story 4 (depends on US2/US3 data)
- **Developer B**: Continue User Story 3
- **Developer C**: User Story 6 (depends on US2 caching)

---

## Summary Statistics

- **Total Tasks**: 252
- **Phase 1 (Setup)**: 9 tasks
- **Phase 2 (Foundational)**: 24 tasks (BLOCKING)
- **Phase 3 (US1)**: 49 tasks
- **Phase 4 (US2)**: 47 tasks
- **Phase 5 (US3)**: 24 tasks
- **Phase 6 (US4)**: 27 tasks
- **Phase 7 (US5)**: 20 tasks
- **Phase 8 (US6)**: 17 tasks
- **Phase 9 (Polish)**: 34 tasks

**Parallelizable Tasks**: ~120 tasks marked [P] can run in parallel within their phase

**MVP Scope** (US1 + US2): 82 tasks (~33% of total)

**Estimated Timeline**:

- Setup + Foundational: 1-2 weeks
- MVP (US1 + US2): 3-4 weeks
- Full Feature Set (US1-US6): 8-10 weeks
- Polish + QA: 1-2 weeks
- **Total**: 10-14 weeks with 1-2 developers

---

## Notes

- All tasks follow the required checklist format: `- [ ] [ID] [P?] [Story?] Description with file path`
- [P] marker indicates tasks that can run in parallel (different files, no dependencies on incomplete tasks)
- [Story] label (US1-US6) maps tasks to specific user stories for traceability
- File paths use lib/ structure as defined in plan.md
- Tests are OPTIONAL per speckit guidelines - included here as most projects benefit from them
- Commit after each task or logical group of related tasks
- Stop at checkpoints to validate story independence before proceeding
- Each user story is independently testable and delivers value on its own
