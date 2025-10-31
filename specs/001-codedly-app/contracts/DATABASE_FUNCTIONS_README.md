# Database Functions - Setup Instructions

## Overview

This file contains the SQL functions (RPC - Remote Procedure Calls) needed for XP and streak management in Codedly. These functions should be executed in your Supabase SQL Editor **after** running `database-schema.sql`.

## Prerequisites

✅ Supabase project created
✅ `database-schema.sql` already executed successfully
✅ All 9 tables exist (user_profiles, user_stats, modules, lessons, etc.)
✅ RLS policies enabled

## Installation Steps

### 1. Open Supabase SQL Editor

1. Log in to your Supabase dashboard
2. Select your Codedly project
3. Navigate to **SQL Editor** in the left sidebar
4. Click **New Query**

### 2. Execute the Functions

1. Copy the entire contents of `database-functions.sql`
2. Paste into the SQL Editor
3. Click **Run** or press `Ctrl/Cmd + Enter`
4. Wait for confirmation message: "Success. No rows returned"

### 3. Verify Installation

Run this query to check if functions exist:

```sql
SELECT
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('add_xp', 'update_streak', 'complete_lesson', 'complete_quiz');
```

You should see 4 rows:

- add_xp | FUNCTION
- update_streak | FUNCTION
- complete_lesson | FUNCTION
- complete_quiz | FUNCTION

## Function Details

### 1. `add_xp(user_id_param UUID, xp_to_add INTEGER)`

**Purpose:** Adds XP to user and recalculates level

**Formula:** `level = floor((-1 + sqrt(1 + 8*xp/100))/2) + 1`

**Usage in Dart:**

```dart
await supabase.rpc('add_xp', params: {
  'user_id_param': userId,
  'xp_to_add': 10,
});
```

**Example:**

- User has 0 XP, Level 1
- Call `add_xp(userId, 10)`
- Result: 10 XP, Level 1
- Call `add_xp(userId, 40)` (total 50 XP)
- Result: 50 XP, Level 2

---

### 2. `update_streak(user_id_param UUID)`

**Purpose:** Updates daily activity streak

**Logic:**

- Same day activity → No change
- Consecutive day (1 day gap) → Increment streak
- Gap > 1 day → Reset streak to 1

**Usage in Dart:**

```dart
await supabase.rpc('update_streak', params: {
  'user_id_param': userId,
});
```

**Example:**

- Day 1: First activity → streak = 1
- Day 2: Activity → streak = 2
- Day 3: Activity → streak = 3
- Day 5: Activity (gap) → streak = 1

---

### 3. `complete_lesson(user_id_param UUID, lesson_id_param UUID, xp_earned INTEGER)`

**Purpose:** Complete workflow for finishing a lesson

**What it does:**

1. Adds XP to user
2. Updates streak
3. Increments lessons_completed counter
4. Updates user_progress table

**Usage in Dart:**

```dart
await supabase.rpc('complete_lesson', params: {
  'user_id_param': userId,
  'lesson_id_param': lessonId,
  'xp_earned': 10,
});
```

**Example:**

- User completes "Your First Python Program" lesson
- Earns 10 XP
- Streak updates (if consecutive day)
- Progress saved to database

---

### 4. `complete_quiz(user_id_param UUID, quiz_id_param UUID, score_percentage INTEGER, xp_earned INTEGER)`

**Purpose:** Complete workflow for finishing a quiz

**What it does:**

1. Adds XP to user
2. Updates streak
3. Increments quizzes_completed counter (if score >= 70%)
4. Updates user_progress table with score

**Usage in Dart:**

```dart
await supabase.rpc('complete_quiz', params: {
  'user_id_param': userId,
  'quiz_id_param': quizId,
  'score_percentage': 80,
  'xp_earned': 15,
});
```

**Example:**

- User completes "Python Basics Quiz"
- Gets 80% score (passes - 70% threshold)
- Earns 15 XP (10 base + 5 bonus)
- Quiz marked as completed

---

## Testing the Functions

### Test 1: Add XP

```sql
-- Get a real user_id from your user_profiles table
SELECT id FROM user_profiles LIMIT 1;

-- Replace YOUR_USER_ID with actual UUID
SELECT add_xp('YOUR_USER_ID'::UUID, 25);

-- Check result
SELECT total_xp, current_level FROM user_stats WHERE user_id = 'YOUR_USER_ID'::UUID;
```

### Test 2: Update Streak

```sql
SELECT update_streak('YOUR_USER_ID'::UUID);

-- Check result
SELECT streak_count, last_activity_date FROM user_stats WHERE user_id = 'YOUR_USER_ID'::UUID;
```

### Test 3: Complete Lesson

```sql
-- Get a lesson ID
SELECT id FROM lessons LIMIT 1;

-- Replace IDs
SELECT complete_lesson(
  'YOUR_USER_ID'::UUID,
  'YOUR_LESSON_ID'::UUID,
  10
);

-- Check results
SELECT * FROM user_stats WHERE user_id = 'YOUR_USER_ID'::UUID;
SELECT * FROM user_progress WHERE user_id = 'YOUR_USER_ID'::UUID;
SELECT * FROM xp_records WHERE user_id = 'YOUR_USER_ID'::UUID ORDER BY created_at DESC;
```

## Security

All functions have:

- ✅ **SECURITY DEFINER** - Runs with creator privileges
- ✅ **GRANT EXECUTE TO authenticated** - Only authenticated users can call
- ✅ **RLS policies** - Data filtered by user_id automatically

## Troubleshooting

### Error: "function does not exist"

**Solution:** Re-run `database-functions.sql` in SQL Editor

### Error: "permission denied"

**Solution:** Check if you're authenticated. Functions only work for logged-in users.

### Functions run but no data changes

**Solution:**

1. Check if user_id exists in user_stats table
2. Verify RLS policies allow updates
3. Check if user_stats was auto-created when user registered

### How to drop/recreate functions

```sql
-- Drop all functions
DROP FUNCTION IF EXISTS add_xp(UUID, INTEGER);
DROP FUNCTION IF EXISTS update_streak(UUID);
DROP FUNCTION IF EXISTS complete_lesson(UUID, UUID, INTEGER);
DROP FUNCTION IF EXISTS complete_quiz(UUID, UUID, INTEGER, INTEGER);

-- Then re-run database-functions.sql
```

## Integration with Flutter App

The stats remote data source already calls these functions:

**File:** `lib/features/stats/data/datasources/stats_remote_data_source.dart`

```dart
// Add XP (lines 68-89)
Future<UserStatsModel> addXp(int xpToAdd) async {
  await _supabaseClient.rpc('add_xp', params: {
    'user_id_param': userId,
    'xp_to_add': xpToAdd,
  });
  return await getUserStats();
}

// Update Streak (lines 92-112)
Future<UserStatsModel> updateStreak() async {
  await _supabaseClient.rpc('update_streak', params: {
    'user_id_param': userId,
  });
  return await getUserStats();
}
```

## Next Steps

After setting up these functions:

1. ✅ Test each function in SQL Editor
2. ✅ Verify data updates in table views
3. ✅ Test from Flutter app (when lesson/quiz features are built)
4. ✅ Monitor xp_records table for transaction history

## Support

If you encounter issues:

1. Check Supabase logs (Logs → Postgres Logs)
2. Verify user authentication in app
3. Test functions directly in SQL Editor
4. Check RLS policies are enabled

---

**Last Updated:** October 31, 2025  
**Version:** 1.0.0  
**Status:** ✅ Ready for Production
