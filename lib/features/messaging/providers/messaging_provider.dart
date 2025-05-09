import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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

  // Development mode flag
  final bool _devMode = true; // Set to false when you have real Firebase setup

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

      if (_devMode) {
        // In development mode, generate mock matches and users
        await Future.delayed(
          const Duration(milliseconds: 800),
        ); // Simulate network delay

        final mockData = _generateMockMatchesAndUsers(userId);
        _matches = mockData.matches;
        mockData.users.forEach((id, user) {
          _matchedUsers[id] = user;
        });

        _isLoading = false;
        notifyListeners();
      } else {
        // Normal Firebase flow
        _firebaseService.getMatches(userId).listen((matches) {
          _matches = matches;
          notifyListeners();

          // Load user profiles for all matches
          for (final match in matches) {
            _loadMatchedUserProfile(match, userId);
          }
        });
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate mock matches and users for development
  ({List<MatchModel> matches, Map<String, UserModel> users})
  _generateMockMatchesAndUsers(String currentUserId) {
    final Uuid uuid = Uuid();
    final List<MatchModel> mockMatches = [];
    final Map<String, UserModel> mockUsers = {};

    final List<String> names = [
      'Emma',
      'Olivia',
      'Ava',
      'Isabella',
      'Sophia',
      'Charlotte',
      'Mia',
      'Amelia',
    ];

    // Generate 5 mock matches
    for (int i = 0; i < 5; i++) {
      final String matchId = uuid.v4();
      final String otherUserId = uuid.v4();
      final DateTime matchTime = DateTime.now().subtract(
        Duration(days: i, hours: i * 2),
      );

      // Create a match
      final match = MatchModel(
        id: matchId,
        user1Id: currentUserId,
        user2Id: otherUserId,
        user1LikedUser2: true,
        user2LikedUser1: true,
        status: MatchStatus.matched,
        createdAt: matchTime,
        matchedAt: matchTime,
        messageCount: i < 2 ? 0 : i * 3, // First two matches have no messages
        lastMessageAt: i < 2 ? null : matchTime.add(const Duration(hours: 1)),
        lastMessagePreview:
            i < 2 ? null : 'Hey there! Looking forward to chatting with you!',
        hasUnreadMessages: i == 2, // One match has unread messages
      );

      mockMatches.add(match);

      // Create a matching user
      final user = UserModel(
        id: otherUserId,
        email: 'user$i@example.com',
        name: names[i % names.length],
        photoUrls: [],
        birthDate: DateTime(1990 + i, 1 + i, 1 + i * 2),
        gender: 'Female',
        interestedIn: 'Male',
        isProfileComplete: true,
        createdAt: DateTime.now().subtract(Duration(days: 30 + i)),
        lastActive: DateTime.now().subtract(Duration(hours: i * 4)),
        promptResponses: {
          'I value most in a relationship':
              'Trust, communication, and shared values.',
          'My favorite family tradition':
              'Sunday dinners with the whole family.',
        },
        matchingPreferences: {},
        hometown: 'Nashville, TN',
        faithTradition: 'Christian',
      );

      mockUsers[otherUserId] = user;
    }

    return (matches: mockMatches, users: mockUsers);
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

      if (_devMode) {
        // Generate mock messages for this conversation
        await Future.delayed(
          const Duration(milliseconds: 600),
        ); // Simulate network delay
        _currentConversation = _generateMockMessages(matchId, currentUserId);
        _isLoading = false;
        notifyListeners();
      } else {
        // Mark messages as read when opening the conversation
        await _firebaseService.markMessagesAsRead(matchId, currentUserId);

        // Listen to messages for this match
        _firebaseService.getMessages(matchId).listen((messages) {
          _currentConversation = messages;
          notifyListeners();
        });
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate mock messages for development
  List<MessageModel> _generateMockMessages(
    String matchId,
    String currentUserId,
  ) {
    // Find the match to get the other user's ID
    final match = _matches.firstWhere((m) => m.id == matchId);
    final String otherUserId =
        match.user1Id == currentUserId ? match.user2Id : match.user1Id;

    // If this is one of the first two matches, return no messages
    if (match.messageCount == 0) {
      return [];
    }

    final Uuid uuid = Uuid();
    final List<MessageModel> messages = [];

    // Sample messages from the other user
    final List<String> otherUserMessages = [
      'Hi there! I noticed we have similar values. How are you?',
      'I really enjoy hiking and spending time outdoors. What about you?',
      'What church do you attend?',
      'Tell me more about your family traditions!',
      'Do you enjoy cooking? I love trying new recipes.',
    ];

    // Sample messages from the current user
    final List<String> currentUserMessages = [
      'Hey! I\'m doing well, thanks for asking!',
      'I love hiking too! I try to get out every weekend.',
      'I attend Grace Community Church. It\'s a big part of my life.',
      'Sunday dinners are a must in my family. We all get together.',
      'I\'m actually a pretty good cook! Italian food is my specialty.',
    ];

    // Generate message history
    final int messageCount =
        3 + (match.id.hashCode % 5); // Between 3-7 messages
    final DateTime baseTime = DateTime.now().subtract(const Duration(days: 1));

    for (int i = 0; i < messageCount; i++) {
      final bool isFromCurrentUser = i % 2 == 1; // Alternate messages
      final String senderId = isFromCurrentUser ? currentUserId : otherUserId;
      final String receiverId = isFromCurrentUser ? otherUserId : currentUserId;
      final String text =
          isFromCurrentUser
              ? currentUserMessages[i % currentUserMessages.length]
              : otherUserMessages[i % otherUserMessages.length];

      final message = MessageModel(
        id: uuid.v4(),
        matchId: matchId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        timestamp: baseTime.add(Duration(minutes: i * 15)),
        isRead:
            true, // All messages read except the last one if from other user
      );

      messages.add(message);
    }

    // If this match has unread messages, add an unread message
    if (match.hasUnreadMessages) {
      final message = MessageModel(
        id: uuid.v4(),
        matchId: matchId,
        senderId: otherUserId,
        receiverId: currentUserId,
        text:
            'Just wondering if you\'re free this weekend? Would love to meet for coffee!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      );

      messages.add(message);
    }

    return messages;
  }

  Future<void> sendMessage(String text) async {
    try {
      if (_currentMatchId == null) {
        throw Exception('No active conversation');
      }

      if (_devMode) {
        // Simulate sending a message in development mode
        final String mockUserId = 'current-user-id';
        final match = _matches.firstWhere((m) => m.id == _currentMatchId);
        final String receiverId =
            match.user1Id == mockUserId ? match.user2Id : match.user1Id;

        final Uuid uuid = Uuid();
        final newMessage = MessageModel(
          id: uuid.v4(),
          matchId: _currentMatchId!,
          senderId: mockUserId,
          receiverId: receiverId,
          text: text,
          timestamp: DateTime.now(),
          isRead: false,
        );

        _currentConversation = [..._currentConversation, newMessage];

        // Update match preview
        final matchIndex = _matches.indexWhere((m) => m.id == _currentMatchId);
        if (matchIndex >= 0) {
          final updatedMatch = _matches[matchIndex].copyWith(
            lastMessagePreview:
                text.length > 50 ? '${text.substring(0, 47)}...' : text,
            lastMessageAt: DateTime.now(),
            messageCount: _matches[matchIndex].messageCount + 1,
          );

          _matches[matchIndex] = updatedMatch;
        }

        notifyListeners();
      } else {
        if (_firebaseService.currentUser == null) {
          throw Exception('User not authenticated');
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
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  UserModel? getMatchedUser(MatchModel match) {
    if (_devMode) {
      // In development mode, look up the matched user directly
      final mockUserId = 'current-user-id';
      final String otherUserId =
          match.user1Id == mockUserId ? match.user2Id : match.user1Id;
      return _matchedUsers[otherUserId];
    } else {
      if (_firebaseService.currentUser == null) return null;

      final String currentUserId = _firebaseService.currentUser!.uid;
      final String otherUserId =
          match.user1Id == currentUserId ? match.user2Id : match.user1Id;

      return _matchedUsers[otherUserId];
    }
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}
