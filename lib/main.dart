import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harbour/core/theme/app_theme.dart';
import 'package:harbour/core/config/app_config.dart';
import 'package:harbour/services/firebase_service.dart';
import 'package:harbour/features/auth/screens/login_screen.dart';
import 'package:harbour/features/auth/screens/register_screen.dart';
import 'package:harbour/features/auth/providers/auth_provider.dart' as app_auth;
import 'package:harbour/features/profile/providers/profile_provider.dart';
import 'package:harbour/features/discovery/providers/discovery_provider.dart';
import 'package:harbour/features/messaging/providers/messaging_provider.dart';
import 'package:harbour/core/constants/app_routes.dart';
import 'package:harbour/features/auth/screens/onboarding_screen.dart';
import 'package:harbour/features/profile/screens/profile_screen.dart';
import 'package:harbour/features/discovery/screens/discovery_screen.dart';
import 'package:harbour/features/messaging/screens/matches_screen.dart';
import 'package:harbour/features/messaging/screens/conversation_screen.dart';
import 'package:harbour/features/profile/screens/edit_profile_screen.dart';
import 'package:harbour/features/profile/screens/view_profile_screen.dart';
import 'package:harbour/test_firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  await AppConfig.initialize();

  bool firebaseInitialized = false;

  try {
    // Initialize Firebase only in production or if explicitly enabled
    if (AppConfig.isProduction || !AppConfig.useMockData) {
      await Firebase.initializeApp();

      try {
        // Initialize Firebase App Check - This is crucial for authentication to work properly
        await FirebaseAppCheck.instance.activate(
          // Use debug providers only in debug mode
          androidProvider: const bool.fromEnvironment('dart.vm.product')
              ? AndroidProvider.playIntegrity
              : AndroidProvider.debug,
          appleProvider: const bool.fromEnvironment('dart.vm.product')
              ? AppleProvider.deviceCheck
              : AppleProvider.debug,
        );

        if (AppConfig.enableLogging) {
          print("Firebase initialized successfully with App Check");
        }
        firebaseInitialized = true;
      } catch (appCheckError) {
        if (AppConfig.enableLogging) {
          print("Failed to initialize Firebase App Check: $appCheckError");
        }
        // Still consider Firebase initialized if only App Check failed
        firebaseInitialized = true;
      }
    } else {
      if (AppConfig.enableLogging) {
        print("Running in development mode with mock data");
      }
    }
  } catch (e) {
    if (AppConfig.enableLogging) {
      print("Failed to initialize Firebase: $e");
      print("Running in development mode without Firebase");
    }
  }

  runApp(MyApp(firebaseInitialized: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MyApp({super.key, this.firebaseInitialized = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        StreamProvider.value(
          value: FirebaseService().authStateChanges,
          initialData: null,
        ),
        ChangeNotifierProvider<app_auth.AuthProvider>(
          create: (context) => app_auth.AuthProvider(
            firebaseService: context.read<FirebaseService>(),
          ),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(
            firebaseService: context.read<FirebaseService>(),
          ),
        ),
        ChangeNotifierProvider<DiscoveryProvider>(
          create: (context) => DiscoveryProvider(
            firebaseService: context.read<FirebaseService>(),
          ),
        ),
        ChangeNotifierProvider<MessagingProvider>(
          create: (context) => MessagingProvider(
            firebaseService: context.read<FirebaseService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Harbour',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          // Splash route - decide where to go based on auth state
          AppRoutes.splash: (context) => firebaseInitialized
              ? Consumer<User?>(
                  builder: (context, user, _) {
                    if (user == null) {
                      return const OnboardingScreen();
                    } else {
                      return const AppScaffold();
                    }
                  },
                )
              : const OnboardingScreen(), // Always start with onboarding if Firebase is not initialized
          // Other routes - these will be directly navigated to
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.profile: (context) => const AppScaffold(initialTabIndex: 2),
          AppRoutes.editProfile: (context) => const EditProfileScreen(),

          // Main app routes - directly accessible after authentication
          AppRoutes.discovery: (context) =>
              const AppScaffold(initialTabIndex: 0),
          AppRoutes.matches: (context) => const AppScaffold(initialTabIndex: 1),
          AppRoutes.conversation: (context) => const ConversationScreen(),
          AppRoutes.viewProfile: (context) => const ViewProfileScreen(),
          '/test-firebase': (context) => const FirebaseTester(),
        },
      ),
    );
  }
}

class AppScaffold extends StatefulWidget {
  final int initialTabIndex;

  const AppScaffold({super.key, this.initialTabIndex = 0});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late int _selectedIndex;

  static const List<Widget> _screens = [
    DiscoveryScreen(),
    MatchesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryDeepBlue,
        unselectedItemColor: AppTheme.textTertiary,
        onTap: _onItemTapped,
      ),
    );
  }
}
