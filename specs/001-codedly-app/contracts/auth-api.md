# Authentication API Contracts

**Service**: Supabase Auth  
**Base URL**: `https://[project-ref].supabase.co/auth/v1`  
**Client**: supabase_flutter package handles these automatically

## Overview

Authentication is managed by Supabase Auth. The Flutter app uses the `supabase_flutter` client which handles token management, session persistence, and API calls automatically.

---

## 1. Sign Up (Email/Password)

**Client Method**: `supabase.auth.signUp()`

**Request**:

```dart
final response = await supabase.auth.signUp(
  email: 'user@example.com',
  password: 'securePassword123',
  data: {
    'display_name': 'John Doe',
    'language_preference': 'en',
  },
);
```

**Response Success** (201 Created):

```json
{
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "created_at": "2025-10-31T12:00:00Z",
    "user_metadata": {
      "display_name": "John Doe",
      "language_preference": "en"
    }
  },
  "session": {
    "access_token": "jwt-token-here",
    "refresh_token": "refresh-token-here",
    "expires_in": 3600
  }
}
```

**Response Error** (400 Bad Request):

```json
{
  "error": "User already registered",
  "error_description": "A user with this email address has already been registered"
}
```

**Post-Signup Flow**:

1. Client receives user and session
2. Store session tokens securely (handled by supabase_flutter)
3. Create user_profile record in database (trigger or manual)
4. Navigate to onboarding screen

---

## 2. Sign In (Email/Password)

**Client Method**: `supabase.auth.signInWithPassword()`

**Request**:

```dart
final response = await supabase.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'securePassword123',
);
```

**Response Success** (200 OK):

```json
{
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "user_metadata": {
      "display_name": "John Doe"
    }
  },
  "session": {
    "access_token": "jwt-token-here",
    "refresh_token": "refresh-token-here",
    "expires_in": 3600
  }
}
```

**Response Error** (400 Bad Request):

```json
{
  "error": "Invalid login credentials",
  "error_description": "Invalid login credentials"
}
```

---

## 3. Sign In with Google (OAuth)

**Client Method**: `supabase.auth.signInWithOAuth()`

**Request**:

```dart
final response = await supabase.auth.signInWithOAuth(
  Provider.google,
  redirectTo: 'com.codedly.app://callback',
);
```

**Flow**:

1. Opens browser/webview with Google OAuth
2. User authenticates with Google
3. Redirects back to app with token
4. Supabase validates and creates session

**Response**: Same as Sign In success

---

## 4. Sign Out

**Client Method**: `supabase.auth.signOut()`

**Request**:

```dart
await supabase.auth.signOut();
```

**Response Success** (204 No Content)

**Side Effects**:

- Invalidates current session
- Clears stored tokens
- User must re-authenticate

---

## 5. Password Reset Request

**Client Method**: `supabase.auth.resetPasswordForEmail()`

**Request**:

```dart
await supabase.auth.resetPasswordForEmail(
  'user@example.com',
  redirectTo: 'com.codedly.app://reset-password',
);
```

**Response Success** (200 OK):

```json
{
  "message": "Check your email for the password reset link"
}
```

**Flow**:

1. User enters email
2. Supabase sends reset email
3. User clicks link in email
4. Redirects to app with reset token
5. User enters new password
6. App calls update password endpoint

---

## 6. Update Password

**Client Method**: `supabase.auth.updateUser()`

**Request**:

```dart
await supabase.auth.updateUser(
  UserAttributes(password: 'newSecurePassword456'),
);
```

**Response Success** (200 OK):

```json
{
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "updated_at": "2025-10-31T12:05:00Z"
  }
}
```

---

## 7. Get Current Session

**Client Method**: `supabase.auth.currentSession`

**Usage**:

```dart
final session = supabase.auth.currentSession;
if (session != null) {
  // User is logged in
  final userId = session.user.id;
  final accessToken = session.accessToken;
}
```

**Returns**: `Session?` (null if not authenticated)

---

## 8. Refresh Session (Automatic)

**Client Handling**: supabase_flutter automatically refreshes tokens before expiration

**Manual Refresh**:

```dart
final response = await supabase.auth.refreshSession();
```

---

## Error Codes

| Code | Error                   | Description                                      |
| ---- | ----------------------- | ------------------------------------------------ |
| 400  | Invalid credentials     | Wrong email or password                          |
| 400  | User already registered | Email already in use                             |
| 400  | Password too short      | Minimum 6 characters required (Supabase default) |
| 400  | Invalid email           | Email format validation failed                   |
| 401  | Unauthorized            | Invalid or expired token                         |
| 422  | Validation error        | Missing required fields                          |
| 429  | Too many requests       | Rate limit exceeded                              |
| 500  | Server error            | Internal Supabase error                          |

---

## Security Considerations

1. **Token Storage**: supabase_flutter uses secure storage (Keychain on iOS, EncryptedSharedPreferences on Android)
2. **Password Requirements**: Enforce minimum 8 characters client-side (Supabase default is 6)
3. **Rate Limiting**: Supabase has built-in rate limiting for auth endpoints
4. **RLS Policies**: All database queries automatically use authenticated user's ID via RLS
5. **No API Key in Code**: Use environment variables for Supabase keys

---

## Client Configuration

```dart
// Initialize Supabase client
await Supabase.initialize(
  url: 'https://[project-ref].supabase.co',
  anonKey: '[anon-key]',  // Public key, safe to commit
  authCallbackUrlHostname: 'callback',
  debug: false,
);

// Access client
final supabase = Supabase.instance.client;
```

---

## Auth State Listening

```dart
// Listen to auth state changes
supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  final event = data.event;

  if (event == AuthChangeEvent.signedIn) {
    // User signed in
  } else if (event == AuthChangeEvent.signedOut) {
    // User signed out
  } else if (event == AuthChangeEvent.tokenRefreshed) {
    // Token refreshed
  }
});
```

---

## Implementation Notes

1. **Automatic Session Management**: The package handles token refresh automatically
2. **Deep Linking**: Configure deep links for OAuth and password reset flows
3. **Error Handling**: Wrap auth calls in try-catch, show user-friendly messages
4. **Loading States**: Show spinner during async auth operations
5. **Profile Creation**: After signup, create user_profile record in database
