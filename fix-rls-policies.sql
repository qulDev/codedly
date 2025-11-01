-- Fix RLS Policies for Codedly App
-- This script fixes the Row Level Security policies that are blocking sign-up
-- Run this in Supabase SQL Editor: https://app.supabase.com/project/pzezxtsyujkwhphghyyt/sql

-- ============================================================================
-- DROP EXISTING POLICIES (if any conflicts)
-- ============================================================================

DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;

DROP POLICY IF EXISTS "Users can view own stats" ON user_stats;
DROP POLICY IF EXISTS "Users can update own stats" ON user_stats;
DROP POLICY IF EXISTS "Users can insert own stats" ON user_stats;

DROP POLICY IF EXISTS "Users can view own progress" ON user_progress;
DROP POLICY IF EXISTS "Users can insert own progress" ON user_progress;
DROP POLICY IF EXISTS "Users can update own progress" ON user_progress;

DROP POLICY IF EXISTS "Users can view own XP records" ON xp_records;
DROP POLICY IF EXISTS "Users can insert own XP records" ON xp_records;

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_records ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- USER_PROFILES POLICIES
-- ============================================================================

-- Allow users to view their own profile
CREATE POLICY "Users can view own profile"
    ON user_profiles FOR SELECT
    USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE
    USING (auth.uid() = id);

-- Allow users to insert their own profile (CRITICAL for sign-up!)
CREATE POLICY "Users can insert own profile"
    ON user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================================================
-- USER_STATS POLICIES
-- ============================================================================

-- Allow users to view their own stats
CREATE POLICY "Users can view own stats"
    ON user_stats FOR SELECT
    USING (auth.uid() = user_id);

-- Allow users to update their own stats (via triggers mostly)
CREATE POLICY "Users can update own stats"
    ON user_stats FOR UPDATE
    USING (auth.uid() = user_id);

-- Allow users to insert their own stats (during profile creation)
CREATE POLICY "Users can insert own stats"
    ON user_stats FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- USER_PROGRESS POLICIES
-- ============================================================================

-- Allow users to view their own progress
CREATE POLICY "Users can view own progress"
    ON user_progress FOR SELECT
    USING (auth.uid() = user_id);

-- Allow users to insert their own progress
CREATE POLICY "Users can insert own progress"
    ON user_progress FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own progress
CREATE POLICY "Users can update own progress"
    ON user_progress FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================================================
-- XP_RECORDS POLICIES
-- ============================================================================

-- Allow users to view their own XP records
CREATE POLICY "Users can view own XP records"
    ON xp_records FOR SELECT
    USING (auth.uid() = user_id);

-- Allow users to insert their own XP records (via triggers/functions)
CREATE POLICY "Users can insert own XP records"
    ON xp_records FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check if policies were created successfully
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename IN ('user_profiles', 'user_stats', 'user_progress', 'xp_records')
ORDER BY tablename, policyname;
