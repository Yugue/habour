import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_service.dart';

class DiscoveryProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  List<UserModel> _discoveryProfiles = [];
  Map<String, dynamic> _filterPreferences = {};
  bool _isLoading = false;
  String? _error;
  int _currentProfileIndex = 0;

  // Development mode flag
  final bool _devMode = true; // Set to false when you have real Firebase setup

  DiscoveryProvider({required FirebaseService firebaseService})
    : _firebaseService = firebaseService;

  List<UserModel> get discoveryProfiles => _discoveryProfiles;
  Map<String, dynamic> get filterPreferences => _filterPreferences;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentProfileIndex => _currentProfileIndex;
  UserModel? get currentProfile =>
      _discoveryProfiles.isNotEmpty &&
              _currentProfileIndex < _discoveryProfiles.length
          ? _discoveryProfiles[_currentProfileIndex]
          : null;

  Future<void> loadDiscoveryProfiles() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_devMode) {
        // In development mode, generate mock profiles
        await Future.delayed(
          const Duration(milliseconds: 800),
        ); // Simulate network delay
        _discoveryProfiles = _generateMockProfiles();
        _currentProfileIndex = 0;
      } else {
        // Normal Firebase flow
        if (_firebaseService.currentUser == null) {
          throw Exception('User not authenticated');
        }

        _discoveryProfiles = await _firebaseService.getDiscoveryProfiles(
          _firebaseService.currentUser!.uid,
          _filterPreferences,
        );

        _currentProfileIndex = 0;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate mock profiles for development
  List<UserModel> _generateMockProfiles() {
    final List<String> names = [
      'Emma',
      'Olivia',
      'Ava',
      'Isabella',
      'Sophia',
      'Charlotte',
      'Mia',
      'Amelia',
      'Harper',
      'Evelyn',
      'Liam',
      'Noah',
      'William',
      'James',
      'Oliver',
      'Benjamin',
      'Elijah',
      'Lucas',
      'Mason',
      'Logan',
    ];

    final List<String> hometowns = [
      'Nashville, TN',
      'Austin, TX',
      'Charleston, SC',
      'Savannah, GA',
      'Dallas, TX',
      'Denver, CO',
      'Charlotte, NC',
      'Raleigh, NC',
      'Atlanta, GA',
      'Phoenix, AZ',
    ];

    final List<String> faiths = [
      'Christian',
      'Catholic',
      'Baptist',
      'Protestant',
      'Methodist',
      'Presbyterian',
      'Lutheran',
      'Mormon',
    ];

    final List<String> politicalViews = [
      'Conservative',
      'Moderate Conservative',
      'Libertarian',
    ];

    final Uuid uuid = Uuid();

    return List.generate(10, (index) {
      final bool isFemale = index < 10;
      final int randomYear = 1985 + (index % 15);
      final int randomMonth = 1 + (index % 12);
      final int randomDay = 1 + (index % 28);

      return UserModel(
        id: uuid.v4(),
        email: 'user$index@example.com',
        name: names[index % names.length],
        bio:
            'I\'m looking for someone who shares my values and traditions. I enjoy the outdoors, cooking, and spending time with family.',
        photoUrls: [],
        birthDate: DateTime(randomYear, randomMonth, randomDay),
        gender: isFemale ? 'Female' : 'Male',
        interestedIn: isFemale ? 'Male' : 'Female',
        isProfileComplete: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        promptResponses: {
          'I value most in a relationship':
              'Trust, communication, and shared values.',
          'My favorite family tradition':
              'Sunday dinners with the whole family.',
          'On weekends you can find me':
              'Hiking, volunteering at church, or trying new recipes.',
        },
        hometown: hometowns[index % hometowns.length],
        faithTradition: faiths[index % faiths.length],
        nonNegotiableValue: 'Faith, Family, and Freedom',
        kidsPreference: 'Want kids',
        relocationPreference: 'Open to relocating',
        lifestylePreference:
            index % 3 == 0 ? 'Urban' : (index % 3 == 1 ? 'Suburban' : 'Rural'),
        faithLevel: 'Very important',
        matchingPreferences: {},
        politicalAlignment: politicalViews[index % politicalViews.length],
        traditionalRoles: index % 2 == 0,
      );
    });
  }

  void updateFilterPreferences(Map<String, dynamic> preferences) {
    _filterPreferences = preferences;
    notifyListeners();

    // Reload profiles with new preferences
    loadDiscoveryProfiles();
  }

  Future<void> likeCurrentProfile() async {
    try {
      if (currentProfile == null) {
        return;
      }

      if (_devMode) {
        // Just simulate liking in dev mode
        // Move to the next profile
        _moveToNextProfile();
      } else {
        if (_firebaseService.currentUser == null) {
          return;
        }

        await _firebaseService.createLike(
          _firebaseService.currentUser!.uid,
          currentProfile!.id,
        );

        // Move to the next profile
        _moveToNextProfile();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void skipCurrentProfile() {
    _moveToNextProfile();
  }

  void _moveToNextProfile() {
    if (_currentProfileIndex < _discoveryProfiles.length - 1) {
      _currentProfileIndex++;
    } else {
      // Reload profiles if we've gone through all available profiles
      loadDiscoveryProfiles();
    }
    notifyListeners();
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}
