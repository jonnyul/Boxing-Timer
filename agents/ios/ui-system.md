# iOS — UI System

## Aesthetic

Premium aggressive boxing. "UFC fight night meets Nike Training Club." Dark mode only. High contrast. Bold italic uppercase headings. Electric accent colors.

## Per-Page Color Identity

Each page has its own accent color used for the page title and its primary accent elements. Titles are a single word in the page's accent color, 32pt aggressiveHeading, left-aligned:

| Page | Title | Color | Notes |
|------|-------|-------|-------|
| Home (Timer) | TIMER | cyan | Left-aligned; total workout time block on top-right |
| Stats | STATS | green | Activity graph squares are also green |
| Presets | PRESETS | orange | Preset cards and icons are all orange |
| Settings | SETTINGS | `appTextSecondary` (gray) | Muted — utility page |
| Preset Edit | PRESETS | orange | Same title as Presets tab; back button on top-left |

Tab bar icons: Timer=`clock.fill` (cyan), Presets=`slider.horizontal.3` (orange), Stats=`chart.bar.fill` (green), Settings=`gearshape.fill` (gray).

## Color Tokens

Defined in `ColorExtension.swift`.

| Token | Hex | Usage |
|-------|-----|-------|
| `appBackground` | `#1C2A4A` | All screen backgrounds |
| `appBackgroundDeep` | `#152039` | Tab bar, headers, keypad sheet |
| `appCyan` | `#00F2FF` | Primary accent: timers, resume button, TIMER title |
| `appRed` | `#FF003D` | Round phase banner, stop button, danger |
| `appOrange` | `#EC5B13` | Presets tab, preset cards, save/confirm actions |
| `appGreen` | `#FFD700` | Done state |
| `appStatsGreen` | `#30D158` | Stats page title and heatmap |
| `appTextSecondary` | `#94A3B8` | Secondary/label text |
| Card border | `white @ 8%` | `RoundedRectangle` overlay stroke |
| Card background | `white @ 5%` | Card fill |

## Typography Scale

Defined in `AppDesign.Typography`. Each level doubles the previous.

| Token | Size | Usage |
|-------|------|-------|
| `rowTitleSize` | 15pt | Base: SettingRow titles, Privacy Policy text |
| `controlValueSize` | 20pt | Value readouts in SettingRow controls and preset stat cards |
| `cardTitleSize` | 30pt | Preset card name (`.cardTitle()`) — semibold, uppercase, NOT italic |
| `statNumberSize` | 38pt | Stats summary numbers (SESSIONS, MINUTES, ROUNDS) — 1.25× card title |
| `pageTitleSize` | 48pt | Page headings via `.aggressiveHeading(size: pageTitleSize)` — always add `.lineLimit(1).minimumScaleFactor(0.3)` directly on Text — 1.25× stat |

Phase banner in TimerView uses 48pt — fixed, not part of this scale.

## Design Tokens (`AppDesign` enum in `DesignSystem.swift`)

Single source of truth for all visual constants. Always pull from here instead of hardcoding.

### Radii
| Token | Value | Usage |
|-------|-------|-------|
| `Radius.card` | 16pt | Cards, sheet containers, chunky buttons |
| `Radius.badge` | 12pt | Icon badges, text fields, action buttons |
| `Radius.button` | 10pt | Compact inline buttons (value box, +/−) |
| `Radius.heatmap` | 3pt | Contribution graph squares + legend swatches |

### Spacing
`xxs=4, xs=6, sm=8, md=12, lg=16, xl=20, xxl=24`

### Card Surface
`Card.background = white/5`, `Card.border = white/8`, `Card.radius = 16pt`. Use `.cardStyle(padding:)` modifier.

### Controls (inline, inside setting rows)
`Control.radius = 10pt`, `Control.background = white/4%`, `Control.padding = 8pt`
`Control.iconSize = controlValueSize` (20pt)
**Sizing**: all control buttons (value box, +/−, action buttons, WorkoutInfo block) use `.padding(AppDesign.Control.padding)` — no `frame(height:)`. This keeps top/bottom equal to left/right padding.

### Action Buttons
Full-width icon-only buttons: play, reset, plus, checkmark, back.
`ActionButton.radius = 12pt`. Height is content-driven via `.padding(.vertical, AppDesign.Control.padding)` — **do not** use `frame(height: 44)`.
`ActionButton.iconSize = controlValueSize` (20pt) for symbol glyphs.

### Workout Info Block
Total workout time — shown in HomeView header, PresetCard top-left, PresetEditView bottom row.
`WorkoutInfo.iconSize = 14pt`, `WorkoutInfo.fontSize = Typography.controlValueSize` (matches timer rectangle values), `WorkoutInfo.background = #5DA9FF @ 15%`
Padding: `.padding(AppDesign.Control.padding)` — no fixed frame height.

### Semantic Icons
These SF Symbol names are fixed across all screens. Always use the matching color.

| Token | SF Symbol | Color | Meaning |
|-------|-----------|-------|---------|
| `Icons.rounds` | `repeat` | `.green` | Number of rounds |
| `Icons.work` | `flame.fill` | `.orange` | Round duration |
| `Icons.rest` | `pause.fill` | `.blue` | Break duration |
| `Icons.getReady` | `hourglass` | `.yellow` | Get-ready countdown |
| `Icons.roundEnd` | `bell.fill` | `.yellow` | Round-end notice |
| `Icons.breakEnd` | `bell.fill` | `.cyan` | Break-end notice |
| `Icons.time` | `clock.fill` | `.appOrange` | Total workout time |
| `Icons.play` | `play.fill` | navy/white | Start action |
| `Icons.plus` | `plus` | white | Save/add action |
| `Icons.reset` | `arrow.2.circlepath` | white | Reset to defaults |
| `Icons.confirm` | `checkmark` | white | Confirm/save |
| `Icons.back` | `chevron.left` | white | Go back |

## Typography Modifiers

| Modifier | Font | Usage |
|----------|------|-------|
| `.aggressiveHeading(size:)` | Black, italic, uppercase, -0.5 tracking | Page headings (`pageTitleSize` = 120pt + `minimumScaleFactor(0.3)`), phase banner (48pt — do not change) |
| `.labelUppercase(size:)` | Heavy, uppercase, +2 tracking, secondary color | Section labels, card subtitles, preset stats |
| `.timerDisplay(size:)` | Black, monospaced, -2 tracking, monospacedDigit, fixedSize(vertical) | Main countdown timer (96pt) |
| `.rowTitle()` | `rowTitleSize` = 15pt semibold italic uppercase | SettingRow titles, Privacy Policy — base of the type scale |
| `.cardTitle()` | `cardTitleSize` = 30pt semibold italic uppercase (2× rowTitle) | Preset card name |

**`minimumScaleFactor` must be applied directly to `Text`, not through a `ViewModifier` wrapper** — the scaling never reaches the text renderer when wrapped.

## Spacing & Layout Rules

- Screen top padding: 20pt (`.padding(.top, 20)`)
- Screen horizontal/bottom padding: 16pt (`.padding([.horizontal, .bottom])`)
- VStack spacing between sections: `AppDesign.Layout.rowSpacing` (12pt) throughout all tabs
- **`Layout.titleBottomTrim`**: negative bottom padding (e.g. `-10pt`) on **page titles** and on the **Home total-workout pill** so the visual gap to the next row matches row-to-row spacing. **Do not** put negative padding on small square header buttons — `PressFeedbackButtonStyle` uses `clipShape` and will clip the label. Presets `+`: use `HStack(alignment: .bottom)` with the title, and a fixed `frame(width:height:)` square (`ActionButton.height` × `ActionButton.height`) for the icon — no trim on the button.
- Card internal padding: 16pt (`.cardStyle(padding: 16)`)
- All SettingRow titles: uppercase, centered, `lineLimit(2)`, `minimumScaleFactor(0.8)`

## Buttons

### Action Buttons (standalone icon-only)
Used at the bottom of HomeView and inside PresetCard. Height 44pt, radius 12pt, font 20pt bold.
```swift
// Play (cyan)
PressFeedbackButtonStyle(cornerRadius: 12, normalBackground: .appCyan, pressedBackground: .appCyanPressed)
// Reset (ghost)
PressFeedbackButtonStyle(cornerRadius: 12, normalBackground: Color.white.opacity(0.08), pressedBackground: Color.white.opacity(0.15))
// Plus / Save / Confirm (orange)
PressFeedbackButtonStyle(cornerRadius: 12, normalBackground: .appOrange, pressedBackground: .appOrangePressed)
// Back (ghost)
PressFeedbackButtonStyle(cornerRadius: 12, normalBackground: Color.white.opacity(0.08), pressedBackground: Color.white.opacity(0.15))
```
Back/plus/check/play/reset icon glyphs should use `AppDesign.Typography.controlValueSize` with `.padding(AppDesign.Control.padding)` unless a screen-specific exception is documented.

### Chunky Buttons (text label, full-width)
Used in TimerView (PAUSE, RESUME, STOP).
```swift
.buttonStyle(.chunkyPrimary)   // cyan bg — resume
.buttonStyle(.chunkyDanger)    // red bg  — stop
.buttonStyle(.chunkyGhost)     // white/10 — pause
```
Spec: 18pt black italic uppercase, 20pt vertical padding, 16pt corner radius.

### Interaction Feedback
No scale or pressed-state color changes app-wide (static, instant feel). The only exception is `NumericSettingEditorSheet` which flashes digit boxes red and shakes on invalid input.

## Components

### AppBackground
```swift
AppBackground()
```
Required on every page. Dark navy base + red gradient from the top. Never substitute with a raw color fill.

### SettingRow
Two modes:
```swift
SettingRow(icon: "repeat", iconColor: .green, title: "ROUND", mode: .count(range: 1...50), value: $rounds)
SettingRow(icon: "flame.fill", iconColor: .orange, title: "ROUND LENGTH", mode: .duration(), value: $roundDuration)
```
- Title is uppercase, 15pt semibold italic white, centered in available space
- Tapping the icon badge resets that field to its default value
- Tapping the value chip opens `NumericSettingEditorSheet`
- `+` / `−` apply the configured step immediately — SF Symbols `plus.circle.fill` / `minus.circle.fill` use `.font(.system(size: AppDesign.Typography.controlValueSize, weight: .bold))` and `.padding(AppDesign.Control.padding)` to match value-chip text size and insets.

### NumericSettingEditorSheet
Custom keypad for direct numeric entry. Fixed `height(420)` detent.
- Duration values render as `MM:SS`
- Keypad buttons: 44pt tall (`ActionButton.height`). Digit/backspace symbols use `controlValueSize` and `.padding(AppDesign.Control.padding)`.
- Apply button: checkmark icon (not text), full-width, uses `controlValueSize` + `.padding(AppDesign.Control.padding)` and the active setting's color.
- Invalid entry: digit boxes flash red and shake; no change committed

### IconBadge
```swift
IconBadge(systemName: "flame.fill", color: .orange)
```
Default is 44×44pt, colored background at 15% opacity, 12pt corner radius. For SettingRow left icons, pass explicit `size` and `iconSize` so icon glyph uses `controlValueSize` with effective insets matching `Control.padding`.
Use the same explicit `size`/`iconSize` pattern for the Settings Privacy Policy icon badge.

### Workout Info Block
Shown top-right of HomeView header, PresetCard top-left, and PresetEditView bottom row. On HomeView, apply `.padding(.bottom, AppDesign.Layout.titleBottomTrim)` to the pill so spacing to `TimerSettingsEditor` matches SettingRow gaps.
```swift
HStack(spacing: 6) {
    Image(systemName: "clock.fill").font(.system(size: AppDesign.WorkoutInfo.iconSize))
    Text(totalSeconds.mmss).font(.system(size: AppDesign.WorkoutInfo.fontSize, weight: .bold, design: .monospaced))
}
.foregroundColor(.white)
.padding(AppDesign.Control.padding)
.background(AppDesign.WorkoutInfo.background)
.cornerRadius(AppDesign.ActionButton.radius)
```

### PresetCard
Card in PresetsView. Internal padding: 16pt (`AppDesign.Spacing.lg`).
- **Top row**: Total workout time pill (same as Workout Info Block) + `Spacer` + ellipsis `Menu` (edit/delete).
- **Preset name**: `.cardTitle()` — `cardTitleSize`, semibold, uppercase. `.lineLimit(1).minimumScaleFactor(0.5)` on `Text`.
- **Stats row** (under title): Single `HStack` with three `presetStatCard` pills — **icon + value only** (no "ROUNDS" / "WORK" / "REST" text). `repeat` (green) + round count, `flame.fill` (orange) + round duration MM:SS, `pause.fill` (blue) + break duration MM:SS. Each pill: `.padding(AppDesign.Control.padding)`, `.frame(maxWidth: .infinity)`, `Radius.button`, value font `controlValueSize`. Do NOT use `TimerInfoCard` here.
- **Play button**: icon-only (`play.fill`), orange, full-width, icon uses `controlValueSize` and `.padding(AppDesign.Control.padding)` (same as SettingRow value controls).

### Timer Info Cards (TimerView)
The three cards in the active timer screen (ROUNDS, WORK, REST):
```swift
timerInfoCard(title: "ROUNDS", value: "...", icon: "repeat")
timerInfoCard(title: "WORK",   value: ...,   icon: "flame.fill")
timerInfoCard(title: "REST",   value: ...,   icon: "pause.fill")
```
Pattern: `IconBadge` + bold monospaced value + `labelUppercase(size: 8)` title. Cards use `cornerRadius(AppDesign.Radius.card)`.
**Padding**: `.padding(16)` — uniform 16pt all sides. Matches `presetStatCard` in PresetCard.

## Navigation

- 4-tab `TabView`: Timer, Presets, Stats, Settings
- Each tab owns a root `NavigationStack` (Presets tab uses path-based navigation)
- **Preset editing is a push navigation page** (not a sheet) — tab bar stays visible
- `AppNavigationState` (in `TimerViewModel.swift`) owns:
  - `selectedTab: AppTab`
  - `presetsPath: [PresetsDestination]` — drives `NavigationStack` in `PresetsView`
  - `presetsNewPresetSettings: TimerSettings?` — pre-fills the add-preset page
  - `presetsReturnTab: AppTab` — determines which tab `<` navigates back to
- `PresetsDestination` enum: `.add` or `.edit(UUID)`
- Pressing `+` from the Timer tab: sets `presetsReturnTab = .timer`, switches to Presets tab, pushes `.add`
- Pressing `+` from the Presets tab: sets `presetsReturnTab = .presets`, pushes `.add`
- Pressing `<` in PresetEditView: calls `dismiss()` then switches to `presetsReturnTab` if not already `.presets`

## ContributionHeatmap (StatsView)

365-day GitHub-style activity graph. **Implemented with `Canvas`** — a single draw call. Do not replace with LazyVGrid.

Key constraints:
- `Canvas { ctx, size in ... }` with `.frame(height: gridHeight)`
- `squareSize` updated by `.onGeometryChange(for: CGFloat.self)`
- 18 columns, legend squares use `AppDesign.Radius.heatmap` (3pt) cornerRadius
- Intensity: `0.25 + intensity * 0.75` opacity on `appStatsGreen`. Empty days: `white/6%`

## Animations

- **Phase banner pulse**: `PulseEffect` ViewModifier in `TimerView.swift`. Pulses on `isInNoticeWindow`.
- **Progress bars**: `.animation(.linear(duration: 1.0))` on round progress bars.
- **Button press**: No animations.

## SegmentedRoundProgressBar

- Rows of up to 10 bars (supports 50 rounds)
- Incomplete rows centered horizontally
- Fill color always `appOrange`
- During `.breakTime`: completed rounds show as filled
- During `.done`: all bars filled

## Do Not

- Do not use `.navigationBarHidden(false)` — all nav bars are hidden
- Do not use `UIKit` views — pure SwiftUI only
- Do not use raw `Color.appBackground` as page background — always `AppBackground()`
- Do not use `#Preview` macros
- Do not apply `minimumScaleFactor` inside a `ViewModifier` — apply directly on `Text`
