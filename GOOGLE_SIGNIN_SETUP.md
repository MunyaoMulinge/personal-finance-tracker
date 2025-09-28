# Google Sign-In Setup for Supabase

## Issue
Google Sign-In shows the email selection but doesn't complete the authentication with Supabase.

## Root Cause
Supabase needs to be configured with Google OAuth credentials for the Google Sign-In to work properly.

## Solution Steps

### 1. Configure Google OAuth in Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to Authentication > Providers
3. Enable Google provider
4. Add your Google OAuth credentials:
   - Client ID
   - Client Secret

### 2. Get Google OAuth Credentials
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Google+ API
4. Go to Credentials > Create Credentials > OAuth 2.0 Client IDs
5. Configure OAuth consent screen
6. Create credentials for:
   - Android app (using SHA-1 fingerprint)
   - Web app (for Supabase callback)

### 3. Configure Redirect URLs
In Google OAuth settings, add these redirect URLs:
- `https://your-project-ref.supabase.co/auth/v1/callback`
- For development: `http://localhost:3000/auth/v1/callback`

### 4. Update Android Configuration
Add to `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        resValue "string", "default_web_client_id", "YOUR_GOOGLE_CLIENT_ID"
    }
}
```

### 5. Test the Integration
Once configured, the Google Sign-In should:
1. Show Google account picker
2. Complete authentication with Supabase
3. Create user session in the app

## Current Status
- ✅ Google Sign-In UI implemented
- ✅ Google authentication flow coded
- ❌ Supabase Google OAuth configuration needed
- ❌ Google Cloud Console setup required

## Next Steps
1. Set up Google Cloud Console project
2. Configure Supabase Google provider
3. Test the complete flow
