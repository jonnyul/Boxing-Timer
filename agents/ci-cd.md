# CI/CD — GitHub Actions & Vercel

## Status: BUILD GREEN, SUBMISSION GATED (as of 2026-03-21)

Every push to `main` that changes `ios/**` now performs a real iOS build in GitHub Actions. App Store submission on `main` only runs when the workflow can authenticate to the private `fastlane-match` repo. Pushes to `dev` run the same build validation path but skip the App Store submission steps.

For Fastlane details see [agents/ios/fastlane.md](./ios/fastlane.md).

---

## GitHub Repository

- **URL:** https://github.com/jonnyul/Boxing-Timer
- **Branches:**
  - `main` — production; triggers full iOS deploy + App Store submission
  - `dev` — development; triggers iOS build/sign only

---

## Workflows

| File | Trigger | What it does |
|------|---------|--------------|
| `ios-deploy.yml` | Push to `main` or `dev` (`ios/**` or workflow changes) | Validates iOS build on both branches; runs App Store submission on `main` only when match auth succeeds |

### ios-deploy.yml — Step breakdown

| Step | Runs on | What it does |
|------|---------|--------------|
| Checkout | both | Checks out the repo |
| Select Xcode | both | Selects `/Applications/Xcode.app` |
| Set up Ruby | both | Ruby 3.3 via pinned `ruby/setup-ruby` SHA |
| Install Fastlane | both | `bundle install` in `ios/` |
| Patch Fastlane compatibility | both | Applies OpenSSL 3.x and nil review-detail fixes |
| Write App Store Connect API Key | both | Decodes `ASC_API_KEY_CONTENT` to `~/asc-keys/AuthKey_${ASC_KEY_ID}.p8` |
| Prepare ASC version for submission | `main` only | Sets `contentRightsDeclaration` and creates `appStoreReviewDetails` if missing |
| Validate iOS build | both | Runs `xcodebuild` against target `Boxing Timer` with signing disabled |
| Verify match repo access | `main` only | Checks whether the workflow can authenticate to `jonnyul/fastlane-match` |
| Run Fastlane release | `main` only | Executes `fastlane release` only if match repo access succeeds |

---

## GitHub Secrets

All secrets are set on both the repo (`jonnyul/Boxing-Timer`) and the org (`jonnyul`).

| Secret | What it is |
|--------|-------------|
| `ASC_API_KEY_CONTENT` | Base64-encoded `AuthKey_3349GWYVGR.p8` |
| `ASC_KEY_ID` | `3349GWYVGR` |
| `ASC_ISSUER_ID` | `220f0894-51a2-449c-ad61-9715441b4a11` |
| `APPLE_TEAM_ID` | `3LN6SHFTXK` |
| `MATCH_PASSWORD` | Passphrase for the match certs repo |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 of `jonnyul:PAT` for the fastlane-match repo |
| `REVIEW_CONTACT_FIRST_NAME` | Jonathan |
| `REVIEW_CONTACT_LAST_NAME` | Ulloa |
| `REVIEW_CONTACT_PHONE` | Review contact phone number |
| `REVIEW_CONTACT_EMAIL` | Review contact email address |
| `VERCEL_TOKEN` | Vercel personal/team token |
| `VERCEL_ORG_ID` | Vercel team/org ID |
| `VERCEL_PROJECT_ID` | Vercel project ID for `web/site/` |

---

## Fastlane

Located at `ios/fastlane/`. Run from the `ios/` directory.

| Lane | Command | What it does |
|------|---------|--------------|
| `release` | `fastlane release` | Build + submit to App Store |
| `beta` | `fastlane beta` | Build + upload to TestFlight |
| `screenshots` | `fastlane screenshots` | Capture App Store screenshots |

Fastlane-specific behavior, match setup, screenshot capture details, and release-lane notes live in [agents/ios/fastlane.md](./ios/fastlane.md).

---

## Vercel (Web)

`web/site/` is deployed via Vercel. Connected via `web/site/.vercel/project.json`.

---

## Known Issues / Deadlines

- **SDK Warning (deadline: 2026-04-28):** ITMS-90725: Must build with iOS 26 SDK (Xcode 26) by April 28, 2026. Non-blocking until then.
- **Node.js 20 deprecation (deadline: 2026-06-02):** `actions/checkout@v4` uses Node.js 20. Non-blocking until June 2026.
- **CodeQL workflow removed:** This repo is private, so the previous CodeQL workflow was removed from `dev` and should stay absent unless the repo plan changes.
- **Current release blocker:** `MATCH_GIT_BASIC_AUTHORIZATION` does not currently allow GitHub Actions to clone `https://github.com/jonnyul/fastlane-match`, so the App Store submission path is gated behind a repository-access check instead of failing the whole build.
