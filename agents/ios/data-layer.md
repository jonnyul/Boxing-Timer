# iOS — Data Layer

## Storage Locations

| Data | Location | Format |
|------|----------|--------|
| `TimerSettings` | `UserDefaults` key `"timerSettings"` | JSON-encoded |
| `[Preset]` | `Documents/presets.json` | JSON array |
| `[WorkoutSession]` | `Documents/sessions.json` | JSON array, newest-first |
| Live Activity state | ActivityKit in-memory only | Not persisted |

No iCloud, no network, no HealthKit, no CoreData, no SwiftData.

## PersistenceManager Threading Rules

`PersistenceManager` is implicitly `@MainActor` (project-wide default). However, `loadSessions()`, `saveSessions()`, `documentsDirectory`, and related file I/O methods are marked **`nonisolated`** so they can be called from background threads without blocking the main actor.

**Current `nonisolated` methods in PersistenceManager:**
- `var documentsDirectory: URL`
- `func loadSessions() -> [WorkoutSession]`
- `func saveSessions(_ sessions: [WorkoutSession])`

Any new method that does file I/O should also be `nonisolated`.

## Async Load Pattern for StatsViewModel

`StatsViewModel.loadSessions()` loads sessions **off the main thread** to avoid blocking tab-switch animations:

```swift
func loadSessions() {
    let pm = PersistenceManager.shared   // captured here, on MainActor
    Task {
        let loaded = await Task.detached(priority: .userInitiated) {
            pm.loadSessions()            // runs on background thread
        }.value
        sessions = loaded               // back on MainActor
    }
}
```

Key detail: `PersistenceManager.shared` must be captured **before** entering the detached task because `shared` is a `@MainActor` static property — accessing it inside `Task.detached` would be a concurrency violation.

## Models

### WorkoutSession
```swift
struct WorkoutSession: Identifiable, Codable, Sendable {
    var id: UUID
    var date: Date
    var durationMinutes: Int
    var roundsCompleted: Int
    var presetName: String
}
```
Saved at workout completion. Newest-first in the array.

### TimerSettings
```swift
struct TimerSettings: Codable {
    var numberOfRounds: Int
    var roundDuration: Int          // seconds
    var breakDuration: Int          // seconds
    var roundEndNotice: Int         // seconds before round ends
    var breakEndNotice: Int         // seconds before break ends
    var getReadyDuration: Int       // seconds
    var bellsType: Int              // 1, 2, or 3
}
```

Current first-launch defaults:
- `numberOfRounds = 12`
- `getReadyDuration = 5`
- `roundDuration = 180`
- `roundEndNotice = 10`
- `breakDuration = 60`
- `breakEndNotice = 10`
- `bellsType = 1`

These defaults only apply when no saved `timerSettings` payload exists in `UserDefaults`. Once a user changes settings and they are saved, the app restores the saved values instead of reapplying defaults.

### Preset
```swift
struct Preset: Identifiable, Codable {
    var id: UUID
    var name: String
    var settings: TimerSettings
    var summaryLine: String { get }  // computed, e.g. "12 × 3:00 / 1:00"
}
```

## Preset Defaults

There are no seeded presets anymore.

`PersistenceManager.loadPresets()` now returns an empty array when `Documents/presets.json` does not exist.

`PersistenceManager` also runs a one-time cleanup that removes the legacy built-in presets from existing installs when they exactly match the old shipped preset names/settings:
- `"HIIT 10 x 30/30"`
- `"Long Boxing"`
- `"Short Boxing"`

## Persistence Access Rules

- **Always** go through `PersistenceManager.shared`. Never touch `UserDefaults` or the file system directly from a View or ViewModel.
- `StatsViewModel` keeps sessions in memory (`@Published var sessions`). `addSession()` in the VM both updates the in-memory array and writes to disk.
- `PresetsViewModel` is the sole owner of the presets array in memory.
- `PresetEditView` can now be initialized with `initialSettings` so the timer screen can launch the preset sheet prefilled from the current custom timer values.
