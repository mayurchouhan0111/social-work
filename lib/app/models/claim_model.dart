import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimModel {
  final String id;
  final String itemId;
  final String claimerId;
  final String posterId;
  final List<String> answers;
  final String status;
  final DateTime createdAt;

  ClaimModel({
    required this.id,
    required this.itemId,
    required this.claimerId,
    required this.posterId,
    required this.answers,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'claimerId': claimerId,
      'posterId': posterId,
      'answers': answers,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClaimModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ClaimModel(
      id: documentId,
      itemId: map['itemId'] ?? '',
      claimerId: map['claimerId'] ?? '',
      posterId: map['posterId'] ?? '',
      answers: List<String>.from(map['answers'] ?? []),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
