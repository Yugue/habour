# Environment Configuration Setup

This document explains how to configure the development and production environments for the Harbour app.

## Quick Start

1. Create a `.env` file in the project root:
```bash
cp .env.example .env
```

2. Update the values in `.env` according to your environment.

## .env File Template

Create a `.env` file in the project root with the following content:

```env
# Environment Configuration
# Copy this content to .env and update with your values

# Environment: development or production
ENVIRONMENT=development

# API URLs (if you have a backend)
DEV_API_URL=http://localhost:3000
PROD_API_URL=https://api.harbour.app

# Firebase Configuration
USE_FIREBASE_EMULATOR=false

# Feature Flags
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false

# Development Settings
SHOW_PERFORMANCE_OVERLAY=false
ENABLE_DEBUG_BANNER=true
```

## How It Works

The app uses a centralized `AppConfig` class located at `lib/core/config/app_config.dart` that:

1. **Determines the environment** based on (in priority order):
   - Environment variable from `.env` file
   - Flutter build mode (debug/release)
   - Default to development

2. **Provides feature flags**:
   - `useMockData` - Whether to use mock data instead of Firebase
   - `enableLogging` - Whether to enable console logging
   - `showDevTools` - Whether to show development tools

3. **Manages environment-specific configurations**:
   - API endpoints
   - Firebase emulator settings
   - Feature toggles

## Switching Between Environments

### Development Mode (Default)
- Uses mock data for all providers
- Bypasses Firebase authentication
- Shows development logs and tools
- No Firebase connection required

### Production Mode
To run in production mode:

1. Update `.env`:
```env
ENVIRONMENT=production
```

2. Or build in release mode:
```bash
flutter run --release
```

## Adding New Environment Variables

1. Add the variable to your `.env` file
2. Access it in code using:
```dart
final myVar = dotenv.env['MY_VARIABLE'];
```

3. For type safety, add a getter in `AppConfig`:
```dart
static String get myVariable => dotenv.env['MY_VARIABLE'] ?? 'default';
```

## Security Notes

⚠️ **Important**: Never commit the `.env` file to version control. It's already included in `.gitignore`.

For production deployments, set environment variables through your CI/CD pipeline or hosting platform. 