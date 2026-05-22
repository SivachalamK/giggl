# Giggl

Event management marketplace — Flutter + Supabase + Razorpay.

## Setup

1. Copy `.env.example` to `.env` and fill keys.
2. Run `flutter pub get`
3. Apply `supabase/migrations/001_initial_schema.sql` in Supabase SQL Editor.
4. Enable Google OAuth and Phone auth in Supabase Dashboard.
5. `flutter run`

## Platforms

- Android / iOS / Web

## Structure

```
lib/
  core/       # theme, router, config
  features/   # feature-first modules
  shared/     # widgets, models
  services/   # payment, notifications
```
