class QuestionOptionModel {
  final String id;
  final String label;
  final String value;
  final String? condition; // 'next_section' or 'submit_form'
  final String? targetSectionId; // ID of section to jump to (if condition is next_section)
  final int order;

  QuestionOptionModel({
    required this.id,
    required this.label,
    required this.value,
    this.condition,
    this.targetSectionId,
    required this.order,
  });

  QuestionOptionModel copyWith({
    String? id,
    String? label,
    String? value,
    String? condition,
    String? targetSectionId,
    int? order,
  }) {
    return QuestionOptionModel(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
      condition: condition ?? this.condition,
      targetSectionId: targetSectionId ?? this.targetSectionId,
      order: order ?? this.order,
    );
  }

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'].toString(),
      label: json['label'] as String,
      value: json['value'] as String,
      condition: json['condition'] as String?,
      targetSectionId: json['target_section_id']?.toString(),
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'value': value,
      'condition': condition,
      'target_section_id': targetSectionId,
      'order': order,
    };
  }
}
