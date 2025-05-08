import 'package:flutter/material.dart';
import '../../../models/match_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_service.dart';

class MessagingProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  List<MatchModel> _matches = [];
  final Map<String, UserModel> _matchedUsers = {};
  List<MessageModel> _currentConversation = [];
  String? _currentMatchId;
  bool _isLoading = false;
  String? _error;

  MessagingProvider({required FirebaseService firebaseService})
    : _firebaseService = firebaseService;

  List<MatchModel> get matches => _matches;
  Map<String, UserModel> get matchedUsers => _matchedUsers;
  List<MessageModel> get currentConversation => _currentConversation;
  String? get currentMatchId => _currentMatchId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<MatchModel>> getMatchesStream(String userId) {
    return _firebaseService.getMatches(userId);
  }

  Future<void> loadMatches(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _firebaseService.getMatches(userId).listen((matches) {
        _matches = matches;
        notifyListeners();

        // Load user profiles for all matches
        for (final match in matches) {
          _loadMatchedUserProfile(match, userId);
        }
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMatchedUserProfile(
    MatchModel match,
    String currentUserId,
  ) async {
    try {
      // Determine which user ID in the match is the other user (not current user)
      final String otherUserId =
          match.user1Id == currentUserId ? match.user2Id : match.user1Id;

      // Only load if we don't already have this user's profile
      if (!_matchedUsers.containsKey(otherUserId)) {
        final UserModel? userProfile = await _firebaseService.getUserProfile(
          otherUserId,
        );

        if (userProfile != null) {
          _matchedUsers[otherUserId] = userProfile;
          notifyListeners();
        }
      }
    } catch (e) {
      // Just log the error, don't interrupt the whole process
      print('Error loading matched user profile: $e');
    }
  }

  Future<void> selectConversation(String matchId, String currentUserId) async {
    try {
      _isLoading = true;
      _error = null;
      _currentMatchId = matchId;
      _currentConversation = [];
      notifyListeners();

      // Mark messages as read when opening the conversation
      await _firebaseService.markMessagesAsRead(matchId, currentUserId);

      // Listen to messages for this match
      _firebaseService.getMessages(matchId).listen((messages) {
        _currentConversation = messages;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    try {
      if (_currentMatchId == null || _firebaseService.currentUser == null) {
        throw Exception('No active conversation or user not authenticated');
      }

      // Find the current match to get the receiver ID
      final MatchModel match = _matches.firstWhere(
        (match) => match.id == _currentMatchId,
        orElse: () => throw Exception('Match not found'),
      );

      final String senderId = _firebaseService.currentUser!.uid;
      final String receiverId =
          match.user1Id == senderId ? match.user2Id : match.user1Id;

      await _firebaseService.sendMessage(
        _currentMatchId!,
        senderId,
        receiverId,
        text,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  UserModel? getMatchedUser(MatchModel match) {
    if (_firebaseService.currentUser == null) return null;

    final String currentUserId = _firebaseService.currentUser!.uid;
    final String otherUserId =
        match.user1Id == currentUserId ? match.user2Id : match.user1Id;

    return _matchedUsers[otherUserId];
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}
