import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/match_model.dart';
import '../models/message_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');
  final CollectionReference _matchesCollection = FirebaseFirestore.instance
      .collection('matches');
  final CollectionReference _messagesCollection = FirebaseFirestore.instance
      .collection('messages');

  // Current user
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Authentication methods
  Future<User?> signUp(String email, String password, String name) async {
    try {
      print(
        "FirebaseService: Starting user creation process with email: $email",
      );

      // Create the user in Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("FirebaseService: Auth user created successfully");
      final User? user = result.user;

      if (user != null) {
        print(
          "FirebaseService: Creating user profile in Firestore for UID: ${user.uid}",
        );
        // Create user profile in Firestore
        await _createUserProfile(user.uid, name, email);
        print("FirebaseService: User profile created successfully");
        return user;
      }
      print("FirebaseService: User creation returned null user");
      return null;
    } catch (e) {
      print("FirebaseService ERROR in signUp: $e");
      if (e is FirebaseAuthException) {
        print("FirebaseService ERROR code: ${e.code}");
        print("FirebaseService ERROR message: ${e.message}");
      }
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;

      if (user != null) {
        // Update last active timestamp
        await _usersCollection.doc(user.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Update last active timestamp before signing out
      if (currentUser != null) {
        await _usersCollection.doc(currentUser!.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
      }

      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // User profile methods
  Future<void> _createUserProfile(
    String userId,
    String name,
    String email,
  ) async {
    try {
      final UserModel newUser = UserModel(
        id: userId,
        email: email,
        name: name,
        photoUrls: [],
        birthDate: DateTime.now().subtract(
          const Duration(days: 365 * 25),
        ), // Default to 25 years old
        gender: 'Not specified', // This should be updated by the user
        interestedIn: 'Not specified', // This should be updated by the user
        isProfileComplete: false,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        promptResponses: {},
        matchingPreferences: {},
      );

      await _usersCollection.doc(userId).set(newUser.toMap());
    } catch (e) {
      print("Error creating user profile: $e");
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final DocumentSnapshot doc = await _usersCollection.doc(userId).get();

      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Storage methods
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName = '${userId}_${Uuid().v4()}';
      final Reference storageRef = _storage.ref().child(
        'profile_images/$fileName',
      );

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Match methods
  Future<void> createLike(String currentUserId, String likedUserId) async {
    try {
      // Check if there's already a match document for these users
      final QuerySnapshot existingMatches =
          await _matchesCollection
              .where('user1Id', isEqualTo: likedUserId)
              .where('user2Id', isEqualTo: currentUserId)
              .get();

      if (existingMatches.docs.isNotEmpty) {
        // This means the other user already liked the current user
        final DocumentSnapshot matchDoc = existingMatches.docs.first;
        final MatchModel match = MatchModel.fromDocument(matchDoc);

        // Update to a mutual match
        await _matchesCollection.doc(match.id).update({
          'user2LikedUser1': true,
          'status': 'matched',
          'matchedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create a new like
        final MatchModel newMatch = MatchModel(
          id: Uuid().v4(),
          user1Id: currentUserId,
          user2Id: likedUserId,
          user1LikedUser2: true,
          user2LikedUser1: false,
          status: MatchStatus.pending,
          createdAt: DateTime.now(),
        );

        await _matchesCollection.doc(newMatch.id).set(newMatch.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<MatchModel>> getMatches(String userId) {
    try {
      return _matchesCollection
          .where(
            Filter.or(
              Filter('user1Id', isEqualTo: userId),
              Filter('user2Id', isEqualTo: userId),
            ),
          )
          .where('status', isEqualTo: 'matched')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MatchModel.fromDocument(doc))
                .toList();
          });
    } catch (e) {
      rethrow;
    }
  }

  // Message methods
  Future<void> sendMessage(
    String matchId,
    String senderId,
    String receiverId,
    String text,
  ) async {
    try {
      final MessageModel newMessage = MessageModel(
        id: Uuid().v4(),
        matchId: matchId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        timestamp: DateTime.now(),
      );

      // Add the message to Firestore
      await _messagesCollection.doc(newMessage.id).set(newMessage.toMap());

      // Update the match with the latest message info
      await _matchesCollection.doc(matchId).update({
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessagePreview':
            text.length > 50 ? '${text.substring(0, 47)}...' : text,
        'hasUnreadMessages': true,
        'messageCount': FieldValue.increment(1),
        'isCurrentUserTurn': false,
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<MessageModel>> getMessages(String matchId) {
    try {
      return _messagesCollection
          .where('matchId', isEqualTo: matchId)
          .orderBy('timestamp')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MessageModel.fromDocument(doc))
                .toList();
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String matchId, String userId) async {
    try {
      // Get unread messages sent to this user in this match
      final QuerySnapshot unreadMessages =
          await _messagesCollection
              .where('matchId', isEqualTo: matchId)
              .where('receiverId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      // Create a batch to update multiple messages at once
      final WriteBatch batch = _firestore.batch();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Commit the batch
      await batch.commit();

      // Update the match to mark messages as read
      await _matchesCollection.doc(matchId).update({
        'hasUnreadMessages': false,
        'isCurrentUserTurn': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Discovery methods
  Future<List<UserModel>> getDiscoveryProfiles(
    String currentUserId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      // Get the current user to use their preferences
      final currentUser = await getUserProfile(currentUserId);
      if (currentUser == null) return [];

      // Build query based on preferences
      Query query = _usersCollection.where(
        'isProfileComplete',
        isEqualTo: true,
      );

      // Gender preference
      if (currentUser.interestedIn.isNotEmpty) {
        query = query.where('gender', isEqualTo: currentUser.interestedIn);
      }

      // Faith level preference
      if (preferences.containsKey('faithLevel') &&
          preferences['faithLevel'] != null) {
        query = query.where('faithLevel', isEqualTo: preferences['faithLevel']);
      }

      // Lifestyle preference
      if (preferences.containsKey('lifestylePreference') &&
          preferences['lifestylePreference'] != null) {
        query = query.where(
          'lifestylePreference',
          isEqualTo: preferences['lifestylePreference'],
        );
      }

      final QuerySnapshot snapshot = await query.limit(20).get();

      // Convert to UserModels and filter out the current user
      List<UserModel> users =
          snapshot.docs
              .map((doc) => UserModel.fromDocument(doc))
              .where((user) => user.id != currentUserId)
              .toList();

      return users;
    } catch (e) {
      rethrow;
    }
  }
}
