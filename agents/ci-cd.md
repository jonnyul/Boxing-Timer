# CI/CD — GitHub, Fastlane, Vercel

## Status: FULLY WORKING (as of 2026-03-17)

Every push to `main` that changes `ios/**` automatically builds, signs, uploads, and submits to App Store review. Dev pushes run the same pipeline but skip the App Store submission steps.

---

## GitHub Repository

- **URL:** https://github.com/jonnyull/Boxing-Timer
- **Branches:**
  - `main` — production; triggers full iOS deploy + App Store submission
  - `dev` — development; triggers iOS build/sign only (no App Store submission)

---

## GitHub Actions Workflows

| File | Trigger | What it does |
|------|---------|--------------|
| `ios-deploy.yml` | Push to `main` or `dev` (ios/** or workflow changes) | Builds + signs on both; submits to App Store on `main` only |
| `codeql.yml` | Push/PR to `main` or `dev`, weekly Saturday | CodeQL scan: actions, javascript-typescript, swift |

### ios-deploy.yml — Step breakdown

| Step | Runs on | What it does |
|------|---------|--------------|
| Checkout | both | — |
| Select Xcode | both | — |
| Set up Ruby | both | ruby 3.3, bundler latest, pinned to SHA |
| Install Fastlane | both | `bundle install` |
| Patch Fastlane compatibility | both | OpenSSL 3.x fix, nil review detail fix |
| Write App Store Connect API Key | both | Decodes `ASC_API_KEY_CONTENT` secret to `~/asc-keys/` |
| Prepare ASC version for submission | **main only** | Sets contentRightsDeclaration, creates appStoreReviewDetail |
| Run Fastlane release | **main only** | match + gym + upload_to_app_store |

---

## Required GitHub Secrets

All secrets are set on both the repo (`jonnyull/Boxing-Timer`) and the org (`jonnyull`).

| Secret | What it is |
|--------|-----------|
| `ASC_API_KEY_CONTENT` | Base64-encoded `AuthKey_3349GWYVGR.p8` |
| `ASC_KEY_ID` | `3349GWYVGR` |
| `ASC_ISSUER_ID` | `220f0894-51a2-449c-ad61-9715441b4a11` |
| `APPLE_TEAM_ID` | `3LN6SHFTXK` |
| `MATCH_PASSWORD` | Passphrase for the match certs repo |
| `MATCH_GIT_BASIC_AUTHORIZATION` | base64 of `jonnyul:PAT` for fastlane-match repo |
| `REVIEW_CONTACT_FIRST_NAME` | Jonathan |
| `REVIEW_CONTACT_LAST_NAME` | Ulloa |
| `REVIEW_CONTACT_PHONE` | From env.sh |
| `REVIEW_CONTACT_EMAIL` | From env.sh |
| `VERCEL_TOKEN` | From vercel.com → Settings → Tokens |
| `VERCEL_ORG_ID` | `team_pH8NmacSBy5oAvMLyCbGUe9W` |
| `VERCEL_PROJECT_ID` | `prj_TRvYPokY33uiy5Q8h1bf2XFjsY4x` |

---

## Fastlane

Located at `ios/fastlane/`. Run from the `ios/` directory.

| Lane | Command | What it does |
|------|---------|--------------|
| `release` | `fastlane release` | Build + submit to App Store (used by CI) |
| `beta` | `fastlane beta` | Build + upload to TestFlight |
| `screenshots` | `fastlane screenshots` | Capture App Store screenshots |
| `codesign` | `fastlane codesign` | Create dist cert + provisioning profile |

### Fastlane Match
- Private cert repo: https://github.com/jonnyul/fastlane-match
- Local copy: `/Users/buzzulloa/fastlane-match/`
- Type: appstore, Bundle ID: `john.Boxing-Timer`

### Build Number
The release lane fetches `latest_testflight_build_number` from ASC and adds 1. Never reads from the local xcodeproj.

### Fastlane Patches Applied in CI
- `token.rb`: `OpenSSL::PKey::EC.new` → `OpenSSL::PKey.read` (OpenSSL 3.x bug)
- `model.rb`: `raise "No data"` → `return nil` (nil review detail on first submit)
- `upload_metadata.rb`: safe navigator on `app_store_review_detail&.` (nil guard)

### Simulator UDIDs (screenshots lane)
- iPhone 17 Pro Max: `F2310914-3385-4C5A-8C0E-F990FFDAE113`
- iPhone 17 Pro: `58539C49-E5C1-4566-9215-1CE33ACEB315`
- iPhone 16e: `50F52ACB-529F-4D1F-A749-5D50790F72B4`

Update these in `Fastfile` if simulators are recreated.

---

## Vercel (Web)

`web/site/` is deployed via Vercel. Connected via `web/site/.vercel/project.json`.

---

## SDK Warning (deadline: 2026-04-28)

ITMS-90725: Must build with iOS 26 SDK (Xcode 26) by April 28, 2026. Non-blocking until then.
