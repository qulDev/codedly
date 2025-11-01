-- ULTIMATE RLS FIX - Copy and paste this ENTIRE block into Supabase SQL Editor
-- URL: https://app.supabase.com/project/pzezxtsyujkwhphghyyt/sql

-- ============================================================================
-- STEP 1: Clean slate - remove all existing policies
-- ============================================================================

DO $$ 
BEGIN
    -- Drop user_profiles policies
    DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
    DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
    DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
    
    -- Drop user_stats policies
    DROP POLICY IF EXISTS "Users can insert own stats" ON user_stats;
    DROP POLICY IF EXISTS "Users can view own stats" ON user_stats;
    DROP POLICY IF EXISTS "Users can update own stats" ON user_stats;
    
    RAISE NOTICE 'Old policies dropped successfully';
END $$;

-- ============================================================================
-- STEP 2: Ensure RLS is enabled
-- ============================================================================

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 3: Create new policies for user_profiles
-- ============================================================================

-- Allow users to INSERT their own profile
CREATE POLICY "Users can insert own profile"
    ON user_profiles 
    FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- Allow users to SELECT their own profile
CREATE POLICY "Users can view own profile"
    ON user_profiles 
    FOR SELECT 
    USING (auth.uid() = id);

-- Allow users to UPDATE their own profile
CREATE POLICY "Users can update own profile"
    ON user_profiles 
    FOR UPDATE 
    USING (auth.uid() = id);

-- ============================================================================
-- STEP 4: Create new policies for user_stats
-- ============================================================================

-- Allow users to INSERT their own stats
CREATE POLICY "Users can insert own stats"
    ON user_stats 
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- Allow users to SELECT their own stats
CREATE POLICY "Users can view own stats"
    ON user_stats 
    FOR SELECT 
    USING (auth.uid() = user_id);

-- Allow users to UPDATE their own stats
CREATE POLICY "Users can update own stats"
    ON user_stats 
    FOR UPDATE 
    USING (auth.uid() = user_id);

-- ============================================================================
-- STEP 5: Verification - Check if policies were created
-- ============================================================================

SELECT 
    '✅ POLICIES CREATED SUCCESSFULLY!' as status,
    tablename,
    policyname,
    cmd as operation
FROM pg_policies 
WHERE tablename IN ('user_profiles', 'user_stats')
ORDER BY tablename, cmd;

-- ============================================================================
-- Expected Output: Should show 6 policies total
-- - user_profiles: INSERT, SELECT, UPDATE (3 policies)
-- - user_stats: INSERT, SELECT, UPDATE (3 policies)
-- ============================================================================
