class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String unit;
  final String? nikNip;
  final String? photoUrl;
  final String? phone;
  final String? position;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.unit,
    this.nikNip,
    this.photoUrl,
    this.phone,
    this.position,
    this.createdAt,
    this.updatedAt,
  });

  // Copy with method untuk update data
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? unit,
    String? nikNip,
    String? photoUrl,
    String? phone,
    String? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      unit: unit ?? this.unit,
      nikNip: nikNip ?? this.nikNip,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      position: position ?? this.position,
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
      unit: json['unit'] as String,
      nikNip: json['nikNip'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phone: json['phone'] as String?,
      position: json['position'] as String?,
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
      'unit': unit,
      'nikNip': nikNip,
      'photoUrl': photoUrl,
      'phone': phone,
      'position': position,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
