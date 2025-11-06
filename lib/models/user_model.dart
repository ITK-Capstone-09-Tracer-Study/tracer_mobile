class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? unitType; // institutional, faculty, major (lowercase sesuai API)
  final int? unitId; // ID of the unit (faculty_id or major_id) - integer sesuai API
  final String? unitName; // Name for display purposes (not from API, for local use)
  final String? nikNip; // Will be used in the future
  final String? phoneNumber; // Renamed from phone to match API
  final DateTime? emailVerifiedAt; // For future implementation
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.unitType,
    this.unitId,
    this.unitName,
    this.nikNip,
    this.phoneNumber,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  // Copy with method untuk update data
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? unitType,
    int? unitId,
    String? unitName,
    String? nikNip,
    String? phoneNumber,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      unitType: unitType ?? this.unitType,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      nikNip: nikNip ?? this.nikNip,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From JSON (untuk API integration)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(), // Convert int to String for internal use
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      unitType: json['unit_type'] as String?,
      unitId: json['unit_id'] as int?,
      unitName: json['unit_name'] as String?, // For local use, not from API
      nikNip: json['nik_nip'] as String?, // Will be used in future
      phoneNumber: json['phone_number'] as String?,
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // To JSON (untuk API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? id, // Convert back to int for API if possible
      'name': name,
      'email': email,
      'role': role,
      'unit_type': unitType,
      'unit_id': unitId,
      // unit_name is not sent to API, only for local display
      'nik_nip': nikNip, // Will be used in future
      'phone_number': phoneNumber,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
