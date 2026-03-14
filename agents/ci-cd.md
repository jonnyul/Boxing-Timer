# CI/CD — GitHub, Fastlane, Vercel

## GitHub Repository

- **URL:** https://github.com/jonnyul/Boxing-Timer
- **Branches:**
  - `main` — source of truth, general development
  - `dev` — triggers Vercel preview deployment
  - `prod` — triggers Vercel production deployment AND iOS App Store build

## GitHub Actions Workflows

Located at `.github/workflows/`:

| File | Trigger | What it does |
|------|---------|--------------|
| `ios-deploy.yml` | Push to `prod` (ios/** changes) | Builds archive + submits to App Store via Fastlane |
| `web-deploy.yml` | Push to `prod` or `dev` (web/site/** changes) | Deploys to Vercel production or preview |

## Required GitHub Secrets

Before CI/CD works, these secrets must be set in the repo Settings → Secrets:

### iOS
| Secret | Value |
|--------|-------|
| `ASC_API_KEY_CONTENT` | Contents of `~/Desktop/appstuff/keys/apple-keys/AuthKey_ZV4778F669.p8` |
| `DISTRIBUTION_CERT_BASE64` | Base64-encoded Apple Distribution .p12 certificate |
| `DISTRIBUTION_CERT_PASSWORD` | Password for the .p12 |
| `PROVISIONING_PROFILE_BASE64` | Base64-encoded App Store provisioning profile |

### Web (Vercel)
| Secret | Value |
|--------|-------|
| `VERCEL_TOKEN` | From vercel.com → Settings → Tokens |
| `VERCEL_ORG_ID` | From `.vercel/project.json` after running `vercel link` |
| `VERCEL_PROJECT_ID` | From `.vercel/project.json` after running `vercel link` |

## Fastlane

Located at `ios/fastlane/`.

| Lane | Command | What it does |
|------|---------|--------------|
| `beta` | `fastlane beta` | Build + upload to TestFlight |
| `release` | `fastlane release` | Build + submit to App Store |
| `codesign` | `fastlane codesign` | Create/download dist cert + App Store provisioning profile |
| `screenshots` | `fastlane screenshots` | Capture App Store screenshots via snapshot |

Run from the `ios/` directory.

## Vercel (Web)

The `web/site/` site is configured for Vercel deployment.

To set up for the first time:
1. `cd web/site && vercel login`
2. `vercel link` — links to a Vercel project, creates `.vercel/project.json`
3. Get the org ID and project ID from `.vercel/project.json`
4. Add them as GitHub secrets (see above)
5. Push to `prod` branch to trigger production deployment

## Screenshots

9 screenshots captured (2026-03-14) and committed to `ios/fastlane/screenshots/en-US/`:
- iPhone 17 Pro Max, iPhone 17 Pro, iPhone 16e
- Screens: 01_Home, 02_Presets, 03_Stats

**Known issue:** Fastlane's `snapshot` action fails on iOS 26.x simulators due to version mismatch (simctl shows `26.3`, xcodebuild reports `26.3.1`). The `screenshots` lane bypasses this by using `xcrun simctl io screenshot` triggered by NSLog parsing, with simulator UDIDs hard-coded in the Fastfile.

If simulators are recreated, update the UDIDs in the `screenshots` lane of `Fastfile`.

## Blocking Issues (as of 2026-03-14)

### App Store Connect API Key — RESOLVED
Issuer ID corrected to `220f0894-51a2-449c-ad61-9715441b4a11` (was missing trailing `1`). API key ZV4778F669 is Active/Admin.

### Code Signing
No Apple Distribution certificate exists in the local keychain (only Apple Development). For App Store export, a distribution cert + App Store provisioning profile for `john.Boxing-Timer` is required. Run `fastlane codesign` (once API key is validated end-to-end) to create them automatically.

### Vercel Login — RESOLVED
`vercel login` and `vercel link` completed. Org ID and Project ID set as GitHub secrets.
