# Deploy Sant Narhari Sonar Web App to Vercel

Vercel does **not** have Flutter on its build servers, so running `flutter build web` on Vercel fails. This project uses **GitHub Actions** to build Flutter web and deploy the prebuilt output to Vercel.

**Important:** `vercel.json` has `"github": { "enabled": false }` so Vercel does **not** try to build on push (which would fail). Deployment happens **only** when the GitHub Action runs (after you add the secrets below).

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
