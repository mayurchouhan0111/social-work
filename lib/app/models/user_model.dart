class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? mobileNumber;
  final String? enrollmentNumber;
  final String? identityCardImageUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.mobileNumber,
    this.enrollmentNumber,
    this.identityCardImageUrl,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'mobile_number': mobileNumber,
      'enrollment_number': enrollmentNumber,
      'identity_card_image_url': identityCardImageUrl,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create from Map (from Supabase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      mobileNumber: map['mobile_number'],
      enrollmentNumber: map['enrollment_number'],
      identityCardImageUrl: map['identity_card_image_url'],
      isVerified: map['is_verified'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? mobileNumber,
    String? enrollmentNumber,
    String? identityCardImageUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      identityCardImageUrl: identityCardImageUrl ?? this.identityCardImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, mobileNumber: $mobileNumber, enrollmentNumber: $enrollmentNumber, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.mobileNumber == mobileNumber &&
        other.enrollmentNumber == enrollmentNumber &&
        other.identityCardImageUrl == identityCardImageUrl &&
        other.isVerified == isVerified &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    email.hashCode ^
    name.hashCode ^
    mobileNumber.hashCode ^
    enrollmentNumber.hashCode ^
    identityCardImageUrl.hashCode ^
    isVerified.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode;
  }
}
