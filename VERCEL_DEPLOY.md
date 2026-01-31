# Deploy Sant Narhari Sonar Web App to Vercel

---

## Fresh deploy (new Vercel project)

If you deleted the old project and are importing this repo again:

1. Go to [vercel.com](https://vercel.com) → **Add New…** → **Project**.
2. **Import** the repo: `kartik18012006/sant-narhari-sonar` (connect GitHub if needed).
3. **Build settings** (important):
   - **Framework Preset:** leave as **Other** (or let Vercel auto-detect).
   - **Build Command:** set to **`npm run build`** (do **not** use `flutter pub get && flutter build web`).
   - **Output Directory:** set to **`build/web`**.
4. Click **Deploy**.

The repo includes `package.json` and `build.js` so `npm run build` creates a placeholder page and the deploy succeeds. To deploy the **full Flutter app**, add the three GitHub secrets and run the **Deploy to Vercel** workflow (see sections 2–4 below).

---

## How deployment works

Vercel does **not** have Flutter on its build servers, so running `flutter build web` on Vercel fails. This repo uses **`npm run build`** on Vercel (placeholder) and **GitHub Actions** to build and deploy the full Flutter app when you run the workflow.

---

## 0. Fix "flutter: command not found" (do this in the Vercel dashboard)

Vercel is still running **Build Command: `flutter pub get && flutter build web`** (set when you imported the repo). Vercel’s servers don’t have Flutter, so that build always fails. You have to change this **in the Vercel dashboard**; the repo can’t override it.

**Option A – Disconnect Git (recommended)**  
Then only the GitHub Action will deploy.

1. [Vercel](https://vercel.com) → open project **sant-narhari-sonar** → **Settings**.
2. In the left sidebar, click **Git**.
3. Under **Connected Git Repository**, click **Disconnect** (or **Disconnect Repository**). Confirm.
4. From now on, **no push will trigger a Vercel build.** Deploys happen only when you run the **Deploy to Vercel** workflow (see step 4 below).

**Option B – Keep Git connected; use the repo’s no-op build**

The repo has a `package.json` build that creates a tiny placeholder so Vercel doesn’t run Flutter.

1. **Settings** → **Build & Development Settings**.
2. Under **Override**, set **Build Command** to: `npm run build`
3. Set **Output Directory** to: `build/web` (if not already).
4. Save. The next deploy will run `npm run build` (no Flutter) and succeed. Run the **Deploy to Vercel** workflow in GitHub Actions to deploy the full Flutter app.

Then add the three GitHub secrets (step 3 below) and run the **Deploy to Vercel** workflow from the repo **Actions** tab. That workflow builds Flutter and deploys the app to Vercel.

---

## 1. Push the project to Git

From the project root:

```bash
# If you haven't added a remote yet:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push (branch name must be main or master for auto-deploy)
git push -u origin main
```

Use your actual GitHub repo URL. If your default branch is `master`, the workflow runs on push to `master` too.

---

## 2. Create a Vercel project and get IDs

1. Go to [vercel.com](https://vercel.com) and sign in (e.g. with GitHub).
2. Click **Add New…** → **Project**.
3. **Import** the same GitHub repository you pushed in step 1.
4. **Do not** use Vercel’s build. We only need the project so we can get IDs and a token:
   - After creating the project, go to **Project Settings** → **General**.
   - Copy **Project ID** (e.g. `prj_xxxx`).
   - Go to **Settings** → **Teams** (or your profile) → your team/account → **Settings** → **General** → copy **Team/Org ID** (e.g. `team_xxxx`; for personal it may look like `team_xxxx` or be under your profile).
5. Create a token:
   - [Vercel Account → Tokens](https://vercel.com/account/tokens) (or **Settings** → **Tokens**).
   - Create a token with a name (e.g. `GitHub Actions`) and copy it.

---

## 3. Add GitHub secrets

In your GitHub repo: **Settings** → **Secrets and variables** → **Actions** → **New repository secret**. Add:

| Secret name         | Value                          |
|---------------------|--------------------------------|
| `VERCEL_TOKEN`      | The token from step 2.5        |
| `VERCEL_ORG_ID`     | Team/Org ID from step 2.4     |
| `VERCEL_PROJECT_ID` | Project ID from step 2.4      |

---

## 4. Deploy

- Every push to `main` (or `master`) will:
  1. Build the Flutter web app in GitHub Actions.
  2. Deploy the built output to Vercel with `--prebuilt`.

- First run: open the **Actions** tab in the repo and confirm the “Deploy to Vercel” workflow runs and succeeds.

- Your app will be available at the Vercel URL (e.g. `https://your-project.vercel.app`).

---

## 5. Optional: deploy from your machine

Without GitHub Actions you can build and deploy locally:

```bash
flutter pub get
flutter build web

# Create .vercel/output (same as in the workflow)
mkdir -p .vercel/output/static
cp -r build/web/* .vercel/output/static/
echo '{"version":3,"routes":[{"handle":"filesystem"},{"handle":"rewrite"},{"src":"/(.*)","dest":"/index.html"}]}' > .vercel/output/config.json

# Deploy (requires Vercel CLI: npm i -g vercel)
vercel deploy --prebuilt --prod
```

Ensure the project is linked (`vercel link` in the repo if needed) and that you’re logged in (`vercel login`).
