# iSpeye APK Distribution Page

Static landing page for direct APK distribution. Captures emails to Supabase, serves APK from GitHub Releases.

## Setup (one-time)

### 1. Run the Supabase SQL

Open https://app.supabase.com/project/bwjuxeqzqyeimrqxfamw/sql/new and paste the contents of `supabase_setup.sql`. Click Run.

This creates an `app_downloads` table with row-level security:
- Anyone can INSERT (the page submits emails anonymously)
- No one can SELECT via the anon key (your admin reads via Supabase dashboard or service role)

### 2. Build & host the APK on GitHub Releases

```powershell
# From project root
flutter build apk --release
```

Output: `build\app\outputs\flutter-apk\app-release.apk` (~50–80 MB)

Create a GitHub release:
1. Push this `apk-distribution-page` folder to a new GitHub repo (e.g. `ispeye-download`).
2. Repo → Releases → **Draft a new release**.
3. Tag: `v1.3.1` (matches pubspec). Title: `iSpeye 1.3.1`.
4. **Drag `app-release.apk` into the assets area.** Rename to `ispeye-v1.3.1.apk` if you want.
5. Publish release.
6. Right-click the uploaded APK → **Copy link address** — you'll get a URL like:
   `https://github.com/<user>/ispeye-download/releases/download/v1.3.1/ispeye-v1.3.1.apk`

### 3. Wire the APK URL into the page

Open `index.html`. Find:
```html
<a id="downloadLink" class="download-btn" href="APK_URL_PLACEHOLDER" download>
```

Replace `APK_URL_PLACEHOLDER` with the URL you copied in step 2.

### 4. Deploy

**Netlify drop (fastest):** drag this folder onto https://app.netlify.com/drop
**Vercel:** `vercel --prod` from this folder
**GitHub Pages:** Settings → Pages → Source: main → save

You get a public URL like `https://ispeye-download.netlify.app`.

## Updating the APK (each new release)

1. Bump version in pubspec.yaml (`1.3.2+3` etc.)
2. `flutter build apk --release`
3. Create new GitHub release with new tag, upload new APK
4. Update `APK_URL_PLACEHOLDER` in `index.html` (or use a fixed-URL pattern — see below)
5. Push to repo (Netlify auto-deploys)

### Pro tip: stable "latest" URL

GitHub doesn't give a moving "latest APK" URL automatically, but you can:
- Use the release **download** URL pattern with your latest tag, OR
- Mirror the APK to a fixed Supabase Storage path (`apks/ispeye-latest.apk`) and overwrite on each release. Then the HTML never needs editing.

## Reading captured emails

Supabase dashboard → Table Editor → `app_downloads`. Or query via SQL:

```sql
select email, user_agent, created_at
from app_downloads
order by created_at desc;
```

## Privacy notes

- The page transmits the user's email + User-Agent string to Supabase.
- Add a privacy notice to the form if distributing publicly (GDPR / Ghana Data Protection Act compliance).
- IP address is NOT captured client-side; if you want it, add an Edge Function proxy or use a Supabase trigger that reads `request.header('x-forwarded-for')`.
