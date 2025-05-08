import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harbour/core/theme/app_theme.dart';
import 'package:harbour/services/firebase_service.dart';
import 'package:harbour/features/auth/screens/splash_screen.dart';
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
import 'package:harbour/test_firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
    // Continue without Firebase for development purposes
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          create:
              (context) => app_auth.AuthProvider(
                firebaseService: context.read<FirebaseService>(),
              ),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create:
              (context) => ProfileProvider(
                firebaseService: context.read<FirebaseService>(),
              ),
        ),
        ChangeNotifierProvider<DiscoveryProvider>(
          create:
              (context) => DiscoveryProvider(
                firebaseService: context.read<FirebaseService>(),
              ),
        ),
        ChangeNotifierProvider<MessagingProvider>(
          create:
              (context) => MessagingProvider(
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
          AppRoutes.splash:
              (context) => Consumer<User?>(
                builder: (context, user, _) {
                  if (user == null) {
                    return const OnboardingScreen();
                  } else {
                    return const AppScaffold();
                  }
                },
              ),
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
          AppRoutes.editProfile: (context) => const EditProfileScreen(),
          AppRoutes.discovery: (context) => const DiscoveryScreen(),
          AppRoutes.matches: (context) => const MatchesScreen(),
          AppRoutes.conversation: (context) => const ConversationScreen(),
          '/test-firebase': (context) => const FirebaseTester(),
        },
      ),
    );
  }
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DiscoveryScreen(),
    MatchesScreen(),
    ProfileScreen(),
  ];

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
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textLight,
        onTap: _onItemTapped,
      ),
    );
  }
}
