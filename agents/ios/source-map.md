# iOS — Source Map

Current source layout.

## Main App Target (`ios/Boxing Timer/`)

### App Entry

| File | Purpose |
|------|---------|
| `Boxing_TimerApp.swift` | `@main` app entry. Creates the 4-tab `TabView`, injects environment objects, configures nav/tab bar appearance, sets up audio session. Tab bar timer icon is `clock.fill`. |

### Models/

| File | Purpose |
|------|---------|
| `Models/TimerSettings.swift` | `TimerSettings` struct (rounds, durations, bell type, total-time helper). |
| `Models/Preset.swift` | `Preset` struct (identifiable, codable workout preset). |
| `Models/WorkoutSession.swift` | `WorkoutSession` struct (identifiable, codable session record). |

### ViewModels/

| File | Purpose |
|------|---------|
| `ViewModels/TimerViewModel.swift` | `TimerViewModel`, `TimerPhase`, `AppTab`, `PresetsDestination`, and `AppNavigationState`. All timer logic, background/foreground handling, and session saving. `AppNavigationState` owns `selectedTab`, `presetsPath`, `presetsNewPresetSettings`, and `presetsReturnTab`. |
| `ViewModels/PresetsViewModel.swift` | `PresetsViewModel` — loads, adds, updates, and deletes presets via `PersistenceManager`. |
| `ViewModels/StatsViewModel.swift` | `StatsViewModel` — loads sessions off the main thread; exposes aggregate stats. |

### Views/

| File | Purpose |
|------|---------|
| `Views/HomeView.swift` | `HomeView` — idle home screen. Title "TIMER" (32pt, cyan, left-aligned) with total workout time block on top-right. Shows `TimerSettingsEditor` + three action buttons (play, reset, plus). Pressing plus sets `presetsReturnTab = .timer` and navigates to the preset-add page in the Presets tab. Shows `TimerView` inline while running. |
| `Views/TimerView.swift` | `TimerView`, `SegmentedRoundProgressBar` — active-workout display, phase banner, elapsed/remaining time, timer info cards (ROUNDS/WORK/REST), round progress bar, pause/stop controls. |
| `Views/PresetsView.swift` | `PresetsView`, `PresetCard` — uses `NavigationStack(path: $navigationState.presetsPath)` for path-based navigation. `PresetCard` shows clock icon + total time (orange), preset name, stats row with semantic icons (repeat/flame/pause), and a 44pt play-icon-only button. |
| `Views/PresetEditView.swift` | `PresetEditView` — push-navigation page (not a sheet) for creating or editing a preset. Has a `<` back button top-left that returns to `presetsReturnTab`. Title is "PRESETS" (32pt, orange). Contains `TimerSettingsEditor`, name text field (44pt), total workout info block (44pt), and checkmark confirm button (44pt). |
| `Views/StatsView.swift` | `StatsView`, `StatSummaryCard`, `ContributionHeatmap` — training history. |
| `Views/OptionsView.swift` | `OptionsView` — privacy policy link only. |

### Components/

| File | Purpose |
|------|---------|
| `Components/AppBackground.swift` | `AppBackground` — full-screen gradient background. Required on every screen. |
| `Components/SegmentedPicker.swift` | `SegmentedPicker<T>` — generic horizontal segmented control. |
| `Components/NumericSettingEditorSheet.swift` | `NumericSettingEditorSheet` — keypad sheet. `height(420)` detent. Keypad buttons 44pt. Apply is a checkmark icon (not text), 44pt, uses active setting color. |
| `Components/SettingRow.swift` | `SettingRow` — stepper row with icon badge, uppercase italic label (centered), value chip, +/− controls. Icon tap resets to default. |
| `Components/TimerSettingsEditor.swift` | `TimerSettingsEditor` — stacked `SettingRow`s for all 6 timer parameters. Labels: ROUND, READY, ROUND LENGTH, ROUND END, BREAK LENGTH, BREAK END. |

### Utilities/

| File | Purpose |
|------|---------|
| `Utilities/AudioManager.swift` | `AudioManager` — plays system sounds; manages background audio keep-alive. |
| `Utilities/ColorExtension.swift` | `Color` hex initializer and all app color tokens. |
| `Utilities/DesignSystem.swift` | `AppDesign` enum (Radius, Spacing, Card, Badge, Control, ActionButton, WorkoutInfo, Icons, Layout tokens), typography modifiers (`AggressiveHeading`, `LabelStyle`, `TimerDisplayStyle`, `CardStyle`), `ChunkyButtonStyle`, `PressFeedbackButtonStyle`, `TintedChunkyButtonStyle`, `IconBadge`, `SectionHeader`. |
| `Utilities/Extensions.swift` | `Int.mmss` formatting helper. |
| `Utilities/PersistenceManager.swift` | `PersistenceManager` — UserDefaults for settings; JSON files for presets and sessions. |
