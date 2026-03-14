# iOS — Source Map

Current source layout after the March 13, 2026 split into per-concern files.

## Main App Target (`ios/Boxing Timer/`)

### App Entry

| File | Purpose |
|------|---------|
| `Boxing_TimerApp.swift` | `@main` app entry. Creates the 4-tab `TabView`, injects environment objects, configures nav/tab bar appearance, and sets up the audio session. |

### Models/

| File | Purpose |
|------|---------|
| `Models/TimerSettings.swift` | `TimerSettings` struct (rounds, durations, bell type, total-time helper). |
| `Models/Preset.swift` | `Preset` struct (identifiable, codable workout preset). |
| `Models/WorkoutSession.swift` | `WorkoutSession` struct (identifiable, codable session record). |

### ViewModels/

| File | Purpose |
|------|---------|
| `ViewModels/TimerViewModel.swift` | `TimerViewModel`, `TimerPhase`, `AppTab`, and `AppNavigationState`. All timer logic, background/foreground handling, and session saving. |
| `ViewModels/PresetsViewModel.swift` | `PresetsViewModel` — loads, adds, updates, and deletes presets via `PersistenceManager`. |
| `ViewModels/StatsViewModel.swift` | `StatsViewModel` — loads sessions off the main thread; exposes aggregate stats. |

### Views/

| File | Purpose |
|------|---------|
| `Views/HomeView.swift` | `HomeView` — idle home screen with settings editor, centered `Save as Preset` action, and start button; shows `TimerView` while running. |
| `Views/TimerView.swift` | `TimerView`, `SegmentedRoundProgressBar`, `PulseEffect` — active-workout display, elapsed/remaining time, pause/stop controls. |
| `Views/PresetsView.swift` | `PresetsView`, `PresetCard` — preset list, start/edit/delete actions. |
| `Views/PresetEditView.swift` | `PresetEditView` — sheet for creating or editing a preset; can also be opened prefilled from the timer screen via `initialSettings`; uses the sheet drag indicator instead of an in-content close button. |
| `Views/StatsView.swift` | `StatsView`, `StatSummaryCard`, `ContributionHeatmap` — training history with centered page title. |
| `Views/OptionsView.swift` | `OptionsView` — bell-type picker and privacy policy link. |

### Components/

| File | Purpose |
|------|---------|
| `Components/AppBackground.swift` | `AppBackground` — full-screen gradient background. |
| `Components/SegmentedPicker.swift` | `SegmentedPicker<T>` — generic horizontal segmented control. |
| `Components/NumericSettingEditorSheet.swift` | `NumericSettingEditorSheet` — custom keypad sheet for direct numeric entry with place-value selection, zero-out backspace behavior, active-color Apply button, and a fixed tall detent. |
| `Components/SettingRow.swift` | `SettingRow` — stepper row with icon, label, +/− controls, and tap-to-edit value chip. |
| `Components/TimerSettingsEditor.swift` | `TimerSettingsEditor` — stacked `SettingRow`s for all timer parameters; owns the sheet routing for keypad-based editing. |

### Utilities/

| File | Purpose |
|------|---------|
| `Utilities/AudioManager.swift` | `AudioManager` — plays system sounds and manages silent background-audio keep-alive. |
| `Utilities/ColorExtension.swift` | `Color` hex initializer and all app color tokens. |
| `Utilities/DesignSystem.swift` | Typography modifiers (`AggressiveHeading`, `LabelStyle`, etc.), `CardStyle`, `ChunkyButtonStyle`, `TintedChunkyButtonStyle`, `PressFeedbackButtonStyle`, `IconBadge`, `SectionHeader`, and all `View` / `ButtonStyle` convenience extensions. |
| `Utilities/Extensions.swift` | `Int.mmss` formatting helper. |
| `Utilities/PersistenceManager.swift` | `PersistenceManager` — UserDefaults for settings; JSON files for presets and sessions; no preset seeding; one-time cleanup of legacy built-in presets. |
