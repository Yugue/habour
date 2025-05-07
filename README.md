# Harbour - Conservative Dating App

A Flutter-based dating app designed for politically conservative individuals. Harbour provides a platform for people with traditional values to connect and build meaningful relationships.

## Features

- **Authentication**: Secure login and registration
- **Profile Creation**: Build a detailed profile showcasing your values and traditions
- **Discovery Feed**: Vertical scrolling of curated matches
- **Messaging**: Clean, text-first messaging experience with matches
- **Matching Filters**: Customizable preferences for faith level, lifestyle, and values

## App Structure

The app follows a clean, modular architecture:

- **Core**: Theme, constants, and utilities
- **Features**: Feature-based modules (auth, profile, discovery, messaging)
- **Models**: Data models (user, match, message)
- **Services**: Firebase services (auth, firestore, storage)
- **Widgets**: Reusable UI components

## Setup Instructions

### Prerequisites

- Flutter SDK 3.7.0 or higher
- Dart 3.0.0 or higher
- Firebase account

### Installation

1. Clone the repository:
```
git clone https://github.com/yourusername/harbour.git
cd harbour
```

2. Install dependencies:
```
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Enable Authentication, Firestore, and Storage
   - Add Android and iOS apps in Firebase console
   - Download and add the configuration files:
     - For Android: `google-services.json` to `android/app/`
     - For iOS: `GoogleService-Info.plist` to `ios/Runner/`

4. Run the app:
```
flutter run
```

## Firebase Structure

### Firestore Collections

- **users**: User profiles
- **matches**: Match connections between users
- **messages**: Messages exchanged in conversations

## Project Structure

```
lib/
  ├── core/
  │   ├── constants/     # App routes, strings, etc.
  │   ├── theme/         # App theme (colors, typography)
  │   └── utils/         # Helper functions
  │
  ├── features/
  │   ├── auth/          # Authentication screens and logic
  │   ├── discovery/     # Profile discovery and matching
  │   ├── messaging/     # Conversations and messaging
  │   └── profile/       # Profile creation and editing
  │
  ├── models/            # Data models
  │   ├── user_model.dart
  │   ├── match_model.dart
  │   └── message_model.dart
  │
  ├── services/          # Firebase services
  │   └── firebase_service.dart
  │
  ├── widgets/           # Reusable components
  │
  └── main.dart          # App entry point
```

## UI Design

- **Colors**: Deep blue, warm beige, olive accents
- **Typography**: Serif headlines (Libre Baskerville), modern sans-serif body (Montserrat)
- **Style**: Calm, grounded, elegant — not flashy or gamified

## License

[Your chosen license]

## Acknowledgements

- [Flutter](https://flutter.dev)
- [Firebase](https://firebase.google.com)
- Design inspiration from Hinge
