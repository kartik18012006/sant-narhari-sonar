# One-time setup — Sant Narhari Sonar

Use this checklist for everything that must be done manually (Firebase Console, Firestore data, config).

---

## Already done (by script / previous steps)

- **Firestore rules & indexes** — Deployed. To redeploy:  
  `firebase deploy --only firestore`
- **Flutter web build** — Verified; output is in `build/web`.

---

## 1. Firebase Console — Authentication

1. Open [Firebase Console](https://console.firebase.google.com/project/sant-narhari-sonar) → **Authentication** → **Sign-in method**.
2. Enable **Phone** and **Email/Password**.
3. (Android) **Project Settings** → Your Android app → add **SHA-1** and **SHA-256** (from Play Console / App Signing or `keytool`).
4. (Phone) Under Phone, add **test phone numbers** if needed for development.

---

## 2. Set admin users (Firestore)

Admin Panel in the app is visible only when `users/{uid}.isAdmin == true`.

1. Open [Firestore](https://console.firebase.google.com/project/sant-narhari-sonar/firestore).
2. Go to **users** collection.
3. Find the document whose **document ID** is the admin user’s UID (same as in Auth).
4. Edit the document and add (or set) field:  
   **Name:** `isAdmin`  
   **Type:** boolean  
   **Value:** `true`  
5. Repeat for each admin account.

---

## 3. Payment config (Firestore)

The app reads Razorpay config from Firestore; without it you get “Payment config not found”.

1. In Firestore, create or use collection **payment**.
2. Add a document (e.g. **razorpay** or **test**) with fields:
   - `key_id` (string) — Razorpay key ID.
   - `mode` (string) — `"test"` or `"live"`.
   - `key_secret` (string, optional) — Only for **testing**; do **not** use in production. For production, create orders on a backend and never put `key_secret` in Firestore or the app.

---

## 4. Web app — Firebase config

The web app uses `lib/firebase_options.dart`. You must add your real web config from Firebase.

1. In Firebase Console → **Project Settings** → **Your apps**, click **Add app** → **Web** (or use existing web app).
2. Copy the config object (apiKey, appId, messagingSenderId, etc.).
3. Open `lib/firebase_options.dart` and replace the placeholder values in `DefaultFirebaseOptions.web`:
   - `apiKey` → your web API key  
   - `appId` → your web app ID  
   - `messagingSenderId` → your sender ID  
   - Keep `projectId`, `authDomain`, `storageBucket` as-is unless your project uses different values.

Or run from project root:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then choose the web platform and the `sant-narhari-sonar` project so it regenerates `lib/firebase_options.dart`.

---

## 5. Optional: Storage rules & Hosting

- **Storage:**  
  `firebase deploy --only storage`
- **Hosting (web):**  
  Build: `flutter build web`  
  Deploy: `firebase deploy --only hosting`

---

## 6. Quick checklist

- [ ] Auth: Phone + Email/Password enabled; SHA fingerprints added (Android).
- [ ] Firestore: `users/{uid}.isAdmin = true` for each admin.
- [ ] Firestore: `payment` collection with `key_id` (and optional `key_secret` for test only).
- [ ] Web: Firebase web app created and `lib/firebase_options.dart` updated.
- [ ] (Optional) Deploy storage rules and hosting.

After this, the app and web app can use the same Firebase project and logic; only these one-time config steps are manual.
