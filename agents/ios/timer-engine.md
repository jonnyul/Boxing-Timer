# iOS — Timer Engine

## State Machine

```
idle → getReady → round → breakTime → round → breakTime → ... → done → idle
```

Enum `TimerPhase`: `idle`, `getReady`, `round`, `breakTime`, `done`

Phase durations come from `TimerSettings`:
- `getReady` → `getReadyDuration` seconds
- `round` → `roundDuration` seconds
- `breakTime` → `breakDuration` seconds
- `done` → no countdown, terminal state

## Phase Transitions

Managed by `TimerViewModel.advancePhase()`. Called when `timeRemaining` reaches 0.

```
getReady     → round (round 1)
round        → breakTime     (if currentRound < numberOfRounds)
round        → done          (if currentRound == numberOfRounds)
breakTime    → round         (increment currentRound)
done         → idle          (auto or on stop)
```

## Notice Windows

`isInNoticeWindow` is set to `true` when `timeRemaining == noticeTime` for the current phase (one-time trigger on the exact tick). It remains `true` until `advancePhase()` clears it on phase transition:
- Round end notice: configurable seconds before round ends
- Break end notice: configurable seconds before break ends

Notice window triggers visual pulse animation on the phase banner and timer display (via the `PulseEffect` ViewModifier in `TimerView.swift` — not inline `.animation(.repeatForever)`), and changes timer color to red.

## Progress Computation

`progress` (passed to `SegmentedRoundProgressBar`) is computed as:
```
progress = 1 - (timeRemaining / phaseDuration)
```
This is a value in [0, 1] that increases from 0 at phase start toward 1 at phase end.

Since `timeRemaining` is an integer that decrements once per second, `progress` jumps in discrete steps between ticks; the `.animation(.linear(duration: 1.0))` on `SegmentedRoundProgressBar` interpolates these steps smoothly — the 1.0 s duration matches the tick interval for continuous, gapless fill.

The bar reaches its maximum computed `progress` value just before the phase ends (when `timeRemaining == 1`, `progress = 1 - 1/phaseDuration`, which is just under 1.0). It fills fully because when the round ends and transitions to `.breakTime`, `SegmentedRoundProgressBar.isCompleted()` marks the current round as fully completed — so the bar displays as 100% full during the break period without any gap or flash.

## Timer Loop

`TimerViewModel` runs a `Timer.scheduledTimer` with a 1.0 second interval. Each callback hops back to the main actor before mutating state. Each tick:
1. Decrements `timeRemaining`
2. Increments `elapsedTotal`
3. Checks `isInNoticeWindow`
4. When `timeRemaining == 0`: clears notice state and calls `advancePhase()`

## syncCompanionExperience

Called on every phase transition and on pause/resume. It:
1. Calls `LiveActivityManager.shared.startOrUpdate(...)` with current state

Audio playback is triggered separately by the phase-transition methods and notice-window checks.

## Pause / Resume

- `pause()` — invalidates the timer, stops the background keepalive audio, updates live activity with `isPaused: true`
- `resume()` — restarts the timer, updates live activity with `isPaused: false`
- The live activity uses `timerRange: ClosedRange<Date>` — when paused, `isPaused: true` is set and the view shows a static string instead of `Text(timerInterval:)`

## Background Keepalive

`AudioManager` starts a silent looping `AVAudioPlayer` when a workout begins. This keeps the app's audio session active, which keeps the app running in the background on iOS. Result: the timer keeps running and bells still fire while the phone is locked, without requiring local notifications.

**Fallback path** (if background execution is interrupted):
- On `willResignActiveNotification`: records `backgroundedAt = Date()`
- On `didBecomeActiveNotification`: calculates elapsed seconds since `backgroundedAt`, fast-forwards the timer by that amount via `fastForward(seconds:)`
- This only activates when background audio keepalive is unavailable (e.g., user kills audio session)

## Screen Awake

`UIApplication.shared.isIdleTimerDisabled = true` while timer is running. Restored to `false` on stop.

## phaseDisplayText

The string shown in the large phase banner in `TimerView`. Examples:
- `getReady` → `"GET READY"`
- `round` → `"ROUND 1"`, `"ROUND 2"`, etc.
- `breakTime` → `"BREAK"`
- `done` → `"DONE"`
- `idle` → `""`

This same string is sent as `phaseName` to the Live Activity.

## No fullScreenCover

`TimerView` is shown **inline** inside `HomeView` using a conditional `if timerVM.isRunning`. The tab bar stays visible at all times during a workout. There is no modal, no sheet, no `fullScreenCover`. Do not add one.
