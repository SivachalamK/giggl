# Giggl — Build & Run

## Fixed in this project

- Gradle **8.14** + AGP **8.11.1** + Kotlin **2.2.20** (Java 21 compatible)
- AndroidX enabled
- Patched local `packages/razorpay_flutter` for modern Gradle
- Demo data fallback when Supabase is offline
- Web-safe payment service (conditional export)
- Firebase placeholder `firebase_options.dart`

## Commands

```powershell
cd d:\giggl
flutter clean
flutter pub get
flutter run
```

Android device:

```powershell
flutter run -d RZCWA0YEG7W
```

Web:

```powershell
flutter run -d chrome
```

## If build fails

1. **Disk space** — free space on `C:` (Gradle/Kotlin caches need several GB).
2. Clear Gradle cache: `Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches` (optional).
3. Copy `.env.example` → `.env` and add real Supabase keys.
4. Run SQL: `supabase/migrations/001_initial_schema.sql`

## Environment

- Flutter 3.44+
- JDK 21 (Android Studio JBR)
