# CI/CD — GitHub, Fastlane, Vercel

## Status: FULLY WORKING (as of 2026-03-14)

Every push to `main` that changes `ios/**` automatically builds, signs, uploads, and submits to App Store review.

---

## GitHub Repository

- **URL:** https://github.com/jonnyul/Boxing-Timer
- **Branch:** `main` — triggers both iOS deploy and Vercel deploy

## GitHub Actions Workflows

| File | Trigger | What it does |
|------|---------|--------------|
| `ios-deploy.yml` | Push to `main` (ios/** changes) | Builds archive + submits to App Store via Fastlane |
| `web-deploy.yml` | Push to `main` (web/** changes) | Deploys to Vercel |

## Required GitHub Secrets

### iOS
| Secret | Value |
|--------|-------|
| `ASC_API_KEY_CONTENT` | Contents of `~/keys/apple-keys/AuthKey_3349GWYVGR.p8`, base64-encoded |
| `MATCH_PASSWORD` | Passphrase used to encrypt the match certs repo |
| `MATCH_GIT_BASIC_AUTHORIZATION` | base64 of `username:PAT` for the fastlane-match repo |

### Web (Vercel)
| Secret | Value |
|--------|-------|
| `VERCEL_TOKEN` | From vercel.com → Settings → Tokens |
| `VERCEL_ORG_ID` | From `.vercel/project.json` |
| `VERCEL_PROJECT_ID` | From `.vercel/project.json` |

---

## Fastlane

Located at `ios/fastlane/`. Run from the `ios/` directory.

| Lane | Command | What it does |
|------|---------|--------------|
| `release` | `fastlane release` | Build + submit to App Store (used by CI) |
| `beta` | `fastlane beta` | Build + upload to TestFlight |
| `screenshots` | `fastlane screenshots` | Capture App Store screenshots |

### Fastlane Match
- Private repo: https://github.com/jonnyul/fastlane-match
- Local copy: `/Users/buzzulloa/fastlane-match/`
- Type: appstore, Bundle ID: john.Boxing-Timer

### Build Number
The release lane fetches `latest_testflight_build_number` from ASC and adds 1. Never reads from the local xcodeproj — avoids drift.

### Code Signing (gym)
```
xcargs: CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY='Apple Distribution' PROVISIONING_PROFILE_SPECIFIER='match AppStore john.Boxing-Timer'
```

---

## CI Workflow — Key Details

The workflow has a **"Prepare ASC version for submission"** step that runs before `fastlane release`. It uses raw HTTP + JWT to:
1. PATCH `apps/{id}` with `contentRightsDeclaration: DOES_NOT_USE_THIRD_PARTY_CONTENT` — this is on the **App** resource, NOT appStoreVersions
2. POST `appStoreReviewDetails` with contact info if the review detail doesn't exist for the current version

### Fastlane Patches Applied in CI
- `token.rb`: `OpenSSL::PKey::EC.new` → `OpenSSL::PKey.read` (OpenSSL 3.x bug)
- `model.rb`: `raise "No data"` → `return nil` (no crash on missing review detail)
- `upload_metadata.rb`: `app_store_review_detail.` → `app_store_review_detail&.` (safe nil handling)

---

## Vercel (Web)

`web/` is configured for Vercel. Privacy policy at `web/privacy-policy/` serves the app's privacy URL.

---

## Screenshots

Captured via the `screenshots` lane using `xcrun simctl io screenshot` + NSLog parsing (bypasses fastlane's broken iOS 26.x version matching).

Devices (UDIDs hardcoded in Fastfile — update if simulators are recreated):
- iPhone 17 Pro Max: F2310914-3385-4C5A-8C0E-F990FFDAE113
- iPhone 17 Pro: 58539C49-E5C1-4566-9215-1CE33ACEB315
- iPhone 16e: 50F52ACB-529F-4D1F-A749-5D50790F72B4

---

## SDK Warning (deadline: 2026-04-28)

ITMS-90725: Must build with iOS 26 SDK (Xcode 26) by April 28, 2026. Non-blocking until then.
