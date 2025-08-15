class CollegeModel {
  final String id;
  final String university;
  final String collegeName;
  final String type;
  final String state;
  final String district;
  final String city; // Added this field as it's used in the UI

  CollegeModel({
    required this.id,
    required this.university,
    required this.collegeName,
    required this.type,
    required this.state,
    required this.district,
    required this.city,
  });

  // Factory constructor for the API response format (List)
  factory CollegeModel.fromList(List<dynamic> data) {
    return CollegeModel(
      id: data[0]?.toString() ?? '',
      university: data[1]?.toString() ?? '',
      collegeName: data[2]?.toString() ?? '',
      type: data[3]?.toString() ?? '',
      state: data[4]?.toString() ?? '',
      district: data[5]?.toString() ?? '',
      city: data[5]?.toString() ?? '', // Using district as city for now
    );
  }

  // Factory constructor for JSON format (if needed)
  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    return CollegeModel(
      id: json['id']?.toString() ?? '',
      university: json['university']?.toString() ?? '',
      collegeName: json['college_name']?.toString() ?? json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      city: json['city']?.toString() ?? json['district']?.toString() ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university': university,
      'college_name': collegeName,
      'type': type,
      'state': state,
      'district': district,
      'city': city,
    };
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'university': university,
      'college_name': collegeName,
      'type': type,
      'state': state,
      'district': district,
      'city': city,
    };
  }

  // Create a copy with updated fields
  CollegeModel copyWith({
    String? id,
    String? university,
    String? collegeName,
    String? type,
    String? state,
    String? district,
    String? city,
  }) {
    return CollegeModel(
      id: id ?? this.id,
      university: university ?? this.university,
      collegeName: collegeName ?? this.collegeName,
      type: type ?? this.type,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
    );
  }

  @override
  String toString() {
    return 'CollegeModel(id: $id, university: $university, collegeName: $collegeName, type: $type, state: $state, district: $district, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CollegeModel &&
        other.id == id &&
        other.university == university &&
        other.collegeName == collegeName &&
        other.type == type &&
        other.state == state &&
        other.district == district &&
        other.city == city;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    university.hashCode ^
    collegeName.hashCode ^
    type.hashCode ^
    state.hashCode ^
    district.hashCode ^
    city.hashCode;
  }

  // Helper getter for display name
  String get displayName => collegeName;

  // Helper getter for location
  String get location => '$city, $state';

  // Helper getter for full location
  String get fullLocation => '$city, $district, $state';
}
