-- Codedly Mobile App - Database Functions
-- Version: 1.0.0
-- Created: 2025-10-31
-- Description: RPC functions for XP and streak management

-- ============================================================================
-- FUNCTION: Add XP to user and recalculate level
-- Formula: level = floor((-1 + sqrt(1 + 8*xp/100))/2) + 1
-- ============================================================================

CREATE OR REPLACE FUNCTION add_xp(
    user_id_param UUID,
    xp_to_add INTEGER
)
RETURNS void AS $$
DECLARE
    new_total_xp INTEGER;
    new_level INTEGER;
BEGIN
    -- Get current total XP and add new XP
    SELECT total_xp + xp_to_add INTO new_total_xp
    FROM user_stats
    WHERE user_id = user_id_param;

    -- Calculate new level based on XP formula
    -- level = floor((-1 + sqrt(1 + 8*xp/100))/2) + 1
    new_level := FLOOR((SQRT(1.0 + 8.0 * new_total_xp / 100.0) - 1.0) / 2.0) + 1;

    -- Update user stats
    UPDATE user_stats
    SET 
        total_xp = new_total_xp,
        current_level = new_level,
        updated_at = NOW()
    WHERE user_id = user_id_param;

    -- Log XP transaction (optional - for history)
    INSERT INTO xp_records (user_id, xp_amount, reason)
    VALUES (user_id_param, xp_to_add, 'XP earned');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION add_xp(UUID, INTEGER) TO authenticated;

-- ============================================================================
-- FUNCTION: Update user streak
-- Increments streak if activity is consecutive, resets if gap exists
-- ============================================================================

CREATE OR REPLACE FUNCTION update_streak(
    user_id_param UUID
)
RETURNS void AS $$
DECLARE
    current_last_activity DATE;
    current_streak INTEGER;
    days_since_activity INTEGER;
BEGIN
    -- Get current streak data
    SELECT last_activity_date, streak_count 
    INTO current_last_activity, current_streak
    FROM user_stats
    WHERE user_id = user_id_param;

    -- Calculate days since last activity
    IF current_last_activity IS NULL THEN
        days_since_activity := 999; -- First time user
    ELSE
        days_since_activity := CURRENT_DATE - current_last_activity;
    END IF;

    -- Update streak based on activity pattern
    IF days_since_activity = 0 THEN
        -- Same day activity - no change to streak
        RETURN;
    ELSIF days_since_activity = 1 THEN
        -- Consecutive day - increment streak
        UPDATE user_stats
        SET 
            streak_count = streak_count + 1,
            last_activity_date = CURRENT_DATE,
            updated_at = NOW()
        WHERE user_id = user_id_param;
    ELSE
        -- Gap in activity - reset streak to 1
        UPDATE user_stats
        SET 
            streak_count = 1,
            last_activity_date = CURRENT_DATE,
            updated_at = NOW()
        WHERE user_id = user_id_param;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION update_streak(UUID) TO authenticated;

-- ============================================================================
-- FUNCTION: Complete lesson and update stats
-- Combines XP addition and streak update in one transaction
-- ============================================================================

CREATE OR REPLACE FUNCTION complete_lesson(
    user_id_param UUID,
    lesson_id_param UUID,
    xp_earned INTEGER
)
RETURNS void AS $$
BEGIN
    -- Add XP
    PERFORM add_xp(user_id_param, xp_earned);

    -- Update streak
    PERFORM update_streak(user_id_param);

    -- Increment lessons completed counter
    UPDATE user_stats
    SET 
        lessons_completed = lessons_completed + 1,
        updated_at = NOW()
    WHERE user_id = user_id_param;

    -- Update or insert user progress
    INSERT INTO user_progress (
        user_id,
        content_type,
        content_id,
        is_completed,
        xp_earned,
        attempts_count,
        first_attempted_at,
        completed_at
    ) VALUES (
        user_id_param,
        'lesson',
        lesson_id_param,
        true,
        xp_earned,
        1,
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id, content_type, content_id) 
    DO UPDATE SET
        is_completed = true,
        xp_earned = GREATEST(user_progress.xp_earned, EXCLUDED.xp_earned),
        attempts_count = user_progress.attempts_count + 1,
        completed_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION complete_lesson(UUID, UUID, INTEGER) TO authenticated;

-- ============================================================================
-- FUNCTION: Complete quiz and update stats
-- Similar to complete_lesson but for quizzes
-- ============================================================================

CREATE OR REPLACE FUNCTION complete_quiz(
    user_id_param UUID,
    quiz_id_param UUID,
    score_percentage INTEGER,
    xp_earned INTEGER
)
RETURNS void AS $$
BEGIN
    -- Add XP
    PERFORM add_xp(user_id_param, xp_earned);

    -- Update streak
    PERFORM update_streak(user_id_param);

    -- Increment quizzes completed counter (only if passing score)
    IF score_percentage >= 70 THEN
        UPDATE user_stats
        SET 
            quizzes_completed = quizzes_completed + 1,
            updated_at = NOW()
        WHERE user_id = user_id_param;
    END IF;

    -- Update or insert user progress
    INSERT INTO user_progress (
        user_id,
        content_type,
        content_id,
        is_completed,
        score_percentage,
        xp_earned,
        attempts_count,
        first_attempted_at,
        completed_at
    ) VALUES (
        user_id_param,
        'quiz',
        quiz_id_param,
        score_percentage >= 70,
        score_percentage,
        xp_earned,
        1,
        NOW(),
        CASE WHEN score_percentage >= 70 THEN NOW() ELSE NULL END
    )
    ON CONFLICT (user_id, content_type, content_id) 
    DO UPDATE SET
        is_completed = EXCLUDED.score_percentage >= 70,
        score_percentage = GREATEST(user_progress.score_percentage, EXCLUDED.score_percentage),
        xp_earned = GREATEST(user_progress.xp_earned, EXCLUDED.xp_earned),
        attempts_count = user_progress.attempts_count + 1,
        completed_at = CASE WHEN EXCLUDED.score_percentage >= 70 THEN NOW() ELSE user_progress.completed_at END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION complete_quiz(UUID, UUID, INTEGER, INTEGER) TO authenticated;

-- ============================================================================
-- END OF FILE
-- ============================================================================
