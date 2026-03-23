# Web — Privacy Policy Site

## Setup

- **Location:** `web/site/`
- **Framework:** Next.js (App Router), TypeScript, Tailwind CSS
- **Package manager:** npm
- **Purpose:** Single-page privacy policy for the Boxing Timer iOS app
- **Scope:** `web/site/` is the only maintained web app in this repo. `web/catalyst-ui-kit/` was removed and should not be recreated unless explicitly requested.

## Structure

```
web/site/
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
cd web/site
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

The page renders a `PrivacyPolicy` default export with a `Section` helper component for consistent heading/body layout. Style matches the iOS app (navy `#1C2A4A` background, white text, blue-300 accent labels).

## Pending

- Replace placeholder `privacy@boxingtimer.app` with a real address before publishing
- Add `output: 'export'` to `next.config.ts` for static hosting (Vercel, GitHub Pages, etc.)
- Hold the `eslint` v10 upgrade for now. A direct bump caused `npm run lint` to crash inside `eslint-plugin-react`; keep `eslint` on v9 until the lint toolchain is upgraded together.
