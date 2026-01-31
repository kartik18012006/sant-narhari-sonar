# Sant Narhari Sonar — Flutter Web Setup

The web app uses **the same Firebase project, Firestore, Auth, and Storage** as the Android/iOS app. One codebase (`lib/`), same backend.

---

## 1. Firebase Web App (one-time)

1. Open [Firebase Console](https://console.firebase.google.com/) → project **sant-narhari-sonar**.
2. Go to **Project settings** (gear) → **Your apps**.
3. Click **Add app** → choose **Web** (</>).
4. Register the app (e.g. nickname "Sant Narhari Sonar Web").
5. Copy the `firebaseConfig` object (apiKey, authDomain, projectId, storageBucket, messagingSenderId, appId).

---

## 2. Configure Web in the Project

1. Open **`lib/firebase_options.dart`**.
2. Replace the placeholder values in **`DefaultFirebaseOptions.web`** with your web app config:

   - **apiKey** ← `firebaseConfig.apiKey`
   - **appId** ← `firebaseConfig.appId`
   - **messagingSenderId** ← `firebaseConfig.messagingSenderId`
   - **projectId** ← `sant-narhari-sonar` (or from config)
   - **authDomain** ← `firebaseConfig.authDomain` (e.g. `sant-narhari-sonar.firebaseapp.com`)
   - **storageBucket** ← `firebaseConfig.storageBucket` (e.g. `sant-narhari-sonar.firebasestorage.app`)

3. Save the file.

---

## 3. Run Locally

```bash
flutter pub get
flutter run -d chrome
```

Or build and serve:

```bash
flutter build web
# Serve build/web with any static server, e.g.:
cd build/web && python3 -m http.server 8080
# Open http://localhost:8080
```

---

## 4. Deploy to Firebase Hosting

```bash
flutter build web
firebase deploy --only hosting
```

The app will be available at `https://<project-id>.web.app` (e.g. `https://sant-narhari-sonar.web.app`).

---

## 5. Web vs Mobile

| Feature | Web | Mobile |
|--------|-----|--------|
| Firebase (Auth, Firestore, Storage) | Same project | Same project |
| Phone OTP | Yes (reCAPTCHA) | Yes |
| Email sign-in / verification | Yes | Yes |
| Payment (UPI/Card) | **Other** only (Razorpay not on web) | UPI, Card, Other |
| Image upload (photo) | Yes (bytes) | Yes |
| All other features | Same | Same |

On web, payment screen shows only **"Other"** (record payment, contact admin). UPI/Card use the mobile app.

---

## 6. Optional: FlutterFire CLI

To generate `firebase_options.dart` for all platforms (including web) from Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then select the same Firebase project and enable the **web** platform. This overwrites `lib/firebase_options.dart` with the correct web (and other) configs.
