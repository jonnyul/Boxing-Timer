# iOS — Build & Deploy

## Project

- **Xcode project:** `ios/Boxing Timer.xcodeproj`
- **Language:** Swift 5 / SwiftUI
- **Deployment target:** iOS 26.2 (set in pbxproj)
- **No third-party dependencies.** Apple frameworks only.

## Targets

This project has one build target:

| Target | Bundle | Output | Purpose |
|--------|--------|--------|---------|
| `Boxing Timer` | `john.Boxing-Timer` | `Boxing Timer.app` | Main app |

Files in `ios/Boxing Timer/` are auto-included in the main app target via **filesystem-synchronized groups** (pbxproj objectVersion 77). Adding a Swift file to the directory is enough for target membership.

## Critical Compiler Flags

- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — **Every type is implicitly `@MainActor` unless explicitly opted out.** Mark methods or properties `nonisolated` to run them off the main actor. Mark methods `nonisolated` when they do file I/O or other blocking work that must run on a background thread.
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES` — Every file must explicitly import any framework it uses. No transitive imports.
- **Treat every warning as an error.** Do not ship builds with warnings. If xcodebuild output is non-empty, fix everything in it before declaring done.
- **No `#Preview` macros.** Use `PreviewProvider` structs if previews are needed, or skip them.

## Build Command

```bash
cd "ios" && xcodebuild \
  -project "Boxing Timer.xcodeproj" \
  -scheme "Boxing Timer" \
  -destination "id=00008120-00014D910E32601E" \
  -quiet build 2>&1
```

A clean build produces **empty output** (no stdout, no stderr beyond the launch line). Any text output = a warning or error that must be fixed.

On March 13, 2026 the app was rebuilt and reinstalled successfully after the timer-defaults, keypad-entry, explicit pressed-color, and dead-code cleanup update. `xcodebuild` completed successfully with no Swift compiler warnings or errors. The only remaining console line was Xcode's `IDERunDestination: Supported platforms for the buildables in the current scheme is empty.` note.

## Install Command

```bash
xcrun devicectl device install app \
  --device 00008120-00014D910E32601E \
  ~/Library/Developer/Xcode/DerivedData/Boxing_Timer-*/Build/Products/Debug-iphoneos/"Boxing Timer.app" 2>&1
```

## Device

- **Device name:** jonny
- **Device ID:** `00008120-00014D910E32601E`
- **Platform:** iOS physical device (not simulator)

## DerivedData Pattern

`~/Library/Developer/Xcode/DerivedData/Boxing_Timer-*/` — use glob, the hash suffix changes.
