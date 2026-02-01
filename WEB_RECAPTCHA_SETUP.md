# Web reCAPTCHA Enterprise Setup

## Issue
When logging in with phone number on the web app, you may see errors like:
- "Failed to initialize reCAPTCHA Enterprise config"
- "Failed to load resource: identitytoolkit.googleapis.com" (400 errors)

## Solution
Enable reCAPTCHA Enterprise in Firebase Console for phone authentication on web.

## Steps to Fix

### 1. Enable reCAPTCHA Enterprise in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **sant-narhari-sonar**
3. Navigate to **Authentication** → **Settings** → **reCAPTCHA Enterprise**
4. Click **Enable reCAPTCHA Enterprise**
5. Follow the setup wizard:
   - Accept the terms
   - Select your project (sant-narhari-sonar)
   - Choose the reCAPTCHA type (reCAPTCHA Enterprise is recommended)
6. Save the configuration

### 2. Authorize Your Domain

1. In Firebase Console → **Authentication** → **Settings** → **Authorized domains**
2. Make sure your web domain is listed:
   - `sonarcommunity.com` (your production domain)
   - `localhost` (for local development)
   - `sant-narhari-sonar.web.app` (Firebase Hosting domain)
   - `sant-narhari-sonar.firebaseapp.com` (Firebase Hosting domain)

### 3. Verify Phone Authentication Settings

1. Go to **Authentication** → **Sign-in method**
2. Click on **Phone**
3. Ensure it's **Enabled**
4. Check that **reCAPTCHA Enterprise** is selected (not reCAPTCHA v2)

### 4. Test the Fix

1. Rebuild your web app:
   ```bash
   flutter build web
   ```

2. Deploy to Firebase Hosting:
   ```bash
   firebase deploy --only hosting
   ```

3. Test phone login on your web app:
   - Go to `sonarcommunity.com` or your deployed URL
   - Try logging in with a phone number
   - The reCAPTCHA should appear automatically
   - Complete the reCAPTCHA verification
   - OTP should be sent successfully

## Troubleshooting

### If reCAPTCHA still doesn't work:

1. **Check Browser Console**: Look for any remaining errors
2. **Verify Domain**: Ensure your domain is authorized in Firebase Console
3. **Check API Keys**: Verify that your Firebase web config (`firebase_options.dart`) has the correct API key
4. **Clear Browser Cache**: Clear your browser cache and try again
5. **Check Firebase Console Logs**: Look for any errors in Firebase Console → Authentication → Usage

### Common Issues:

- **400 Error from identitytoolkit.googleapis.com**: Usually means reCAPTCHA Enterprise is not enabled
- **reCAPTCHA not showing**: Check that the container div exists in `web/index.html` (it should be there)
- **Domain not authorized**: Add your domain to authorized domains list

## Notes

- The reCAPTCHA container is already configured in `web/index.html` with id `recaptcha-container`
- The code automatically handles reCAPTCHA on web - no additional code changes needed
- reCAPTCHA Enterprise is free for up to 1 million assessments per month
- For mobile apps (Android/iOS), reCAPTCHA is not required - Firebase uses Play Integrity (Android) or App Attest (iOS)

## Additional Resources

- [Firebase Phone Auth Documentation](https://firebase.google.com/docs/auth/web/phone-auth)
- [reCAPTCHA Enterprise Setup](https://firebase.google.com/docs/auth/web/phone-auth#recaptcha-enterprise)
