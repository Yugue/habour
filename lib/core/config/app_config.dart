import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, production }

class AppConfig {
  static late Environment _environment;
  static bool _initialized = false;

  // Initialize the configuration
  static Future<void> initialize() async {
    if (_initialized) return;

    // Load environment variables
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file doesn't exist, default to development
      if (kDebugMode) {
        print('No .env file found, defaulting to development mode');
      }
    }

    // Determine environment from multiple sources
    _environment = _determineEnvironment();
    _initialized = true;

    if (kDebugMode) {
      print('App running in ${_environment.name} mode');
    }
  }

  static Environment _determineEnvironment() {
    // Priority order:
    // 1. Environment variable from .env file
    // 2. Flutter build mode (kReleaseMode)
    // 3. Default to development

    try {
      final envString = dotenv.env['ENVIRONMENT']?.toLowerCase();
      if (envString == 'production' || envString == 'prod') {
        return Environment.production;
      } else if (envString == 'development' || envString == 'dev') {
        return Environment.development;
      }
    } catch (e) {
      // If dotenv is not initialized, fall back to build mode
      if (kDebugMode) {
        print(
          'DotEnv not initialized, using build mode to determine environment',
        );
      }
    }

    // If no env variable or error, use Flutter's build mode
    return kReleaseMode ? Environment.production : Environment.development;
  }

  // Getters
  static Environment get environment {
    if (!_initialized) {
      throw Exception(
        'AppConfig not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _environment;
  }

  static bool get isDevelopment => environment == Environment.development;
  static bool get isProduction => environment == Environment.production;

  // Feature flags
  static bool get useMockData => isDevelopment;
  static bool get enableLogging => isDevelopment;
  static bool get showDevTools => isDevelopment;

  // API endpoints (can be different for dev/prod)
  static String get apiBaseUrl {
    try {
      if (isDevelopment) {
        return dotenv.env['DEV_API_URL'] ?? 'http://localhost:3000';
      }
      return dotenv.env['PROD_API_URL'] ?? 'https://api.harbour.app';
    } catch (e) {
      // Fallback if dotenv is not initialized
      return isDevelopment
          ? 'http://localhost:3000'
          : 'https://api.harbour.app';
    }
  }

  // Firebase configuration can also be environment-specific
  static bool get useFirebaseEmulator {
    try {
      return isDevelopment && (dotenv.env['USE_FIREBASE_EMULATOR'] == 'true');
    } catch (e) {
      // Fallback if dotenv is not initialized
      return false;
    }
  }

  // Override environment for testing
  @visibleForTesting
  static void setEnvironment(Environment env) {
    _environment = env;
    _initialized = true;
  }
}
