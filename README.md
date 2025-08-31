# Habit Tracker

Modern Flutter app to help you build and track habits, view insights, and stay motivated with daily quotes. Built with Firebase Auth, Firestore, and Provider state management.

## Features

- Email/password authentication (Firebase Auth)
- Create, filter, complete, and delete habits (Firestore)
- Streaks and 7‑day completion charts
- Category insights (pie chart) and weekly activity (bar chart)
- Motivational quotes carousel with favorites
- Profile page with theme toggle (light/dark)

## Tech Stack

- Flutter (Material 3, `provider`)
- Firebase: Auth, Firestore
- SharedPreferences for lightweight caching
- HTTP for quotes API
- `fl_chart` for charts, `carousel_slider` for quotes carousel

## Project Structure

```
lib/
  main.dart                     # App entry, Firebase init, routes
  theme/                        # Theming (light/dark)
  models/                       # Data models: Habit, Quote, UserProfile
  providers/                    # ChangeNotifiers: Auth, Habits, Quotes, Theme
  services/                     # Firebase/HTTP services
  screens/                      # UI pages (auth, home, habits, quotes, analytics, profile)
  widgets/                      # Reusable widgets (charts)
```

## Prerequisites

- Flutter SDK (stable channel)
- Dart SDK compatible with `environment: sdk: ^3.8.0`
- Firebase project with the following enabled:
  - Authentication (Email/Password)
  - Cloud Firestore (in Native/Datastore mode)

## Firebase Setup

Android:
- Pandroid/app/google-services.json` (already present in this repo)
- Ensure Gradle is configured (default Flutter + `google-services` plugin)

iOS:
- Add `ios/Runner/GoogleService-Info.plist`
- In Xcode, add the file to the Runner target

Web (optional):
- This app includes inline web `FirebaseOptions` in `main.dart`. If you prefer generated configs, run `flutterfire configure` and replace the inline options with the generated file.

## Running the App

```
flutter pub get
flutter run
```

device/emulator when prompted. For web, run `flutter run -d chrome`.

## Building Releases

Android APK (release):
```
flutter build apk
```

iOS (requires Xcode/macOS):
```
flutter build ios
```

Web:
```
flutter build web
```

## Firestore Data Model

- User profile: `users/{uid}`
  - `uid, displayName, email, gender?, dateOfBirth?, heightCm?, createdAt, updatedAt`
- Habits: `users/{uid}/habits/{habitId}`
  - `title, category, frequency (daily|weekly), createdAt, startDate?, currentStreak, completionHistory[], notes?`
- Favorite quotes: `users/{uid}/favorites/quotes/items/{quoteId}`
  - `id, content, author`

## Example Firestore Security Rules (simplified)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /habits/{habitId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /favorites/quotes/items/{quoteId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

Adjust for your needs before deploying.

## Environment & Configuration Notes

- The app uses `SharedPreferences` to cache simple session/profile fields.
- For web CORS resilience, the quotes service tries multiple public APIs with fallbacks.
- If you change dependencies (e.g., `carousel_slider`), reference its docs for API changes (e.g., controller types in v5).

## Troubleshooting

- Build fails after dependency updates:
  - Run `flutter clean && flutter pub get`
  - Ensure your Flutter/Dart SDK matches the constraints in `pubspec.yaml`

- Firebase initialization issues:
  - Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
  - For web, confirm `FirebaseOptions` in `main.dart` or run `flutterfire configure`

- Quotes carousel page indicator not moving:
  - Ensure `carousel_slider` is v5+ and `CarouselSliderController` is used

## Screenshots
- # Project Screenshots

Below are the screenshots of the project:

## Screenshots

![Screenshot 1](ScreenShot/Screenshot%202025-08-29%20184410.png)
![Screenshot 2](ScreenShot/Screenshot%202025-08-29%20184501.png)
![Screenshot 3](ScreenShot/Screenshot%202025-08-29%20184614.png)
![Screenshot 4](ScreenShot/Screenshot%202025-08-29%20184701.png)
![Screenshot 5](ScreenShot/Screenshot%202025-08-29%20184728.png)
![Screenshot 6](ScreenShot/Screenshot%202025-08-29%20184749.png)
![Screenshot 7](ScreenShot/Screenshot%202025-08-29%20191021.png)
![Screenshot 8](ScreenShot/Screenshot%202025-08-29%20191619.png)
![Screenshot 9](ScreenShot/Screenshot%202025-08-29%20192417.png)




## License

MIT
