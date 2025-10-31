# 🔐 Google Sign-In Setup Guide for Codedly

Complete guide to implement Google Sign-In authentication in your Codedly Flutter app using Supabase.

## 📋 Table of Contents

1. [Google Cloud Console Setup](#1-google-cloud-console-setup)
2. [Supabase Configuration](#2-supabase-configuration)
3. [Flutter App Configuration](#3-flutter-app-configuration)
4. [Testing](#4-testing)
5. [Troubleshooting](#5-troubleshooting)

---

## 1. 🌐 Google Cloud Console Setup

### Step 1.1: Create/Select Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **"Select a project"** → **"New Project"**
3. Enter project name: **"Codedly"**
4. Click **"Create"**
5. Wait for project creation and select it

### Step 1.2: Enable Required APIs

1. Navigate to **"APIs & Services"** → **"Library"**
2. Search for **"Google+ API"** (or "Google Identity")
3. Click **"Enable"**

### Step 1.3: Configure OAuth Consent Screen

1. Go to **"APIs & Services"** → **"OAuth consent screen"**
2. Select **"External"** user type → Click **"Create"**
3. Fill in required fields:
   - **App name:** Codedly
   - **User support email:** Your email
   - **Developer contact email:** Your email
4. Click **"Save and Continue"**
5. Skip **"Scopes"** section (click "Save and Continue")
6. Add test users if needed
7. Click **"Save and Continue"** → **"Back to Dashboard"**

### Step 1.4: Create OAuth 2.0 Credentials

#### For Web (Required for Supabase)

1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
3. Select **"Web application"**
4. Enter details:
   - **Name:** Codedly Web
   - **Authorized JavaScript origins:**
     ```
     https://pzezxtsyujkwhphghyyt.supabase.co
     ```
   - **Authorized redirect URIs:**
     ```
     https://pzezxtsyujkwhphghyyt.supabase.co/auth/v1/callback
     ```
5. Click **"CREATE"**
6. **IMPORTANT:** Copy the **Client ID** and **Client Secret** (you'll need these for Supabase)

#### For Android (Optional - for native app)

1. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. Select **"Android"**
3. Enter details:
   - **Name:** Codedly Android
   - **Package name:** `com.example.codedly` (check `android/app/src/main/AndroidManifest.xml`)
4. Get SHA-1 certificate fingerprint:

   ```bash
   # For debug builds
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

   # For release builds (if you have a release keystore)
   keytool -list -v -keystore /path/to/your-release-key.jks -alias your-key-alias
   ```

5. Paste the SHA-1 fingerprint
6. Click **"CREATE"**

#### For iOS (Optional - for native app)

1. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. Select **"iOS"**
3. Enter details:
   - **Name:** Codedly iOS
   - **Bundle ID:** `com.example.codedly` (check `ios/Runner/Info.plist`)
4. Click **"CREATE"**

---

## 2. ⚙️ Supabase Configuration

### Step 2.1: Enable Google Provider

1. Go to your [Supabase Dashboard](https://app.supabase.com/)
2. Select your **Codedly** project
3. Navigate to **Authentication** → **Providers**
4. Find **Google** in the list
5. Toggle **"Enable Sign in with Google"** to **ON** ✅

### Step 2.2: Add Credentials

1. In the Google provider settings:
   - **Client ID:** Paste the Client ID from Google Cloud Console (Web application)
   - **Client Secret:** Paste the Client Secret from Google Cloud Console
   - **Callback URL:** Should auto-populate as:
     ```
     https://pzezxtsyujkwhphghyyt.supabase.co/auth/v1/callback
     ```
2. Click **"Save"**

### Step 2.3: Verify Callback URL

Make sure the callback URL in Supabase matches what you entered in Google Cloud Console:

- Supabase shows: `https://pzezxtsyujkwhphghyyt.supabase.co/auth/v1/callback`
- Google Cloud Console redirect URI should match exactly

---

## 3. 📱 Flutter App Configuration

### Step 3.1: Dependencies (Already Added ✅)

Your `pubspec.yaml` already has all required dependencies:

```yaml
dependencies:
  supabase_flutter: ^2.5.6 # Includes OAuth support
  flutter_riverpod: ^2.5.1 # State management
```

### Step 3.2: Code Implementation (Already Done ✅)

The following files have been created/updated:

#### ✅ Use Case Created

- `lib/features/auth/domain/usecases/sign_in_with_google.dart`

#### ✅ Provider Updated

- `lib/features/auth/presentation/providers/auth_provider.dart`
  - Added `SignInWithGoogle` use case
  - Added `signInWithGoogle()` method

#### ✅ Sign-In Screen Updated

- `lib/features/auth/presentation/screens/sign_in_screen.dart`
  - Google button now calls `ref.read(authProvider.notifier).signInWithGoogle()`
  - Handles success/error states
  - Navigates to HomeScreen on success

#### ✅ Data Source Implementation

- `lib/features/auth/data/datasources/auth_remote_data_source.dart`
  - `signInWithGoogle()` method using `signInWithOAuth(OAuthProvider.google)`
  - Auto-creates user profile if doesn't exist
  - Fetches existing profile if user already signed in before

### Step 3.3: Platform-Specific Setup (Optional)

#### For Android Deep Linking (Optional)

If you want deep linking support, update `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    ...>

    <!-- Add this intent filter -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="https"
            android:host="pzezxtsyujkwhphghyyt.supabase.co"
            android:pathPrefix="/auth/v1/callback" />
    </intent-filter>
</activity>
```

#### For iOS Deep Linking (Optional)

Update `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.example.codedly</string>
        </array>
    </dict>
</array>
```

---

## 4. 🧪 Testing

### Test Flow

1. **Run your Flutter app:**

   ```bash
   flutter run
   ```

2. **Navigate to Sign-In Screen**

   - Open the app
   - Go to the sign-in page

3. **Click "Sign in with Google" button**

   - Should open browser/web view
   - Shows Google account selection
   - May show consent screen (first time)

4. **Select Google Account**

   - Choose your Google account
   - Grant permissions if asked

5. **Verify Redirect**
   - Should redirect back to app
   - Should create user profile in Supabase
   - Should navigate to HomeScreen

### Check Supabase Dashboard

1. Go to **Authentication** → **Users**
2. Verify new user appears with:

   - Email from Google account
   - Provider: `google`
   - Created timestamp

3. Go to **Table Editor** → **user_profiles**
4. Verify profile record created with:
   - User ID matching auth user
   - Email
   - Display name (from Google)
   - Language preference: `en`
   - `onboarding_completed`: `false`

---

## 5. 🔧 Troubleshooting

### Issue: "Google sign in failed"

**Possible Causes:**

1. **Incorrect Client ID/Secret in Supabase**

   - Solution: Double-check they match Google Cloud Console credentials

2. **Redirect URI mismatch**

   - Solution: Ensure Google Cloud Console redirect URI exactly matches:
     ```
     https://pzezxtsyujkwhphghyyt.supabase.co/auth/v1/callback
     ```

3. **Google+ API not enabled**
   - Solution: Enable "Google+ API" in Google Cloud Console → APIs & Services → Library

### Issue: "Access blocked: This app's request is invalid"

**Solution:**

- Configure OAuth consent screen in Google Cloud Console
- Add your email as a test user
- Ensure app is in "Testing" mode (can have up to 100 test users)

### Issue: User profile not created

**Solution:**
Check your Supabase database:

1. Verify `user_profiles` table exists
2. Check RLS (Row Level Security) policies allow INSERT
3. Check the `signInWithGoogle()` method in `auth_remote_data_source.dart`

### Issue: "Invalid redirect URI"

**Solution:**

1. Go to Google Cloud Console → Credentials
2. Edit your OAuth 2.0 Client ID
3. Add these URIs to "Authorized redirect URIs":
   ```
   https://pzezxtsyujkwhphghyyt.supabase.co/auth/v1/callback
   ```
4. Save and wait 5 minutes for changes to propagate

### Issue: App crashes after Google sign-in

**Solution:**

1. Check Flutter logs: `flutter logs`
2. Look for authentication errors
3. Verify Supabase URL and ANON_KEY in `.env` file
4. Ensure all dependencies are up to date: `flutter pub get`

---

## 📊 Sign-In Flow Diagram

```
User Clicks "Sign in with Google"
            ↓
Flutter calls authProvider.signInWithGoogle()
            ↓
Calls SignInWithGoogle use case
            ↓
Calls AuthRepository.signInWithGoogle()
            ↓
Calls AuthRemoteDataSource.signInWithGoogle()
            ↓
Supabase.auth.signInWithOAuth(OAuthProvider.google)
            ↓
Opens browser with Google consent
            ↓
User selects account & grants permission
            ↓
Google redirects to: https://pzezxtsyujkwhphghyyt.supabase.co/auth/v1/callback
            ↓
Supabase processes OAuth response
            ↓
Creates/updates auth user
            ↓
App fetches/creates user_profile
            ↓
Returns UserModel to app
            ↓
Updates AuthState to authenticated
            ↓
Navigates to HomeScreen
```

---

## 🎯 Quick Checklist

- [ ] Google Cloud project created
- [ ] Google+ API enabled
- [ ] OAuth consent screen configured
- [ ] Web OAuth Client ID created
- [ ] Client ID & Secret copied
- [ ] Supabase Google provider enabled
- [ ] Client ID & Secret pasted in Supabase
- [ ] Redirect URIs match in both platforms
- [ ] Flutter code updated (✅ Already done)
- [ ] Code generation run (✅ Already done)
- [ ] App tested with Google sign-in
- [ ] User profile created in database

---

## 📚 Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)

---

## ✅ What's Already Implemented

Your app already has:

1. ✅ Complete Google Sign-In code implementation
2. ✅ Use case: `SignInWithGoogle`
3. ✅ Provider method: `authProvider.signInWithGoogle()`
4. ✅ UI button connected in `sign_in_screen.dart`
5. ✅ Error handling and loading states
6. ✅ Automatic user profile creation
7. ✅ Navigation to HomeScreen after success

**You only need to configure Google Cloud Console and Supabase!**

---

Generated: October 31, 2025
Last Updated: October 31, 2025
