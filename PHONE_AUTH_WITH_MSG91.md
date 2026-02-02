# Phone Authentication with MSG91 OTP

## Current Implementation

Your app now uses **MSG91 for OTP verification** + **Firebase Anonymous Authentication** instead of email/password.

### How it works:

1. **User enters phone number** → MSG91 sends OTP
2. **User enters OTP** → MSG91 verifies it
3. **After successful OTP verification** → App signs in with Firebase Anonymous Auth
4. **Phone number is stored** in Firestore user profile for identification

### Benefits:

✅ No fake email/password required  
✅ True phone-based authentication  
✅ Works on both web and mobile  
✅ No Firebase Phone Auth complexity (reCAPTCHA on web)  
✅ No API key issues  

## Required Setup in Firebase Console

### 1. Enable Anonymous Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **sant-narhari-sonar**
3. Go to **Authentication** → **Sign-in method**
4. Enable **Anonymous** sign-in method
5. Click **Save**

### 2. Firestore Rules (Already Configured)

Your `firestore.rules` already allows anonymous authenticated users to:
- Create their own user document
- Read their own data
- Update their profile

## Code Changes Made

### 1. `phone_otp_screen.dart`
- Removed fake email/password authentication
- Now uses `FirebaseAuthService.instance.signInAnonymously()` after OTP verification
- Checks if user exists by phone number before creating new profile

### 2. `firebase_auth_service.dart`
- Added `signInAnonymously()` method

### 3. `firestore_service.dart`
- Added `getUserByPhone()` method to check existing users

## User Flow

```
User Enters Phone (919876543210)
           ↓
    MSG91 Sends OTP
           ↓
   User Enters OTP (1234)
           ↓
    MSG91 Verifies OTP ✓
           ↓
Firebase Anonymous Sign-in
           ↓
Store Phone in Firestore
           ↓
    User Logged In! 🎉
```

## Testing

1. **Enable Anonymous Auth** in Firebase Console (see above)
2. Run the app: `flutter run -d chrome --web-renderer html`
3. Enter a valid Indian phone number
4. Enter the OTP received
5. You should be logged in successfully without any API key errors

## Notes

- Each user gets a unique Firebase UID even though they sign in anonymously
- The phone number in Firestore identifies the user
- For returning users, the app checks if phone exists and links to the same profile
- This approach is simpler than Firebase Phone Auth on web (which requires reCAPTCHA setup)
