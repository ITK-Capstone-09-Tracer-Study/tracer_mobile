class SurveyKindModel {
  final int id;
  final String name;
  final String? description;
  final String respondentRole; // 'alumni' or 'supervisor'
  final int order;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SurveyKindModel({
    required this.id,
    required this.name,
    this.description,
    required this.respondentRole,
    required this.order,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SurveyKindModel.fromJson(Map<String, dynamic> json) {
    return SurveyKindModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      respondentRole: json['respondent_role'] as String,
      order: json['order'] as int,
      isActive: json['is_active'] is bool 
          ? json['is_active'] as bool 
          : (json['is_active'] == 1),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'respondent_role': respondentRole,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// Get display name for respondent role
  String get respondentRoleDisplay {
    switch (respondentRole) {
      case 'alumni':
        return 'Alumni';
      case 'supervisor':
        return 'Supervisor';
      default:
        return respondentRole;
    }
  }
}
