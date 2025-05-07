import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_service.dart';

class DiscoveryProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  List<UserModel> _discoveryProfiles = [];
  Map<String, dynamic> _filterPreferences = {};
  bool _isLoading = false;
  String? _error;
  int _currentProfileIndex = 0;

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

      if (_firebaseService.currentUser == null) {
        throw Exception('User not authenticated');
      }

      _discoveryProfiles = await _firebaseService.getDiscoveryProfiles(
        _firebaseService.currentUser!.uid,
        _filterPreferences,
      );

      _currentProfileIndex = 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFilterPreferences(Map<String, dynamic> preferences) {
    _filterPreferences = preferences;
    notifyListeners();

    // Reload profiles with new preferences
    loadDiscoveryProfiles();
  }

  Future<void> likeCurrentProfile() async {
    try {
      if (currentProfile == null || _firebaseService.currentUser == null) {
        return;
      }

      await _firebaseService.createLike(
        _firebaseService.currentUser!.uid,
        currentProfile!.id,
      );

      // Move to the next profile
      _moveToNextProfile();
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
