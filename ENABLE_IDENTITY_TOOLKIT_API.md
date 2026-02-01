# Enable Identity Toolkit API for Firebase Authentication

## 🔍 Important Clarification

**Firebase Authentication does NOT have a separate API called "Firebase Authentication API"**

Instead, Firebase Authentication uses the **Identity Toolkit API** in Google Cloud Console.

## ✅ Step-by-Step: Enable Identity Toolkit API

### Method 1: Direct Link (Easiest)

1. Click this direct link: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=sant-narhari-sonar
2. Click the **"Enable"** button
3. Wait for it to enable (usually takes a few seconds)

### Method 2: Manual Navigation

1. Go to **Google Cloud Console**: https://console.cloud.google.com/
2. Select project: **sant narhari sonar**
3. In the left sidebar, go to: **APIs & Services** → **Library**
4. In the search bar, type: **"Identity Toolkit API"**
5. Click on **"Identity Toolkit API"** from the results
6. Click the **"Enable"** button

## 🔍 Alternative: Search for Related APIs

If you can't find "Identity Toolkit API", try searching for:

- **"Identity Toolkit"** (without "API")
- **"Firebase Authentication"** (may show Identity Toolkit as related)
- **"Google Identity"**

## ✅ Verify It's Enabled

1. Go to: **APIs & Services** → **Enabled APIs & services**
2. Search for: **"Identity Toolkit"**
3. You should see **"Identity Toolkit API"** in the list with status **"Enabled"**

## 📋 Other APIs You May Need

While enabling Identity Toolkit API, also ensure these are enabled:

1. **Identity Toolkit API** ← **REQUIRED for Firebase Auth**
2. **Firebase Installations API** ← Already visible in your list
3. **Firebase Cloud Messaging API** ← If using push notifications
4. **Firebase Hosting API** ← If deploying to Firebase Hosting

## ⚠️ Common Confusion

- ❌ **"Firebase Authentication API"** → Does NOT exist
- ✅ **"Identity Toolkit API"** → This is what Firebase Auth uses

## 🧪 After Enabling

1. Wait 1-2 minutes for the API to fully activate
2. Rebuild your web app: `flutter clean && flutter build web`
3. Deploy: `firebase deploy --only hosting`
4. Test phone login on web

## 🔗 Quick Links

- **Enable Identity Toolkit API**: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=sant-narhari-sonar
- **View Enabled APIs**: https://console.cloud.google.com/apis/dashboard?project=sant-narhari-sonar

---

**TL;DR**: Enable **"Identity Toolkit API"** instead of "Firebase Authentication API" - they're the same thing!
