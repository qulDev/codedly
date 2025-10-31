# Data Model: Codedly Mobile App

**Feature**: Codedly Mobile App  
**Created**: 2025-10-31  
**Purpose**: Define all entities, their attributes, relationships, and validation rules

## Entity Relationship Overview

```
User (auth.users - Supabase Auth)
  ├── 1:N → UserProgress (tracks lesson/quiz completion)
  ├── 1:N → XPRecord (history of XP transactions)
  └── 1:1 → UserStats (aggregated stats: level, total_xp, streak)

Module
  ├── 1:N → Lesson
  └── 1:N → Quiz

Lesson
  ├── N:1 → Module
  ├── 1:N → Hint
  └── 1:N → UserProgress

Quiz
  ├── N:1 → Module
  ├── 1:N → Question
  └── 1:N → UserProgress

Question
  └── N:1 → Quiz
```

---

## Core Entities

### 1. User (Extended Profile)

Supabase Auth manages authentication, but we store additional profile data in `user_profiles` table.

**Table**: `user_profiles`

| Field                | Type         | Constraints             | Description                                   |
| -------------------- | ------------ | ----------------------- | --------------------------------------------- |
| id                   | uuid         | PK, FK (auth.users.id)  | User identifier (matches Supabase Auth)       |
| email                | varchar(255) | NOT NULL, UNIQUE        | User email (duplicated from auth for queries) |
| display_name         | varchar(100) | NULL                    | User's chosen display name                    |
| language_preference  | varchar(5)   | NOT NULL, DEFAULT 'en'  | 'en' or 'id'                                  |
| onboarding_completed | boolean      | NOT NULL, DEFAULT false | Has user completed onboarding?                |
| created_at           | timestamptz  | NOT NULL, DEFAULT now() | Account creation timestamp                    |
| updated_at           | timestamptz  | NOT NULL, DEFAULT now() | Last profile update                           |

**Validation Rules**:

- `email`: Must match email format (validated by Supabase Auth)
- `display_name`: 1-100 characters, alphanumeric + spaces, optional
- `language_preference`: Must be 'en' or 'id'

**Relationships**:

- 1:1 with Supabase Auth users
- 1:N with UserProgress
- 1:N with XPRecord
- 1:1 with UserStats

**Indexes**:

- PRIMARY KEY (id)
- UNIQUE (email)

---

### 2. UserStats (Aggregated User Statistics)

Separate table for frequently accessed aggregated data to optimize queries.

**Table**: `user_stats`

| Field              | Type        | Constraints               | Description                        |
| ------------------ | ----------- | ------------------------- | ---------------------------------- |
| user_id            | uuid        | PK, FK (user_profiles.id) | User identifier                    |
| total_xp           | integer     | NOT NULL, DEFAULT 0       | Cumulative XP earned               |
| current_level      | integer     | NOT NULL, DEFAULT 1       | Calculated level based on total_xp |
| streak_count       | integer     | NOT NULL, DEFAULT 0       | Current consecutive days streak    |
| last_activity_date | date        | NULL                      | Last day user completed content    |
| lessons_completed  | integer     | NOT NULL, DEFAULT 0       | Count of completed lessons         |
| quizzes_completed  | integer     | NOT NULL, DEFAULT 0       | Count of completed quizzes         |
| modules_completed  | integer     | NOT NULL, DEFAULT 0       | Count of fully completed modules   |
| updated_at         | timestamptz | NOT NULL, DEFAULT now()   | Last stats update                  |

**Validation Rules**:

- `total_xp`: >= 0
- `current_level`: >= 1
- `streak_count`: >= 0
- `lessons_completed`: >= 0
- `quizzes_completed`: >= 0
- `modules_completed`: >= 0

**Relationships**:

- N:1 with User (user_id → user_profiles.id)

**Indexes**:

- PRIMARY KEY (user_id)
- INDEX (current_level) for leaderboards (future feature)

**Business Logic**:

- `current_level` is calculated from `total_xp` using formula: `floor((-1 + sqrt(1 + 8 * total_xp / 100)) / 2) + 1`
- `streak_count` increments if `last_activity_date` is yesterday, resets to 1 if > 1 day gap

---

### 3. Module

Represents a learning unit (e.g., "Introduction to Python").

**Table**: `modules`

| Field                      | Type         | Constraints                   | Description                            |
| -------------------------- | ------------ | ----------------------------- | -------------------------------------- |
| id                         | uuid         | PK, DEFAULT gen_random_uuid() | Module identifier                      |
| title_en                   | varchar(200) | NOT NULL                      | English title                          |
| title_id                   | varchar(200) | NOT NULL                      | Indonesian title                       |
| description_en             | text         | NULL                          | English description                    |
| description_id             | text         | NULL                          | Indonesian description                 |
| order_index                | integer      | NOT NULL, UNIQUE              | Display order (1, 2, 3...)             |
| difficulty_level           | varchar(20)  | NOT NULL                      | 'beginner', 'intermediate', 'advanced' |
| estimated_duration_minutes | integer      | NULL                          | Estimated time to complete             |
| required_level             | integer      | NOT NULL, DEFAULT 1           | Minimum user level to unlock           |
| is_published               | boolean      | NOT NULL, DEFAULT false       | Visible to users?                      |
| created_at                 | timestamptz  | NOT NULL, DEFAULT now()       | Creation timestamp                     |
| updated_at                 | timestamptz  | NOT NULL, DEFAULT now()       | Last update                            |

**Validation Rules**:

- `title_en`, `title_id`: 1-200 characters, NOT NULL
- `order_index`: Unique, positive integer
- `difficulty_level`: Must be one of ('beginner', 'intermediate', 'advanced')
- `required_level`: >= 1
- `estimated_duration_minutes`: > 0 if set

**Relationships**:

- 1:N with Lesson
- 1:N with Quiz

**Indexes**:

- PRIMARY KEY (id)
- UNIQUE (order_index)
- INDEX (is_published, order_index) for fetching active modules in order

---

### 4. Lesson

Represents a single learning session within a module.

**Table**: `lessons`

| Field                      | Type         | Constraints                   | Description                                 |
| -------------------------- | ------------ | ----------------------------- | ------------------------------------------- |
| id                         | uuid         | PK, DEFAULT gen_random_uuid() | Lesson identifier                           |
| module_id                  | uuid         | NOT NULL, FK (modules.id)     | Parent module                               |
| title_en                   | varchar(200) | NOT NULL                      | English title                               |
| title_id                   | varchar(200) | NOT NULL                      | Indonesian title                            |
| content_en                 | text         | NOT NULL                      | English instructional content (Markdown)    |
| content_id                 | text         | NOT NULL                      | Indonesian instructional content (Markdown) |
| code_template              | text         | NULL                          | Starter code for the lesson                 |
| expected_output            | text         | NULL                          | Expected code output for validation         |
| validation_type            | varchar(20)  | NOT NULL, DEFAULT 'output'    | 'output', 'pattern', 'custom'               |
| validation_pattern         | text         | NULL                          | Regex or pattern for validation             |
| order_index                | integer      | NOT NULL                      | Order within module (1, 2, 3...)            |
| xp_reward                  | integer      | NOT NULL, DEFAULT 10          | XP awarded on completion                    |
| estimated_duration_minutes | integer      | NULL                          | Estimated time                              |
| is_published               | boolean      | NOT NULL, DEFAULT false       | Visible to users?                           |
| created_at                 | timestamptz  | NOT NULL, DEFAULT now()       | Creation timestamp                          |
| updated_at                 | timestamptz  | NOT NULL, DEFAULT now()       | Last update                                 |

**Validation Rules**:

- `title_en`, `title_id`: 1-200 characters
- `content_en`, `content_id`: NOT NULL (can be empty for code-only lessons)
- `validation_type`: Must be one of ('output', 'pattern', 'custom')
- `order_index`: Positive integer, unique within module
- `xp_reward`: > 0

**Relationships**:

- N:1 with Module (module_id → modules.id)
- 1:N with Hint
- 1:N with UserProgress

**Indexes**:

- PRIMARY KEY (id)
- INDEX (module_id, order_index) for fetching lessons in order
- INDEX (is_published)

**Business Logic**:

- Validation types:
  - `output`: Compare user code output with `expected_output` (exact match)
  - `pattern`: Use `validation_pattern` regex to validate output
  - `custom`: Call Supabase Edge Function for complex validation

---

### 5. Hint

Provides guidance for lessons when users are stuck.

**Table**: `lesson_hints`

| Field        | Type        | Constraints                   | Description                           |
| ------------ | ----------- | ----------------------------- | ------------------------------------- |
| id           | uuid        | PK, DEFAULT gen_random_uuid() | Hint identifier                       |
| lesson_id    | uuid        | NOT NULL, FK (lessons.id)     | Parent lesson                         |
| hint_text_en | text        | NOT NULL                      | English hint text                     |
| hint_text_id | text        | NOT NULL                      | Indonesian hint text                  |
| order_index  | integer     | NOT NULL                      | Hint sequence (show hints 1, 2, 3...) |
| created_at   | timestamptz | NOT NULL, DEFAULT now()       | Creation timestamp                    |

**Validation Rules**:

- `hint_text_en`, `hint_text_id`: NOT NULL, at least 10 characters
- `order_index`: Positive integer, unique within lesson

**Relationships**:

- N:1 with Lesson (lesson_id → lessons.id)

**Indexes**:

- PRIMARY KEY (id)
- INDEX (lesson_id, order_index) for fetching hints in sequence

---

### 6. Quiz

Represents an assessment with multiple questions.

**Table**: `quizzes`

| Field                    | Type         | Constraints                   | Description                |
| ------------------------ | ------------ | ----------------------------- | -------------------------- |
| id                       | uuid         | PK, DEFAULT gen_random_uuid() | Quiz identifier            |
| module_id                | uuid         | NOT NULL, FK (modules.id)     | Parent module              |
| title_en                 | varchar(200) | NOT NULL                      | English title              |
| title_id                 | varchar(200) | NOT NULL                      | Indonesian title           |
| description_en           | text         | NULL                          | English description        |
| description_id           | text         | NULL                          | Indonesian description     |
| order_index              | integer      | NOT NULL                      | Order within module        |
| passing_score_percentage | integer      | NOT NULL, DEFAULT 70          | Minimum % to pass (0-100)  |
| xp_per_correct_answer    | integer      | NOT NULL, DEFAULT 5           | XP for each correct answer |
| bonus_xp_for_perfect     | integer      | NOT NULL, DEFAULT 10          | Extra XP for 100% score    |
| is_published             | boolean      | NOT NULL, DEFAULT false       | Visible to users?          |
| created_at               | timestamptz  | NOT NULL, DEFAULT now()       | Creation timestamp         |
| updated_at               | timestamptz  | NOT NULL, DEFAULT now()       | Last update                |

**Validation Rules**:

- `title_en`, `title_id`: 1-200 characters
- `passing_score_percentage`: 0-100
- `xp_per_correct_answer`: > 0
- `order_index`: Positive integer, unique within module

**Relationships**:

- N:1 with Module (module_id → modules.id)
- 1:N with Question
- 1:N with UserProgress

**Indexes**:

- PRIMARY KEY (id)
- INDEX (module_id, order_index)
- INDEX (is_published)

---

### 7. Question

Represents a single multiple-choice question within a quiz.

**Table**: `quiz_questions`

| Field                | Type        | Constraints                   | Description                            |
| -------------------- | ----------- | ----------------------------- | -------------------------------------- |
| id                   | uuid        | PK, DEFAULT gen_random_uuid() | Question identifier                    |
| quiz_id              | uuid        | NOT NULL, FK (quizzes.id)     | Parent quiz                            |
| question_text_en     | text        | NOT NULL                      | English question                       |
| question_text_id     | text        | NOT NULL                      | Indonesian question                    |
| options_en           | jsonb       | NOT NULL                      | Array of English answer options        |
| options_id           | jsonb       | NOT NULL                      | Array of Indonesian answer options     |
| correct_answer_index | integer     | NOT NULL                      | Index of correct answer (0-based)      |
| explanation_en       | text        | NULL                          | English explanation for correct answer |
| explanation_id       | text        | NULL                          | Indonesian explanation                 |
| order_index          | integer     | NOT NULL                      | Question order in quiz (1, 2, 3...)    |
| created_at           | timestamptz | NOT NULL, DEFAULT now()       | Creation timestamp                     |
| updated_at           | timestamptz | NOT NULL, DEFAULT now()       | Last update                            |

**Validation Rules**:

- `question_text_en`, `question_text_id`: NOT NULL, at least 10 characters
- `options_en`, `options_id`: JSONB arrays with 3-5 strings each
- `correct_answer_index`: 0 to (options.length - 1)
- `order_index`: Positive integer, unique within quiz

**JSONB Structure for options**:

```json
["Option A text", "Option B text", "Option C text", "Option D text"]
```

**Relationships**:

- N:1 with Quiz (quiz_id → quizzes.id)

**Indexes**:

- PRIMARY KEY (id)
- INDEX (quiz_id, order_index)

---

### 8. UserProgress

Tracks user's completion status for lessons and quizzes.

**Table**: `user_progress`

| Field              | Type        | Constraints                     | Description                    |
| ------------------ | ----------- | ------------------------------- | ------------------------------ |
| id                 | uuid        | PK, DEFAULT gen_random_uuid()   | Progress record identifier     |
| user_id            | uuid        | NOT NULL, FK (user_profiles.id) | User who completed content     |
| content_type       | varchar(10) | NOT NULL                        | 'lesson' or 'quiz'             |
| content_id         | uuid        | NOT NULL                        | Lesson or Quiz ID              |
| is_completed       | boolean     | NOT NULL, DEFAULT false         | Completion status              |
| score_percentage   | integer     | NULL                            | For quizzes: score 0-100       |
| xp_earned          | integer     | NOT NULL, DEFAULT 0             | XP awarded for this completion |
| attempts_count     | integer     | NOT NULL, DEFAULT 0             | Number of attempts             |
| first_attempted_at | timestamptz | NULL                            | First attempt timestamp        |
| completed_at       | timestamptz | NULL                            | Completion timestamp           |
| created_at         | timestamptz | NOT NULL, DEFAULT now()         | Record creation                |

**Validation Rules**:

- `content_type`: Must be 'lesson' or 'quiz'
- `score_percentage`: 0-100, NULL for lessons
- `xp_earned`: >= 0
- `attempts_count`: >= 0

**Relationships**:

- N:1 with User (user_id → user_profiles.id)
- N:1 with Lesson or Quiz (polymorphic via content_type + content_id)

**Indexes**:

- PRIMARY KEY (id)
- UNIQUE (user_id, content_type, content_id) for single progress record per user per content
- INDEX (user_id, is_completed) for fetching completed items
- INDEX (user_id, completed_at) for recent activity

**Business Logic**:

- First attempt sets `first_attempted_at`
- Completion sets `is_completed = true`, `completed_at = now()`
- `attempts_count` increments on each attempt
- `xp_earned` is calculated based on content and performance

---

### 9. XPRecord

Historical log of all XP transactions for auditing and analytics.

**Table**: `xp_records`

| Field        | Type         | Constraints                     | Description                                     |
| ------------ | ------------ | ------------------------------- | ----------------------------------------------- |
| id           | uuid         | PK, DEFAULT gen_random_uuid()   | XP record identifier                            |
| user_id      | uuid         | NOT NULL, FK (user_profiles.id) | User who earned XP                              |
| xp_amount    | integer      | NOT NULL                        | XP gained (can be negative for penalties)       |
| reason       | varchar(100) | NOT NULL                        | Short description of reason                     |
| content_type | varchar(10)  | NULL                            | 'lesson', 'quiz', or NULL for bonuses           |
| content_id   | uuid         | NULL                            | Related content ID if applicable                |
| metadata     | jsonb        | NULL                            | Additional data (e.g., quiz score, streak days) |
| created_at   | timestamptz  | NOT NULL, DEFAULT now()         | Transaction timestamp                           |

**Validation Rules**:

- `xp_amount`: Can be negative for penalties (future feature)
- `reason`: 1-100 characters, descriptive
- `content_type`: NULL or one of ('lesson', 'quiz', 'bonus')

**Example Reasons**:

- "Completed Lesson: Variables in Python"
- "Quiz Score: 8/10"
- "7-Day Streak Bonus"
- "First Lesson in Module Bonus"

**Relationships**:

- N:1 with User (user_id → user_profiles.id)
- N:1 with Lesson or Quiz (optional, via content_type + content_id)

**Indexes**:

- PRIMARY KEY (id)
- INDEX (user_id, created_at DESC) for user XP history
- INDEX (created_at) for analytics

**Business Logic**:

- Immutable: Records are never updated or deleted (append-only log)
- Used for XP history graphs and audit trails

---

## Local Storage Entities (Hive)

For offline caching and performance optimization.

### CachedLesson (Hive Box: lessonsBox)

```dart
@HiveType(typeId: 1)
class CachedLesson {
  @HiveField(0)
  String id;

  @HiveField(1)
  String moduleId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String content;

  @HiveField(4)
  String? codeTemplate;

  @HiveField(5)
  String? expectedOutput;

  @HiveField(6)
  int xpReward;

  @HiveField(7)
  DateTime cachedAt;

  @HiveField(8)
  List<CachedHint> hints;
}
```

### CachedQuiz (Hive Box: quizzesBox)

```dart
@HiveType(typeId: 2)
class CachedQuiz {
  @HiveField(0)
  String id;

  @HiveField(1)
  String moduleId;

  @HiveField(2)
  String title;

  @HiveField(3)
  List<CachedQuestion> questions;

  @HiveField(4)
  int passingScorePercentage;

  @HiveField(5)
  int xpPerCorrectAnswer;

  @HiveField(6)
  DateTime cachedAt;
}
```

### SyncQueueItem (Hive Box: progressQueueBox)

```dart
@HiveType(typeId: 3)
class SyncQueueItem {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type;  // 'lesson_complete', 'quiz_complete'

  @HiveField(2)
  Map<String, dynamic> data;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  int retryCount;

  @HiveField(5)
  bool isSynced;
}
```

---

## Validation Rules Summary

| Entity       | Key Validations                                                            |
| ------------ | -------------------------------------------------------------------------- |
| User         | Email format, password min 8 chars (Supabase Auth), language 'en'/'id'     |
| UserStats    | All counts >= 0, level >= 1, streak >= 0                                   |
| Module       | Order unique, difficulty enum, required_level >= 1                         |
| Lesson       | Order unique per module, xp_reward > 0, validation_type enum               |
| Hint         | Hint text >= 10 chars, order unique per lesson                             |
| Quiz         | Passing score 0-100, order unique per module, xp_per_correct > 0           |
| Question     | Options array 3-5 items, correct_answer_index valid, order unique per quiz |
| UserProgress | Content_type enum, score 0-100, xp_earned >= 0                             |
| XPRecord     | Reason descriptive, immutable records                                      |

---

## Denormalization Decisions

To optimize performance, some data is intentionally denormalized:

1. **user_profiles.email**: Duplicated from Supabase Auth for easier queries without joins
2. **user_stats**: Aggregated data (total_xp, counts) stored separately for fast dashboard queries
3. **lessons/quizzes localized fields**: Both EN and ID stored in same table (not separate translation table) for simpler queries

**Trade-offs**:

- **Pro**: Faster reads (no joins), simpler queries, better offline experience
- **Con**: Must maintain consistency when updating (e.g., update total_xp when XP awarded)
- **Mitigation**: Use database triggers or application-level transactions to keep data consistent

---

## Next Steps

With data model complete, proceed to:

- **Phase 1**: Generate API contracts for Supabase endpoints
- **Phase 1**: Create database schema SQL migration file
- **Phase 1**: Write quickstart guide for local setup
