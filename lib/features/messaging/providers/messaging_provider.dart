import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/match_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase_service.dart';
import 'dart:math' as math;

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

        // Always use the provided userId parameter (don't hardcode a different ID)
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

    // Create consistent last messages (most recent) for users with conversations
    final Map<String, String> lastMessagesForUsers = {
      'Emma': 'Would you like to grab coffee sometime?',
      'Olivia': 'I enjoyed our conversation about faith.',
      'Ava': 'Thanks for sharing about your family traditions!',
      'Isabella': 'What church do you attend?',
      'Sophia': 'Do you enjoy cooking? I love trying new recipes.',
      'Charlotte': 'Looking forward to meeting you!',
      'Mia': 'I see you enjoy hiking too! Where is your favorite trail?',
      'Amelia': 'What are your thoughts on traditional family values?',
    };

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
      final String name = names[i % names.length];
      final DateTime matchTime = DateTime.now().subtract(
        Duration(days: i, hours: i * 2),
      );

      // Determine if it's the current user's turn to reply (default false)
      final bool isCurrentUserTurn =
          i == 3; // One conversation where it's your turn

      // Create message preview for conversations with messages
      String? messagePreview;
      if (i >= 2) {
        // Use the last message for the preview, not the first
        messagePreview = lastMessagesForUsers[name] ?? 'Hello!';
      }

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
        lastMessagePreview: messagePreview,
        hasUnreadMessages: i == 2, // One match has unread messages
        isCurrentUserTurn: isCurrentUserTurn, // Explicitly set who's turn it is
      );

      mockMatches.add(match);

      // Create a matching user
      final user = UserModel(
        id: otherUserId,
        email: 'user$i@example.com',
        name: name,
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

        // Find the match or create a placeholder for new matches
        try {
          // Try to find the match in existing matches
          int matchIndex = -1;
          if (_matches.isNotEmpty) {
            matchIndex = _matches.indexWhere((m) => m.id == matchId);
          }

          if (matchIndex >= 0 && matchIndex < _matches.length) {
            // Mark messages as read in the match
            final updatedMatch = _matches[matchIndex].copyWith(
              hasUnreadMessages: false,
              // Only change turn if current user is receiving messages
              isCurrentUserTurn: _matches[matchIndex].isCurrentUserTurn,
            );
            _matches[matchIndex] = updatedMatch;
          } else if (_matches.isNotEmpty) {
            // If not found but we have some matches, create a placeholder entry
            print(
              'Match not found in _matches, creating placeholder for: $matchId',
            );
          }
        } catch (e) {
          print('Error finding match: $e');
        }

        // Generate mock messages regardless
        try {
          _currentConversation = _generateMockMessages(matchId, currentUserId);
        } catch (e) {
          print('Error generating mock messages: $e');
          _currentConversation = [];
        }

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
    // Try to find the match
    MatchModel? match;
    String otherUserId = 'unknown-user';
    bool hasUnreadMessages = false;
    int messageCount = 0;
    bool isCurrentUserTurn = false; // Default to false if not found
    String? matchPreview;

    try {
      match = _matches.firstWhere((m) => m.id == matchId);
      otherUserId = match.user2Id; // In dev mode, current user is always user1
      hasUnreadMessages = match.hasUnreadMessages;
      messageCount = match.messageCount;
      isCurrentUserTurn = match.isCurrentUserTurn;
      matchPreview = match.lastMessagePreview;

      // Get the matched user's name (currently unused but may be needed for future features)
      // final matchedUser = _matchedUsers[otherUserId];
      // if (matchedUser != null) {
      //   otherUserName = matchedUser.name;
      // }
    } catch (e) {
      // If match not found, create a temporary ID and return empty messages
      // This happens when navigating directly to a conversation
      print('Match not found for ID: $matchId. Using empty messages.');
      return [];
    }

    // If this is one of the matches with no messages, return empty list
    if (messageCount == 0) {
      return [];
    }

    final Uuid uuid = Uuid();
    final List<MessageModel> messages = [];

    // Sample messages from the other user - ensure first message matches preview
    final List<String> initialMessages = [
      'Hi there! I noticed we have similar values. How are you?',
      'I really enjoy hiking and spending time outdoors. What about you?',
      'What church do you attend?',
      'Tell me more about your family traditions!',
    ];

    // Sample messages from the current user
    final List<String> currentUserMessages = [
      'Hey! I\'m doing well, thanks for asking!',
      'I love hiking too! I try to get out every weekend.',
      'I attend Grace Community Church. It\'s a big part of my life.',
      'Sunday dinners are a must in my family. We all get together.',
    ];

    // For the last message, we'll use the preview that's displayed in the matches list
    final String lastMessage =
        matchPreview ?? 'Do you enjoy cooking? I love trying new recipes.';

    // Calculate how many message pairs we need
    final int historyMessageCount = math.max(0, messageCount - 1);
    final int messagePairs = math.min(
      (historyMessageCount / 2).ceil(),
      math.min(initialMessages.length, currentUserMessages.length),
    );

    // Generate conversation history
    final DateTime baseTime = DateTime.now().subtract(const Duration(days: 1));

    // First message is always from the other user
    for (int i = 0; i < messagePairs; i++) {
      // Other user's message
      if (i < messagePairs) {
        final String text = initialMessages[i % initialMessages.length];
        final message = MessageModel(
          id: uuid.v4(),
          matchId: matchId,
          senderId: otherUserId,
          receiverId: currentUserId,
          text: text,
          timestamp: baseTime.add(Duration(minutes: i * 30)),
          isRead: true,
        );
        messages.add(message);
      }

      // Current user's message
      if (i < messagePairs) {
        final String text = currentUserMessages[i % currentUserMessages.length];
        final message = MessageModel(
          id: uuid.v4(),
          matchId: matchId,
          senderId: currentUserId,
          receiverId: otherUserId,
          text: text,
          timestamp: baseTime.add(Duration(minutes: i * 30 + 15)),
          isRead: true,
        );
        messages.add(message);
      }
    }

    // Now add the final message that matches the preview in the matches list
    if (messageCount > 0) {
      // If it's the user's turn, the last message was from the other person
      final String lastSenderId =
          isCurrentUserTurn ? otherUserId : currentUserId;
      final String lastReceiverId =
          isCurrentUserTurn ? currentUserId : otherUserId;

      final message = MessageModel(
        id: uuid.v4(),
        matchId: matchId,
        senderId: lastSenderId,
        receiverId: lastReceiverId,
        text: lastMessage,
        timestamp:
            match.lastMessageAt ??
            DateTime.now().subtract(const Duration(hours: 2)),
        isRead: !hasUnreadMessages,
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
        MatchModel? match;
        int matchIndex = -1;
        String currentUserId = '';

        try {
          matchIndex = _matches.indexWhere((m) => m.id == _currentMatchId);
          if (matchIndex >= 0) {
            match = _matches[matchIndex];
            // Determine the current user ID from the match - always use user1Id in dev mode
            currentUserId = match.user1Id;
          } else {
            // If match not found, must provide a fallback ID
            currentUserId = 'dev-user-id';
          }
        } catch (e) {
          print('Error finding match: $e');
          currentUserId = 'dev-user-id';
        }

        // Determine the receiver ID
        String receiverId;
        if (match != null) {
          receiverId =
              match.user2Id; // In dev mode, current user is always user1
        } else {
          // Create a temporary receiverId if no match found
          receiverId = 'temp-receiver-$_currentMatchId';
        }

        final Uuid uuid = Uuid();
        final DateTime messageTime = DateTime.now();

        // Create the new message
        try {
          final newMessage = MessageModel(
            id: uuid.v4(),
            matchId: _currentMatchId!,
            senderId: currentUserId,
            receiverId: receiverId,
            text: text,
            timestamp: messageTime,
            isRead: false,
          );

          // Add the new message to the conversation
          _currentConversation = [..._currentConversation, newMessage];

          // Update match preview and metadata
          if (matchIndex >= 0 && matchIndex < _matches.length) {
            // Get the existing match count
            int existingCount = _matches[matchIndex].messageCount;

            final updatedMatch = _matches[matchIndex].copyWith(
              lastMessagePreview:
                  text.length > 50 ? '${text.substring(0, 47)}...' : text,
              lastMessageAt: messageTime,
              messageCount: existingCount + 1,
              isCurrentUserTurn:
                  false, // After sending a message, it's the other person's turn
              hasUnreadMessages: false, // Our own message can't be unread
            );

            _matches[matchIndex] = updatedMatch;
          }
        } catch (e) {
          throw Exception('Error creating message: $e');
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
      // We should use the user1Id as the current user ID (not a hardcoded ID)
      final String currentUserId = match.user1Id;
      final String otherUserId =
          match.user1Id == currentUserId ? match.user2Id : match.user1Id;
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
