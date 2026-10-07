# TrendLens — Flutter app

Weekly AI trend-template studio for TikTok/Reels/Shorts creators.
Built on a $0 stack: on-device effects + a backend AI proxy. The app never
calls AI APIs directly.

## Setup

Flutter is **not** installed in this build environment — run these on your
own machine:

```bash
cd app
flutter pub get
# The android/ and ios/ folders are not committed. Generate them locally:
flutter create .
flutter run
```

## Architecture

- `lib/main.dart` — GetX setup, `ThemeController` + `PremiumController` init,
  Splash → onboarding → main-tabs routing.
- `lib/core/` — `app_config.dart` (backend base URL), `routes.dart`.
- `lib/theme/` — `app_colors.dart` (Bright Creator tokens + shared accents),
  `app_theme.dart` (light/dark `ThemeData`).
- `lib/app/models/` — `TrendTemplate` (gradient-pair thumbnails, no binary assets).
- `lib/app/controllers/` — `ThemeController`, `PremiumController`,
  `TemplatesController` (backend → bundled JSON fallback), `EditorController`.
- `lib/app/views/` — 11 screens (splash, 3 onboarding, home, template detail,
  editor, export, discover, library, profile, paywall, main tabs).
- `lib/app/widgets/` — gradient thumbnails, template cards, pills, CTA buttons.
- `lib/services/` — `api_service.dart`, `effect_pipeline.dart`
  (ffmpeg_kit_flutter), `creation_storage.dart`.
- `assets/templates.json` — 12 sample templates (3 per category).

## How themes work

`ThemeController` (GetX) holds `ThemeMode.light/dark/system`, persisted in
`shared_preferences` under `theme_mode`. `GetMaterialApp` rebuilds on change.
Light "Bright Creator" (#FAFAF8 bg) is the default; dark uses #0E0E12.
Switch it in Profile → theme selector.

## How premium works

`PremiumController.isPremium` (persisted bool). The paywall's Subscribe button
currently calls `grantPremium()` — **demo only**. TODO: wire real IAP
(RevenueCat / Play Billing / StoreKit) and verify receipts server-side before
granting.

## How storage works

- **Free:** creations save to the app documents directory
  (`.../creations/`) via `CreationStorage.saveLocal`. The export screen shows a
  "Cloud backup is a Pro feature" upsell banner.
- **Pro:** `CreationStorage.uploadCloud` does a multipart POST to
  `/api/upload` with `x-premium: true` + `x-user-id` headers. The gate is
  enforced client-side for UX **and** server-side — the server rejects uploads
  without valid premium headers.

## Backend

`AppConfig.apiBaseUrl` defaults to `http://10.0.2.2:3000` (Android emulator
loopback). Change it to your Servarica server URL/IP for physical devices.

## TODO

- [ ] Real in-app purchases (paywall + `PremiumController.grantPremium`)
- [ ] `EffectPipeline.applyTransition` (ffmpeg xfade/zoompan)
- [ ] `EffectPipeline.beatSyncCut` (needs backend beat-map API)
- [ ] Watermark overlay on free exports (currently label-only)
- [ ] `generate android/ios` via `flutter create .` on a dev machine
- [ ] `flutter analyze` / `flutter test` (Flutter not installed in this env)
