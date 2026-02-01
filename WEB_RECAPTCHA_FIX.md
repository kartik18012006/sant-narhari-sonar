# Web reCAPTCHA Verification Fix - Complete Guide

## 🔴 Critical Issues Found

Based on your screenshots and error logs:

1. **400 Bad Request errors** from `identitytoolkit.googleapis.com`
2. **reCAPTCHA Enterprise initialization failures**
3. **Site keys showing "Assessment count: 0"** (not being used)
4. **Domain verification disabled** on some keys

## ✅ Code Fixes Applied

### 1. Updated Firebase JS SDK
- **Changed**: `11.0.0` → `11.1.0` (latest stable)
- **File**: `web/index.html`
- **Why**: Better reCAPTCHA Enterprise support and bug fixes

### 2. Improved reCAPTCHA Container
- **Changed**: Made container invisible but present (1px x 1px, hidden)
- **File**: `web/index.html`
- **Why**: Firebase needs the container but it shouldn't be visible to users

## 🔧 Firebase Console Configuration (REQUIRED)

### Step 1: Verify reCAPTCHA Enterprise is Enabled

1. Go to Firebase Console → **Authentication** → **Settings** → **reCAPTCHA**
2. Verify **reCAPTCHA Enterprise** is enabled
3. If not enabled, click **"Manage reCAPTCHA"** and enable it

### Step 2: Configure Site Keys for Web

**CRITICAL**: The site keys showing "Assessment count: 0" need to be properly configured.

1. In Firebase Console → **Authentication** → **Settings** → **reCAPTCHA**
2. Click **"Configure site keys"** button
3. For **Web** platform:
   - Click **"Add"** or **"Configure"** for Web
   - **Domain verification**: Ensure your domains are verified:
     - `sonarcommunity.com`
     - `www.sonarcommunity.com`
     - `localhost` (for development)
     - `sant-narhari-sonar.web.app`
     - `sant-narhari-sonar.firebaseapp.com`
   - If domain verification is disabled, click **"Enable domain verification"**
   - Save the configuration

### Step 3: Verify Authorized Domains

1. Firebase Console → **Authentication** → **Settings** → **Authorized domains**
2. Ensure these domains are listed:
   - ✅ `localhost`
   - ✅ `sonarcommunity.com`
   - ✅ `www.sonarcommunity.com`
   - ✅ `sant-narhari-sonar.web.app`
   - ✅ `sant-narhari-sonar.firebaseapp.com`

### Step 4: Check API Key Restrictions

1. Go to Google Cloud Console → **APIs & Services** → **Credentials**
2. Find your web API key: `AIzaSyA66p2GptE2Qz9vFi40VAKNYOxoaH08GwA`
3. Click on the key to edit
4. Under **"Application restrictions"**:
   - Select **"HTTP referrers (web sites)"**
   - Add these referrers:
     - `https://sonarcommunity.com/*`
     - `https://www.sonarcommunity.com/*`
     - `http://localhost:*` (for development)
     - `https://sant-narhari-sonar.web.app/*`
     - `https://sant-narhari-sonar.firebaseapp.com/*`
5. Under **"API restrictions"**:
   - Select **"Restrict key"**
   - Ensure these APIs are enabled:
     - Identity Toolkit API
     - Firebase Authentication API
6. **Save** the key

### Step 5: Verify Phone Authentication Settings

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click on **Phone**
3. Ensure **Phone** is **Enabled**
4. Check that **reCAPTCHA Enterprise** is selected (not reCAPTCHA v2)
5. **SMS fraud risk threshold**: Set to "Block none (1)" for testing, or adjust as needed

## 🧪 Testing Steps

### 1. Rebuild Web App

```bash
flutter clean
flutter build web
```

### 2. Test Locally

```bash
# Serve the build
cd build/web
python3 -m http.server 8080

# Open http://localhost:8080
# Try phone login
```

### 3. Test on Production

```bash
# Deploy to Firebase Hosting
firebase deploy --only hosting

# Or deploy to your custom domain
# Then test on https://sonarcommunity.com
```

### 4. Check Browser Console

- Open Chrome DevTools → Console
- Look for reCAPTCHA errors
- Should see: "reCAPTCHA Enterprise initialized" (no errors)
- Should NOT see: "Failed to initialize reCAPTCHA Enterprise config"

## 🔍 Troubleshooting

### Error: "Failed to initialize reCAPTCHA Enterprise config"

**Causes**:
- Domain verification disabled on site key
- API key restrictions too strict
- Site key not properly linked in Firebase Console

**Solutions**:
1. Enable domain verification in Firebase Console → Authentication → Settings → reCAPTCHA
2. Check API key restrictions in Google Cloud Console
3. Verify site keys are configured for Web platform

### Error: "400 Bad Request" from identitytoolkit.googleapis.com

**Causes**:
- API key not authorized for Identity Toolkit API
- Domain not authorized in Firebase Console
- reCAPTCHA site key misconfiguration

**Solutions**:
1. Enable Identity Toolkit API in Google Cloud Console
2. Add domain to Authorized domains in Firebase Console
3. Reconfigure reCAPTCHA site keys

### Error: "Assessment count: 0" on site keys

**Meaning**: The site keys exist but aren't being used

**Solutions**:
1. Verify domain verification is enabled
2. Ensure domains match exactly (including www)
3. Rebuild and redeploy web app
4. Clear browser cache and test again

## ✅ Verification Checklist

- [ ] Firebase JS SDK updated to 11.1.0+
- [ ] reCAPTCHA container present in `web/index.html`
- [ ] reCAPTCHA Enterprise enabled in Firebase Console
- [ ] Site keys configured for Web platform
- [ ] Domain verification enabled on site keys
- [ ] All domains added to Authorized domains
- [ ] API key restrictions configured correctly
- [ ] Phone Authentication enabled
- [ ] Web app rebuilt and deployed
- [ ] Tested on localhost (no errors)
- [ ] Tested on production domain (no errors)

## 📝 Summary

**Code Changes**:
- ✅ Updated Firebase JS SDK to 11.1.0
- ✅ Improved reCAPTCHA container configuration

**Firebase Console Actions Required**:
1. ✅ Enable domain verification on reCAPTCHA site keys
2. ✅ Configure API key restrictions properly
3. ✅ Verify all domains are authorized

**After Fixes**:
- Rebuild: `flutter clean && flutter build web`
- Deploy: `firebase deploy --only hosting`
- Test: Try phone login on web

The web OTP verification should now work correctly! 🎉
