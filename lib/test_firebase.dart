import 'dart:io';
import 'package:flutter/material.dart';
import 'services/firebase_service.dart';

class FirebaseTester extends StatefulWidget {
  const FirebaseTester({super.key});

  @override
  State<FirebaseTester> createState() => _FirebaseTesterState();
}

class _FirebaseTesterState extends State<FirebaseTester> {
  final FirebaseService _firebaseService = FirebaseService();
  String _status = 'Testing Firebase...';
  bool _isLoading = false;

  Future<void> _testFirebase() async {
    setState(() {
      _isLoading = true;
      _status = 'Starting Firebase tests...';
    });

    try {
      // 1. Test Authentication
      _status = 'Testing Authentication...';

      // Sign Up
      final testEmail = 'test${DateTime.now().millisecondsSinceEpoch}@test.com';
      final testPassword = 'Test123!';
      final testName = 'Test User';

      final user = await _firebaseService.signUp(
        testEmail,
        testPassword,
        testName,
      );
      if (user == null) throw Exception('Sign up failed');
      _status = '✅ Sign up successful';

      // Sign In
      final signedInUser = await _firebaseService.signIn(
        testEmail,
        testPassword,
      );
      if (signedInUser == null) throw Exception('Sign in failed');
      _status = '✅ Sign in successful';

      // 2. Test Firestore
      _status = 'Testing Firestore...';

      // Get User Profile
      final userProfile = await _firebaseService.getUserProfile(user.uid);
      if (userProfile == null) throw Exception('Failed to get user profile');
      _status = '✅ User profile retrieved';

      // Update User Profile
      final updatedProfile = userProfile.copyWith(
        name: 'Updated Test User',
        bio: 'This is a test bio',
      );
      await _firebaseService.updateUserProfile(updatedProfile);
      _status = '✅ User profile updated';

      // 3. Test Storage
      _status = 'Testing Storage...';

      // Create a test image file
      final testImage = File('test_image.jpg');
      // Note: You'll need to create a test image file first
      if (!await testImage.exists()) {
        throw Exception('Test image file not found');
      }

      final imageUrl = await _firebaseService.uploadProfileImage(
        testImage,
        user.uid,
      );
      if (imageUrl.isEmpty) throw Exception('Failed to upload image');
      _status = '✅ Image uploaded successfully';

      // 4. Test Matching
      _status = 'Testing Matching...';

      // Create a test like
      await _firebaseService.createLike(
        user.uid,
        'test_liked_user_id', // You'll need a valid user ID here
      );
      _status = '✅ Like created successfully';

      // 5. Clean up
      _status = 'Cleaning up...';

      // Delete test user
      await user.delete();
      _status = '✅ Test user deleted';

      setState(() {
        _status = '✅ All Firebase tests completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Tests')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _testFirebase,
                child: const Text('Run Firebase Tests'),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
