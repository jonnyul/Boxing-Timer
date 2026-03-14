# Boxing Timer — Agent Entry Point

This folder is the authoritative source of truth for all AI coding agents working on this project. The root-level files (`AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `GEMINI.md`) are mirrors — do not edit them directly, edit files inside `agents/` only.

## Repository Layout

```
Boxing Timer/
├── ios/                    # SwiftUI iOS app (Xcode project)
├── web/                    # Next.js privacy policy site
├── agents/                 # This folder — agent instructions
├── AGENTS.md / CLAUDE.md / CODEX.md / GEMINI.md   # DO NOT EDIT — mirrors of agents/README.md entry point
```

## What to Read for Each Task Type

| Task | Read first | Then read |
|------|-----------|-----------|
| Any iOS change | `ios/build.md` | `ios/source-map.md` |
| iOS UI / styling | `ios/ui-system.md` | `ios/source-map.md` |
| Timer logic / phases | `ios/timer-engine.md` | `ios/source-map.md` |
| Data / persistence | `ios/data-layer.md` | — |
| Live Activity | `ios/live-activity.md` | `ios/build.md` |
| Web privacy policy | `web/overview.md` | — |
| Unsure if a feature was removed | `decisions.md` | — |
| Updating agents/ | `conventions.md` | — |

## Sub-project Docs

- [`ios/build.md`](./ios/build.md) — Xcode targets, build commands, install, warnings
- [`ios/source-map.md`](./ios/source-map.md) — Every file and its purpose
- [`ios/timer-engine.md`](./ios/timer-engine.md) — State machine, phases, background keepalive
- [`ios/data-layer.md`](./ios/data-layer.md) — Models, persistence, threading rules
- [`ios/ui-system.md`](./ios/ui-system.md) — Design tokens, components, styling patterns
- [`ios/live-activity.md`](./ios/live-activity.md) — Two-target architecture, sync protocol
- [`web/overview.md`](./web/overview.md) — Privacy policy Next.js site
- [`decisions.md`](./decisions.md) — Removed features and architectural choices (read before adding anything)
- [`conventions.md`](./conventions.md) — How to maintain this folder
