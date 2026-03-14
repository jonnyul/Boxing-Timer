# Web — Privacy Policy Site

## Setup

- **Location:** `web/privacy-policy/`
- **Framework:** Next.js (App Router), TypeScript, Tailwind CSS
- **Package manager:** npm
- **Purpose:** Single-page privacy policy for the Boxing Timer iOS app

## Structure

```
web/privacy-policy/
├── app/
│   ├── layout.tsx      # Root layout with metadata
│   ├── page.tsx        # Privacy policy content
│   └── globals.css     # Tailwind base + dark background
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

## Commands

```bash
cd web/privacy-policy
npm install
npm run dev      # localhost:3000
npm run build    # production build
```

## Design

Matches the iOS app visually:
- Background: `#1C2A4A` (appBackground)
- Text: white
- Accent: `#29ABE2` cyan (links, badges)
- Centered max-width layout, responsive
- Geist Sans font

## Content Sections

1. Introduction
2. Data We Collect (none)
3. Local Storage (UserDefaults + JSON files, device-only)
4. No Network Requests
5. No Third-Party Services
6. Children's Privacy (COPPA compliant)
7. Changes to This Policy
8. Contact

Effective date: March 12, 2026.

## Pending

- Replace placeholder `privacy@boxingtimer.app` with a real address before publishing
- Add `output: 'export'` to `next.config.ts` for static hosting (Vercel, GitHub Pages, etc.)
