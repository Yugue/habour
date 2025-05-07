class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main App Routes
  static const String home = '/home';

  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String viewProfile = '/profile/view';
  static const String editPrompts = '/profile/edit-prompts';
  static const String editRoots = '/profile/edit-roots';
  static const String editHomeFuture = '/profile/edit-home-future';

  // Discovery Routes
  static const String discovery = '/discovery';
  static const String filterPreferences = '/discovery/filters';

  // Messaging Routes
  static const String matches = '/matches';
  static const String conversation = '/conversation';

  // Settings Routes
  static const String settings = '/settings';
  static const String premium = '/settings/premium';
  static const String notifications = '/settings/notifications';
  static const String privacy = '/settings/privacy';
  static const String help = '/settings/help';
}
