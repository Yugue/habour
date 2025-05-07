import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String matchId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  // Factory constructor to create a MessageModel from a Firebase document
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      matchId: data['matchId'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      metadata: data['metadata'],
    );
  }

  // Convert a MessageModel to a map for storing in Firebase
  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  // Create a copy of the MessageModel with updated fields
  MessageModel copyWith({
    String? id,
    String? matchId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}
