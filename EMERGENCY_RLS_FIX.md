# 🚨 EMERGENCY RLS FIX - Step by Step

You're still getting the error, which means the policies weren't applied correctly. Follow these exact steps:

---

## 📋 **STEP 1: Go to Supabase SQL Editor**

1. Open this URL in your browser:

   ```
   https://app.supabase.com/project/pzezxtsyujkwhphghyyt/sql
   ```

2. You should see the SQL Editor interface

---

## 📋 **STEP 2: Run This EXACT SQL**

Copy and paste this ENTIRE block (click "Copy" below):

```sql
-- Delete ALL existing policies first
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;

-- Make sure RLS is enabled
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create the INSERT policy (THIS IS CRITICAL!)
CREATE POLICY "Users can insert own profile"
    ON user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Create the SELECT policy
CREATE POLICY "Users can view own profile"
    ON user_profiles FOR SELECT
    USING (auth.uid() = id);

-- Create the UPDATE policy
CREATE POLICY "Users can update own profile"
    ON user_profiles FOR UPDATE
    USING (auth.uid() = id);

-- Verify it worked
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'user_profiles';
```

3. **Paste it in the SQL Editor**
4. **Click "RUN"** button (or press Ctrl+Enter)
5. **Check the results** - should show 3 policies (INSERT, SELECT, UPDATE)

---

## 📋 **STEP 3: Fix user_stats Table Too**

After step 2 succeeds, run this:

```sql
-- Fix user_stats policies
DROP POLICY IF EXISTS "Users can insert own stats" ON user_stats;
DROP POLICY IF EXISTS "Users can view own stats" ON user_stats;
DROP POLICY IF EXISTS "Users can update own stats" ON user_stats;

ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own stats"
    ON user_stats FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own stats"
    ON user_stats FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own stats"
    ON user_stats FOR UPDATE
    USING (auth.uid() = user_id);

-- Verify
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'user_stats';
```

---

## 📋 **STEP 4: Test Sign Up**

1. **Refresh your web app**: http://localhost:8080
2. **Try a NEW email** (not the one you tried before):
   - Display Name: TestUser
   - Email: test@example.com
   - Password: Test123!
   - Language: English
3. **Click Sign Up**

Should work now! ✅

---

## ❓ **If STILL Getting Error:**

### Check #1: Is RLS Enabled?

Run this:

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'user_profiles';
```

Should show: `rowsecurity = true`

### Check #2: Do Policies Exist?

Run this:

```sql
SELECT * FROM pg_policies WHERE tablename = 'user_profiles';
```

Should show 3 rows (INSERT, SELECT, UPDATE)

### Check #3: Test Policy Manually

Run this (replace YOUR_USER_ID with actual UUID):

```sql
-- This simulates what happens during sign-up
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims.sub = 'YOUR_USER_ID';

INSERT INTO user_profiles (id, email, display_name, language_preference)
VALUES ('YOUR_USER_ID', 'test@test.com', 'Test', 'en');
```

---

## 🆘 **LAST RESORT: Temporarily Disable RLS**

⚠️ **WARNING: Only for testing! Re-enable after fixing!**

```sql
-- DISABLE RLS (allows all operations)
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats DISABLE ROW LEVEL SECURITY;
```

Try sign-up. If it works, the problem is definitely the policies.

Then RE-ENABLE:

```sql
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
```

And create the policies again from Step 2.

---

## 📸 **Screenshots to Help:**

After running the SQL in Step 2, you should see output like:

```
policyname                      | cmd
--------------------------------|--------
Users can insert own profile    | INSERT
Users can view own profile      | SELECT
Users can update own profile    | UPDATE
```

If you see this, the policies are correctly applied! ✅

---

## 🎯 **Quick Troubleshooting:**

| Error Message                           | Solution                          |
| --------------------------------------- | --------------------------------- |
| "relation user_profiles does not exist" | Run database-schema.sql first     |
| "policy already exists"                 | Use DROP POLICY IF EXISTS first   |
| "must be owner of table"                | You're not logged in as superuser |
| Still getting RLS error                 | Try the LAST RESORT option above  |

---

**Created:** November 1, 2025  
**Status:** Emergency fix for RLS blocking sign-up  
**Files:** MINIMAL_RLS_FIX.sql (use this one!)
