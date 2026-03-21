# Fastlane — iOS Build & App Store Automation

Located at `ios/fastlane/`. Always run from the `ios/` directory.

---

## Lanes

| Lane | Command | What it does |
|------|---------|--------------|
| `release` | `fastlane release` | Build + submit to App Store (used by CI) |
| `beta` | `fastlane beta` | Build + upload to TestFlight |
| `screenshots` | `fastlane screenshots` | Capture App Store screenshots |
| `codesign` | `fastlane codesign` | Create dist cert + provisioning profile |

---

## Match (Code Signing)

- Private cert repo: https://github.com/jonnyul/fastlane-match
- Local copy: `/Users/buzzulloa/fastlane-match/`
- Type: appstore, Bundle ID: `john.Boxing-Timer`

---

## Build Number

The `release` lane fetches `latest_testflight_build_number` from ASC and adds 1. It never reads from the local xcodeproj.

When a version is already in `Ready For Review`, the release lane skips screenshot upload. App Store Connect can reject screenshot deletion/replacement for an in-review version, but binary upload and submission can still proceed.

---

## ENV Fallbacks (Fastfile / Appfile)

Constants fall back to hardcoded values for local runs; CI always provides secrets via env:

```ruby
KEY_ID    = ENV["ASC_KEY_ID"]    || "3349GWYVGR"
ISSUER_ID = ENV["ASC_ISSUER_ID"] || "220f0894-51a2-449c-ad61-9715441b4a11"
TEAM_ID   = ENV["APPLE_TEAM_ID"] || "3LN6SHFTXK"
```

---

## Patches Applied in CI

These are patched inline by ios-deploy.yml before running Fastlane. They fix upstream Fastlane bugs that aren't yet released:

| File | Change | Why |
|------|--------|-----|
| `token.rb` | `OpenSSL::PKey::EC.new` → `OpenSSL::PKey.read` | OpenSSL 3.x removed EC constructor |
| `model.rb` | `raise "No data"` → `return nil` | App Store review detail is nil on first submit |
| `upload_metadata.rb` | Safe navigator on `app_store_review_detail&.` | Nil guard to match model.rb fix |

---

## Screenshot Simulator UDIDs

Used by the `screenshots` lane. Update these in `Fastfile` if simulators are recreated.

| Device | UDID |
|--------|------|
| iPhone 17 Pro Max | `F2310914-3385-4C5A-8C0E-F990FFDAE113` |
| iPhone 17 Pro | `58539C49-E5C1-4566-9215-1CE33ACEB315` |
| iPhone 16e | `50F52ACB-529F-4D1F-A749-5D50790F72B4` |
