# Firebase setup (Sant Narhari Sonar)

## Done in the app

- **google-services.json** is in `android/app/google-services.json` (and a copy in `android/`).
- **Firebase Auth**: Phone OTP and Email/Password sign-in/sign-up, forgot password.
- **Cloud Firestore**: User profile on sign-in; payment records; placeholder collections for family_directory, matrimony, etc.
- **Auth gate**: If user is signed in, app opens Main Shell; else Onboarding.
- **Profile**: Sign out and Login Yearly payment entry.

## You need to do in Firebase Console

1. **Enable Auth methods**
   - [Firebase Console](https://console.firebase.google.com) → your project **sant-narhari-sonar** → **Authentication** → **Sign-in method**.
   - Enable **Phone** (and add your test phone numbers if needed).
   - Enable **Email/Password**.

2. **Create Firestore**
   - **Firestore Database** → **Create database** (start in test mode, then replace with rules below).
   - Deploy rules: use the project’s `firestore.rules` (e.g. `firebase deploy --only firestore:rules` if you use Firebase CLI).

3. **Android: SHA-1 (for Phone Auth)**
   - Run: `cd android && ./gradlew signingReport` (or use Android Studio).
   - Copy the **SHA-1** and add it in **Project settings** → **Your apps** → Android app → **Add fingerprint**.

4. **Optional: iOS**
   - Add `GoogleService-Info.plist` to `ios/Runner/` and enable Phone Auth in Xcode if you build for iOS.

## Firestore rules

Rules are in **firestore.rules**. Deploy them from the Firebase CLI or paste into **Firestore** → **Rules** in the console.

## Firebase Storage (images)

- **Enable Storage**: Firebase Console → **Storage** → **Get started** (choose a location).
- **Rules**: Use **storage.rules** in this project. Deploy with `firebase deploy --only storage`, or paste the rules in **Storage** → **Rules** in the console.
- **Paths used**: `social_workers/{userId}/{timestamp}.jpg` (Register Social Worker photo). Images are uploaded by authenticated users and the download URL is stored in Firestore.

## Payment gateway (Razorpay) — config in Firestore

- **Collection:** `payment`
- **Document:** `razorpay`

Store the Razorpay test API config here. The app **fetches from Firestore** (no keys in code). When you get production keys, **replace them in Firestore** — no app update.

**Fields:**

| Field    | Type   | Example        | Note |
|----------|--------|----------------|------|
| `key_id` | string | `rzp_test_xxx` | Razorpay API key (test or live) |
| `mode`   | string | `test` or `live` | Shown in app; use `live` when you switch to production key |

Create the document in Console: **Firestore** → **Start collection** → Collection ID: `payment` → Document ID: `razorpay` → Add fields `key_id`, `mode`.

## Collections used

| Collection         | Use                          |
|--------------------|------------------------------|
| `payment`          | Gateway config: `payment/razorpay` (key_id, mode) — app fetches here |
| `users`            | Profile (uid, email, phone, displayName, createdAt, updatedAt) |
| `payments`         | Payment records (userId, featureId, amountInr, status, createdAt) |
| `family_directory` | For future family directory  |
| `matrimony`        | For future matrimony         |
| `social_workers`   | For future social workers    |
| `advertisements`   | For future ads               |
| `news`             | For future news              |
| `events`           | For future events            |
