# GearShare

A peer-to-peer equipment rental marketplace built with Flutter, Firebase, and Supabase.

Rent out your gear or borrow what you need — cameras, tools, camping equipment, sports gear, and more.

## Features

- **User Authentication** — Email/password signup & login with Firebase Auth
- **Equipment Listings** — Create, edit, and browse rental listings with images
- **Rental Requests** — Request to rent items with date range, pickup method, and message
- **CNIC Verification** — OCR-based CNIC validation via Google ML Kit + image upload to Supabase Storage
- **Real-time Updates** — Approved request banner, rental history, and listing status sync via Firestore streams
- **Push Notifications** — FCM integration notifies renters when their request is approved
- **Insurance & Security Deposit** — Optional fields per listing
- **Verified Reviews** — "Previous renter" badges on reviews from users who completed rentals
- **Dark Mode** — Full dark theme support
- **Responsive** — Works on Android, iOS, Web, and desktop

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x (Dart) |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Storage | Supabase Storage (images, CNIC docs) |
| Push | Firebase Cloud Messaging + Cloud Functions |
| OCR | Google ML Kit Text Recognition |
| State | Provider |
| Images | CachedNetworkImage, ImagePicker |

## Prerequisites

- Flutter SDK ^3.12
- A Firebase project (for Auth, Firestore, FCM)
- A Supabase project (for Storage)
- Node.js 20+ (for Cloud Functions deployment)

## Setup

### 1. Clone and install dependencies

```bash
git clone https://github.com/your-username/gearshare.git
cd gearshare
flutter pub get
```

### 2. Configure Firebase

```bash
# Install the FlutterFire CLI if you haven't already
dart pub global activate flutterfire_cli

# Log in to Firebase
firebase login

# Configure your Firebase project
flutterfire configure --project=your-firebase-project-id
```

This will:
- Regenerate `lib/firebase_options.dart` with your project's keys
- Download `android/app/google-services.json`
- Download `ios/Runner/GoogleService-Info.plist` (if on macOS)

### 3. Configure Supabase

1. Copy the example config:
   ```bash
   cp lib/config/supabase_config.example.dart lib/config/supabase_config.dart
   ```
2. Open `lib/config/supabase_config.dart` and paste your Supabase URL and anon key from your Supabase project dashboard → Settings → API.

### 4. Cloud Functions (optional — required for push notifications)

```bash
cd functions
npm install
npx firebase deploy --only functions
```

### 5. Run

```bash
flutter run
```

Use `--dart-define` for platform-specific overrides if needed:
```bash
flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
```

## Building for Release

### Android

```bash
flutter build apk --release
# or for app bundle:
flutter build appbundle --release
```

### iOS (requires macOS)

```bash
cd ios
pod install
cd ..
flutter build ios --release
```

## Project Structure

```
lib/
├── config/           # Supabase & Firebase config
├── constants/        # Colors, app bar, bottom nav, drawer, shimmer
├── providers/        # ThemeProvider
├── screens/          # All app screens
├── services/         # FCM, image upload, CNIC validation, location
└── main.dart         # Entry point with routing
functions/            # Firebase Cloud Functions (push notifications)
```

## Security Notes

The following files contain Firebase/Supabase project credentials and are **not** committed to version control (they are regenerated per developer):

| File | Purpose | Setup Command |
|------|---------|--------------|
| `lib/firebase_options.dart` | Firebase SDK config | `flutterfire configure` |
| `lib/config/supabase_config.dart` | Supabase URL + anon key | Copy from `supabase_config.example.dart` |
| `android/app/google-services.json` | Android Firebase config | `flutterfire configure` |

## License

MIT
