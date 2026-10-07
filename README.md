# TrendLens

Weekly AI trend-template studio for TikTok / Reels / Shorts creators.
Pick a trending template, apply it to your photo in one tap, post it.
Free exports carry a watermark — Pro ($2.99/mo or $19.99/yr) removes it and
unlocks new drops 48h early.

Built on a **$0 stack**: on-device video effects + a free AI image API behind
a caching proxy. No paid APIs, no database.

## The three pieces

| Piece | Dir | Tech | Purpose |
|---|---|---|---|
| Mobile app | `app/` | Flutter + GetX | 11 screens, themes, editor, export, paywall |
| Backend | `server/` | Node.js + Express + multer | Template catalog, AI style proxy, premium cloud storage |
| Admin panel | `admin/` | Next.js 14 + Tailwind | Template CRUD, user/premium management, stats |

## $0 architecture

- **Effect templates** (transitions, filters, captions) run 100% on-device via
  `ffmpeg_kit_flutter` — zero server cost.
- **AI image styles** go through the backend `POST /api/ai/style`, which proxies
  the free Pollinations.ai API (no key needed) with a **disk cache** keyed by
  prompt hash — repeat requests cost nothing. The app never calls Pollinations
  directly. Rate-limited to 20 req/hour per IP.
- **Template catalog** is `server/data/templates.json`, editable from the admin
  panel; the app falls back to its bundled `assets/templates.json` offline.
- **Storage rule**: FREE users store creations locally on-device only.
  PREMIUM users upload to the Servarica VPS via `POST /api/upload`
  (multipart, `x-premium: true` header, enforced server-side too).

## Quickstart

**App** (`app/`): install Flutter, then
`flutter pub get && flutter run`. For a physical device, set
`AppConfig.apiBaseUrl` in `lib/core/app_config.dart` to your server URL.
Run `flutter create .` inside `app/` to generate `android/`/`ios/` folders.

**Server** (`server/`): `npm install && npm start` (port 3000).
Copy `.env.example` to `.env` and set `ADMIN_KEY`. See `DEPLOY.md` for the
Servarica VPS setup (pm2 + nginx).

**Admin** (`admin/`): `npm install && npm run dev`. Set `ADMIN_API_URL` and
`NEXT_PUBLIC_ADMIN_KEY` (must equal the server's `ADMIN_KEY`).

## Themes

Light "Bright Creator" theme is default; dark theme and system-default
follow the OS. Switchable in Profile > Settings, persisted locally.

## TODOs before production

- Real IAP (RevenueCat / Play Billing / StoreKit) — paywall currently flips a
  local demo flag.
- Real auth — server upload/admin endpoints use header flags (`x-premium`,
  `x-admin-key`); admin login gate is client-side only.
- Render the free-export watermark into the video (currently label-only).
- Implement `applyTransition` / `beatSyncCut` in the effect pipeline.
- Apple App Store: add `NSPhotoLibraryUsageDescription` etc. when generating
  platform folders.

## Branches

All work happens on `staging`. Never push directly to `main`.
