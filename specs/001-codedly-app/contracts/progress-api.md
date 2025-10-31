# Progress & XP API Contracts

**Service**: Supabase Database + Edge Functions  
**Base URL**: `https://[project-ref].supabase.co/rest/v1` (database), `/functions/v1` (edge functions)  
**Client**: supabase_flutter

## Overview

Progress tracking involves user_progress, xp_records, and user_stats tables. Most operations are INSERT/UPDATE with RLS policies ensuring users can only modify their own data.

---

## 1. Complete Lesson (Award XP)

**Purpose**: Mark lesson as complete, award XP, update stats

**Client Flow**:

1. Validate code completion (client + server)
2. Insert/update user_progress record
3. Insert xp_record
4. Update user_stats (total_xp, lessons_completed, current_level)

**Client Query** (Optimistic Update):

```dart
final userId = supabase.auth.currentUser!.id;
final now = DateTime.now().toIso8601String();

// 1. Upsert user_progress
await supabase.from('user_progress').upsert({
  'user_id': userId,
  'content_type': 'lesson',
  'content_id': lessonId,
  'is_completed': true,
  'xp_earned': xpAmount,  // e.g., 10
  'completed_at': now,
  'attempts_count': attemptCount,
}, onConflict: 'user_id,content_type,content_id');

// 2. Insert XP record
await supabase.from('xp_records').insert({
  'user_id': userId,
  'xp_amount': xpAmount,
  'reason': 'Completed Lesson: $lessonTitle',
  'content_type': 'lesson',
  'content_id': lessonId,
});

// 3. Update user stats (increment XP and lesson count)
final currentStats = await supabase
    .from('user_stats')
    .select('total_xp, lessons_completed')
    .eq('user_id', userId)
    .single();

final newTotalXp = currentStats['total_xp'] + xpAmount;
final newLevel = calculateLevel(newTotalXp);  // Client-side formula

await supabase.from('user_stats').update({
  'total_xp': newTotalXp,
  'current_level': newLevel,
  'lessons_completed': currentStats['lessons_completed'] + 1,
  'last_activity_date': DateTime.now().toIso8601String().split('T')[0],
}).eq('user_id', userId);
```

**Response Success**: (200 OK for updates, 201 Created for inserts)

**Server-Side Validation** (Edge Function - Optional):

```
POST /functions/v1/complete-lesson
Headers:
  Authorization: Bearer <jwt>
  Content-Type: application/json
Body:
{
  "lesson_id": "lesson-uuid-1",
  "user_code": "print('Hello, World!')",
  "validation_result": "correct"
}

Response:
{
  "success": true,
  "xp_awarded": 10,
  "new_total_xp": 110,
  "level_up": false,
  "new_level": 1
}
```

---

## 2. Complete Quiz (Award XP for Correct Answers)

**Purpose**: Submit quiz results, calculate score, award XP

**Client Flow**:

1. User completes all questions
2. Calculate score percentage
3. Calculate XP (correct answers × xp_per_correct + bonus if perfect)
4. Insert user_progress with score
5. Insert xp_record
6. Update user_stats

**Client Query**:

```dart
final userId = supabase.auth.currentUser!.id;
final correctAnswers = 8;  // out of 10
final totalQuestions = 10;
final scorePercentage = (correctAnswers / totalQuestions * 100).round();

// XP calculation
final xpPerCorrect = 5;
final bonusXpForPerfect = 10;
final xpEarned = (correctAnswers * xpPerCorrect) +
                 (scorePercentage == 100 ? bonusXpForPerfect : 0);

// 1. Upsert progress
await supabase.from('user_progress').upsert({
  'user_id': userId,
  'content_type': 'quiz',
  'content_id': quizId,
  'is_completed': true,
  'score_percentage': scorePercentage,
  'xp_earned': xpEarned,
  'completed_at': DateTime.now().toIso8601String(),
  'attempts_count': attemptCount,
}, onConflict: 'user_id,content_type,content_id');

// 2. Insert XP record
await supabase.from('xp_records').insert({
  'user_id': userId,
  'xp_amount': xpEarned,
  'reason': 'Quiz Score: $correctAnswers/$totalQuestions',
  'content_type': 'quiz',
  'content_id': quizId,
  'metadata': {
    'score_percentage': scorePercentage,
    'correct_answers': correctAnswers,
    'total_questions': totalQuestions,
  },
});

// 3. Update stats
// (same as lesson completion)
```

**Response Success**: (200/201)

---

## 3. Get User Progress Summary

**Purpose**: Fetch user's current stats for dashboard

**Client Query**:

```dart
final userId = supabase.auth.currentUser!.id;

final stats = await supabase
    .from('user_stats')
    .select('*')
    .eq('user_id', userId)
    .single();
```

**Response** (200 OK):

```json
{
  "user_id": "user-uuid-1",
  "total_xp": 250,
  "current_level": 3,
  "streak_count": 5,
  "last_activity_date": "2025-10-31",
  "lessons_completed": 25,
  "quizzes_completed": 3,
  "modules_completed": 2,
  "updated_at": "2025-10-31T14:30:00Z"
}
```

**Derived Calculations** (Client-side):

```dart
// XP needed for next level
int xpForLevel(int level) => 100 * level;

// Progress to next level
int xpForNextLevel = xpForLevel(stats.currentLevel + 1);
int xpInCurrentLevel = stats.totalXp - (50 * stats.currentLevel * (stats.currentLevel - 1));
double progressPercentage = (xpInCurrentLevel / xpForNextLevel) * 100;
```

---

## 4. Get User's Completed Content

**Purpose**: Fetch list of lessons/quizzes the user has completed

**Client Query**:

```dart
final userId = supabase.auth.currentUser!.id;

final completedLessons = await supabase
    .from('user_progress')
    .select('content_id, xp_earned, score_percentage, completed_at')
    .eq('user_id', userId)
    .eq('content_type', 'lesson')
    .eq('is_completed', true)
    .order('completed_at', ascending: false);

final completedQuizzes = await supabase
    .from('user_progress')
    .select('content_id, xp_earned, score_percentage, completed_at')
    .eq('user_id', userId)
    .eq('content_type', 'quiz')
    .eq('is_completed', true)
    .order('completed_at', ascending: false);
```

**Response**:

```json
[
  {
    "content_id": "lesson-uuid-1",
    "xp_earned": 10,
    "score_percentage": null,
    "completed_at": "2025-10-30T10:15:00Z"
  },
  {
    "content_id": "lesson-uuid-2",
    "xp_earned": 10,
    "score_percentage": null,
    "completed_at": "2025-10-30T11:30:00Z"
  }
]
```

---

## 5. Get XP History

**Purpose**: Fetch user's XP transaction history for visualizations

**Client Query**:

```dart
final userId = supabase.auth.currentUser!.id;

// Last 30 days
final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));

final xpHistory = await supabase
    .from('xp_records')
    .select('xp_amount, reason, content_type, created_at')
    .eq('user_id', userId)
    .gte('created_at', thirtyDaysAgo.toIso8601String())
    .order('created_at', ascending: false)
    .limit(100);
```

**Response**:

```json
[
  {
    "xp_amount": 10,
    "reason": "Completed Lesson: Variables in Python",
    "content_type": "lesson",
    "created_at": "2025-10-31T09:15:00Z"
  },
  {
    "xp_amount": 40,
    "reason": "Quiz Score: 8/10",
    "content_type": "quiz",
    "created_at": "2025-10-31T09:45:00Z"
  },
  {
    "xp_amount": 50,
    "reason": "7-Day Streak Bonus",
    "content_type": "bonus",
    "created_at": "2025-10-31T10:00:00Z"
  }
]
```

**Client Aggregation** (for daily XP chart):

```dart
Map<String, int> dailyXp = {};
for (var record in xpHistory) {
  String date = record['created_at'].split('T')[0];  // YYYY-MM-DD
  dailyXp[date] = (dailyXp[date] ?? 0) + record['xp_amount'];
}
```

---

## 6. Update Streak

**Purpose**: Increment or reset streak based on last activity date

**Logic** (Client-side):

```dart
final stats = await getUserStats();
final today = DateTime.now();
final lastActivity = DateTime.parse(stats.lastActivityDate);
final daysDifference = today.difference(lastActivity).inDays;

int newStreak;
if (daysDifference == 1) {
  // Consecutive day - increment
  newStreak = stats.streakCount + 1;
} else if (daysDifference == 0) {
  // Same day - no change
  newStreak = stats.streakCount;
} else {
  // Streak broken - reset to 1
  newStreak = 1;
}

await supabase.from('user_stats').update({
  'streak_count': newStreak,
  'last_activity_date': today.toIso8601String().split('T')[0],
}).eq('user_id', userId);

// Check for streak milestone bonus
if (newStreak % 7 == 0) {
  // Award bonus XP for 7-day streak
  await awardBonusXp(50, '$newStreak-Day Streak Bonus');
}
```

---

## 7. Award Bonus XP

**Purpose**: Give XP for special achievements (streaks, first lesson in module, etc.)

**Client Query**:

```dart
Future<void> awardBonusXp(int xpAmount, String reason) async {
  final userId = supabase.auth.currentUser!.id;

  // Insert XP record
  await supabase.from('xp_records').insert({
    'user_id': userId,
    'xp_amount': xpAmount,
    'reason': reason,
    'content_type': 'bonus',
    'content_id': null,
  });

  // Update total XP
  final stats = await getUserStats();
  final newTotalXp = stats.totalXp + xpAmount;
  final newLevel = calculateLevel(newTotalXp);

  await supabase.from('user_stats').update({
    'total_xp': newTotalXp,
    'current_level': newLevel,
  }).eq('user_id', userId);
}
```

**Bonus Triggers**:

- 7-day streak: +50 XP
- 30-day streak: +200 XP
- Complete first lesson in module: +20 XP
- Perfect quiz score (100%): +10 XP (already in quiz completion)

---

## 8. Offline Sync Queue

**Purpose**: Sync progress completed while offline

**Hive Queue Structure**:

```dart
class SyncQueueItem {
  String id;
  String type;  // 'lesson_complete', 'quiz_complete', 'bonus_xp'
  Map<String, dynamic> data;
  DateTime timestamp;
  int retryCount;
  bool isSynced;
}
```

**Sync Process**:

```dart
Future<void> syncQueue() async {
  final queue = await getSyncQueue();  // From Hive

  for (var item in queue.where((i) => !i.isSynced)) {
    try {
      if (item.type == 'lesson_complete') {
        await completeLessonOnServer(item.data);
      } else if (item.type == 'quiz_complete') {
        await completeQuizOnServer(item.data);
      }

      // Mark as synced
      item.isSynced = true;
      await saveQueueItem(item);

    } catch (e) {
      item.retryCount++;
      if (item.retryCount >= 3) {
        // Max retries reached, show error to user
        notifyUser('Some progress failed to sync');
      }
      await saveQueueItem(item);
    }
  }

  // Clean up synced items older than 7 days
  await cleanOldSyncedItems();
}
```

---

## Level Calculation Formula

**Formula**: `level = floor((-1 + sqrt(1 + 8 * total_xp / 100)) / 2) + 1`

**XP Required for Each Level**:

- Level 1 → 2: 100 XP (total: 100)
- Level 2 → 3: 200 XP (total: 300)
- Level 3 → 4: 300 XP (total: 600)
- Level 4 → 5: 400 XP (total: 1000)
- Level 5 → 6: 500 XP (total: 1500)

**Client Implementation**:

```dart
int calculateLevel(int totalXp) {
  return ((sqrt(1 + 8 * totalXp / 100) - 1) / 2).floor() + 1;
}

int xpForLevel(int level) {
  return 100 * level;
}

int totalXpForLevel(int level) {
  return 50 * level * (level + 1);
}
```

---

## Error Handling

| Code    | Error        | Description                                        |
| ------- | ------------ | -------------------------------------------------- |
| 200/201 | Success      | Progress recorded                                  |
| 400     | Bad request  | Invalid data (e.g., negative XP)                   |
| 401     | Unauthorized | User not authenticated                             |
| 403     | Forbidden    | Attempting to modify another user's progress (RLS) |
| 409     | Conflict     | Duplicate completion attempt                       |
| 500     | Server error | Database error                                     |

**Client Strategy**:

- 409 errors: Treat as success (already completed)
- 500 errors: Queue for offline sync
- 401 errors: Refresh token, retry

---

## Performance Considerations

1. **Batch Updates**: If multiple lessons completed quickly, batch XP updates
2. **Optimistic UI**: Show XP/level immediately, sync in background
3. **Denormalized Stats**: user_stats table avoids expensive aggregations
4. **Indexed Queries**: All progress queries use indexed columns
5. **Connection Pooling**: Supabase handles pooling

---

## Security Notes

1. **RLS Policies**: Users can ONLY modify their own progress
2. **Server Validation**: Critical operations (XP award) should validate on server
3. **XP Tampering**: Consider server-side XP calculation for high-stakes scenarios
4. **Rate Limiting**: Supabase has built-in rate limiting
5. **Audit Trail**: xp_records table provides immutable audit log
