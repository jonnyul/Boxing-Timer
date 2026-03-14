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

## Blocking Issues (as of 2026-03-13)

### App Store Connect API Key
The issuer ID in `keys.md` (`220f0894-51a2-449c-ad61-9715441b4a11`) appears to have 11 characters in the last UUID segment instead of the standard 12. This causes API 401 errors. **Verify the correct issuer ID at:** App Store Connect → Users and Access → Keys.

### Code Signing
No Apple Distribution certificate exists in the local keychain (only Apple Development). For App Store export, a distribution cert + App Store provisioning profile for `john.Boxing-Timer` is required. Once the API key is fixed, run `fastlane codesign` to create them automatically.

### Vercel Login
Vercel CLI requires interactive browser login (`vercel login`). Run this once locally, then extract the token for GitHub secrets.
