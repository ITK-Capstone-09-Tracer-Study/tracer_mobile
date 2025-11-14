/// Model untuk User sesuai dengan API
/// Endpoint: /{panel}/users
/// Sesuai dengan UserTransformer dari API
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // admin, tracer_team, major_team, head_of_unit
  final String unitType; // institutional, faculty, major (sesuai API Unit enum)
  final int? unitId; // ID of the unit (nullable sesuai API)
  final String nikNip; // NIK/NIP - required field
  final String phoneNumber; // Phone number - required field
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Field tambahan untuk display purposes (tidak dari API)
  final String? unitName; // Name for display purposes (not from API, for local use)
  final String? departmentName; // Untuk display major team
  final String? facultyName; // Untuk display major team atau faculty team

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.unitType,
    required this.nikNip,
    required this.phoneNumber,
    this.unitId,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    // Display fields
    this.unitName,
    this.departmentName,
    this.facultyName,
  });

  /// Copy with method untuk update data
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? unitType,
    int? unitId,
    String? nikNip,
    String? phoneNumber,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? unitName,
    String? departmentName,
    String? facultyName,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      unitType: unitType ?? this.unitType,
      unitId: unitId ?? this.unitId,
      nikNip: nikNip ?? this.nikNip,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unitName: unitName ?? this.unitName,
      departmentName: departmentName ?? this.departmentName,
      facultyName: facultyName ?? this.facultyName,
    );
  }

  /// From JSON (untuk API integration)
  /// Sesuai dengan UserTransformer dari API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      unitType: json['unit_type'] as String,
      unitId: json['unit_id'] as int?,
      nikNip: json['nik_nip'] as String,
      phoneNumber: json['phone_number'] as String,
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      // Display fields - tidak dari API langsung, bisa di-populate dari relasi
      unitName: null, // Akan di-set dari logic terpisah
      departmentName: null,
      facultyName: null,
    );
  }

  /// To JSON (untuk API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'unit_type': unitType,
      'unit_id': unitId,
      'nik_nip': nikNip,
      'phone_number': phoneNumber,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// To JSON untuk create/update request (hanya field yang diperlukan)
  /// Sesuai dengan CreateUserRequest dan UpdateUserRequest
  Map<String, dynamic> toRequestJson({String? password}) {
    final Map<String, dynamic> data = {
      'email': email,
      'role': role,
      'unit_type': unitType,
      'nik_nip': nikNip,
      'name': name,
      'phone_number': phoneNumber,
    };

    // unit_id hanya dikirim jika tidak null
    if (unitId != null) {
      data['unit_id'] = unitId;
    }

    // password opsional untuk update, required untuk create
    if (password != null) {
      data['password'] = password;
    }

    return data;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, unitType: $unitType, unitId: $unitId, nikNip: $nikNip)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
