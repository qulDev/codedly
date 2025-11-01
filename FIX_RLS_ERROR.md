# 🔧 Fix RLS Policy Error - Quick Guide

## ❌ The Error You're Seeing:

```
PostgresException(message: new row violates row-level security policy for table 'user_profiles', code: 42501)
```

This happens during sign-up because Supabase's Row Level Security (RLS) is blocking the INSERT operation on the `user_profiles` table.

---

## ✅ Quick Fix (2 minutes):

### **Option 1: Run SQL Script (Recommended)**

1. **Open Supabase SQL Editor:**

   - Go to: https://app.supabase.com/project/pzezxtsyujkwhphghyyt/sql

2. **Create New Query:**

   - Click **"New query"**

3. **Copy & Paste:**

   - Open the file: `fix-rls-policies.sql` in your project
   - Copy all the SQL code
   - Paste into Supabase SQL Editor

4. **Run the Query:**

   - Click **"Run"** button (or press Ctrl+Enter)
   - You should see: "Success. No rows returned"

5. **Verify:**
   - Scroll down to see the verification query results
   - Should show policies like "Users can insert own profile"

### **Option 2: Manual Fix via Dashboard**

1. **Go to Table Editor:**

   - https://app.supabase.com/project/pzezxtsyujkwhphghyyt/editor

2. **Select `user_profiles` table**

3. **Click on "RLS" button** (top right)

4. **Add Policy:**

   - Click "+ New Policy"
   - Choose "For full customization"
   - Name: `Users can insert own profile`
   - Command: `INSERT`
   - WITH CHECK: `auth.uid() = id`
   - Click "Review" → "Save Policy"

5. **Repeat for other operations:**
   - SELECT policy: `auth.uid() = id`
   - UPDATE policy: `auth.uid() = id`

---

## 🧪 Test After Fixing:

1. **Refresh your web app** (http://localhost:8080)

2. **Try signing up again:**

   - Display Name: Remus
   - Email: mm.rizqullah@gmail.com
   - Password: godRemus123
   - Language: English

3. **Should succeed!** ✅
   - No more RLS error
   - Profile created in database
   - User logged in automatically
   - Redirects to onboarding

---

## 📊 What the Policies Do:

| Policy                        | Table         | Action | Rule                                   |
| ----------------------------- | ------------- | ------ | -------------------------------------- |
| Users can insert own profile  | user_profiles | INSERT | User can only create their own profile |
| Users can view own profile    | user_profiles | SELECT | User can only see their own profile    |
| Users can update own profile  | user_profiles | UPDATE | User can only edit their own profile   |
| Users can insert own stats    | user_stats    | INSERT | Auto-created with profile              |
| Users can view own stats      | user_stats    | SELECT | User sees their own stats              |
| Users can view own progress   | user_progress | SELECT | User sees their own lesson progress    |
| Users can insert own progress | user_progress | INSERT | User can mark lessons complete         |

---

## 🔍 Why This Happened:

When you ran the database schema migration earlier, it's possible that:

1. The RLS policies weren't applied
2. They were applied but got removed
3. There was a conflict with existing policies

The fix script **drops and recreates** all policies to ensure they're set up correctly.

---

## ✅ After Running the Fix:

Your sign-up flow will work:

1. User fills sign-up form
2. Supabase Auth creates user account ✅
3. App tries to INSERT into `user_profiles` ✅ (no longer blocked!)
4. RLS checks: `auth.uid() = id` ✅ (matches!)
5. Profile created successfully ✅
6. User redirected to onboarding ✅

---

## 🚨 If Still Not Working:

Check these:

1. **Verify RLS is enabled:**

   ```sql
   SELECT tablename, rowsecurity
   FROM pg_tables
   WHERE tablename = 'user_profiles';
   ```

   Should show: `rowsecurity = true`

2. **Verify policies exist:**

   ```sql
   SELECT * FROM pg_policies
   WHERE tablename = 'user_profiles';
   ```

   Should show 3 policies (SELECT, INSERT, UPDATE)

3. **Check auth.uid():**

   ```sql
   SELECT auth.uid();
   ```

   Should return your user ID when logged in

4. **Disable RLS temporarily (NOT for production!):**
   ```sql
   ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
   ```
   Only use this for testing, then re-enable:
   ```sql
   ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
   ```

---

## 📚 Learn More:

- [Supabase RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS Documentation](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)

---

**Created:** November 1, 2025  
**File:** `fix-rls-policies.sql`  
**Status:** Ready to run ✅
