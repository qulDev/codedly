# Content API Contracts (Modules, Lessons, Quizzes)

**Service**: Supabase Database (PostgreSQL)  
**Base URL**: `https://[project-ref].supabase.co/rest/v1`  
**Client**: supabase_flutter handles REST queries

## Overview

Content is fetched from Supabase using the Dart client's query builder. All queries automatically enforce Row Level Security (RLS) policies using the authenticated user's JWT token.

---

## 1. Get All Modules

**Purpose**: Fetch all published modules for the home screen

**Client Query**:

```dart
final response = await supabase
    .from('modules')
    .select('*')
    .eq('is_published', true)
    .order('order_index', ascending: true);
```

**Response Success** (200 OK):

```json
[
  {
    "id": "uuid-1",
    "title_en": "Introduction to Python",
    "title_id": "Pengenalan Python",
    "description_en": "Learn Python basics",
    "description_id": "Pelajari dasar Python",
    "order_index": 1,
    "difficulty_level": "beginner",
    "estimated_duration_minutes": 120,
    "required_level": 1,
    "is_published": true,
    "created_at": "2025-10-31T10:00:00Z",
    "updated_at": "2025-10-31T10:00:00Z"
  },
  {
    "id": "uuid-2",
    "title_en": "Data Structures",
    "title_id": "Struktur Data",
    "description_en": "Lists, tuples, dictionaries",
    "description_id": "List, tuple, dictionary",
    "order_index": 2,
    "difficulty_level": "intermediate",
    "estimated_duration_minutes": 180,
    "required_level": 5,
    "is_published": true,
    "created_at": "2025-10-31T10:00:00Z",
    "updated_at": "2025-10-31T10:00:00Z"
  }
]
```

**Localization**: Client selects `title_en`/`title_id` based on user's language preference

---

## 2. Get Module with Progress

**Purpose**: Fetch a module with user's progress on its lessons and quizzes

**Client Query**:

```dart
final userId = supabase.auth.currentUser!.id;

// Get module
final module = await supabase
    .from('modules')
    .select('*')
    .eq('id', moduleId)
    .single();

// Get lessons for this module
final lessons = await supabase
    .from('lessons')
    .select('id, title_en, title_id, order_index, xp_reward, is_published')
    .eq('module_id', moduleId)
    .eq('is_published', true)
    .order('order_index', ascending: true);

// Get user's progress for these lessons
final lessonIds = lessons.map((l) => l['id']).toList();
final progress = await supabase
    .from('user_progress')
    .select('*')
    .eq('user_id', userId)
    .eq('content_type', 'lesson')
    .in_('content_id', lessonIds);
```

**Combined Response Structure** (Client-side merge):

```json
{
  "module": {
    "id": "uuid-1",
    "title_en": "Introduction to Python",
    "title_id": "Pengenalan Python",
    ...
  },
  "lessons": [
    {
      "id": "lesson-uuid-1",
      "title_en": "Your First Program",
      "title_id": "Program Pertama Anda",
      "order_index": 1,
      "xp_reward": 10,
      "is_completed": true,
      "progress": {
        "completed_at": "2025-10-30T14:20:00Z",
        "xp_earned": 10
      }
    },
    {
      "id": "lesson-uuid-2",
      "title_en": "Variables",
      "title_id": "Variabel",
      "order_index": 2,
      "xp_reward": 10,
      "is_completed": false,
      "progress": null
    }
  ]
}
```

---

## 3. Get Lesson Detail

**Purpose**: Fetch full lesson content including hints

**Client Query**:

```dart
// Get lesson
final lesson = await supabase
    .from('lessons')
    .select('*')
    .eq('id', lessonId)
    .single();

// Get hints for this lesson
final hints = await supabase
    .from('lesson_hints')
    .select('*')
    .eq('lesson_id', lessonId)
    .order('order_index', ascending: true);
```

**Response - Lesson** (200 OK):

```json
{
  "id": "lesson-uuid-1",
  "module_id": "module-uuid-1",
  "title_en": "Your First Python Program",
  "title_id": "Program Python Pertama Anda",
  "content_en": "# Welcome to Python!\n\nLet's print Hello World...",
  "content_id": "# Selamat datang di Python!\n\nMari cetak Hello World...",
  "code_template": "print(\"Hello, World!\")",
  "expected_output": "Hello, World!",
  "validation_type": "output",
  "validation_pattern": null,
  "order_index": 1,
  "xp_reward": 10,
  "estimated_duration_minutes": 5,
  "is_published": true,
  "created_at": "2025-10-31T10:00:00Z",
  "updated_at": "2025-10-31T10:00:00Z"
}
```

**Response - Hints**:

```json
[
  {
    "id": "hint-uuid-1",
    "lesson_id": "lesson-uuid-1",
    "hint_text_en": "Use the print() function with text in quotes.",
    "hint_text_id": "Gunakan fungsi print() dengan teks di dalam tanda kutip.",
    "order_index": 1,
    "created_at": "2025-10-31T10:00:00Z"
  }
]
```

---

## 4. Get Quizzes for Module

**Purpose**: Fetch quizzes associated with a module

**Client Query**:

```dart
final quizzes = await supabase
    .from('quizzes')
    .select('id, title_en, title_id, description_en, description_id, order_index, passing_score_percentage')
    .eq('module_id', moduleId)
    .eq('is_published', true)
    .order('order_index', ascending: true);

// Get user's quiz completion
final userId = supabase.auth.currentUser!.id;
final quizIds = quizzes.map((q) => q['id']).toList();
final quizProgress = await supabase
    .from('user_progress')
    .select('*')
    .eq('user_id', userId)
    .eq('content_type', 'quiz')
    .in_('content_id', quizIds);
```

**Response**:

```json
[
  {
    "id": "quiz-uuid-1",
    "title_en": "Python Basics Quiz",
    "title_id": "Kuis Dasar Python",
    "description_en": "Test your knowledge!",
    "description_id": "Uji pengetahuan Anda!",
    "order_index": 1,
    "passing_score_percentage": 70,
    "is_completed": false,
    "user_score": null
  }
]
```

---

## 5. Get Quiz with Questions

**Purpose**: Fetch quiz and all its questions for taking the quiz

**Client Query**:

```dart
// Get quiz details
final quiz = await supabase
    .from('quizzes')
    .select('*')
    .eq('id', quizId)
    .single();

// Get questions
final questions = await supabase
    .from('quiz_questions')
    .select('*')
    .eq('quiz_id', quizId)
    .order('order_index', ascending: true);
```

**Response - Quiz**:

```json
{
  "id": "quiz-uuid-1",
  "module_id": "module-uuid-1",
  "title_en": "Python Basics Quiz",
  "title_id": "Kuis Dasar Python",
  "description_en": "Test your knowledge of Python basics",
  "description_id": "Uji pengetahuan dasar Python Anda",
  "order_index": 1,
  "passing_score_percentage": 70,
  "xp_per_correct_answer": 5,
  "bonus_xp_for_perfect": 10,
  "is_published": true
}
```

**Response - Questions**:

```json
[
  {
    "id": "question-uuid-1",
    "quiz_id": "quiz-uuid-1",
    "question_text_en": "Which function displays output in Python?",
    "question_text_id": "Fungsi mana yang menampilkan output di Python?",
    "options_en": ["show()", "print()", "display()", "output()"],
    "options_id": ["show()", "print()", "display()", "output()"],
    "correct_answer_index": 1,
    "explanation_en": "print() is the correct function.",
    "explanation_id": "print() adalah fungsi yang benar.",
    "order_index": 1
  },
  {
    "id": "question-uuid-2",
    "quiz_id": "quiz-uuid-1",
    "question_text_en": "What symbol assigns a value to a variable?",
    "question_text_id": "Simbol apa yang memberikan nilai ke variabel?",
    "options_en": [":", "=", "==", "->"],
    "options_id": [":", "=", "==", "->"],
    "correct_answer_index": 1,
    "explanation_en": "= assigns values. == compares values.",
    "explanation_id": "= memberikan nilai. == membandingkan nilai.",
    "order_index": 2
  }
]
```

**Security Note**: Questions include `correct_answer_index`, but client should NOT rely on this for validation. Use server-side validation.

---

## 6. Search Lessons/Modules (Future Feature)

**Purpose**: Search content by keyword

**Client Query**:

```dart
final results = await supabase
    .from('lessons')
    .select('id, title_en, title_id, content_en, content_id')
    .or('title_en.ilike.%keyword%,content_en.ilike.%keyword%')
    .eq('is_published', true)
    .limit(20);
```

---

## Caching Strategy

### Client-Side Caching (Hive)

1. **Modules**: Cache for 24 hours, refresh on app start if stale
2. **Lessons**: Cache indefinitely (for offline access), update on explicit refresh
3. **Quizzes**: Do NOT cache questions (security), cache quiz metadata only
4. **Progress**: Sync queue for offline writes, refresh on app resume

**Hive Cache Keys**:

- `modules_cache` → List of modules
- `lesson_{lessonId}` → Individual lesson detail
- `hints_{lessonId}` → Hints for lesson

**Cache Invalidation**:

- User-triggered refresh (pull-to-refresh)
- Content version change (future feature)
- Manual cache clear from settings

---

## Error Handling

| Code | Error          | Description                        |
| ---- | -------------- | ---------------------------------- |
| 200  | Success        | Data retrieved                     |
| 400  | Bad request    | Invalid query parameters           |
| 401  | Unauthorized   | User not authenticated             |
| 403  | Forbidden      | User lacks permission (RLS policy) |
| 404  | Not found      | Resource doesn't exist             |
| 406  | Not acceptable | Invalid data format requested      |
| 500  | Server error   | Database or Supabase error         |

**Client Retry Strategy**:

- Network errors: Retry 3 times with exponential backoff
- 401 errors: Refresh session token, retry once
- 500 errors: Show error to user, don't retry (likely persistent issue)

---

## Performance Optimizations

1. **Pagination**: For large datasets (future), use `.range(start, end)`
2. **Select Specific Columns**: Use `.select('id, title_en')` instead of `.select('*')`
3. **Indexed Queries**: Database has indexes on frequently queried columns
4. **Connection Pooling**: Supabase handles connection pooling automatically
5. **CDN**: Supabase PostgREST is globally distributed

---

## Implementation Example

```dart
class ContentRepository {
  final SupabaseClient _client;

  ContentRepository(this._client);

  Future<List<Module>> getModules() async {
    try {
      final data = await _client
          .from('modules')
          .select('*')
          .eq('is_published', true)
          .order('order_index');

      return data.map((json) => Module.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<Lesson> getLessonDetail(String lessonId) async {
    try {
      final lessonData = await _client
          .from('lessons')
          .select('*')
          .eq('id', lessonId)
          .single();

      final hintsData = await _client
          .from('lesson_hints')
          .select('*')
          .eq('lesson_id', lessonId)
          .order('order_index');

      final lesson = Lesson.fromJson(lessonData);
      lesson.hints = hintsData.map((h) => Hint.fromJson(h)).toList();

      return lesson;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
```
