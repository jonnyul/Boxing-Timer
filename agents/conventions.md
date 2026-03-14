# Agent Conventions

## This Folder

All AI agent instructions live in `agents/`. The root-level files (`AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `GEMINI.md`) are entry-point mirrors — they redirect agents here. Do not edit them directly.

## Folder Structure

```
agents/
├── README.md               # Entry point and navigation table
├── ios/
│   ├── build.md            # Targets, build commands, compiler flags
│   ├── source-map.md       # Every file and its purpose
│   ├── timer-engine.md     # State machine, phases, background keepalive
│   ├── data-layer.md       # Models, persistence, threading rules
│   ├── ui-system.md        # Design tokens, components, styling rules
│   └── live-activity.md    # Two-target architecture, sync protocol
├── web/
│   └── overview.md         # Privacy policy Next.js site
├── decisions.md            # Removed features + architectural choices
└── conventions.md          # This file
```

## Rules for Maintaining agents/

### After every task that changes behavior
Update the relevant file(s). If a change touches:
- Build setup / targets → update `ios/build.md`
- File structure → update `ios/source-map.md`
- Timer phases or audio → update `ios/timer-engine.md`
- Persistence or models → update `ios/data-layer.md`
- UI components or design → update `ios/ui-system.md`
- Live Activity → update `ios/live-activity.md`
- A decision to remove/not-add something → add a row to `decisions.md`

### Creating new files
If a new sub-project or major concern appears that doesn't fit any existing file, create a new file. Do not shoehorn unrelated content into existing files. Examples:
- Android app → `agents/android/`
- Backend API → `agents/api.md`
- Apple Watch → `agents/ios/watch.md`

### What belongs here vs in code
- **In agents/:** decisions, rules, patterns, things NOT derivable from reading the code, build commands, device IDs, removed features, threading constraints
- **Not in agents/:** code snippets that simply duplicate what's in the source files, git history, debugging notes for a single session

### Audience
Only AI coding agents read this folder. Write for an agent with no prior conversation context, not for humans. Be precise, complete, and direct. Avoid filler prose.
