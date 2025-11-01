-- MINIMAL FIX for RLS Error - Codedly App
-- Run this in Supabase SQL Editor ONLY
-- URL: https://app.supabase.com/project/pzezxtsyujkwhphghyyt/sql

-- Step 1: Check if policies exist
SELECT tablename, policyname 
FROM pg_policies 
WHERE tablename = 'user_profiles';

-- Step 2: Drop ALL existing policies on user_profiles
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT policyname FROM pg_policies WHERE tablename = 'user_profiles'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON user_profiles', r.policyname);
    END LOOP;
END $$;

-- Step 3: Create fresh policies
CREATE POLICY "Users can insert own profile"
    ON user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view own profile"
    ON user_profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE
    USING (auth.uid() = id);

-- Step 4: Verify policies were created
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename = 'user_profiles'
ORDER BY cmd;

-- Step 5: Fix user_stats policies too
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT policyname FROM pg_policies WHERE tablename = 'user_stats'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON user_stats', r.policyname);
    END LOOP;
END $$;

CREATE POLICY "Users can insert own stats"
    ON user_stats FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own stats"
    ON user_stats FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own stats"
    ON user_stats FOR UPDATE
    USING (auth.uid() = user_id);

-- Final verification
SELECT 'SUCCESS! Policies created:' as status;
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('user_profiles', 'user_stats')
ORDER BY tablename, cmd;
