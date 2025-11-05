class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? unitType; // Institutional, Faculty, Major
  final String? unitId; // ID of the unit (faculty_id or major_id)
  final String? unitName; // Name for display purposes
  final String? nikNip;
  final String? photoUrl;
  final String? phone;
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
    this.photoUrl,
    this.phone,
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
    String? unitId,
    String? unitName,
    String? nikNip,
    String? photoUrl,
    String? phone,
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
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From JSON (untuk future API integration)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      unitType: json['unit_type'] as String?,
      unitId: json['unit_id'] as String?,
      unitName: json['unit_name'] as String?,
      nikNip: json['nikNip'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // To JSON (untuk future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'unit_type': unitType,
      'unit_id': unitId,
      'unit_name': unitName,
      'nikNip': nikNip,
      'photoUrl': photoUrl,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
