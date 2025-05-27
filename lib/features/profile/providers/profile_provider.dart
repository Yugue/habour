import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_service.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  UserModel? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Development mode flag
  final bool _devMode = true; // Set to false when you have real Firebase setup

  ProfileProvider({required FirebaseService firebaseService})
    : _firebaseService = firebaseService;

  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProfile(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_devMode) {
        // In development mode, generate a mock user profile
        await Future.delayed(
          const Duration(milliseconds: 800),
        ); // Simulate network delay
        _userProfile = _generateMockUserProfile(userId);
      } else {
        // Normal Firebase flow
        _userProfile = await _firebaseService.getUserProfile(userId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate a mock user profile for development
  UserModel _generateMockUserProfile(String userId) {
    return UserModel(
      id: userId,
      email: 'current.user@example.com',
      name: 'Alex Chen',
      bio:
          'Conservative values enthusiast looking for a meaningful relationship based on shared traditional values and faith.',
      photoUrls: [],
      birthDate: DateTime(1990, 5, 15),
      gender: 'Male',
      interestedIn: 'Female',
      isProfileComplete: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastActive: DateTime.now(),
      promptResponses: {
        'I value most in a relationship':
            'Faith, trust, and shared traditional values.',
        'My faith means to me':
            'My faith is the cornerstone of my life and decision-making.',
        'A tradition I want to pass down':
            'Sunday family dinners and maintaining strong conservative values across generations.',
      },
      hometown: 'Nashville, TN',
      faithTradition: 'Christian',
      nonNegotiableValue: 'Faith comes first in every decision',
      kidsPreference: 'Want kids',
      relocationPreference: 'Open to relocating',
      lifestylePreference: 'Suburban',
      faithLevel: 'Very important',
      matchingPreferences: {'age_min': 23, 'age_max': 32, 'distance': 50},
      politicalAlignment: 'Conservative',
      traditionalRoles: true,
    );
  }

  Future<void> updateUserProfile(UserModel updatedProfile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_devMode) {
        // Just simulate an update in dev mode
        await Future.delayed(const Duration(milliseconds: 600));
        _userProfile = updatedProfile;
      } else {
        // Normal Firebase flow
        await _firebaseService.updateUserProfile(updatedProfile);
        _userProfile = updatedProfile;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_devMode) {
        // Simulate uploading an image in dev mode
        await Future.delayed(const Duration(seconds: 1));

        // Create a fake URL
        final String mockImageUrl =
            'https://example.com/mock-image-${DateTime.now().millisecondsSinceEpoch}.jpg';

        if (_userProfile == null) {
          throw Exception('User profile not loaded');
        }

        // Update the photo URLs
        final List<String> updatedPhotoUrls = List.from(
          _userProfile!.photoUrls,
        );
        updatedPhotoUrls.add(mockImageUrl);

        _userProfile = _userProfile!.copyWith(photoUrls: updatedPhotoUrls);
      } else {
        // Normal Firebase flow
        if (_userProfile == null || _firebaseService.currentUser == null) {
          throw Exception('User not authenticated');
        }

        final String downloadUrl = await _firebaseService.uploadProfileImage(
          imageFile,
          _firebaseService.currentUser!.uid,
        );

        // Update the user's photo URLs
        final List<String> updatedPhotoUrls = List.from(
          _userProfile!.photoUrls,
        );
        updatedPhotoUrls.add(downloadUrl);

        final updatedProfile = _userProfile!.copyWith(
          photoUrls: updatedPhotoUrls,
        );

        await _firebaseService.updateUserProfile(updatedProfile);
        _userProfile = updatedProfile;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePromptResponses(
    Map<String, String> promptResponses,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_userProfile == null) {
        throw Exception('User profile not loaded');
      }

      final updatedProfile = _userProfile!.copyWith(
        promptResponses: promptResponses,
      );

      await _firebaseService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRootsSection({
    String? hometown,
    String? faithTradition,
    String? nonNegotiableValue,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_userProfile == null) {
        throw Exception('User profile not loaded');
      }

      final updatedProfile = _userProfile!.copyWith(
        hometown: hometown ?? _userProfile!.hometown,
        faithTradition: faithTradition ?? _userProfile!.faithTradition,
        nonNegotiableValue:
            nonNegotiableValue ?? _userProfile!.nonNegotiableValue,
      );

      await _firebaseService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHomeFutureSection({
    String? kidsPreference,
    String? relocationPreference,
    String? lifestylePreference,
    String? faithLevel,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_userProfile == null) {
        throw Exception('User profile not loaded');
      }

      final updatedProfile = _userProfile!.copyWith(
        kidsPreference: kidsPreference ?? _userProfile!.kidsPreference,
        relocationPreference:
            relocationPreference ?? _userProfile!.relocationPreference,
        lifestylePreference:
            lifestylePreference ?? _userProfile!.lifestylePreference,
        faithLevel: faithLevel ?? _userProfile!.faithLevel,
      );

      await _firebaseService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePoliticalAlignment(String politicalAlignment) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_userProfile == null) {
        throw Exception('User profile not loaded');
      }

      final updatedProfile = _userProfile!.copyWith(
        politicalAlignment: politicalAlignment,
      );

      await _firebaseService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTraditionalRoles(bool traditionalRoles) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_userProfile == null) {
        throw Exception('User profile not loaded');
      }

      final updatedProfile = _userProfile!.copyWith(
        traditionalRoles: traditionalRoles,
      );

      await _firebaseService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
