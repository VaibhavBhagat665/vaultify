# Vaultify

A cross-platform Flutter application with Firebase OTP authentication and REST API CRUD operations.

**Live Demo:** https://pravah-cc286.web.app
**APK** - https://drive.google.com/file/d/15H7k9uErIT3drJ9MCABHa_rpvg7tvXwl/view?usp=sharing

## Features

- Firebase Phone OTP Authentication (Web & Mobile)
- Full CRUD operations (Create, Read, Update, Delete)
- GetX state management and dependency injection
- Responsive UI for mobile and web
- Local data persistence
- Dark theme with glass-card design

## Firebase Phone Auth Setup

### Prerequisites
- Firebase project with Blaze (pay-as-you-go) billing plan
- Phone Authentication enabled in Firebase Console

### Web Setup

1. Go to Firebase Console > Authentication > Sign-in method
2. Enable Phone provider
3. Add your domain to authorized domains:
   - `localhost` (for development)
   - Your Firebase hosting domain (e.g., `pravah-cc286.web.app`)
4. Configure reCAPTCHA:
   - Firebase automatically handles reCAPTCHA for web
   - For production, add your domain to reCAPTCHA allowed domains

### Mobile Setup (Android)

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. Add SHA-1 and SHA-256 fingerprints to Firebase:
   ```bash
   cd android
   ./gradlew signingReport
   ```
4. Enable Phone Auth in Firebase Console

### Mobile Setup (iOS)

1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/`
3. Add URL scheme to `ios/Runner/Info.plist`
4. Enable Phone Auth in Firebase Console

### Important Notes

- Phone Authentication requires Firebase Blaze billing plan
- SMS verification has usage limits and costs
- The app includes a "Skip for now" option for testing without billing enabled

## Dependencies

```yaml
dependencies:
  flutter: sdk
  get: ^4.6.6              # State management, DI, navigation
  http: ^1.2.2             # HTTP client for API calls
  firebase_core: ^3.8.1    # Firebase initialization
  firebase_auth: ^5.3.4    # Phone OTP authentication
  shared_preferences: ^2.2.2  # Local data persistence
  google_fonts: ^6.2.1     # Typography
  shimmer: ^3.0.0          # Loading animations
  flutter_animate: ^4.5.2  # UI animations
  intl: ^0.19.0            # Date formatting
  json_annotation: ^4.9.0  # JSON serialization
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
└── app/
    ├── core/
    │   ├── bindings/         # GetX dependency injection
    │   ├── routes/           # Navigation routes
    │   └── theme/            # App theme and colors
    ├── data/
    │   ├── models/           # Data models (ApiObject)
    │   └── services/         # API, Auth, LocalStorage services
    ├── modules/
    │   ├── splash/           # Splash screen
    │   ├── auth/             # Login and OTP screens
    │   ├── home/             # Dashboard
    │   └── objects/          # CRUD screens (list, detail, create, edit)
    └── widgets/              # Reusable UI components
```

## Design Choices

### State Management (GetX)
- Reactive state with `.obs` and `Obx()`
- Dependency injection via `Get.put()` and `Get.find()`
- Navigation with `Get.toNamed()` and `Get.back()`
- Snackbar notifications via `Get.snackbar()`

### Architecture
- Service layer for API calls and authentication
- Controllers for business logic
- Views for UI presentation
- Bindings for dependency setup per route

### Local Storage Strategy
The demo API (restful-api.dev) doesn't persist data. Solution:
- `LocalStorageService` stores created objects locally
- Tracks modified and deleted objects separately
- Combines local changes with API data on fetch
- Persists across app restarts using SharedPreferences

### Error Handling
- Try-catch blocks in all async operations
- User-friendly error messages via snackbars
- Graceful fallbacks for service initialization failures

## API Integration

**Base URL:** https://api.restful-api.dev/objects

### Endpoints Used
- `GET /objects` - List all objects
- `GET /objects/:id` - Get single object
- `POST /objects` - Create new object
- `PUT /objects/:id` - Update object
- `DELETE /objects/:id` - Delete object

### Data Model
```dart
class ApiObject {
  final String? id;
  final String name;
  final Map<String, dynamic>? data;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Build web release
flutter build web --release

# Build Android APK
flutter build apk --release
```

## Limitations

1. **Firebase Billing:** Phone OTP requires Blaze plan with billing enabled
2. **Demo API:** restful-api.dev doesn't persist data (handled via local storage)
3. **Sample Objects:** Objects with ID 1-13 are read-only on the API (editable locally)

## Future Improvements

1. Add biometric authentication option
2. Implement offline-first with sync
3. Add search and filter functionality
4. Support for image attachments
5. Export/import data feature
6. Push notifications for updates
7. Multi-language support

## Testing

```bash
# Run unit tests
flutter test
```

Unit tests cover:
- ApiService methods (GET, POST, PUT, DELETE)
- Controller logic and state management

## License

MIT License
