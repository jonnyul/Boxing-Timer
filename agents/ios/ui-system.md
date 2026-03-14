# iOS — UI System

## Aesthetic

Premium aggressive boxing. "UFC fight night meets Nike Training Club." Dark mode only. High contrast. Bold italic uppercase headings. Electric accent colors.

## Per-Page Color Identity

Each page has its own accent color used for the second word of the page title and its primary accent elements:

| Page | Title | Second word color | Notes |
|------|-------|------------------|-------|
| Home (Timer) | BOXING / TIMER | cyan | Timer countdown, resume button, and TIMER tab icon are all cyan |
| Stats | TRAINING / STATS | green | Activity graph squares are also green |
| Presets | WORKOUT / PRESETS | orange | Preset card accent bars and MIN text are all orange |
| Settings | APP / SETTINGS | `appTextSecondary` (gray) | Muted — settings is a utility page |

Tab bar icons: Timer=cyan, Presets=orange, Stats=green, Settings=gray.

## Color Tokens

Defined in `AppUI.swift` as static `Color` extensions for the app target, and duplicated locally inside `ios/Boxing Timer Live Activity/Boxing_TimerLiveActivity.swift` for the widget target.

| Token | Hex | Usage |
|-------|-----|-------|
| `appBackground` | `#1C2A4A` | All screen backgrounds |
| `appBackgroundDeep` | `#152039` | Tab bar, headers, cards in live activity |
| `appCyan` | `#00F2FF` | Primary accent: values, timers, resume button, progress |
| `appRed` | `#FF003D` | Round phase banner, stop button, danger actions |
| `appOrange` | `#EC5B13` | Tab bar active tint, preset start buttons, progress fill |
| `appGreen` | `#FFD700` | Done state (minimal use) |
| `appTextSecondary` | `#94A3B8` | All secondary/label text |
| Card border | `white @ 8%` | `RoundedRectangle` overlay stroke |
| Card background | `white @ 5%` | Card fill |
| Divider | `white @ 5%` | Section separators |

## Typography Modifiers

| Modifier | Font | Usage |
|----------|------|-------|
| `.aggressiveHeading(size:)` | Black weight, italic, uppercase, -0.5 tracking | Page titles, phase banner |
| `.labelUppercase(size:)` | Heavy weight, uppercase, +2 tracking, secondary color | Section labels, card subtitles |
| `.timerDisplay(size:)` | Black weight, monospaced, -2 tracking, monospacedDigit, fixedSize(vertical) | Main countdown timer |

## Card Container

`.cardStyle(padding:)` applies: `padding`, `white/5` background, 16pt corner radius, `white/8` border stroke.

Used for all content sections (stats cards, contribution graph container, settings groups).

## Buttons

All buttons use `ChunkyButtonStyle` or `PressFeedbackButtonStyle` variants.
```swift
.buttonStyle(.chunkyPrimary)   // cyan bg, dark text — resume, confirm
.buttonStyle(.chunkyDanger)    // red bg, white text — stop
.buttonStyle(.chunkyOrange)    // orange bg, white text — start, presets
.buttonStyle(.chunkyGhost)     // white/10 bg, white text — pause, secondary
```

Button spec: 18pt black italic uppercase, 20pt vertical padding, 16pt corner radius.

### Interaction Feedback
- **No Scale/Pressed States**: All scale effects and pressed-state background color changes have been removed app-wide for a static, instant feel.
- **Keypad Feedback**: Keypad and numeric buttons do not change color when pressed.

The only remaining tap-related visual feedback in the timer editor flow is invalid-entry feedback inside `NumericSettingEditorSheet`:
- if a keypad edit would go out of range, the digit boxes flash red and shake
- normal valid button presses do not change button color

## Components

### AppBackground
```swift
AppBackground()
```
Required on every page. Provides the dark navy base + red gradient from the top. Never substitute with a raw color fill.

### SettingRow
Two modes:
```swift
SettingRow(label: "ROUNDS", icon: "repeat", iconColor: .green, binding: $vm.rounds, mode: .count(range: 1...20, step: 1, suffix: ""))
SettingRow(label: "WORK", icon: "flame.fill", iconColor: .orange, binding: $vm.roundDuration, mode: .duration(min: 30, max: 600, step: 30))
```
Use for all new stepper or duration settings. Do not build one-off stepper HStacks.

Each row now supports two editing paths:
- `-` / `+` still apply the configured step increment immediately.
- Tapping the value chip opens `NumericSettingEditorSheet`, a focused bottom sheet with a custom keypad and place-value editing.

The value chip includes a pencil affordance. Keep that pattern for any future tappable numeric setting rows.

### NumericSettingEditorSheet

Reusable numeric-entry sheet used by both the timer home screen and the preset editor.

Behavior:
- Count-based values render as fixed-width digits based on the max range width.
- Duration values render as `MM:SS` with separate selectable digits.
- Tapping a digit selects the current place.
- Typing a keypad digit replaces only the selected place, then advances one place to the right.
- Backspace zeroes the selected place and moves one place to the left.
- Changes are committed only when the user taps `Apply`.
- The sheet opens directly at its single tall detent (`.fraction(0.86)`) so the keypad is already expanded when presented.
- The duplicate preview value under the digit boxes has been removed.
- The `Apply` button uses the active setting color rather than a shared orange accent.
- If a typed or backspaced value would fall outside the setting's allowed range, the digit boxes stay on the current valid value, flash red, and shake horizontally.

This sheet is the approved solution for "show the current field while the keypad is up" because it isolates the field instead of forcing the parent scroll view to shift around it.

### IconBadge
```swift
IconBadge(systemName: "flame.fill", color: .orange)
```
44×44pt, colored background at 15% opacity, 12pt corner radius.

### Timer info card
The three-card grid in `TimerView` is still local to `MainTimerViews.swift`: each card shows an icon badge, bold monospaced value, and uppercase label. Pattern:
```swift
VStack(spacing: 6) {
    IconBadge(systemName: icon, color: iconColor)
    Text(value).font(.system(size: 18, weight: .bold, design: .monospaced)).foregroundColor(.white)
    Text(title).labelUppercase(size: 8)
}
.frame(maxWidth: .infinity)
.padding(.vertical, 16)
.background(Color.white.opacity(0.05))
.cornerRadius(12)
.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
```

## ContributionHeatmap (StatsView)

365-day GitHub-style activity graph. **Implemented with `Canvas`** — a single draw call. Do not replace with LazyVGrid or any individual view approach.

Key constraints:
- **Uses `Canvas { ctx, size in ... }` with `.frame(height: gridHeight)`.** `gridHeight` is derived from `@State private var squareSize: CGFloat = 14`.
- `squareSize` is updated by `.onGeometryChange(for: CGFloat.self) { $0.size.width } action: { ... }` — fires once when the view lays out, computing exact squareSize from available width.
- All drawing data (`dailyCounts`, `days`) is precomputed as local `let` constants in `body` before being captured by the Canvas closure. This avoids recomputing per-frame.
- The Canvas closure must not call `self` methods — inline all color logic directly in the closure using the captured local constants.
- 18 columns × 21 rows = 378 cells; only 365 are drawn (loop runs `0..<allDays.count`).
- Legend squares use the same `squareSize` state variable. Legend text scales as `max(9, squareSize * 0.8)`.

Intensity levels (cyan opacity): continuous — `0.25 + intensity * 0.75` where `intensity` is a normalized [0,1] value. Empty days use opacity 0.06. Color logic is inlined directly in the Canvas closure (no helper method on `self`). Legend levels are `[0, 0.25, 0.5, 0.75, 1.0]` mapped through the same formula.

**Why Canvas**: LazyVGrid with 378 cells creates 378 SwiftUI view objects. This layout cost blocks the main thread during tab-switch animations, causing liquid glass tab bar lag on the Stats tab. Canvas is a single draw call with zero view objects — the render is instant.

## Navigation

- 4-tab `TabView`: Timer, Presets, Stats, Settings
- Global tab tint is white, but each tab icon is rendered with its own explicit color image
- Each tab owns a root `NavigationStack`
- Preset editing is presented as a sheet, not push navigation
- "Save as Preset" from the timer home screen opens the same preset-edit sheet used by the Presets tab, prefilled with the current timer values
- Preset edit sheets presented from the Timer and Presets tabs use the system drag indicator instead of an in-content close button

## Animations

- **Phase banner + timer display pulse**: handled by `PulseEffect` ViewModifier (defined in `TimerView.swift`). When `isInNoticeWindow` becomes `true`, `withAnimation(.repeatForever)` starts a scale pulse (1.03–1.05, `easeInOut(0.5s)` autoreverse). When `isInNoticeWindow` becomes `false`, `withAnimation(.spring(duration: 0.15))` cleanly snaps scale back to 1.0. There is no `@State isPulsing` flag — the ViewModifier drives itself via `onChange(of: isInNoticeWindow)`.
- **Button press**: No scale or color animations.
- **Tab switching**: system default
- **Progress bars**: `.animation(.linear(duration: 1.0))` to interpolate discrete 1-second ticks.

## Elapsed / Remaining Time

`TimerView` displays ELAPSED and REMAINING labels below the main timer countdown. These use secondary text styling: size 16 monospaced, `appTextSecondary` color. They are always visible during active workout phases.

The elapsed/remaining section is positioned using fixed padding rather than `Spacer()` instances:
- `.padding(.top, 20)` at the bottom of the main timer
- `.padding(.bottom, 16)` between the timer and the elapsed/remaining block
- `.padding(.bottom, 16)` between the elapsed/remaining block and the info cards row

The top "ROUND x/y" text has been removed from the timer layout.

## Timer Digit Clipping Fix

`.padding(.trailing, 4)` is applied to the timer text container to prevent the rightmost digit from being clipped at large font sizes on smaller screen widths.

## SegmentedRoundProgressBar

The round-progress bar below the main timer has the following layout rules:

- Rounds are displayed in rows of up to 10 bars each (supports up to 50 rounds total).
- Incomplete rows (the last row when total rounds are not a multiple of 10) are centered horizontally.
- `GeometryReader` is used to calculate consistent bar widths regardless of screen size.
- Each bar fills smoothly using `.animation(.linear(duration: 1.0))` so the progress visually interpolates between 1-second ticks.
- During `.breakTime` phase, completed rounds (including the round that just ended) show as fully filled, so the bar doesn't disappear during breaks.
- During `.done` phase, all bars including the current round bar show as completed.
- **Fill color is always `appOrange`** — the fill does not switch to `appRed` during the notice window.
- The fill is a plain `Rectangle` (or `Color`) clipped with `.clipShape(RoundedRectangle(cornerRadius: 4))` so it stays within the bar's rounded corners and does not overflow at the leading edge when progress is near zero.

## Do Not

- Do not use `.navigationBarHidden(false)` — all nav bars are hidden on all screens
- Do not add `#Preview` macros — use `PreviewProvider` or skip
- Do not use `UIKit` views — pure SwiftUI only
- Do not use raw `Color.appBackground` as a page background — always `AppBackground()`
