/// نموذج بيانات للأوزان المرتبطة بكل خيار في السؤال
/// كل وزن يربط خياراً مع تخصص معين بقيمة وزن عددية
class QuestionWeightModel {
  final int? id;
  final int questionId;
  final int majorId;
  final int optionIndex; // 0, 1, 2, 3 للخيارات الأربعة
  final int weight; // قيمة الوزن (عادة 0, 1, 2)

  QuestionWeightModel({
    this.id,
    required this.questionId,
    required this.majorId,
    required this.optionIndex,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'majorId': majorId,
      'optionIndex': optionIndex,
      'weight': weight,
    };
  }

  factory QuestionWeightModel.fromMap(Map<String, dynamic> map) {
    return QuestionWeightModel(
      id: map['id'] as int?,
      questionId: map['questionId'] as int,
      majorId: map['majorId'] as int,
      optionIndex: map['optionIndex'] as int,
      weight: map['weight'] as int,
    );
  }

  QuestionWeightModel copyWith({
    int? id,
    int? questionId,
    int? majorId,
    int? optionIndex,
    int? weight,
  }) {
    return QuestionWeightModel(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      majorId: majorId ?? this.majorId,
      optionIndex: optionIndex ?? this.optionIndex,
      weight: weight ?? this.weight,
    );
  }
}



