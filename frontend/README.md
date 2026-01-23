# OjekHub Mobile (Frontend)

OjekHub mobile application built with Flutter and GetX.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
- Android Studio / Xcode (for emulators or physical device setup)
- VS Code (Recommended)
- Backend API running locally or properly configured

## Setup & Installation

1.  **Navigate to the frontend directory:**

    ```bash
    cd frontend
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Configure Environment:**
    - Open `lib/config/env.dart` (or create if missing).
    - Ensure `baseApiUrl` points to your backend (e.g., `http://10.0.2.2:3000/api` for Android Emulator or `http://localhost:3000/api` for iOS Simulator).
    - ensure `googleClientId` is set if testing Google Sign-In.

## Running the App

### Debug Mode (Development)

```bash
flutter run
```

### Specific Platform

```bash
flutter run -d chrome
flutter run -d "iPhone 15"
flutter run -d android
```

## Folder Structure

- `lib/app/modules`: Feature modules (Home, Auth, Order, Queue, etc.)
- `lib/core`: Shared utilities, API client, theme.
- `lib/models`: Data models.
- `lib/routes.dart`: Route definitions and pages.

## Troubleshooting

- **Supabase Connection**: Ensure your Supabase URL and Key in `lib/main.dart` are correct.
- **Backend Connection**: If running on Android Emulator, use `10.0.2.2` instead of `localhost`.
- **Google Sign-In**: Requires correct SHA-1 fingerprint in Supabase/Google Cloud Console for Android.

## Key Features Implemented

- **Role Selection**: Petani, Gudang, Ojek, Pekerja Harian.
- **Employer Dashboard**: Post jobs, manage orders.
- **Worker Dashboard**: View jobs, join queues.
- **Queue System**: Real-time queue management for workers.
