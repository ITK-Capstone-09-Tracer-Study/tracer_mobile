class QuestionModel {
  final String id;
  final String title;
  final String questionType; // 'multiple_choice', 'checkbox', 'short_answer', 'paragraph', 'linear_scale'
  final List<String> options;
  final bool isRequired;
  final int? linearScaleMin;
  final int? linearScaleMax;
  final String? linearScaleLabelMin;
  final String? linearScaleLabelMax;
  final int order;

  QuestionModel({
    required this.id,
    required this.title,
    required this.questionType,
    this.options = const [],
    this.isRequired = false,
    this.linearScaleMin,
    this.linearScaleMax,
    this.linearScaleLabelMin,
    this.linearScaleLabelMax,
    required this.order,
  });

  QuestionModel copyWith({
    String? id,
    String? title,
    String? questionType,
    List<String>? options,
    bool? isRequired,
    int? linearScaleMin,
    int? linearScaleMax,
    String? linearScaleLabelMin,
    String? linearScaleLabelMax,
    int? order,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      questionType: questionType ?? this.questionType,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      linearScaleMin: linearScaleMin ?? this.linearScaleMin,
      linearScaleMax: linearScaleMax ?? this.linearScaleMax,
      linearScaleLabelMin: linearScaleLabelMin ?? this.linearScaleLabelMin,
      linearScaleLabelMax: linearScaleLabelMax ?? this.linearScaleLabelMax,
      order: order ?? this.order,
    );
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      questionType: json['question_type'] as String,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      isRequired: json['is_required'] as bool? ?? false,
      linearScaleMin: json['linear_scale_min'] as int?,
      linearScaleMax: json['linear_scale_max'] as int?,
      linearScaleLabelMin: json['linear_scale_label_min'] as String?,
      linearScaleLabelMax: json['linear_scale_label_max'] as String?,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'question_type': questionType,
      'options': options,
      'is_required': isRequired,
      'linear_scale_min': linearScaleMin,
      'linear_scale_max': linearScaleMax,
      'linear_scale_label_min': linearScaleLabelMin,
      'linear_scale_label_max': linearScaleLabelMax,
      'order': order,
    };
  }
}
