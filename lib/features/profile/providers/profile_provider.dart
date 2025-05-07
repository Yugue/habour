import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_service.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  UserModel? _userProfile;
  bool _isLoading = false;
  String? _error;

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

      _userProfile = await _firebaseService.getUserProfile(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(UserModel updatedProfile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
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

      if (_userProfile == null || _firebaseService.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final String downloadUrl = await _firebaseService.uploadProfileImage(
        imageFile,
        _firebaseService.currentUser!.uid,
      );

      // Update the user's photo URLs
      final List<String> updatedPhotoUrls = List.from(_userProfile!.photoUrls);
      updatedPhotoUrls.add(downloadUrl);

      final updatedProfile = _userProfile!.copyWith(
        photoUrls: updatedPhotoUrls,
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
