import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required FirebaseService firebaseService})
    : _firebaseService = firebaseService {
    _initializeAuth();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _initializeAuth() {
    _firebaseService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print("Attempting to sign up with email: $email and name: $name");
      await _firebaseService.signUp(email, password, name);
      print("Sign up successful");
    } catch (e) {
      print("Error during sign up: $e");
      _error = _getAuthErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.signIn(email, password);
    } catch (e) {
      _error = _getAuthErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.signOut();
    } catch (e) {
      _error = _getAuthErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.resetPassword(email);
    } catch (e) {
      _error = _getAuthErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getAuthErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'operation-not-allowed':
          return 'Email & Password accounts are not enabled.';
        case 'too-many-requests':
          return 'Too many requests. Try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return e.toString();
  }
}
