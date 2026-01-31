# Sant Narhari Sonar — Production Readiness Report

This document summarizes the state of the app’s **frontend**, **backend**, and **operations** for production.

---

## Executive summary

| Area | Status | Notes |
|------|--------|--------|
| **Frontend (Flutter)** | Ready | Auth, payments, registrations, admin UI, bilingual (EN/MR) |
| **Backend (Firebase)** | Ready with caveats | Auth, Firestore, Storage in use; rules and payment need hardening |
| **Security** | Fixed for launch | Admin gating and Settings admin visibility fixed |
| **Production hardening** | Recommended | Firestore admin-only rules, server-side payment, monitoring |

**Verdict:** The app is **suitable for production launch** after completing the “Must-do before production” section below. The “Recommended before/after launch” items will improve security and maintainability.

---

## 1. Frontend (Flutter)

### 1.1 Auth & onboarding
- Phone OTP: validation (10-digit Indian mobile), send OTP, verify, resend, friendly errors.
- Email: sign-in/sign-up, password reset, email verification on sign-up, “Resend verification” on Profile.
- Skip: users can skip login and use limited access.
- Subscription gate: after sign-up, ₹21 payment required for full access (streamed from Firestore).

### 1.2 Main features
- Home: ads, events (free/paid), news; RSVP for events.
- Explore: Matrimony, Family Directory, Social Workers, Business, Ads, News, Events, My Events (RSVPs for creators), Birthdays, Feedback.
- Payments: Razorpay (UPI/Card) via Firestore config (`payment` collection: `key_id`, optional `key_secret` for test).
- Registrations: Matrimony (with photo & family), Family Directory, Business, Social Workers (with photo); all store to Firestore + optional images to Storage.
- Event creators: “My Events” lists their events; “View RSVPs” shows RSVP form submissions.
- Profile: user info, email verification banner, registrations summary, Settings, Sign out.
- About: Sant Narhari content, leaders, goals/objectives/rules (EN/MR).
- Language: English / Marathi (SharedPreferences).

### 1.3 Admin (gated)
- Settings shows “Admin Panel” only if `users/{uid}.isAdmin == true` (Firestore).
- Admin login: email/password; then `isAdmin` check; only then dashboard.
- Auto-continue: if already signed in **and** `isAdmin`, redirect to dashboard; otherwise show login.
- Dashboard: Users, Businesses, Advertisements, News, Events, Family Directory, Registrations (Matrimony), Social Workers, Feedback — list, approve/reject/delete, view full details (including images).

### 1.4 UX & robustness
- Loading states on buttons and streams.
- SnackBars for success/error; friendly auth and payment error messages.
- Empty states for lists; error builders for images.
- No hardcoded API keys in Dart (payment config from Firestore).

### 1.5 Gaps / optional improvements
- No crash reporting (e.g. Firebase Crashlytics).
- No analytics (e.g. Firebase Analytics).
- No deep links / dynamic links.
- Automated tests: only one basic widget test; more tests recommended later.

---

## 2. Backend (Firebase)

### 2.1 Firebase Auth
- Phone (OTP) and Email/Password enabled; email verification sent on sign-up.
- Android: `setAppVerificationDisabledForTesting(true)` only when app is **debuggable** (release builds do not disable verification).
- SHA-1/SHA-256 and test phone numbers must be configured in Firebase Console for production.

### 2.2 Firestore
- **Collections:** `users`, `payment`, `payments`, `family_directory`, `matrimony`, `social_workers`, `advertisements`, `news`, `events`, `event_rsvps`, `businesses`, `feedback`.
- **Indexes:** `firestore.indexes.json` includes indexes for status+createdAt and userId+createdAt (events); deploy with `firebase deploy --only firestore:indexes`.
- **Rules (current):**
  - `users`: read/write own doc only.
  - `payment`: read if auth, write false (Console only).
  - `payments`: create if auth, read own only.
  - `event_rsvps`: read/create if auth; update/delete only own.
  - `businesses`: read/create if auth; update/delete only if `resource.data.userId == request.auth.uid`.
  - Other content collections: **any authenticated user** can read and write (create/update/delete).

**Production risk:** Any logged-in user can currently update any document (e.g. set `status` to `approved`). The app only shows admin actions to admins, but rules do not enforce admin. **Recommended:** Add Firestore rules so that `status` (and other sensitive) updates are allowed only when `get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true`. See “Recommended” section below.

### 2.3 Storage
- **Rules:** `social_workers/{userId}`, `profile_photos/{userId}`, `matrimony/{userId}` — read if auth, write only if `request.auth.uid == userId`.
- Deploy with `firebase deploy --only storage`.

### 2.4 Payment (Razorpay)
- Config from Firestore `payment` collection (e.g. doc `razorpay` or `test`): `key_id`, optional `key_secret`, `mode` (test/live).
- **Test:** With `key_secret` in Firestore, app can create orders client-side (acceptable for test only).
- **Production:** Do **not** store `key_secret` in Firestore or in the app. Create orders in a **secure backend** (e.g. Cloud Functions) and pass only `order_id` to the client. Use Razorpay’s server-side API for order creation and verification.

---

## 3. Security fixes applied (pre-production)

1. **Admin Panel visibility (Settings)**  
   - Before: Admin Panel was shown to all users (`_isAdmin = true` always, including on error).  
   - After: Admin Panel is shown only when `isAdmin` is true in Firestore; on error, `_isAdmin = false`.

2. **Admin login auto-continue**  
   - Before: Any signed-in user was sent to Admin Dashboard without checking `isAdmin`.  
   - After: Auto-continue only if user is signed in **and** `FirestoreService.instance.isAdmin(user.uid)` is true.

3. **Admin Dashboard guard**  
   - On load, the dashboard verifies the current user is admin via Firestore. If not, it shows "Admin access required" and pops back. Prevents direct navigation or bypass from seeing admin content.

4. **Firestore rules — admin-only writes**  
   - Content collections (`family_directory`, `matrimony`, `social_workers`, `advertisements`, `news`, `events`): any authenticated user can **create** and **read**; only users with `users/{uid}.isAdmin == true` can **update** or **delete** (approve/reject/remove content).  
   - **Feedback**: only admins can **read** or **delete**; any auth user can **create**.  
   - **Users**: admins can **read** and **update** any user (e.g. setUserAdmin); users can read/update/delete only their own document.  
   - **Businesses**: create/read by auth; update/delete by owner **or** admin.  
   - So even if someone bypasses the app UI, the backend rejects non-admin status updates and deletes.

---

## 4. Must-do before production

1. **Firebase Console**
   - Enable Phone and Email/Password sign-in methods.
   - Add production SHA-1/SHA-256 (e.g. from Play App Signing) to the Android app.
   - Configure test phone numbers if needed; remove or restrict for production as per policy.
   - Ensure Email verification template (and optional custom domain) is correct.

2. **Firestore**
   - Rules and indexes have been deployed (`firebase deploy --only firestore`). To redeploy: run that command.
   - Set `users/{adminUid}.isAdmin = true` in Firestore for each admin account (see **ONE_TIME_SETUP.md** for step-by-step).

3. **Payment**
   - Create a live Razorpay key pair; store only `key_id` (and optionally `mode: 'live'`) in Firestore for the app.
   - Do **not** put `key_secret` in Firestore or in the client in production.
   - Implement server-side order creation (e.g. Cloud Functions) and, if needed, payment verification.

4. **Release build**
   - Ensure `key.properties` and release keystore exist for Android (or use Play App Signing).
   - Build release: `flutter build apk` / `flutter build appbundle` and verify no debug-only code paths (e.g. admin bypass) run in release.

5. **Config**
   - Use production `google-services.json` (and iOS equivalents) for release builds.
   - Confirm Firestore `payment` document(s) point to live key and no client-side `key_secret`.

---

## 5. Recommended (before or soon after launch)

1. **Firestore rules — admin-only updates**
   - Restrict `update` on content collections (e.g. `advertisements`, `news`, `events`, `family_directory`, `matrimony`, `social_workers`, `businesses`) to admins:
     - e.g. `allow update: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;`
   - Keep `create` for authenticated users where appropriate; restrict `delete` to admin (or owner) as needed.
   - Tighten `event_rsvps` read to event creator or admin if you want to limit who sees RSVP lists.

2. **Payment**
   - Move order creation (and optionally capture verification) to Cloud Functions (or another backend).
   - Remove `key_secret` from client and Firestore in production.

3. **Monitoring & quality**
   - Add Firebase Crashlytics (or similar) and handle fatal errors.
   - Add Firebase Analytics (or similar) for key flows (sign-up, payment, registrations).
   - Add a few integration/widget tests for critical screens (login, payment, admin gate).

4. **Operational**
   - Document how to add/remove admins (Firestore `users/{uid}.isAdmin`).
   - Document backup/restore for Firestore if required by policy.
   - Plan for Play Store listing (privacy policy, app content, permissions).

---

## 6. Quick checklist

See **ONE_TIME_SETUP.md** for a single checklist of all manual steps.

- [ ] Firestore rules and indexes (already deployed; redeploy with `firebase deploy --only firestore` if needed).
- [ ] Set admin UIDs in Firestore (`users/{uid}.isAdmin = true`).
- [ ] Production SHA fingerprints in Firebase Console (Android).
- [ ] Razorpay live key in Firestore; no `key_secret` in client/Firestore.
- [ ] Order creation (and verification) moved to backend for production payments.
- [ ] Release build tested (admin only for admins, payment flow, OTP/email).
- [ ] (Recommended) Admin-only Firestore rules for status/update/delete.
- [ ] (Recommended) Crashlytics + Analytics.
- [ ] (Recommended) Privacy policy and store listing ready.

---

*Last updated: Production readiness review — frontend and backend.*
