# Phase 0: Technical Research & Decisions

**Feature**: Codedly Mobile App  
**Created**: 2025-10-31  
**Purpose**: Resolve technical unknowns and establish best practices for implementation

## Research Areas

### 1. State Management: Riverpod vs BLoC

**Decision**: Flutter Riverpod 2.4+

**Rationale**:

- **Compile-time safety**: Riverpod provides compile-time checking for provider dependencies, reducing runtime errors
- **Better testability**: Providers can be easily overridden in tests without complex setup
- **Less boilerplate**: Compared to BLoC, Riverpod requires less code for simple state management
- **Better for beginners**: Team members new to Flutter will find Riverpod's syntax more intuitive
- **Good for this use case**: App state is mostly independent features (auth, lessons, progress) rather than complex event-driven flows
- **Active maintenance**: Riverpod is actively developed by Remi Rousselet with strong community support

**Alternatives Considered**:

- **BLoC Pattern**: More verbose, better for complex event-driven scenarios. Overkill for this app's relatively simple state flows. Steeper learning curve.
- **Provider (legacy)**: Riverpod's predecessor. Less type-safe, more prone to runtime errors. Superseded by Riverpod.
- **GetX**: Not considered due to constitution requirement (prefer well-established patterns over opinionated frameworks)

**Implementation Approach**:

- Use `StateNotifierProvider` for mutable state (auth status, lesson progress)
- Use `FutureProvider` for async data fetching (lessons, quizzes)
- Use `StreamProvider` for real-time updates (if Supabase realtime needed later)
- Family modifiers for parameterized providers (e.g., lesson by ID)

---

### 2. Code Editor Component

**Decision**: re_editor 0.8+ (https://pub.dev/packages/re_editor)

**Rationale**:

- **Flutter-native**: Built specifically for Flutter, no WebView overhead
- **Syntax highlighting**: Built-in support for Python syntax highlighting
- **Performance**: Handles large code files efficiently with virtualization
- **Line numbers**: Native support for line numbers
- **Customizable**: Theme support for dark mode integration
- **Maintained**: Active development and issue resolution
- **Lightweight**: Minimal dependencies, small package size

**Alternatives Considered**:

- **flutter_code_editor**: Good option but less performant on large files. Re_editor has better virtualization.
- **CodeMirror via WebView**: High overhead, requires JS bridge, slower performance, larger app size. Violates performance constraints.
- **Custom implementation**: Too time-consuming for MVP. Re_editor provides needed features out of the box.

**Implementation Approach**:

- Wrap re_editor in custom widget for consistent theming
- Pre-load Python syntax highlighter configuration
- Implement debouncing for validation checks (wait 500ms after typing stops)
- Cache editor state when navigating away from lesson

---

### 3. Local Storage for Offline Caching

**Decision**: Hive 2.2+ for structured data, Shared Preferences for simple key-value

**Rationale**:

- **Hive advantages**: NoSQL database, fast (written in pure Dart), supports complex objects, type-safe with code generation
- **No native dependencies**: Pure Dart implementation works consistently across platforms
- **Lazy loading**: Load only needed boxes, reducing memory usage
- **Encryption support**: Built-in encryption for sensitive cached data
- **Good for offline-first**: Excellent performance for read-heavy offline scenarios

**Alternatives Considered**:

- **SQLite (sqflite)**: More overhead for simple caching needs. Hive is faster for object storage.
- **ObjectBox**: Faster than Hive but requires native binaries, increasing app size. Overkill for our caching needs.
- **Isar**: Newer, very fast, but less mature than Hive. Sticking with proven solution.

**Implementation Approach**:

- Hive boxes: `lessonsBox`, `quizzesBox`, `modulesBox`, `progressQueueBox`
- Use TypeAdapters for custom entities (Lesson, Quiz, Module)
- Lazy-load boxes (open only when needed)
- SharedPreferences for: language preference, onboarding completion flag, last sync timestamp

---

### 4. Code Validation Strategy

**Decision**: Client-side pattern matching + server-side validation (Supabase Edge Function)

**Rationale**:

- **Client-side validation**: Fast feedback for simple cases (syntax errors, expected output matching)
- **Server-side validation**: Security and complex validation (prevent code injection, execute safely in sandbox)
- **Hybrid approach**: Best user experience (instant feedback) with security (server validation before XP award)
- **Scalable**: Can add more complex validation logic server-side without app updates

**Validation Levels**:

1. **Level 1 - Syntax Check (Client)**: Use regex or simple parsing to detect basic syntax errors (missing colons, unmatched brackets)
2. **Level 2 - Output Matching (Client)**: Compare user code output against expected output string
3. **Level 3 - Secure Execution (Server)**: Supabase Edge Function runs code in sandboxed Deno environment, validates complex logic

**Alternatives Considered**:

- **Client-only validation**: Security risk. Users could manipulate code validation to award themselves XP.
- **Server-only validation**: Poor UX. Every code check requires network round-trip.
- **Third-party API (e.g., Judge0)**: Additional cost, dependency on external service, latency. Edge functions are sufficient.

**Implementation Approach**:

- Create `CodeValidator` utility class for client-side checks
- Implement Supabase Edge Function `/api/validate-code` for server-side validation
- Two-phase validation: instant client feedback → server confirmation before XP award
- Cache validation results for offline mode (assume previously validated code is correct)

---

### 5. Localization File Structure

**Decision**: ARB (Application Resource Bundle) files with flutter_localizations

**Rationale**:

- **Standard Flutter approach**: Official recommendation from Flutter team
- **Tooling support**: Android Studio and VS Code have excellent ARB support with syntax highlighting and validation
- **Code generation**: flutter_gen generates type-safe localization classes
- **Pluralization support**: ARB format handles plurals, genders, and complex message formatting
- **Translation-ready**: ARB format is familiar to professional translators

**File Structure**:

```
lib/core/l10n/
├── app_en.arb          # English (primary, reference file)
├── app_id.arb          # Indonesian (Bahasa Indonesia)
└── l10n.dart           # Generated localization class
```

**Alternatives Considered**:

- **JSON files with custom loader**: Requires more boilerplate, no standard tooling support
- **GetX translations**: Ties localization to GetX, violates architecture independence
- **Easy Localization package**: Extra dependency, ARB is sufficient and native

**Implementation Approach**:

- Start with English ARB as reference
- Add Indonesian translations incrementally feature-by-feature
- Use `Intl.message()` for strings, `Intl.plural()` for count-based strings
- Extract common strings (buttons, errors) to separate ARB section for reusability
- Implement language switching via settings screen (updates Locale in MaterialApp)

---

### 6. XP Calculation & Level Formula

**Decision**: Linear progression with increasing requirements per level

**Formula**:

```
XP required for level N = 100 * N
Total XP to reach level N = 50 * N * (N + 1)
```

Examples:

- Level 1 → Level 2: 100 XP
- Level 2 → Level 3: 200 XP
- Level 3 → Level 4: 300 XP
- Total to reach Level 10: 5,000 XP

**XP Awards**:

- Complete lesson: +10 XP (base)
- Complete quiz: +5 XP per correct answer
- First lesson in module: +20 XP (bonus)
- Perfect quiz score (100%): +10 XP (bonus)
- Daily streak milestone (7 days): +50 XP (bonus)

**Rationale**:

- **Balanced progression**: Level 2 is achievable after ~10 lessons, keeping beginners motivated
- **Increasing challenge**: Higher levels require more effort, rewarding dedication
- **Predictable**: Simple formula is easy to understand and explain to users
- **Room for bonuses**: Base rewards are conservative, allowing bonus XP for special achievements

**Alternatives Considered**:

- **Fixed XP per level**: Too easy at high levels, too hard at low levels. No sense of progression.
- **Exponential growth**: Becomes impossibly grindy at higher levels. Discourages long-term engagement.
- **Non-linear complex formula**: Harder to communicate to users, less transparent.

**Implementation Approach**:

- Store formula constants in `lib/core/constants/xp_constants.dart`
- Create `XpCalculator` utility class with methods: `xpForNextLevel(currentLevel)`, `calculateLevel(totalXp)`
- Use cases: `AwardXpUseCase`, `CalculateLevelUseCase`
- Show visual progress: `(currentLevelXP / xpForNextLevel) * 100` for progress bar percentage

---

### 7. Offline Sync Strategy

**Decision**: Optimistic UI updates with background sync queue

**Rationale**:

- **Better UX**: User sees immediate feedback even offline
- **Reliable**: Queue ensures no data loss when connectivity is spotty
- **Efficient**: Batch syncs when connection restored (reduces API calls)
- **Transparent**: User sees "syncing" indicator if queue has pending items

**Sync Queue Design**:

```dart
class SyncQueueItem {
  String id;
  String type;  // 'lesson_complete', 'quiz_complete', 'xp_award'
  Map<String, dynamic> data;
  DateTime timestamp;
  int retryCount;
}
```

**Sync Flow**:

1. User completes lesson offline → Update local Hive cache + Add to sync queue
2. Show XP animation immediately (optimistic update)
3. When online → Process sync queue in order (FIFO)
4. On successful sync → Remove from queue, update remote timestamp
5. On sync failure → Retry with exponential backoff (max 3 retries)
6. Show sync status icon in app bar (syncing/synced/error)

**Alternatives Considered**:

- **No offline support**: Poor UX for students with unreliable internet. Violates constitution's accessibility principle.
- **Full offline mode with conflict resolution**: Too complex for MVP. Our data is user-specific (no collaboration), so conflicts are rare.
- **Supabase Realtime sync**: Real-time sync is overkill for progress tracking. Background queue is sufficient.

**Implementation Approach**:

- Create `SyncQueue` service in data layer
- Use `WorkManager` (via `workmanager` package) for background sync on Android/iOS
- Store queue in Hive `progressQueueBox`
- Implement retry logic with exponential backoff: 5s, 15s, 45s
- Show sync status using `StreamProvider` watching queue length

---

### 8. Supabase Schema Design Best Practices

**Decision**: Normalized schema with Row Level Security (RLS) policies

**Key Principles**:

- **RLS for security**: Every table has policies to prevent unauthorized access
- **Foreign keys**: Maintain referential integrity between tables
- **Timestamps**: All tables have `created_at` and `updated_at` for auditing
- **Soft deletes**: Use `deleted_at` column instead of hard deletes (preserve user history)
- **Indexes**: Add indexes on foreign keys and frequently queried columns

**RLS Policies**:

```sql
-- Users can only read/write their own progress
CREATE POLICY "Users can view own progress"
  ON user_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress"
  ON user_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

**Rationale**:

- **Security**: RLS prevents users from accessing or modifying other users' data at the database level
- **Audit trail**: Timestamps enable tracking when data was created/modified
- **Data integrity**: Foreign keys prevent orphaned records
- **Performance**: Indexes speed up queries on large datasets

**Implementation Approach**:

- Define schema in migration file: `supabase/migrations/001_initial_schema.sql`
- Create RLS policies for all tables
- Add indexes: `user_progress(user_id, lesson_id)`, `xp_records(user_id, created_at)`
- Use Supabase client's automatic RLS enforcement in app

---

### 9. Testing Strategy

**Decision**: Three-tier testing approach with mocking

**Test Tiers**:

1. **Unit Tests (70% of tests)**: Domain layer use cases, data layer repositories, utility functions
2. **Widget Tests (25% of tests)**: UI components, screens, user interactions
3. **Integration Tests (5% of tests)**: Critical user flows (signup → lesson → XP award)

**Mocking Strategy**:

- Use `mockito` to generate mocks for repositories and data sources
- Use `bloc_test` (or riverpod testing utilities) for provider testing
- Use `fake_async` for time-dependent tests (streak calculation, sync delays)

**Coverage Goals**:

- Domain layer: 90%+ (core business logic must be well-tested)
- Data layer: 80%+ (repositories, data sources)
- Presentation layer: 60%+ (providers, critical widgets)
- Overall target: 70%+

**Rationale**:

- **Constitution compliance**: Meets the 70% minimum coverage requirement
- **Focus on logic**: More tests on business logic (domain) than UI (presentation)
- **Practical**: Integration tests are expensive; unit tests provide better ROI
- **CI-friendly**: Fast unit tests enable quick feedback in CI pipeline

**Implementation Approach**:

- Test file mirrors source structure: `test/features/auth/domain/usecases/sign_in_test.dart`
- Use test fixtures for consistent test data: `test/fixtures/user_fixture.dart`
- Set up CI (GitHub Actions) to run tests, check coverage, fail if <70%

---

### 10. CI/CD Pipeline

**Decision**: GitHub Actions for CI, Codemagic or Fastlane for CD

**CI Pipeline (GitHub Actions)**:

```yaml
on: [push, pull_request]
jobs:
  test:
    - Run flutter analyze
    - Run flutter test --coverage
    - Upload coverage to Codecov
    - Fail if coverage < 70%
  build:
    - Build Android APK
    - Build iOS IPA (on Mac runner)
```

**CD Pipeline (Codemagic)**:

- Trigger on tag creation (`v1.0.0`)
- Build signed release APK/IPA
- Publish to Google Play (internal testing track)
- Publish to TestFlight (iOS beta)

**Rationale**:

- **Automated quality gates**: Prevents merging broken code
- **Fast feedback**: Developers see test results in minutes
- **Consistent builds**: CI/CD ensures reproducible builds
- **Easier releases**: One command to deploy to app stores

**Alternatives Considered**:

- **Manual testing only**: Slow, error-prone, doesn't scale. Constitution requires automated CI.
- **Jenkins self-hosted**: More maintenance overhead, CI runners in cloud are easier.
- **CircleCI**: Good option, but GitHub Actions is free for public repos and integrates seamlessly.

**Implementation Approach**:

- Create `.github/workflows/ci.yml` for test automation
- Set up Codemagic account and connect to GitHub repo
- Configure signing certificates and provisioning profiles in Codemagic
- Document CI/CD workflow in `docs/ci-cd.md`

---

## Summary of Key Decisions

| Area             | Decision                     | Key Benefit                           |
| ---------------- | ---------------------------- | ------------------------------------- |
| State Management | Riverpod                     | Compile-time safety, less boilerplate |
| Code Editor      | re_editor                    | Flutter-native, performant            |
| Local Storage    | Hive + SharedPreferences     | Fast, pure Dart, offline-first        |
| Code Validation  | Client + Server hybrid       | UX + Security                         |
| Localization     | ARB files                    | Standard, tooling support             |
| XP Formula       | Linear increasing            | Balanced progression                  |
| Offline Sync     | Queue with background worker | Reliable, transparent                 |
| Database         | Supabase with RLS            | Security, managed backend             |
| Testing          | 70% coverage, mockito        | Constitution compliance               |
| CI/CD            | GitHub Actions + Codemagic   | Automation, quality gates             |

---

## Next Steps

With research complete, proceed to:

- **Phase 1**: Create `data-model.md` with detailed entity schemas
- **Phase 1**: Generate API contracts in `contracts/` directory
- **Phase 1**: Write `quickstart.md` for local development setup
