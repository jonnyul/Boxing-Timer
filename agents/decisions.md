# Decisions & Removed Features

Read this before adding any new feature. Many things that seem natural to add have already been explicitly removed.

## Removed Features — Do Not Re-Add

These were deliberately cut. Re-adding any of them will be reverted.

| Feature | Where it was | Why removed |
|---------|-------------|-------------|
| **Gloves Mode** (`startInGlovesMode`) | `TimerSettings`, `TimerViewModel`, `HomeView`, `OptionsView`, all preset defaults | Removed at user request |
| **About section** in OptionsView ("Remove Ads", "More On Web") | `OptionsView` | Removed at user request |
| **Behavior section** in OptionsView | `OptionsView` | Removed at user request |
| **Summary card** in HomeView | `HomeView` | Removed at user request — round/work/rest/total overview row |
| **Stats action buttons** | `StatsView` | Removed — "More On Web", "Close", "Clear All" |
| **Recent Workouts list** | `StatsView` | Removed — the workout history table is gone |
| **Period picker** | `StatsView` | Removed — week/month/all filter tabs |
| **Music Volume Dimmed** (`musicVolumeDimmed`) | `TimerSettings`, `OptionsView`, preset defaults | Removed at user request |
| **Break End Notice toggle** | `OptionsView` alerts section | Removed from options screen — still configurable on home/preset screens |
| **WorkoutName + Round fraction on lock screen** | `LiveActivityContentView` | Removed — lock screen now shows only phase name + timer |
| **Live Activity** | `Boxing Timer Live Activity` extension + `LiveActivityManager` + `WorkoutTimerAttributes` | Removed at user request |

## Design Decisions

### Preset card accent color — all orange
All preset cards use `.appOrange` for the accent bar and time label. Previously alternated cyan/red per card. Changed because cyan=active/positive and red=danger throughout the app, so alternating sent confusing signals. Orange is consistent with the presets page identity color.

### Page title second-word colors
Each page's second title word has its own color, creating per-tab visual identity (see `ui-system.md`). Body text stays white — color is reserved for hierarchy markers only, not content text.

### Start button label — "START ROUND" not "START FIGHT"
The main start button in HomeView says "START ROUND", not "START FIGHT". Do not change it back.

## Architectural Decisions

### No fullScreenCover for TimerView
`TimerView` is shown inline inside `HomeView` via a conditional. The tab bar stays visible during workouts. Rationale: user can switch tabs mid-workout; the timer continues running regardless of which tab is active.

### No Local Notifications
Bells fire via `AudioManager` + `AudioServicesPlaySystemSound` while the app is foregrounded or in background with an active audio session. No `UNUserNotificationCenter`. Rationale: simpler, no permission prompt, bell sounds fire immediately in sync with the timer.

### No Push Notifications for Live Activity
`pushType: nil` in `Activity.request(...)`. Live Activity updates are delivered locally by the main app process only. Rationale: the app has no server, all data is local.

### No iCloud / No Network
All data is stored locally on device. `Documents/` for presets and sessions, `UserDefaults` for timer settings. Rationale: user privacy, simpler architecture, no server costs.

### No HealthKit / No Watch
Not in scope. Do not add unless explicitly requested.

### Stats Load is Async
`StatsViewModel.loadSessions()` runs file I/O on a `Task.detached` background thread. This was added because synchronous file reads on the main thread blocked tab-switch animations (noticeable lag when tapping the Stats tab). See `ios/data-layer.md` for the exact pattern.

### LazyVGrid for ContributionHeatmap
The 365-day activity graph was originally a `GeometryReader` wrapping nested `HStack`/`VStack`. The hardcoded `.frame(height: 21 * 12 + 24)` didn't account for the dynamically computed `squareSize`, causing the bottom rows to be cut off. It was replaced with `LazyVGrid` + `.aspectRatio(1, contentMode: .fit)` which auto-sizes height from content. Do not revert to the GeometryReader approach.

### PersistenceManager Methods are nonisolated
`loadSessions()`, `saveSessions()`, and `documentsDirectory` are `nonisolated` because:
1. The whole project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
2. These methods do file I/O and must be callable from background threads
3. Calling them on the main thread blocked UI animations

### No #Preview Macros
Use `PreviewProvider` structs if previews are needed, or skip previews entirely.

