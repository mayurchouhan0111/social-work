import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final String reportedBy;
  final String status; // 'found' or 'lost'
  final DateTime createdAt;
  final String? mobileNumber;

  // Added new fields for student verification
  final String? collegeName;
  final String? enrollmentNumber;
  final String? identityCardImageUrl;

  // New fields for enhanced features
  final double? latitude;
  final double? longitude;
  final String? gpsLocation; // GPS coordinates as string
  final String? deviceInfo; // Optional: device information
  final Map? metadata; // Optional: additional metadata

  // New fields for moderation
  final String? moderationStatus;
  final bool? isConfirmedByAdmin;
  final DateTime? submittedAt;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.reportedBy,
    required this.status,
    required this.createdAt,
    this.mobileNumber,
    this.collegeName,
    this.enrollmentNumber,
    this.identityCardImageUrl,
    this.latitude,
    this.longitude,
    this.gpsLocation,
    this.deviceInfo,
    this.metadata,
    this.moderationStatus,
    this.isConfirmedByAdmin,
    this.submittedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'reportedBy': reportedBy,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'mobileNumber': mobileNumber,
      'collegeName': collegeName,
      'enrollmentNumber': enrollmentNumber,
      'identityCardImageUrl': identityCardImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'gpsLocation': gpsLocation,
      'deviceInfo': deviceInfo,
      'metadata': metadata,
      'moderationStatus': moderationStatus,
      'isConfirmedByAdmin': isConfirmedByAdmin,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  // Create from Map (from Firestore)
  factory ItemModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ItemModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'] ?? '',
      reportedBy: map['reportedBy'] ?? '',
      status: map['status'] ?? 'found',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      mobileNumber: map['mobileNumber'],
      collegeName: map['collegeName'],
      enrollmentNumber: map['enrollmentNumber'],
      identityCardImageUrl: map['identityCardImageUrl'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      gpsLocation: map['gpsLocation'],
      deviceInfo: map['deviceInfo'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      moderationStatus: map['moderationStatus'],
      isConfirmedByAdmin: map['isConfirmedByAdmin'],
      submittedAt: map['submittedAt'] is Timestamp
          ? (map['submittedAt'] as Timestamp).toDate()
          : map['submittedAt'] != null
              ? DateTime.parse(map['submittedAt'])
              : null,
    );
  }

  // Create a copy with updated fields
  ItemModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? location,
    String? reportedBy,
    String? status,
    DateTime? createdAt,
    String? mobileNumber,
    String? collegeName,
    String? enrollmentNumber,
    String? identityCardImageUrl,
    double? latitude,
    double? longitude,
    String? gpsLocation,
    String? deviceInfo,
    Map<String, dynamic>? metadata,
    String? moderationStatus,
    bool? isConfirmedByAdmin,
    DateTime? submittedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      reportedBy: reportedBy ?? this.reportedBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      collegeName: collegeName ?? this.collegeName,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      identityCardImageUrl: identityCardImageUrl ?? this.identityCardImageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsLocation: gpsLocation ?? this.gpsLocation,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      metadata: metadata ?? this.metadata,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      isConfirmedByAdmin: isConfirmedByAdmin ?? this.isConfirmedByAdmin,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, title: $title, status: $status, createdAt: $createdAt, moderationStatus: $moderationStatus)';
  }
}