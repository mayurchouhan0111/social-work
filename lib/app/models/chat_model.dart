import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  ChatModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatModel(
      id: documentId,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
