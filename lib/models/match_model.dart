import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchStatus { pending, matched, rejected, expired }

class MatchModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final bool user1LikedUser2;
  final bool user2LikedUser1;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? matchedAt;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final bool hasUnreadMessages;
  final int messageCount;
  final Map<String, dynamic>? compatibilityMetrics;
  final bool isCurrentUserTurn;

  MatchModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1LikedUser2,
    required this.user2LikedUser1,
    required this.status,
    required this.createdAt,
    this.matchedAt,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.hasUnreadMessages = false,
    this.messageCount = 0,
    this.compatibilityMetrics,
    this.isCurrentUserTurn = false,
  });

  // Factory constructor to create a MatchModel from a Firebase document
  factory MatchModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MatchModel(
      id: doc.id,
      user1Id: data['user1Id'] ?? '',
      user2Id: data['user2Id'] ?? '',
      user1LikedUser2: data['user1LikedUser2'] ?? false,
      user2LikedUser1: data['user2LikedUser1'] ?? false,
      status: _matchStatusFromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      matchedAt:
          data['matchedAt'] != null
              ? (data['matchedAt'] as Timestamp).toDate()
              : null,
      lastMessageAt:
          data['lastMessageAt'] != null
              ? (data['lastMessageAt'] as Timestamp).toDate()
              : null,
      lastMessagePreview: data['lastMessagePreview'],
      hasUnreadMessages: data['hasUnreadMessages'] ?? false,
      messageCount: data['messageCount'] ?? 0,
      compatibilityMetrics: data['compatibilityMetrics'],
      isCurrentUserTurn: data['isCurrentUserTurn'] ?? false,
    );
  }

  // Convert a MatchModel to a map for storing in Firebase
  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'user1LikedUser2': user1LikedUser2,
      'user2LikedUser1': user2LikedUser1,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'matchedAt': matchedAt != null ? Timestamp.fromDate(matchedAt!) : null,
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastMessagePreview': lastMessagePreview,
      'hasUnreadMessages': hasUnreadMessages,
      'messageCount': messageCount,
      'compatibilityMetrics': compatibilityMetrics,
      'isCurrentUserTurn': isCurrentUserTurn,
    };
  }

  // Create a copy of the MatchModel with updated fields
  MatchModel copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    bool? user1LikedUser2,
    bool? user2LikedUser1,
    MatchStatus? status,
    DateTime? createdAt,
    DateTime? matchedAt,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
    bool? hasUnreadMessages,
    int? messageCount,
    Map<String, dynamic>? compatibilityMetrics,
    bool? isCurrentUserTurn,
  }) {
    return MatchModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      user1LikedUser2: user1LikedUser2 ?? this.user1LikedUser2,
      user2LikedUser1: user2LikedUser1 ?? this.user2LikedUser1,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      matchedAt: matchedAt ?? this.matchedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      messageCount: messageCount ?? this.messageCount,
      compatibilityMetrics: compatibilityMetrics ?? this.compatibilityMetrics,
      isCurrentUserTurn: isCurrentUserTurn ?? this.isCurrentUserTurn,
    );
  }

  // Helper method to convert a string to MatchStatus enum
  static MatchStatus _matchStatusFromString(String status) {
    switch (status) {
      case 'matched':
        return MatchStatus.matched;
      case 'rejected':
        return MatchStatus.rejected;
      case 'expired':
        return MatchStatus.expired;
      case 'pending':
      default:
        return MatchStatus.pending;
    }
  }

  // Helper method to check if this is a mutual match
  bool get isMatched => user1LikedUser2 && user2LikedUser1;
}
